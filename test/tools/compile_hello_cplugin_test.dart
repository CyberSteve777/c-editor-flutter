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

/// Compiles [examples/hello_cplugin] to EVC and writes `build/hello.cplugin`.
///
/// Run:
///   flutter test test/tools/compile_hello_cplugin_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('compile hello.cplugin from Flutter package source', () {
    final pluginRoot = Directory('examples/hello_cplugin');
    expect(pluginRoot.existsSync(), isTrue);

    final sourceFile = File(p.join(pluginRoot.path, 'lib', 'main.dart'));
    final manifestFile = File(p.join(pluginRoot.path, 'manifest.json'));
    expect(sourceFile.existsSync(), isTrue);
    expect(manifestFile.existsSync(), isTrue);

    final source = sourceFile.readAsStringSync();
    final manifestText = manifestFile.readAsStringSync().trim();
    final manifest = CPluginManifest.fromJson(
      jsonDecode(manifestText) as Map<String, dynamic>,
    );
    final library = manifest.entryLibrary;
    final packageName =
        library.replaceFirst('package:', '').split('/').first;
    final fileName = library.split('/').last;

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
        pluginId: 'com.example.hello',
        registry: screenRegistry,
      ),
      returnsNormally,
    );
    expect(screenRegistry.screens, isNotEmpty);
    expect(screenRegistry.uiElements, isNotEmpty);

    final outDir = Directory('build/hello_cplugin');
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
    final outFile = File('build/hello.cplugin');
    outFile.parent.createSync(recursive: true);
    outFile.writeAsBytesSync(encoded);

    expect(outFile.existsSync(), isTrue);
    // ignore: avoid_print
    print('Wrote ${outFile.absolute.path} (${encoded.length} bytes)');
  });
}
