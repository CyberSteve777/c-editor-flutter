import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;

import 'package:c_editor/plugins/plugin_constants.dart';

import 'export_engine_base.dart';
import 'export_inject.dart';
import 'export_rsb_isolate.dart';

ExportEngine createExportEngine() => ExportEngineNative();

bool _isUnderPlugins(String entityPath) {
  return p.split(p.normalize(entityPath)).any(isReservedLibraryFolderName);
}

/// `dart:io`-backed export engine. Heavy pack/unpack steps run in `compute`
/// isolates (which default to the native `IoSenIo` backend).
class ExportEngineNative implements ExportEngine {
  bool _cancelled = false;

  @override
  void cancelExport() => _cancelled = true;

  /// `compute` isolates cannot be killed mid-run, so cancellation takes effect
  /// between pipeline steps: the current step finishes, then we abort before the
  /// next one (and before the archive is overwritten).
  void _throwIfCancelled() {
    if (_cancelled) throw const ExportCancelledException();
  }

  @override
  Future<bool> hasEligibleArchive(String rootPath) async {
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) return false;
    await for (final entity in rootDir.list(recursive: true)) {
      if (_isUnderPlugins(entity.path)) continue;
      if (entity is File && entity.path.endsWith('.rsb.smf')) {
        return true;
      }
    }
    return false;
  }

  @override
  Future<List<ExportEntry>> listDirectory(
    String path, {
    required bool archiveStep,
  }) async {
    final dir = Directory(path);
    final items = await dir.list().toList();

    final filtered = items.where((item) {
      if (item is Directory) {
        return !isReservedLibraryFolderName(p.basename(item.path));
      }
      if (item is File) {
        final fileName = p.basename(item.path).toLowerCase();
        if (archiveStep) {
          return fileName.endsWith('.rsb.smf');
        }
        return fileName.endsWith('.json') || fileName.endsWith('.rton');
      }
      return false;
    }).toList();

    filtered.sort((a, b) {
      if (a is Directory && b is File) return -1;
      if (a is File && b is Directory) return 1;
      return p
          .basename(a.path)
          .toLowerCase()
          .compareTo(p.basename(b.path).toLowerCase());
    });

    return filtered
        .map((e) => ExportEntry(
              name: p.basename(e.path),
              path: e.path,
              isDirectory: e is Directory,
            ))
        .toList();
  }

  @override
  String parentDirectory(String path) => p.dirname(path);

  @override
  Future<void> performExport({
    required String archivePath,
    required Map<String, Uint8List> rtonLevels,
    required void Function(double progress, ExportPhase phase) onProgress,
  }) async {
    _cancelled = false;
    final tempDir = await Directory.systemTemp.createTemp('c_editor_export_');
    final tempPath = tempDir.path;

    try {
      _throwIfCancelled();
      onProgress(0.2, ExportPhase.unpackingRsb);
      final tempRsbPath = p.join(tempPath, 'temp.rsb');
      await File(archivePath).copy(tempRsbPath);

      final rsbUnpackDir = p.join(tempPath, 'rsb.bundle');
      await compute(exportIsolateUnpackRsb, (tempRsbPath, rsbUnpackDir));
      _throwIfCancelled();

      onProgress(0.4, ExportPhase.unpackingRsg);
      final packetDir = Directory(p.join(rsbUnpackDir, 'packet'));
      if (!await packetDir.exists()) {
        final rsbFiles = Directory(rsbUnpackDir)
            .listSync(recursive: true)
            .map((e) => p.relative(e.path, from: rsbUnpackDir))
            .take(10)
            .join(', ');
        throw Exception(
          'Packet directory not found in RSB bundle. Contents: $rsbFiles',
        );
      }

      String? packagesRsgPath;
      await for (final entity in packetDir.list()) {
        if (entity is File &&
            p.basename(entity.path).toLowerCase() == 'packages.rsg') {
          packagesRsgPath = entity.path;
          break;
        }
      }
      if (packagesRsgPath == null) {
        throw Exception('Packages.rsg not found in archive.');
      }

      final rsgUnpackDir = p.join(tempPath, 'Packages.packet');
      final packagesRsgPathFinal = packagesRsgPath;
      await compute(exportIsolateUnpackRsg, (packagesRsgPathFinal, rsgUnpackDir));
      _throwIfCancelled();

      onProgress(0.6, ExportPhase.injecting);
      injectRtonLevelsIntoPacket(rsgUnpackDir, rtonLevels);
      _throwIfCancelled();

      onProgress(0.7, ExportPhase.repackingRsg);
      await compute(exportIsolatePackRsg, (rsgUnpackDir, packagesRsgPathFinal));
      _throwIfCancelled();

      onProgress(0.8, ExportPhase.repackingRsb);
      await compute(exportIsolatePackRsb, (rsbUnpackDir, tempRsbPath));
      _throwIfCancelled();

      onProgress(0.9, ExportPhase.finalizing);
      await File(tempRsbPath).copy(archivePath);
    } finally {
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    }
  }
}
