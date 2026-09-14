import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/event_selection_screen.dart';
import 'package:c_editor/screens/select/module_selection_screen.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _plantNameKey = 'plant_armorflame';
const _zombieNameKey = 'zombie_elite_heian_onmyoji_pvz1_hard';
const _plantId =
    'tooltip_regression_plant_with_a_very_long_complete_resource_id';
const _zombieId =
    'tooltip_regression_zombie_with_a_very_long_complete_resource_id';

Widget _app(
  Widget home,
  String locale,
  TargetPlatform platform, {
  double textScale = 1,
}) => MaterialApp(
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: ThemeData(platform: platform),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: home,
);

// Tooltip bubbles render rich text separately from the card's plain Text.
// Checking that live overlay avoids passing on a Tooltip.message property alone.
Finder _bubble(String message) => find.byWidgetPredicate(
  (widget) =>
      widget is Text &&
      widget.data == null &&
      widget.textSpan?.toPlainText() == message,
);

void _expectCompleteBubble(WidgetTester tester, String message) {
  final bubble = _bubble(message);
  expect(bubble, findsOneWidget);
  final paragraph = tester.renderObject<RenderParagraph>(bubble);
  expect(paragraph.didExceedMaxLines, isFalse);
  final box = tester.renderObject<RenderBox>(bubble);
  final rect = Rect.fromPoints(
    box.localToGlobal(Offset.zero),
    box.localToGlobal(box.size.bottomRight(Offset.zero)),
  );
  expect(rect.width, greaterThan(0));
  expect(rect.height, greaterThan(0));
  expect(rect.left, greaterThanOrEqualTo(0));
  expect(rect.top, greaterThanOrEqualTo(0));
  expect(rect.right, lessThanOrEqualTo(360));
  expect(rect.bottom, lessThanOrEqualTo(720));
}

void _expectClippedCardText(WidgetTester tester, String message) {
  final text = find.text(message);
  expect(text, findsOneWidget);
  expect(text.hitTestable(), findsOneWidget);
  expect(
    tester.renderObject<RenderParagraph>(text).didExceedMaxLines,
    isTrue,
    reason: 'The tooltip must expose text actually clipped in the card.',
  );
  expect(_bubble(message), findsNothing);
}

Future<void> _hoverText(WidgetTester tester, String message) async {
  _expectClippedCardText(tester, message);
  final mouse = await tester.createGesture(kind: PointerDeviceKind.mouse);
  await mouse.addPointer(location: Offset.zero);
  await mouse.moveTo(tester.getCenter(find.text(message)));
  await tester.pump(const Duration(milliseconds: 800));
  await tester.pumpAndSettle();
  _expectCompleteBubble(tester, message);
  await mouse.moveTo(const Offset(2, 2));
  await tester.pump(const Duration(seconds: 1));
  await tester.pumpAndSettle();
  expect(_bubble(message), findsNothing);
  await mouse.removePointer();
}

Future<void> _longPressText(WidgetTester tester, String message) async {
  _expectClippedCardText(tester, message);
  final touch = await tester.startGesture(
    tester.getCenter(find.text(message)),
    kind: PointerDeviceKind.touch,
  );
  await tester.pump(const Duration(milliseconds: 700));
  await tester.pumpAndSettle();
  _expectCompleteBubble(tester, message);
  await touch.up();
  // Let the standard touch tooltip expire before testing the icon gesture.
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
  expect(_bubble(message), findsNothing);
}

void _temporaryResources() {
  final plants = PlantRepository().allPlants;
  final zombies = ZombieRepository().allZombies;
  final plantFavorites = PlantRepository().favoriteIds;
  final zombieFavorites = ZombieRepository().favoriteIds;
  final savedPlants = List<PlantInfo>.of(plants);
  final savedZombies = List<ZombieInfo>.of(zombies);
  final savedPlantFavorites = List<String>.of(plantFavorites);
  final savedZombieFavorites = List<String>.of(zombieFavorites);
  plants
    ..clear()
    ..add(PlantInfo(id: _plantId, name: _plantNameKey, tags: [PlantTag.all]));
  zombies
    ..clear()
    ..add(
      ZombieInfo(id: _zombieId, name: _zombieNameKey, tags: [ZombieTag.all]),
    );
  plantFavorites.clear();
  zombieFavorites.clear();
  addTearDown(() {
    plants
      ..clear()
      ..addAll(savedPlants);
    zombies
      ..clear()
      ..addAll(savedZombies);
    plantFavorites
      ..clear()
      ..addAll(savedPlantFavorites);
    zombieFavorites
      ..clear()
      ..addAll(savedZombieFavorites);
  });
}

