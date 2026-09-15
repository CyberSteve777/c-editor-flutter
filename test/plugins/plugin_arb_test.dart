import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
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

  test('parsePluginArbBundle reads placeholder metadata', () {
    const source = '''
{
  "@@locale": "en",
  "total": "Total: {value}",
  "@total": {
    "description": "cart total",
    "placeholders": {
      "value": {
        "type": "double",
        "format": "compactCurrency",
        "optionalParameters": { "decimalDigits": 0, "symbol": "\$" }
      }
    }
  }
}
''';
    final bundle = parsePluginArbBundle(source);
    expect(bundle['total']!.pattern, 'Total: {value}');
    final ph = bundle['total']!.placeholders['value']!;
    expect(ph.type, 'double');
    expect(ph.format, 'compactCurrency');
    expect(ph.optionalParameters['decimalDigits'], 0);
    expect(ph.optionalParameters['symbol'], r'$');
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

  test('lookupPluginArbEntry returns metadata from locale file', () {
    final files = <String, String>{
      'l10n/en.arb': '''
{
  "hello": "Hello {name}",
  "@hello": {
    "placeholders": { "name": { "type": "String" } }
  }
}
''',
    };
    String? read(String path) => files[path];
    final entry = lookupPluginArbEntry(read, 'en', 'hello');
    expect(entry?.pattern, 'Hello {name}');
    expect(entry?.placeholders['name']?.type, 'String');
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

  test('formatPluginArbMessage interpolates simple placeholders', () {
    expect(
      formatPluginArbMessage(
        'Hello {name}',
        args: {'name': 'Ada'},
      ),
      'Hello Ada',
    );
  });

  test('formatPluginArbMessage handles ICU plural', () {
    const pattern =
        '{count, plural, =0{none} =1{one item} other{{count} items}}';
    expect(
      formatPluginArbMessage(pattern, args: {'count': 0}),
      'none',
    );
    expect(
      formatPluginArbMessage(pattern, args: {'count': 1}),
      'one item',
    );
    expect(
      formatPluginArbMessage(pattern, args: {'count': 5}),
      '5 items',
    );
  });

  test('formatPluginArbMessage coerces string count via metadata', () {
    const pattern =
        '{count, plural, =0{none} =1{one item} other{{count} items}}';
    expect(
      formatPluginArbMessage(
        pattern,
        args: {'count': '5'},
        placeholders: {
          'count': const PluginArbPlaceholder(type: 'int'),
        },
      ),
      '5 items',
    );
  });

  test('formatPluginArbMessage applies number format from metadata', () {
    expect(
      formatPluginArbMessage(
        'Total: {value}',
        args: {'value': 1200000},
        locale: 'en',
        placeholders: {
          'value': const PluginArbPlaceholder(
            type: 'int',
            format: 'compact',
          ),
        },
      ),
      'Total: 1.2M',
    );
  });

  test('formatPluginArbMessage applies currency optionalParameters', () {
    final out = formatPluginArbMessage(
      'Price: {amount}',
      args: {'amount': 12.5},
      locale: 'en_US',
      placeholders: {
        'amount': const PluginArbPlaceholder(
          type: 'double',
          format: 'simpleCurrency',
          optionalParameters: {'decimalDigits': 2},
        ),
      },
    );
    expect(out, startsWith('Price: '));
    expect(out.contains('12.50') || out.contains(r'$12.50'), isTrue);
  });

  test('formatPluginArbMessage applies DateTime format from metadata', () {
    final date = DateTime(1996, 7, 10);
    expect(
      formatPluginArbMessage(
        'Date: {date}',
        args: {'date': date},
        locale: 'en_US',
        placeholders: {
          'date': const PluginArbPlaceholder(
            type: 'DateTime',
            format: 'yMd',
          ),
        },
      ),
      'Date: ${DateFormat.yMd('en_US').format(date)}',
    );
  });

  test('formatPluginArbMessage handles ICU select', () {
    const pattern =
        '{gender, select, male{He} female{She} other{They}} liked this.';
    expect(
      formatPluginArbMessage(pattern, args: {'gender': 'female'}),
      'She liked this.',
    );
  });

  test('formatPluginArbMessage leaves plain text unchanged', () {
    expect(formatPluginArbMessage('Level Preview'), 'Level Preview');
  });

  test('coerceLocalizeArgs normalizes maps', () {
    expect(
      coerceLocalizeArgs({'count': 2, 'name': 'x'}),
      {'count': 2, 'name': 'x'},
    );
    expect(coerceLocalizeArgs(null), isNull);
  });
}
