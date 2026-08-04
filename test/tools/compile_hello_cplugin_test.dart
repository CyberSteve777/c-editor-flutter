import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:c_editor/plugins/plugin_runtime.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';
import 'package:c_editor/plugins/plugin_source_compiler.dart';

/// Compiles [plugin_example/hello_cplugin] to EVC and writes `build/hello.cplugin`.
///
/// Run:
///   flutter test test/tools/compile_hello_cplugin_test.dart
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('compile hello.cplugin from Flutter package source', () {
    final pluginRoot = Directory('plugin_example/hello_cplugin');
    expect(pluginRoot.existsSync(), isTrue);

    final package = compilePluginDirectory(pluginRoot.path);
    expect(package.evcBytes, isNotEmpty);
    expect(package.rawZipBytes, isNotEmpty);

    final screenRegistry = PluginScreenRegistry();
    expect(
      () => executePluginEntrypoint(
        evcBytes: package.evcBytes,
        manifest: package.manifest,
        pluginId: 'com.example.hello',
        registry: screenRegistry,
        assets: package.assets,
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

    File(p.join(outDir.path, 'plugin.evc')).writeAsBytesSync(package.evcBytes);
    File(p.join(outDir.path, 'manifest.json')).writeAsStringSync(
      File(p.join(pluginRoot.path, 'manifest.json')).readAsStringSync().trim(),
    );
    for (final entry in package.assets.entries) {
      final out = File(p.join(outDir.path, 'assets', entry.key));
      out.parent.createSync(recursive: true);
      out.writeAsBytesSync(entry.value);
    }

    final outFile = File('build/hello.cplugin');
    outFile.parent.createSync(recursive: true);
    outFile.writeAsBytesSync(package.rawZipBytes);

    expect(outFile.existsSync(), isTrue);
    // ignore: avoid_print
    print(
      'Wrote ${outFile.absolute.path} (${package.rawZipBytes.length} bytes)',
    );
  });
}
