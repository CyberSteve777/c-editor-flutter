import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_export_prefs.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_feature_groups.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_rich_text_controller.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/stage_banner_resolver.dart';

void main() {
  group('sanitizePreviewFileBaseName', () {
    test('strips extension and illegal chars', () {
      expect(sanitizePreviewFileBaseName('My Level.json'), 'My Level');
      expect(sanitizePreviewFileBaseName('a/b:c*.png'), 'a_b_c_');
      expect(sanitizePreviewFileBaseName('   '), 'preview');
    });
  });

  group('PreviewExportPrefs.sanitizeFolderName', () {
    test('blocks path traversal and separators', () {
      expect(PreviewExportPrefs.sanitizeFolderName('previews'), 'previews');
      expect(PreviewExportPrefs.sanitizeFolderName('../x'), 'x');
      expect(PreviewExportPrefs.sanitizeFolderName(r'a\b/c'), 'a_b_c');
      expect(PreviewExportPrefs.sanitizeFolderName(''), 'previews');
    });
  });

  group('PreviewFeatureGroups', () {
    String localize(String key, String fallback) {
      const map = {
        'previewFeaturesPrefix': 'Особенности: ',
        'previewFeature_vasebreaker': 'Вазобой',
        'previewFeature_last_stand': 'Последний Выживший',
        'previewFeature_zomboss_mech': 'Бой с Зомботом',
        'previewFeature_conveyor': 'Конвейер',
      };
      return map[key] ?? fallback;
    }

    String moduleTitle(String objClass) {
      const map = {
        'LastStandMinigameProperties': 'Последний Выживший',
        'ZombossBattleModuleProperties': 'Бой с Зомботом',
        'ZombossLastStandMinigameProperties': 'Бой с Боссом',
        'ConveyorSeedBankProperties': 'Конвейер',
      };
      return map[objClass] ?? objClass;
    }

    test('groups vase modules into one feature', () {
      final groups = PreviewFeatureGroups.forTest(
        groups: [
          const PreviewFeatureGroup(
            id: 'vasebreaker',
            nameKey: 'previewFeature_vasebreaker',
            fallbackName: 'Vasebreaker',
            objClasses: {
              'VaseBreakerPresetProperties',
              'VaseBreakerArcadeModuleProperties',
              'VaseBreakerFlowModuleProperties',
            },
          ),
          const PreviewFeatureGroup(
            id: 'last_stand',
            nameKey: 'previewFeature_last_stand',
            titleObjClass: 'LastStandMinigameProperties',
            fallbackName: 'Last Stand',
            objClasses: {'LastStandMinigameProperties'},
          ),
        ],
        excludeObjClasses: {'RiftThemeDemoModuleProperties'},
      );

      final subtitle = groups.buildSubtitle(
        [
          'VaseBreakerPresetProperties',
          'VaseBreakerArcadeModuleProperties',
          'VaseBreakerFlowModuleProperties',
          'LastStandMinigameProperties',
          'RiftThemeDemoModuleProperties',
        ],
        localize: localize,
        moduleTitle: moduleTitle,
      );

      expect(subtitle, 'Особенности: Вазобой, Последний Выживший');
    });

    test('collapses zomboss mech battle + intro', () {
      final groups = PreviewFeatureGroups.forTest(
        groups: [
          const PreviewFeatureGroup(
            id: 'zomboss_mech',
            nameKey: 'previewFeature_zomboss_mech',
            titleObjClass: 'ZombossBattleModuleProperties',
            fallbackName: 'Zomboss Mech Battle',
            objClasses: {
              'ZombossBattleModuleProperties',
              'ZombossBattleIntroProperties',
            },
          ),
        ],
      );
      expect(
        groups.buildSubtitle(
          [
            'ZombossBattleModuleProperties',
            'ZombossBattleIntroProperties',
          ],
          localize: localize,
          moduleTitle: moduleTitle,
        ),
        'Особенности: Бой с Зомботом',
      );
    });

    test('picks first feature by module order', () {
      final groups = PreviewFeatureGroups.forTest(
        groups: [
          const PreviewFeatureGroup(
            id: 'vasebreaker',
            nameKey: 'previewFeature_vasebreaker',
            fallbackName: 'Vasebreaker',
            objClasses: {
              'VaseBreakerPresetProperties',
              'VaseBreakerArcadeModuleProperties',
            },
          ),
          const PreviewFeatureGroup(
            id: 'last_stand',
            nameKey: 'previewFeature_last_stand',
            titleObjClass: 'LastStandMinigameProperties',
            fallbackName: 'Last Stand',
            objClasses: {'LastStandMinigameProperties'},
          ),
        ],
      );
      expect(
        groups.firstFeatureLabel(
          [
            'LastStandMinigameProperties',
            'VaseBreakerArcadeModuleProperties',
          ],
          localize: localize,
          moduleTitle: moduleTitle,
        ),
        'Последний Выживший',
      );
      expect(
        groups.firstFeatureLabel(
          ['VaseBreakerArcadeModuleProperties'],
          localize: localize,
          moduleTitle: moduleTitle,
        ),
        'Вазобой',
      );
    });

    test('includes conveyor and zomboss groups', () {
      final groups = PreviewFeatureGroups.forTest(
        groups: [
          const PreviewFeatureGroup(
            id: 'zomboss_mech',
            nameKey: 'previewFeature_zomboss_mech',
            titleObjClass: 'ZombossBattleModuleProperties',
            fallbackName: 'Zomboss Mech Battle',
            objClasses: {
              'ZombossBattleModuleProperties',
              'ZombossBattleIntroProperties',
            },
          ),
          const PreviewFeatureGroup(
            id: 'zomboss_non_mech',
            nameKey: 'previewFeature_zomboss_non_mech',
            titleObjClass: 'ZombossLastStandMinigameProperties',
            fallbackName: 'Non-mech Zomboss Battle',
            objClasses: {'ZombossLastStandMinigameProperties'},
          ),
          const PreviewFeatureGroup(
            id: 'conveyor',
            nameKey: 'previewFeature_conveyor',
            titleObjClass: 'ConveyorSeedBankProperties',
            fallbackName: 'Conveyor Belt',
            objClasses: {'ConveyorSeedBankProperties'},
          ),
        ],
      );

      expect(
        groups.buildSubtitle(
          [
            'ZombossBattleIntroProperties',
            'ConveyorSeedBankProperties',
            'ZombossLastStandMinigameProperties',
          ],
          localize: localize,
          moduleTitle: moduleTitle,
        ),
        'Особенности: Бой с Зомботом, Бой с Боссом, Конвейер',
      );
      expect(
        groups.firstFeatureLabel(
          [
            'ConveyorSeedBankProperties',
            'ZombossBattleModuleProperties',
          ],
          localize: localize,
          moduleTitle: moduleTitle,
        ),
        'Конвейер',
      );
    });
  });

  group('StageBannerResolver', () {
    test('uses map and default fallback', () {
      final r = StageBannerResolver.forTest(
        defaultStem: 'Unknown',
        stages: {
          'ModernStage': 'Modern',
          'BowlingStage': 'Modern',
          'LostVolcanoCustom': 'VolcanoLostCity',
        },
      );
      expect(r.resolveStem('ModernStage'), 'Modern');
      expect(r.resolveStem('BowlingStage'), 'Modern');
      expect(r.resolveStem('LostVolcanoCustom'), 'VolcanoLostCity');
      expect(r.resolveStem('MissingStage'), 'Unknown');
      expect(
        r.assetPathForStem('Unknown'),
        'lib/bundled_plugins/level_preview_cplugin/assets/banners/Unknown.png',
      );
      expect(
        r.roundIconAssetForStem('Unknown'),
        'assets/images/others/unknown.webp',
      );
      expect(r.roundIconAltCandidatesForStem('Unknown'), isEmpty);
    });
  });

  group('PreviewLayer text styles', () {
    PreviewLayer textLayer(List<PreviewTextRun> runs) => PreviewLayer(
      id: 't',
      kind: PreviewLayerKind.text,
      bounds: const Rect.fromLTWH(0, 0, 1, 1),
      textRuns: runs,
    );

    test('insert inherits previous character style', () {
      final small = PreviewTextStyleData(fontSize: 12);
      final large = PreviewTextStyleData(fontSize: 48);
      final layer = textLayer([
        PreviewTextRun(text: 'Ab', style: small),
        PreviewTextRun(text: 'C', style: large),
      ]);
      // Insert 'x' before C (after "Ab") → inherits small from 'b'.
      layer.updatePlainTextPreservingStyles('AbxC');
      expect(layer.plainText, 'AbxC');
      expect(layer.textRuns.length, 2);
      expect(layer.textRuns[0].text, 'Abx');
      expect(layer.textRuns[0].style.fontSize, 12);
      expect(layer.textRuns[1].text, 'C');
      expect(layer.textRuns[1].style.fontSize, 48);
    });

    test('insert at start inherits first character style', () {
      final small = PreviewTextStyleData(fontSize: 12);
      final large = PreviewTextStyleData(fontSize: 48);
      final layer = textLayer([
        PreviewTextRun(text: 'A', style: small),
        PreviewTextRun(text: 'B', style: large),
      ]);
      layer.updatePlainTextPreservingStyles('xAB');
      expect(layer.textRuns.first.style.fontSize, 12);
      expect(layer.textRuns.first.text, 'xA');
    });

    test('typingStyle override wins over inherited style', () {
      final small = PreviewTextStyleData(fontSize: 12);
      final layer = textLayer([PreviewTextRun(text: 'Hi', style: small)]);
      layer.updatePlainTextPreservingStyles(
        'Hi!',
        typingStyle: PreviewTextStyleData(fontSize: 64),
      );
      expect(layer.textRuns.length, 2);
      expect(layer.textRuns[0].style.fontSize, 12);
      expect(layer.textRuns[1].text, '!');
      expect(layer.textRuns[1].style.fontSize, 64);
    });
  });

  group('PreviewRichTextController', () {
    test('buildTextSpan keeps one style per run after typing', () {
      final controller = PreviewRichTextController();
      final layer = PreviewLayer(
        id: 't',
        kind: PreviewLayerKind.text,
        bounds: const Rect.fromLTWH(0, 0, 1, 1),
        textRuns: [
          PreviewTextRun(
            text: 'Hi',
            style: PreviewTextStyleData(
              fontFamily: kPreviewCustomFontFamily,
              fontSize: 36,
            ),
          ),
        ],
      );
      controller.loadFromLayer(layer);
      controller.value = TextEditingValue(
        text: 'Hi!',
        selection: const TextSelection.collapsed(offset: 3),
      );
      expect(controller.runs, hasLength(1));
      expect(controller.runs.single.style.fontFamily, kPreviewCustomFontFamily);
      expect(controller.runs.single.style.fontSize, 36);
      controller.dispose();
    });

    test('styleAtCaret uses previous character', () {
      final controller = PreviewRichTextController();
      controller.loadFromLayer(
        PreviewLayer(
          id: 't',
          kind: PreviewLayerKind.text,
          bounds: const Rect.fromLTWH(0, 0, 1, 1),
          textRuns: [
            PreviewTextRun(text: 'A', style: PreviewTextStyleData(fontSize: 12)),
            PreviewTextRun(text: 'B', style: PreviewTextStyleData(fontSize: 48)),
          ],
        ),
      );
      controller.selection = const TextSelection.collapsed(offset: 2);
      expect(controller.styleAtCaret().fontSize, 48);
      controller.selection = const TextSelection.collapsed(offset: 0);
      expect(controller.styleAtCaret().fontSize, 12);
      controller.dispose();
    });
  });
}
