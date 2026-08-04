import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:c_editor/plugins/c_plugin_manifest.dart';

/// Result of successfully unpacking and validating a `.cplugin` archive.
class CPluginPackage {
  const CPluginPackage({
    required this.manifest,
    required this.evcBytes,
    required this.assets,
    required this.rawZipBytes,
  });

  final CPluginManifest manifest;
  final Uint8List evcBytes;

  /// Paths relative to `assets/` (forward slashes) → file bytes.
  final Map<String, Uint8List> assets;

  /// Original archive bytes (for storage / reinstall).
  final Uint8List rawZipBytes;
}

/// Thrown when a file is not a valid `.cplugin`.
class CPluginValidationException implements Exception {
  CPluginValidationException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Validates ZIP bytes as a `.cplugin` package.
class CPluginValidator {
  const CPluginValidator();

  /// Unzips [bytes], checks manifest + EVC presence, returns a package.
  ///
  /// Does not execute plugin code; bytecode loadability is checked by the
  /// [PluginManager] when enabling.
  CPluginPackage validate(Uint8List bytes) {
    if (bytes.isEmpty) {
      throw CPluginValidationException('Plugin file is empty');
    }

    Archive archive;
    try {
      archive = ZipDecoder().decodeBytes(bytes, verify: true);
    } catch (e) {
      throw CPluginValidationException('Not a valid ZIP/.cplugin archive: $e');
    }

    final files = <String, ArchiveFile>{};
    for (final file in archive) {
      if (!file.isFile) continue;
      final name = file.name.replaceAll('\\', '/');
      // Strip leading "./" and optional single top-level folder is NOT done —
      // paths must be rooted at archive root per the format.
      files[name] = file;
    }

    final manifestFile = files['manifest.json'];
    if (manifestFile == null) {
      throw CPluginValidationException('Missing manifest.json');
    }

    CPluginManifest manifest;
    try {
      final manifestText = utf8.decode(manifestFile.content);
      manifest = CPluginManifest.fromJsonString(manifestText);
    } on FormatException catch (e) {
      throw CPluginValidationException('Invalid manifest.json: ${e.message}');
    } catch (e) {
      throw CPluginValidationException('Invalid manifest.json: $e');
    }

    if (!_isSafePluginId(manifest.id)) {
      throw CPluginValidationException(
        'Invalid plugin id "${manifest.id}" (use letters, digits, ., _, -)',
      );
    }

    final evcFile = files['plugin.evc'];
    if (evcFile == null) {
      throw CPluginValidationException('Missing plugin.evc');
    }
    final evcBytes = Uint8List.fromList(evcFile.content);
    if (evcBytes.isEmpty) {
      throw CPluginValidationException('plugin.evc is empty');
    }

    final assets = <String, Uint8List>{};
    const prefix = 'assets/';
    for (final entry in files.entries) {
      if (!entry.key.startsWith(prefix)) continue;
      final relative = entry.key.substring(prefix.length);
      if (relative.isEmpty || relative.endsWith('/')) continue;
      if (relative.contains('..')) {
        throw CPluginValidationException(
          'Unsafe asset path in plugin: ${entry.key}',
        );
      }
      assets[relative] = Uint8List.fromList(entry.value.content);
    }

    return CPluginPackage(
      manifest: manifest,
      evcBytes: evcBytes,
      assets: assets,
      rawZipBytes: bytes,
    );
  }

  static bool _isSafePluginId(String id) {
    return RegExp(r'^[a-zA-Z0-9][a-zA-Z0-9._-]*$').hasMatch(id);
  }
}
