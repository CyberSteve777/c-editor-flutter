import 'dart:convert';
import 'dart:io';

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_auto_composer.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_feature_groups.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_fonts.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/stage_banner_resolver.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/plugins/plugin_arb.dart';
import 'package:flutter_test/flutter_test.dart';

const _pluginRoot = 'lib/bundled_plugins/preview_img_cplugin';
const _locales = ['zh', 'en', 'ru'];

Map<String, String> _messages(String locale) => parsePluginArb(
  File('$_pluginRoot/assets/l10n/$locale.arb').readAsStringSync(),
);

Set<String> _placeholders(String message) => {
  for (final match in RegExp(
    r'\{([A-Za-z][A-Za-z0-9_]*)\}',
  ).allMatches(message))
    match.group(1)!,
};

Set<String> _referencedMessageKeys() {
  final keys = <String>{};
  // Widget identities are not localization keys. This also covers conditional
  // ValueKey arguments, not only constructors containing a single literal.
  final widgetKey = RegExp(r'\b(?:ValueKey|Key)(?:<[^>]+>)?\s*\([^;]*?\)');
  final messageKey = RegExp(r'''['"](preview[A-Z][A-Za-z0-9_]*)['"]''');
  for (final file in Directory('$_pluginRoot/lib').listSync(recursive: true)) {
    if (file is! File || !file.path.endsWith('.dart')) continue;
    final source = file.readAsStringSync().replaceAll(widgetKey, '');
    for (final match in messageKey.allMatches(source)) {
      keys.add(match.group(1)!);
    }
  }
  // These names are assembled at runtime rather than written as full literals.
  keys.addAll([
    for (final tool in PreviewEditTool.values) 'previewTool_${tool.name}',
    for (final shape in PreviewShapeKind.values) 'previewFigure_${shape.name}',
    for (final shape in PreviewShapeKind.values)
      if (shape != PreviewShapeKind.line) 'previewFigure_${shape.name}_filled',
    'previewGenLayerType_background',
    for (final kind in PreviewLayerKind.values)
      'previewGenLayerType_${kind.name}',
  ]);
  final features =
      jsonDecode(
            File('$_pluginRoot/assets/feature_groups.json').readAsStringSync(),
          )
          as Map<String, dynamic>;
  keys.add(features['featuresPrefixKey'] as String);
  for (final group in features['groups'] as List<dynamic>) {
    keys.add((group as Map<String, dynamic>)['nameKey'] as String);
  }
  return keys;
}

