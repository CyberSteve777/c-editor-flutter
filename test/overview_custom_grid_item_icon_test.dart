import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/level_overview/level_overview_dialog.dart';
import 'package:c_editor/screens/level_overview/level_overview_widgets.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart';
import 'package:c_editor/widgets/lawn_grid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _memoId = 'gravestone_egypt_memo';
const _memoAsset = 'assets/images/griditems/gravestone_tutorial.webp';
const _unknownAsset = 'assets/images/others/unknown.webp';

Widget _app(Widget home) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

PvzLevelFile _memoLevel() {
  final level = PvzLevelFile(
    objects: [
      PvzObject(
        aliases: const ['LevelDefinition'],
        objClass: 'LevelDefinition',
        objData: LevelDefinitionData().toJson(),
      ),
      PvzObject(
        aliases: const ['InitialGridItems'],
        objClass: 'InitialGridItemProperties',
        objData: const {
          'InitialGridItemPlacements': [
            {'GridX': 0, 'GridY': 0, 'TypeName': _memoId},
          ],
        },
      ),
    ],
  );
  // Use every real preset property rather than recognizing a partial fixture.
  expect(
    GridItemRepository.ensureCustomGridItemInLevel(
      'gravestone_tutorial',
      level,
    ),
    isTrue,
  );
  return level;
}

Finder _asset(Finder icon, String path) => find.descendant(
  of: icon,
  matching: find.byWidgetPredicate(
    (widget) => widget is AssetImageWidget && widget.assetPath == path,
  ),
);

Rect _globalRect(WidgetTester tester, Finder finder) {
  final box = tester.renderObject<RenderBox>(finder);
  return Rect.fromPoints(
    box.localToGlobal(Offset.zero),
    box.localToGlobal(box.size.bottomRight(Offset.zero)),
  );
}

