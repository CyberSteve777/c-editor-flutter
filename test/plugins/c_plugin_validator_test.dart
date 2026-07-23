import 'dart:convert';
import 'dart:typed_data';

import 'package:archive/archive.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/plugins/c_plugin_validator.dart';

Uint8List _zip(Map<String, List<int>> files) {
  final archive = Archive();
  for (final e in files.entries) {
    archive.addFile(ArchiveFile(e.key, e.value.length, e.value));
  }
  return Uint8List.fromList(ZipEncoder().encode(archive));
}

void main() {
  const validator = CPluginValidator();

  test('rejects empty bytes', () {
    expect(
      () => validator.validate(Uint8List(0)),
      throwsA(isA<CPluginValidationException>()),
    );
  });

  test('rejects non-zip', () {
    expect(
      () => validator.validate(Uint8List.fromList([1, 2, 3, 4])),
      throwsA(isA<CPluginValidationException>()),
    );
  });

  test('rejects zip without manifest', () {
    final bytes = _zip({
      'plugin.evc': [0, 1, 2],
    });
    expect(
      () => validator.validate(bytes),
      throwsA(
        isA<CPluginValidationException>().having(
          (e) => e.message,
          'message',
          contains('manifest.json'),
        ),
      ),
    );
  });

  test('accepts valid cplugin package', () {
    final manifest = jsonEncode({
      'format': 'cplugin',
      'formatVersion': 1,
      'id': 'com.example.test',
      'name': 'Test',
      'version': '1.0.0',
      'entry': {
        'library': 'package:test/main.dart',
        'function': 'initialize',
      },
    });
    final bytes = _zip({
      'manifest.json': utf8.encode(manifest),
      'plugin.evc': [1, 2, 3, 4, 5],
      'assets/note.txt': utf8.encode('hi'),
    });

    final package = validator.validate(bytes);
    expect(package.manifest.id, 'com.example.test');
    expect(package.evcBytes, [1, 2, 3, 4, 5]);
    expect(utf8.decode(package.assets['note.txt']!), 'hi');
  });

  test('rejects wrong format marker', () {
    final manifest = jsonEncode({
      'format': 'not-cplugin',
      'formatVersion': 1,
      'id': 'com.example.test',
      'name': 'Test',
      'version': '1.0.0',
      'entry': {
        'library': 'package:test/main.dart',
        'function': 'initialize',
      },
    });
    final bytes = _zip({
      'manifest.json': utf8.encode(manifest),
      'plugin.evc': [1, 2, 3],
    });
    expect(
      () => validator.validate(bytes),
      throwsA(isA<CPluginValidationException>()),
    );
  });
}
