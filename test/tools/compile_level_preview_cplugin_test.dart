import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:c_editor/plugin_api/eval/c_editor_plugin_eval_plugin.dart';
import 'package:c_editor/plugins/c_plugin_manifest.dart';
import 'package:c_editor/plugins/plugin_runtime.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';

/// Compiles eval-safe Level Preview sources to EVC and writes
/// `build/level_preview.cplugin`.
///
/// In-process bundled load uses `lib/main.dart` + `lib/src/registration.dart`.
/// This test packs the thin `eval_src/main.dart` entry for external / artifact
/// use.
///
/// Note: installing a package with the reserved bundled id
/// `team.international2c.level_preview` is rejected by the host — the artifact
/// is for build verification and future packaging, not overlay install.
///
/// Run:
///   flutter test test/tools/compile_level_preview_cplugin_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('compile level_preview.cplugin from eval_src', () {
    final pluginRoot = Directory(
      'lib/bundled_plugins/level_preview_cplugin',
    );
    expect(pluginRoot.existsSync(), isTrue);

    final sourceFile = File(p.join(pluginRoot.path, 'eval_src', 'main.dart'));
    expect(sourceFile.existsSync(), isTrue);

    const packageName = 'level_preview_cplugin';
    const fileName = 'main.dart';
    const library = 'package:level_preview_cplugin/main.dart';
    const pluginId = 'team.international2c.level_preview';

    final source = sourceFile.readAsStringSync();

    final manifestMap = <String, dynamic>{
      'format': 'cplugin',
      'formatVersion': 1,
      'id': pluginId,
      'version': '1.0.0',
      'authors': ['C-Editor'],
      'minEditorVersion': '0.1.0',
      'entry': {
        'library': library,
        'function': 'initialize',
      },
    };
    final manifestText =
        const JsonEncoder.withIndent('  ').convert(manifestMap);
    final manifest = CPluginManifest.fromJson(manifestMap);

    final compiler = Compiler();
    compiler.addPlugin(flutterEvalPlugin);
    compiler.addPlugin(const CEditorPluginEvalPlugin());
    // dart_eval defaults to only `/main.dart` as an entrypoint; without this,
    // initialize() is dead-code-eliminated and Runtime.executeLib fails.
    compiler.entrypoints
      ..clear()
      ..add('/$fileName')
      ..add(library);

    final program = compiler.compile({
      packageName: {fileName: source},
    });
    final evc = Uint8List.fromList(program.write());
    expect(evc, isNotEmpty);

    final screenRegistry = PluginScreenRegistry();
    expect(
      () => executePluginEntrypoint(
        evcBytes: evc,
        manifest: manifest,
        pluginId: pluginId,
        registry: screenRegistry,
      ),
      returnsNormally,
    );
    expect(screenRegistry.editorActions, isNotEmpty);
    expect(screenRegistry.levelFileActions, isNotEmpty);

    final outDir = Directory('build/level_preview_cplugin');
    if (outDir.existsSync()) {
      outDir.deleteSync(recursive: true);
    }
    outDir.createSync(recursive: true);

    File(p.join(outDir.path, 'plugin.evc')).writeAsBytesSync(evc);
    File(p.join(outDir.path, 'manifest.json')).writeAsStringSync(manifestText);

    final archive = Archive();
    final manifestBytes = utf8.encode(manifestText);
    archive.addFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );
    archive.addFile(ArchiveFile('plugin.evc', evc.length, evc));

    final assetsDir = Directory(p.join(pluginRoot.path, 'assets'));
    if (assetsDir.existsSync()) {
      for (final entity in assetsDir.listSync(recursive: true)) {
        if (entity is! File) continue;
        final rel = p
            .relative(entity.path, from: assetsDir.path)
            .replaceAll('\\', '/');
        final bytes = entity.readAsBytesSync();
        archive.addFile(ArchiveFile('assets/$rel', bytes.length, bytes));
      }
    }

    final encoded = ZipEncoder().encode(archive);
    final outFile = File('build/level_preview.cplugin');
    outFile.parent.createSync(recursive: true);
    outFile.writeAsBytesSync(encoded);

    expect(outFile.existsSync(), isTrue);
    // ignore: avoid_print
    print('Wrote ${outFile.absolute.path} (${encoded.length} bytes)');
  });
}
