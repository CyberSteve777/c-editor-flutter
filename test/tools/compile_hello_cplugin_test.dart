import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:c_editor/plugin_api/eval/c_editor_plugin_eval_plugin.dart';

/// Compiles the hello sample plugin and writes `build/hello.cplugin`.
///
/// Run:
///   flutter test test/tools/compile_hello_cplugin_test.dart
const _source = r'''
import 'package:flutter/material.dart';
import 'package:c_editor/plugin_api.dart';

void initialize(CPluginHost host) {
  host.registerScreen('hello', 'Hello Plugin', (context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello Plugin'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            editorWarningBanner(
              title: 'Plugin loaded',
              message: 'This screen was registered by a .cplugin via flutter_eval.',
            ),
            SizedBox(height: 16.0),
            Text('Plugin id: ' + host.pluginId),
            SizedBox(height: 16.0),
            hostAssetImage(
              assetPath: 'images/round_icons/Stage_Modern.png',
              width: 64.0,
              height: 64.0,
            ),
            SizedBox(height: 16.0),
            pvzAddButton(
              onPressed: () {},
              label: 'Host PvzAddButton',
            ),
          ],
        ),
      ),
    );
  });
}
''';

const _manifest = '''
{
  "format": "cplugin",
  "formatVersion": 1,
  "id": "com.example.hello",
  "name": "Hello Plugin",
  "version": "1.0.0",
  "author": "C-Editor",
  "description": "Sample plugin that registers a Hello screen",
  "minEditorVersion": "0.1.0",
  "entry": {
    "library": "package:hello_plugin/main.dart",
    "function": "initialize"
  }
}
''';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('compile hello.cplugin', () {
    final compiler = Compiler();
    compiler.addPlugin(flutterEvalPlugin);
    compiler.addPlugin(const CEditorPluginEvalPlugin());

    final program = compiler.compile({
      'hello_plugin': {'main.dart': _source},
    });
    final evc = program.write();
    expect(evc, isNotEmpty);

    final outDir = Directory('build/hello_cplugin');
    if (outDir.existsSync()) {
      outDir.deleteSync(recursive: true);
    }
    outDir.createSync(recursive: true);

    File(p.join(outDir.path, 'plugin.evc')).writeAsBytesSync(evc);
    File(p.join(outDir.path, 'manifest.json'))
        .writeAsStringSync(_manifest.trim());

    final archive = Archive();
    final manifestBytes = utf8.encode(_manifest.trim());
    archive.addFile(
      ArchiveFile('manifest.json', manifestBytes.length, manifestBytes),
    );
    archive.addFile(ArchiveFile('plugin.evc', evc.length, evc));

    final encoded = ZipEncoder().encode(archive);
    final outFile = File('build/hello.cplugin');
    outFile.parent.createSync(recursive: true);
    outFile.writeAsBytesSync(encoded);

    expect(outFile.existsSync(), isTrue);
    // ignore: avoid_print
    print('Wrote ${outFile.path} (${encoded.length} bytes)');
  });
}