Future<Finder> _decodedImage(
  WidgetTester tester,
  Finder icon,
  String path,
) async {
  final image = find.descendant(
    of: icon,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Image &&
          widget.image is AssetImage &&
          (widget.image as AssetImage).assetName == path,
    ),
  );
  final decoded = find.descendant(
    of: image,
    matching: find.byWidgetPredicate(
      (widget) => widget is RawImage && widget.image != null,
    ),
  );
  for (
    var attempt = 0;
    attempt < 200 && decoded.evaluate().isEmpty;
    attempt++
  ) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 20));
  }
  expect(decoded, findsOneWidget);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
  return decoded;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    // Match app startup, which registers the real asset manifest before these
    // reusable icons appear. Registration does not decode the whole image library.
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    for (final path in manifest.listAssets()) {
      if (path.startsWith('assets/') &&
          kImageExtensions.any(
            (extension) => path.toLowerCase().endsWith(extension),
          )) {
        AssetImageWidget.registerManifestPath(path);
      }
    }
    AssetImageWidget.markPreloadComplete();
    await Future.wait([
      ReferenceRepository.init(),
      PlantRepository().init(),
      ZombieRepository().init(),
      GridItemRepository.init(),
      StageRepository.init(),
      ZombossMechRepository.ensureLoaded(),
      ZombossBattleRepository.init(),
      ResourceNames.ensureLoaded(),
    ]);
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    rootBundle.clear();
  });

  for (final mismatch in [null, 'Hitpoints', 'PopAnim']) {
    testWidgets(
      'overview ${mismatch == null ? 'recognizes the real courtyard preset' : 'rejects same-named tombstone with changed $mismatch'} in cells and selected details',
      (tester) async {
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = const Size(1200, 1600);
        addTearDown(tester.view.reset);
        final level = _memoLevel();
        if (mismatch != null) {
          final properties = level.objects.singleWhere(
            (object) =>
                object.aliases?.contains('GridItemGravestoneDefaultMemo') ==
                true,
          );
          properties.objData[mismatch] = mismatch == 'Hitpoints'
              ? 701
              : 'POPANIM_GRAVESTONES_EGYPT_GRAVESTONE';
        }
        await tester.pumpWidget(
          _app(
            LevelOverviewDialog(
              levelFile: level,
              parsed: LevelParser.parseLevel(level),
              fileName: 'courtyard-regression.json',
              onClose: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
        final lawn = find.byType(LawnGrid);
        await tester.ensureVisible(lawn);
        await tester.pumpAndSettle();
        final cellIcon = find.descendant(
          of: lawn,
          matching: find.byWidgetPredicate(
            (widget) => widget is GridItemIcon && widget.id == _memoId,
          ),
        );
        expect(cellIcon, findsOneWidget);
        final expectedAsset = mismatch == null ? _memoAsset : _unknownAsset;
        expect(_asset(cellIcon, expectedAsset), findsOneWidget);
        expect(
          find.descendant(
            of: cellIcon,
            matching: find.byType(CustomResourceBadge),
          ),
          findsNothing,
        );
        final cells = find.descendant(
          of: lawn,
          matching: find.byWidgetPredicate(
            (widget) => widget is GestureDetector && widget.onTap != null,
          ),
        );
        await tester.tap(cells.first);
        await tester.pumpAndSettle();
        final selectedIcon = find.byWidgetPredicate(
          (widget) =>
              widget is GridItemIcon &&
              widget.id == _memoId &&
              widget.size == 44,
        );
        expect(selectedIcon, findsOneWidget);
        expect(_asset(selectedIcon, expectedAsset), findsOneWidget);
        expect(
          find.descendant(
            of: selectedIcon,
            matching: find.byType(CustomResourceBadge),
          ),
          mismatch == null ? findsOneWidget : findsNothing,
        );
        expect(
          find.descendant(
            of: selectedIcon,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is Tooltip &&
                  widget.message ==
                      (mismatch == null ? "Player's House tombstone" : _memoId),
            ),
          ),
          findsOneWidget,
        );
        await _decodedImage(tester, selectedIcon, expectedAsset);
        if (mismatch != null) {
          expect(_asset(selectedIcon, _memoAsset), findsNothing);
          expect(_asset(cellIcon, _memoAsset), findsNothing);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'UniversalIcon forwards level properties when choosing a grid item',
    (tester) async {
      const key = ValueKey('universalMemoIcon');
      await tester.pumpWidget(
        _app(
          Center(
            child: UniversalIcon(
              key: key,
              id: _memoId,
              levelFile: PvzLevelFile(objects: []),
            ),
          ),
        ),
      );
      final icon = find.byKey(key);
      expect(_asset(icon, _unknownAsset), findsOneWidget);
      expect(_asset(icon, _memoAsset), findsNothing);
      expect(
        find.descendant(of: icon, matching: find.byType(CustomResourceBadge)),
        findsNothing,
      );
      await _decodedImage(tester, icon, _unknownAsset);
    },
  );

  testWidgets(
    'catalog preview without a level keeps its courtyard icon and badge',
    (tester) async {
      const key = ValueKey('catalogMemoIcon');
      await tester.pumpWidget(
        _app(
          const Center(
            child: GridItemIcon(key: key, id: _memoId),
          ),
        ),
      );
      final icon = find.byKey(key);
      expect(_asset(icon, _memoAsset), findsOneWidget);
      expect(
        find.descendant(of: icon, matching: find.byType(CustomResourceBadge)),
        findsOneWidget,
      );
      await _decodedImage(tester, icon, _memoAsset);
    },
  );

  for (final id in [_memoId, 'lunar_mine_ore']) {
    for (final isGrid in [true, false]) {
      testWidgets(
        '$id stays centered in a narrow ${isGrid ? 'lawn cell' : 'list slot'}',
        (tester) async {
          const slotKey = ValueKey('narrowOverviewIconSlot');
          const iconKey = ValueKey('narrowOverviewIcon');
          final level = _memoLevel();
          final asset = id == _memoId
              ? _memoAsset
              : 'assets/images/griditems/lunar_mine_ore.webp';
          await tester.pumpWidget(
            _app(
              Center(
                child: SizedBox(
                  key: slotKey,
                  width: 28,
                  height: 44,
                  child: GridItemIcon(
                    key: iconKey,
                    id: id,
                    size: 44,
                    isGrid: isGrid,
                    levelFile: level,
                  ),
                ),
              ),
            ),
          );
          final icon = find.byKey(iconKey);
          final decoded = await _decodedImage(tester, icon, asset);
          final slotRect = _globalRect(tester, find.byKey(slotKey));
          final imageRect = _globalRect(tester, decoded);
          expect(slotRect.size, const Size(28, 44));
          expect(
            (imageRect.center - slotRect.center).distance,
            lessThan(.01),
            reason: 'The decoded image must center inside its constrained slot',
          );
          expect(imageRect.left, greaterThanOrEqualTo(slotRect.left));
          expect(imageRect.right, lessThanOrEqualTo(slotRect.right));
          expect(imageRect.top, greaterThanOrEqualTo(slotRect.top));
          expect(imageRect.bottom, lessThanOrEqualTo(slotRect.bottom));
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
