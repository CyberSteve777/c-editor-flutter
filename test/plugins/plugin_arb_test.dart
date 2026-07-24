import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/plugins/plugin_arb.dart';

void main() {
  test('parsePluginArb skips metadata and keeps messages', () {
    const source = '''
{
  "@@locale": "en",
  "levelPreview": "Level Preview",
  "@levelPreview": { "description": "title" },
  "previewInitial": "Initial",
  "count": 3
}
''';
    expect(
      parsePluginArb(source),
      {
        'levelPreview': 'Level Preview',
        'previewInitial': 'Initial',
      },
    );
  });

  test('lookupPluginArbMessage prefers locale then en', () {
    final files = <String, String>{
      'l10n/ru.arb': '{"levelPreview":"Предпросмотр"}',
      'l10n/en.arb': '{"levelPreview":"Level Preview","other":"EN"}',
    };
    String? read(String path) => files[path];

    expect(
      lookupPluginArbMessage(read, 'ru', 'levelPreview'),
      'Предпросмотр',
    );
    expect(lookupPluginArbMessage(read, 'ru', 'other'), 'EN');
    expect(lookupPluginArbMessage(read, 'de', 'levelPreview'), 'Level Preview');
    expect(lookupPluginArbMessage(read, 'en', 'missing'), isNull);
  });

  test('pluginArbAssetCandidates include common names', () {
    expect(
      pluginArbAssetCandidates('zh'),
      containsAll([
        'l10n/zh.arb',
        'l10n/app_zh.arb',
        'l10n/messages_zh.arb',
        'l10n/plugin_zh.arb',
      ]),
    );
  });
}
