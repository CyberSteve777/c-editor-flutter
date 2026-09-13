import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_sticker_catalog.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/rift_theme_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

PvzObject _object(String objClass, Map<String, dynamic> data) =>
    PvzObject(objClass: objClass, objData: data);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<PreviewSticker> catalog;
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    rootBundle.clear();
    catalog = await loadPreviewStickerCatalog();
  });

  test(
    'priority is stable within both current-level and remaining entries',
    () {
      const stickers = [
        PreviewSticker(assetPath: 'assets/images/plants/a.webp', tag: 'plants'),
        PreviewSticker(assetPath: 'assets/images/plants/b.gif', tag: 'plants'),
        PreviewSticker(
          assetPath: 'assets/images/zombies/a.webp',
          tag: 'zombies',
        ),
        PreviewSticker(
          assetPath: 'assets/images/zombies/b.webp',
          tag: 'zombies',
        ),
        PreviewSticker(
          assetPath: 'assets/images/griditems/a.webp',
          tag: 'griditems',
        ),
        PreviewSticker(assetPath: 'assets/images/ui/a.webp', tag: 'ui'),
      ];
      final ordered = prioritizePreviewStickers(
        stickers: stickers,
        priorityAssetPaths: const [
          'assets/images/ui/a.webp',
          'assets/images/zombies/b.webp',
          'assets/images/plants/B.png',
        ],
      );
      expect(ordered, [
        stickers[1],
        stickers[3],
        stickers[5],
        stickers[0],
        stickers[2],
        stickers[4],
      ]);
      expect(stickers.first.assetPath, 'assets/images/plants/a.webp');
      expect(ordered.toSet(), hasLength(stickers.length));
      expect(
        prioritizePreviewStickers(
          stickers: stickers,
          priorityAssetPaths: const [],
        ),
        same(stickers),
      );
    },
  );

  test(
    'overview plants, zombies, grid items, map, music and themes are promoted',
    () {
      final level = PvzLevelFile(
        objects: [
          _object('LevelDefinition', {
            'Name': 'wallnut',
            'Description': 'cosmoss',
            'StageModule': 'RTID(EgyptStage@LevelModules)',
            'MusicSuffix': 'Beach',
          }),
          _object('SeedBankProperties', {
            'PresetPlantList': ['peashooter'],
            'PlantWhiteList': ['sunflower'],
            'PlantBlackList': ['potatomine'],
          }),
          _object('PVZ1CopycatsModuleProperties', {
            'PlantBlackList': ['cherry_bomb'],
            'ZombieWhiteList': ['swashbuckler'],
          }),
          _object('SeedRainProperties', {
            'SeedRains': [
              {'PlantTypeName': 'snowpea'},
            ],
          }),
          _object('InitialZombieProperties', {
            'InitialZombiePlacements': [
              {'TypeName': 'mummy_armor1', 'GridX': 2, 'GridY': 1},
            ],
          }),
          _object('InitialGridItemProperties', {
            'InitialGridItemPlacements': [
              {'TypeName': 'cosmoss', 'GridX': 1, 'GridY': 1},
              {
                'TypeName': 'gravestoneZombieOnDestruction',
                'GridX': 2,
                'GridY': 1,
              },
            ],
          }),
          _object('RiftThemeDemoModuleProperties', {
            'DemoRiftThemeName': ['knight_cheating', 'zombie'],
          }),
        ],
      );
      final priority = previewCurrentLevelStickerAssetPaths(
        stickers: catalog,
        levelFile: level,
        parsed: LevelParser.parseLevel(level),
      );
      expect(
        priority,
        containsAll([
          'assets/images/plants/icon_peashooter.webp',
          'assets/images/plants/icon_sunflower.webp',
          'assets/images/plants/icon_potatomine.webp',
          'assets/images/plants/icon_cherry_bomb.webp',
          'assets/images/plants/icon_snowpea.webp',
          'assets/images/zombies/zombie_mummy_armor1.webp',
          'assets/images/zombies/zombie_swashbuckler.webp',
          'assets/images/griditems/cosmoss.webp',
          'assets/images/griditems/gravestone_dark.webp',
          RiftThemeRepository.iconAssetPath('knight_cheating'),
          RiftThemeRepository.iconAssetPath('zombie'),
        ]),
      );
      expect(
        priority,
        isNot(contains('assets/images/plants/icon_cosmoss.webp')),
      );
      expect(
        priority,
        isNot(contains('assets/images/plants/icon_wallnut.webp')),
      );
      final map = catalog.firstWhere(
        (sticker) =>
            sticker.tag == 'round_icons' &&
            sticker.searchTerms.contains('EgyptStage'),
      );
      expect(priority, contains(map.assetPath));
      final ordered = prioritizePreviewStickers(
        stickers: catalog,
        priorityAssetPaths: priority,
      );
      final priorityStems = priority
          .map(
            (path) => path.replaceFirst(RegExp(r'\.[^/.]+$'), '').toLowerCase(),
          )
          .toSet();
      bool isPreferred(PreviewSticker sticker) => priorityStems.contains(
        sticker.assetPath.replaceFirst(RegExp(r'\.[^/.]+$'), '').toLowerCase(),
      );
      final expected = catalog.where(isPreferred).toList();
      expect(ordered.take(expected.length), expected);
      expect(
        ordered.skip(expected.length),
        catalog.where((s) => !isPreferred(s)),
      );
    },
  );

  test('I-zombie and grid-item seed banks retain resource category', () {
    for (final mode in ['ZombieMode', 'GridItemMode']) {
      final level = PvzLevelFile(
        objects: [
          _object('SeedBankProperties', {
            mode: true,
            'PresetPlantList': [mode == 'ZombieMode' ? 'mummy' : 'cosmoss'],
          }),
        ],
      );
      final priority = previewCurrentLevelStickerAssetPaths(
        stickers: catalog,
        levelFile: level,
        parsed: LevelParser.parseLevel(level),
      );
      expect(
        priority,
        contains(
          mode == 'ZombieMode'
              ? 'assets/images/zombies/zombie_mummy.webp'
              : 'assets/images/griditems/cosmoss.webp',
        ),
      );
      expect(
        priority,
        isNot(contains('assets/images/plants/icon_cosmoss.webp')),
      );
    }
  });

  test(
    'a GIF or shared icon resolved by the document keeps catalog position',
    () {
      final level = PvzLevelFile(objects: []);
      final current = catalog.last;
      final document = PreviewDocument(
        banner: PreviewBannerRef(kind: PreviewBannerSourceKind.assetStem),
        layers: [
          PreviewLayer(
            id: 'custom-source',
            kind: PreviewLayerKind.iconGrid,
            bounds: const Rect.fromLTWH(0, 0, 0.4, 0.4),
            sections: [
              PreviewIconSection(
                rows: [
                  PreviewIconRow(
                    items: [
                      PreviewItem(id: 'custom', assetPath: current.assetPath),
                    ],
                    iconSize: 36,
                  ),
                ],
              ),
            ],
          ),
        ],
      );
      final priority = previewCurrentLevelStickerAssetPaths(
        stickers: catalog,
        levelFile: level,
        parsed: LevelParser.parseLevel(level),
        document: document,
      );
      expect(priority, contains(current.assetPath));
      expect(
        prioritizePreviewStickers(
          stickers: catalog,
          priorityAssetPaths: priority,
        ).first,
        same(current),
      );
    },
  );

  for (final removedPanel in [false, true]) {
    test(
      'bosses and mech summons stay prioritized with '
      '${removedPanel ? 'the preview panel removed' : 'no document'}',
      () async {
        await ZombossMechRepository.init();
        final mech = ZombossMechRepository.getCatalog(
          'ZombieZombossMech_Egypt',
        )!;
        final level = PvzLevelFile(
          objects: [
            _object('ZombossBattleModuleProperties', {
              'ZombossMechType': mech.editableInstance,
            }),
            PvzObject(
              aliases: [mech.editableInstancePropsName],
              objClass: 'ZombieZombossMechEgyptProps',
              objData: {
                'Stages': [
                  {
                    'Actions': ['RTID(SummerZombossEgyptSpawn1@.)'],
                  },
                ],
              },
            ),
            _object('ZombossLastStandMinigameProperties', {
              'ZombossTypeName': 'kongfu_zomboss_qigong',
            }),
          ],
        );
        PreviewDocument? document;
        if (removedPanel) {
          document = PreviewDocument(
            banner: PreviewBannerRef(kind: PreviewBannerSourceKind.assetStem),
            layers: [
              PreviewLayer(
                id: 'zombies',
                kind: PreviewLayerKind.iconGrid,
                bounds: const Rect.fromLTWH(0.5, 0, 0.5, 0.5),
                items: [
                  PreviewItem(
                    id: mech.id,
                    assetPath: 'assets/images/zombies/${mech.icon}',
                  ),
                ],
              ),
            ],
          );
          document.layers.removeWhere((layer) => layer.id == 'zombies');
          expect(document.layers, isEmpty);
        }
        final priority = await loadPreviewCurrentLevelStickerAssetPaths(
          stickers: catalog,
          levelFile: level,
          parsed: LevelParser.parseLevel(level),
          document: document,
        );
        expect(
          priority,
          containsAll([
            'assets/images/zombies/zombossmech_egypt.webp',
            'assets/images/zombies/kongfu_zomboss_qigong.webp',
            'assets/images/zombies/zombie_mummy.webp',
            'assets/images/zombies/zombie_mummy_armor1.webp',
            'assets/images/zombies/zombie_mummy_armor2.webp',
            'assets/images/zombies/zombie_tomb_raiser.webp',
          ]),
        );
        final ordered = prioritizePreviewStickers(
          stickers: catalog,
          priorityAssetPaths: priority,
        );
        final stems = priority
            .map(
              (path) =>
                  path.replaceFirst(RegExp(r'\.[^/.]+$'), '').toLowerCase(),
            )
            .toSet();
        bool isCurrent(PreviewSticker sticker) => stems.contains(
          sticker.assetPath
              .replaceFirst(RegExp(r'\.[^/.]+$'), '')
              .toLowerCase(),
        );
        final currentEntries = catalog.where(isCurrent).toList();
        expect(ordered.take(currentEntries.length), currentEntries);
        expect(
          ordered.skip(currentEntries.length),
          catalog.where((entry) => !isCurrent(entry)),
        );
      },
    );
  }
}