PvzLevelFile _underwaterLevel() => PvzLevelFile(
  objects: [
    PvzObject(
      aliases: const ['LevelDefinition'],
      objClass: 'LevelDefinition',
      objData: LevelDefinitionData(
        stageModule: 'RTID(TooltipStage@CurrentLevel)',
      ).toJson(),
    ),
    PvzObject(
      aliases: const ['TooltipStage'],
      objClass: 'DeepseaStageProperties',
      objData: const {},
    ),
  ],
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ResourceNames.ensureLoaded(),
      PlantRepository().init(),
      ZombieRepository().init(),
    ]);
  });
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  for (final locale in ['en', 'zh']) {
    for (final isPlant in [true, false]) {
      final kind = isPlant ? 'plant' : 'zombie';
      for (final touch in [false, true]) {
        testWidgets(
          '$locale $kind ${touch ? 'text long press preserves icon favorites' : 'name and ID hover show complete text'}',
          (tester) async {
            tester.view.physicalSize = const Size(360, 720);
            tester.view.devicePixelRatio = 1;
            addTearDown(tester.view.reset);
            _temporaryResources();
            var selections = 0;
            final name = ResourceNames.lookupWithLocale(
              locale,
              isPlant ? _plantNameKey : _zombieNameKey,
            );
            final id = isPlant ? _plantId : _zombieId;
            final screen = isPlant
                ? PlantSelectionScreen(
                    stateBucketId: 'tooltip-$locale-$kind-$touch',
                    onPlantSelected: (_) => selections++,
                    onBack: () {},
                  )
                : ZombieSelectionScreen(
                    stateBucketId: 'tooltip-$locale-$kind-$touch',
                    onZombieSelected: (_) => selections++,
                    onBack: () {},
                  );
            await tester.pumpWidget(
              _app(
                screen,
                locale,
                touch ? TargetPlatform.iOS : TargetPlatform.windows,
              ),
            );
            await tester.pumpAndSettle();
            bool isFavorite() => isPlant
                ? PlantRepository().isFavorite(id)
                : ZombieRepository().isFavorite(id);
            for (final message in [name, id]) {
              if (touch) {
                await _longPressText(tester, message);
              } else {
                await _hoverText(tester, message);
              }
              expect(selections, 0);
              expect(isFavorite(), isFalse);
            }
            if (touch) {
              final icon = isPlant
                  ? find.byKey(ValueKey('plantSelectionIcon-$id'))
                  : find.byType(ClipOval).first;
              await tester.longPress(icon);
              await tester.pumpAndSettle();
              expect(isFavorite(), isTrue);
              expect(selections, 0);
              expect(
                find.text(
                  lookupAppLocalizations(Locale(locale)).addedToFavorites,
                ),
                findsOneWidget,
              );
            }
            expect(tester.takeException(), isNull);
          },
        );
      }
    }

    for (final module in [true, false]) {
      testWidgets(
        '$locale ${module ? 'module' : 'event'} hover reveals full clipped description',
        (tester) async {
          tester.view.physicalSize = const Size(360, 720);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final l10n = lookupAppLocalizations(Locale(locale));
          final description = module
              ? l10n.moduleDesc_BronzeDeadWinConProperties
              : l10n.eventDesc_SpawnZombiesFishWaveActionProps;
          var selected = false;
          final screen = module
              ? ModuleSelectionScreen(
                  existingObjClasses: const {},
                  stateBucketId: 'tooltip-description-$locale',
                )
              : EventSelectionScreen(
                  waveIndex: 1,
                  levelFile: _underwaterLevel(),
                  onEventSelected: (_) => selected = true,
                  onBack: () {},
                );
          await tester.pumpWidget(
            _app(screen, locale, TargetPlatform.windows, textScale: 1.5),
          );
          await tester.pumpAndSettle();
          await tester.enterText(
            find.byType(TextField).first,
            module
                ? 'BronzeDeadWinConProperties'
                : 'SpawnZombiesFishWaveActionProps',
          );
          await tester.pumpAndSettle();
          await _hoverText(tester, description);
          expect(selected, isFalse);
          expect(
            module
                ? find.byType(ModuleSelectionScreen)
                : find.byType(EventSelectionScreen),
            findsOneWidget,
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
