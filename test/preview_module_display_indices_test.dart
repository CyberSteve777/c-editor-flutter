import 'dart:convert';

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_module_info.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:flutter_test/flutter_test.dart';

String _localize(String key, String fallback, [Map<String, Object?>? args]) {
  const templates = {
    'previewGenColumnRange': '第{min}–{max}列',
    'previewGenRailRange': '第{col}列，第{start}–{end}行',
    'previewGenDropShipWave':
        '第{wave}波：额外{imp}只，阶级{lv}，第{rmin}–{rmax}行，第{cmin}–{cmax}列',
    'previewGenDropShipWaveTitle':
        '第{wave}波：额外{imp}只，第{rmin}–{rmax}行，第{cmin}–{cmax}列',
    'previewGenRenaiNightWave': '从第{wave}波进入夜晚',
  };
  var text = templates[key] ?? fallback;
  for (final entry in (args ?? const <String, Object?>{}).entries) {
    text = text.replaceAll('{${entry.key}}', '${entry.value}');
  }
  return text;
}

PreviewModuleInfoPayload _build(String objClass, Map<String, dynamic> data) {
  final level = PvzLevelFile(
    objects: [
      PvzObject(aliases: ['Module'], objClass: objClass, objData: data),
    ],
  );
  final original = jsonDecode(jsonEncode(level.toJson()));
  final payload = previewModuleInfoBuild(
    levelFile: level,
    objClass: objClass,
    t: _localize,
  );
  expect(
    level.toJson(),
    original,
    reason: 'Building display text must not mutate the level',
  );
  return payload;
}

void main() {
  group('module display indices', () {
    test('vase column ranges are one-based in text and grid notes', () {
      for (final minColumn in [0, 4]) {
        final data = VaseBreakerPresetData(
          minColumnIndex: minColumn,
          maxColumnIndex: 8,
          vases: [VaseDefinition(plantTypeName: 'peashooter', count: 2)],
        );
        final original = jsonDecode(jsonEncode(data.toJson()));
        final payload = _build('VaseBreakerPresetProperties', data.toJson());

        final expected = '第${minColumn + 1}–9列';
        expect(payload.lines, contains(expected));
        expect(payload.gridNotes, contains(expected));
        expect(payload.sections.single.items.single.label, '×2');
        expect(data.minColumnIndex, minColumn);
        expect(data.maxColumnIndex, 8);
        expect(data.toJson(), original);
      }
    });

    test('rail ranges are one-based while lawn cells stay zero-based', () {
      final data = RailcartPropertiesData(
        rails: [
          RailData(column: 0, rowStart: 0, rowEnd: 4),
          RailData(column: 8, rowStart: 3, rowEnd: 4),
        ],
        railcarts: [RailcartData(column: 0, row: 0)],
      );
      final original = jsonDecode(jsonEncode(data.toJson()));
      final payload = _build('RailcartProperties', data.toJson());

      expect(payload.lines, contains('第1列，第1–5行'));
      expect(payload.lines, contains('第9列，第4–5行'));
      final items = payload.sections.single.items;
      final firstRail = items.firstWhere((item) => item.id == 'rails_0_0');
      final lastRail = items.firstWhere((item) => item.id == 'rails_8_4');
      expect((firstRail.gridX, firstRail.gridY), (0, 0));
      expect((lastRail.gridX, lastRail.gridY), (8, 4));
      expect(items.where((item) => item.id.startsWith('rails_')), hasLength(7));
      expect(data.toJson(), original);
    });

    test('drop-ship wave and area text are one-based in both modes', () {
      final data = DropShipPropertiesData(
        appearWaves: [
          DropShipAppearWaveData(
            wave: 0,
            imp: 2,
            impLv: 3,
            rowRange: MinMaxRange(min: 0, max: 4),
            colRange: MinMaxRange(min: 0, max: 8),
          ),
          DropShipAppearWaveData(
            wave: 2,
            imp: 0,
            impLv: 1,
            rowRange: MinMaxRange(min: 1, max: 3),
            colRange: MinMaxRange(min: 2, max: 7),
          ),
        ],
      );
      final original = jsonDecode(jsonEncode(data.toJson()));
      final payload = _build('DropShipProperties', data.toJson());

      expect(payload.lines, contains('第1波：额外2只，阶级3，第1–5行，第1–9列'));
      expect(payload.lines, contains('第3波：额外0只，阶级1，第2–4行，第3–8列'));
      expect(payload.sections[0].title, '第1波：额外2只，第1–5行，第1–9列');
      expect(payload.sections[1].title, '第3波：额外0只，第2–4行，第3–8列');
      expect(payload.sections[0].items, hasLength(3));
      expect(payload.sections[0].items.first.label, 'Lv3');
      expect(payload.sections[1].items, hasLength(1));
      expect(data.appearWaves.first.wave, 0);
      expect(data.appearWaves.first.rowRange.min, 0);
      expect(data.appearWaves.first.colRange.max, 8);
      expect(data.toJson(), original);
    });

    test(
      'Renai night-start wave is one-based without shifting statue cells',
      () {
        for (final nightStart in [0, 4]) {
          final data = RenaiModulePropertiesData(
            nightEnabled: true,
            nightStartWaveNum: nightStart,
            statueNightInfos: [
              RenaiStatueInfoData(
                gridX: 0,
                gridY: 4,
                waveNumber: nightStart,
                typeName: 'renai_statue',
              ),
            ],
          );
          final original = jsonDecode(jsonEncode(data.toJson()));
          final payload = _build('RenaiModuleProperties', data.toJson());

          final expected = '从第${nightStart + 1}波进入夜晚';
          expect(payload.lines, contains(expected));
          expect(payload.gridNotes, contains(expected));
          final statue = payload.sections.single.items.single;
          expect((statue.gridX, statue.gridY), (0, 4));
          expect(data.nightStartWaveNum, nightStart);
          expect(data.statueNightInfos.single.waveNumber, nightStart);
          expect(data.toJson(), original);
        }
      },
    );
  });
}