void main() {
  final messages = {for (final locale in _locales) locale: _messages(locale)};
  final sources = {
    for (final locale in _locales)
      'l10n/$locale.arb': File(
        '$_pluginRoot/assets/l10n/$locale.arb',
      ).readAsStringSync(),
  };
  String? readAsset(String path) => sources[path];

  test('all preview locales have complete messages and matching arguments', () {
    final english = messages['en']!;
    for (final locale in _locales) {
      final localized = messages[locale]!;
      expect(localized.keys, unorderedEquals(english.keys), reason: locale);
      for (final key in english.keys) {
        expect(localized[key]!.trim(), isNotEmpty, reason: '$locale: $key');
        expect(localized[key], isNot(key), reason: '$locale: $key');
        expect(
          _placeholders(localized[key]!),
          unorderedEquals(_placeholders(english[key]!)),
          reason: '$locale: $key',
        );
      }
    }
  });

  test('literal and dynamic preview UI references exist in all three ARBs', () {
    final referenced = _referencedMessageKeys();
    expect(referenced, contains('previewGenBoldPvZ'));
    expect(referenced, contains('previewGenFontSystemDefault'));
    expect(referenced, contains('previewTool_layers'));
    expect(referenced, isNot(contains('previewGeneratorBackButton')));
    expect(referenced, isNot(contains('previewToolbarCompactPrimaryRow')));
    for (final locale in _locales) {
      expect(
        referenced.difference(messages[locale]!.keys.toSet()),
        isEmpty,
        reason: 'Missing preview UI translations in $locale',
      );
    }
  });

  test(
    'font, layer and failure copy resolve through the real plugin localizer',
    () {
      const keys = [
        'previewGenBoldPvZ',
        'previewGenFontSystemDefault',
        'previewTool_layers',
        'previewGenLayers',
        'previewGenLayersHint',
        'previewGenClose',
        'previewGenLayerToFront',
        'previewGenLayerForward',
        'previewGenLayerBackward',
        'previewGenLayerToBack',
        'previewGenLoadFail',
        'previewGenExportEncodingFail',
        'previewGenExportLibraryNotConfigured',
      ];
      for (final locale in _locales) {
        for (final key in keys) {
          final entry = lookupPluginArbEntry(readAsset, locale, key);
          expect(entry, isNotNull, reason: '$locale: $key');
          expect(
            formatPluginArbMessage(
              entry!.pattern,
              locale: locale,
              placeholders: entry.placeholders,
            ),
            messages[locale]![key],
            reason: '$locale: $key must not fall back to English or the key',
          );
        }
      }
      expect(messages['zh']!['previewGenFontSystemDefault'], '系统默认字体');
      expect(messages['en']!['previewGenFontSystemDefault'], 'System default');
      expect(messages['ru']!['previewGenFontSystemDefault'], 'Системный шрифт');
      expect(messages['zh']!['previewGenBoldPvZ'], contains('模拟'));
      expect(messages['ru']!['previewGenBoldPvZ'], contains('имитация'));
    },
  );

  test('layer numbers use localized names and locale-appropriate spacing', () {
    const expected = {'zh': '贴纸2', 'en': 'Sticker 2', 'ru': 'Стикер 2'};
    for (final locale in _locales) {
      final entry = lookupPluginArbEntry(
        readAsset,
        locale,
        'previewGenLayerLabel',
      )!;
      final type = lookupPluginArbMessage(
        readAsset,
        locale,
        'previewGenLayerType_image',
      )!;
      expect(
        formatPluginArbMessage(
          entry.pattern,
          args: {'type': type, 'number': 2},
          locale: locale,
          placeholders: entry.placeholders,
        ),
        expected[locale],
      );
    }
  });

  test('shape names and border toggle describe the actual controls', () {
    const expectedBorder = {
      'zh': '显示边框',
      'en': 'Show border',
      'ru': 'Показывать границу',
    };
    for (final locale in _locales) {
      expect(
        lookupPluginArbMessage(readAsset, locale, 'previewGenBorder'),
        expectedBorder[locale],
      );
    }
    const chineseFilledShapes = {
      'previewFigure_rect_filled': '实心矩形',
      'previewFigure_oval_filled': '实心椭圆',
      'previewFigure_star_filled': '实心星形',
    };
    for (final entry in chineseFilledShapes.entries) {
      expect(lookupPluginArbMessage(readAsset, 'zh', entry.key), entry.value);
    }
  });

  test('source subtitles are distinct from formal mode and section names', () {
    const expectedEnglish = {
      'previewGenVaseContent': 'Vase content',
      'previewGenProtect': 'Endangered targets',
      'previewGenPresetLayout': 'Preset layout',
      'previewFeature_vasebreaker': 'Vasebreaker',
      'previewPrePlaced': 'Preset Layout',
    };
    for (final entry in expectedEnglish.entries) {
      expect(lookupPluginArbMessage(readAsset, 'en', entry.key), entry.value);
    }
    for (final locale in _locales) {
      for (final key in const [
        'previewGenVaseContent',
        'previewGenPresetLayout',
      ]) {
        expect(
          lookupPluginArbMessage(readAsset, locale, key),
          messages[locale]![key],
          reason: '$locale: $key must not fall back to another locale',
        );
      }
    }
  });

  test('composer defaults use the same source subtitles as localized UI', () {
    final composer = PreviewAutoComposer(
      levelFile: PvzLevelFile(objects: []),
      parsed: ParsedLevelData(objectMap: {}),
      fileName: 'source-labels.json',
      banners: StageBannerResolver.forTest(stages: const {}),
      featureGroups: PreviewFeatureGroups.forTest(groups: const []),
    );
    expect(composer.vasebreakerLabel, messages['en']!['previewGenVaseContent']);
    expect(composer.protectLabel, messages['en']!['previewGenProtect']);
    expect(composer.prePlacedLabel, messages['en']!['previewGenPresetLayout']);
  });

  test(
    'only the system choice needs localization; font proper names stay intact',
    () {
      expect(PreviewFonts.choices.first.label, 'PvZ Preview');
      expect(PreviewFonts.choices.first.family, PreviewFonts.familyPvZ);
      expect(
        PreviewFonts.choices.where((choice) => choice.family == null),
        hasLength(1),
      );
      for (final choice in PreviewFonts.choices.skip(1)) {
        if (choice.family == null) continue;
        expect(choice.label, choice.family);
      }
    },
  );
}
