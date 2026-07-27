import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:path/path.dart' as p;
import 'package:c_editor/plugin_api/eval/c_editor_plugin_eval_plugin.dart';
import 'package:c_editor/plugins/c_plugin_manifest.dart';
import 'package:c_editor/plugins/c_plugin_validator.dart';

/// Compiles a plugin package directory (same layout as `plugin_example/hello_cplugin`)
/// into a [CPluginPackage] ready to install into C-Editor.
///
/// Expected layout:
/// ```
/// <plugin_dir>/
///   manifest.json
///   lib/**/*.dart
///   assets/**           (optional)
/// ```
CPluginPackage compilePluginDirectory(String pluginDirPath) {
  final root = Directory(pluginDirPath);
  if (!root.existsSync()) {
    throw CPluginValidationException('Plugin directory not found: $pluginDirPath');
  }

  final manifestFile = File(p.join(root.path, 'manifest.json'));
  if (!manifestFile.existsSync()) {
    throw CPluginValidationException('Missing manifest.json in $pluginDirPath');
  }

  final manifestText = manifestFile.readAsStringSync().trim();
  final CPluginManifest manifest;
  try {
    manifest = CPluginManifest.fromJson(
      jsonDecode(manifestText) as Map<String, dynamic>,
    );
  } on FormatException catch (e) {
    throw CPluginValidationException('Invalid manifest.json: ${e.message}');
  }

  final library = manifest.entryLibrary;
  if (!library.startsWith('package:')) {
    throw CPluginValidationException(
      'manifest entry.library must be a package: URI (got "$library")',
    );
  }
  final packageName = library.replaceFirst('package:', '').split('/').first;
  final entryRelative = library.substring('package:$packageName/'.length);

  final libDir = Directory(p.join(root.path, 'lib'));
  if (!libDir.existsSync()) {
    throw CPluginValidationException('Missing lib/ in $pluginDirPath');
  }

  final sources = <String, String>{};
  for (final entity in libDir.listSync(recursive: true)) {
    if (entity is! File) continue;
    if (!entity.path.toLowerCase().endsWith('.dart')) continue;
    final rel = p
        .relative(entity.path, from: libDir.path)
        .replaceAll('\\', '/');
    sources[rel] = entity.readAsStringSync();
  }
  if (sources.isEmpty) {
    throw CPluginValidationException('No .dart sources under lib/');
  }
  if (!sources.containsKey(entryRelative)) {
    throw CPluginValidationException(
      'Entry source missing: lib/$entryRelative '
      '(from manifest entry.library=$library)',
    );
  }

  final compiler = Compiler();
  compiler.addPlugin(flutterEvalPlugin);
  compiler.addPlugin(const CEditorPluginEvalPlugin());
  compiler.entrypoints
    ..clear()
    ..add('/${p.basename(entryRelative)}')
    ..add(library)
    ..add('/$entryRelative');

  final Program program;
  try {
    program = compiler.compile({packageName: sources});
  } catch (e) {
    throw CPluginValidationException('Failed to compile plugin sources: $e');
  }

  final evc = Uint8List.fromList(program.write());
  if (evc.isEmpty) {
    throw CPluginValidationException('Compiler produced empty plugin.evc');
  }

  final assets = <String, Uint8List>{};
  final assetsDir = Directory(p.join(root.path, 'assets'));
  if (assetsDir.existsSync()) {
    for (final entity in assetsDir.listSync(recursive: true)) {
      if (entity is! File) continue;
      final rel = p
          .relative(entity.path, from: assetsDir.path)
          .replaceAll('\\', '/');
      if (rel.isEmpty) continue;
      assets[rel] = entity.readAsBytesSync();
    }
  }

  final zipBytes = packCPluginZip(
    manifestText: manifestText,
    evcBytes: evc,
    assets: assets,
  );

  return CPluginPackage(
    manifest: manifest,
    evcBytes: evc,
    assets: assets,
    rawZipBytes: zipBytes,
  );
}

/// Builds a `.cplugin` ZIP from already-compiled parts.
Uint8List packCPluginZip({
  required String manifestText,
  required Uint8List evcBytes,
  Map<String, Uint8List> assets = const {},
}) {
  final archive = Archive();
  final manifestBytes = utf8.encode(manifestText);
  archive.addFile(
    ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
  );
  archive.addFile(ArchiveFile('plugin.evc', evcBytes.length, evcBytes));
  for (final entry in assets.entries) {
    archive.addFile(
      ArchiveFile('assets/${entry.key}', entry.value.length, entry.value),
    );
  }
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

/// Optional absolute/relative path from `--dart-define=CPLUGIN_DEBUG_PATH=...`.
const kCpluginDebugPathDefine = String.fromEnvironment('CPLUGIN_DEBUG_PATH');
