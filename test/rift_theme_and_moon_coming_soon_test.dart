import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/rift_theme_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/modules/rift_theme_module_screen.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/screens/select/rift_theme_selection_screen.dart';
import 'package:c_editor/widgets/rift_theme_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _localizedApp(Widget home) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ResourceNames.ensureLoaded(),
      PlantRepository().init(),
      ZombieRepository().init(),
      RiftThemeRepository.ensureTargetListsLoaded(),
    ]);
  });

  test('rift theme help explains card details interaction in every locale', () {
    expect(
      lookupAppLocalizations(const Locale('zh')).riftThemeHelpOverview,
      contains('长按或右键点击主题卡片'),
    );
    expect(
      lookupAppLocalizations(const Locale('en')).riftThemeHelpOverview,
      contains('Long-press or right-click a theme card'),
    );
    expect(
      lookupAppLocalizations(const Locale('ru')).riftThemeHelpOverview,
      contains('Нажмите и удерживайте карточку темы'),
    );
  });

  testWidgets('all-plants coming soon keeps the general message', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        PlantSelectionScreen(
          stateBucketId: 'coming-soon-all-test',
          onPlantSelected: (_) {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'coming_soon');
    await tester.pumpAndSettle();
    await tester.tap(find.text('coming_soon').last);
    await tester.pumpAndSettle();

    expect(find.text('To Be Continued'), findsOneWidget);
    expect(
      find.text(
        'The plants are still growing strong. Stay tuned for future updates!',
      ),
      findsOneWidget,
    );
  });

  testWidgets('Moon BaseZ coming soon uses the Moon-specific message', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        PlantSelectionScreen(
          stateBucketId: 'coming-soon-moon-test',
          onPlantSelected: (_) {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('By World'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Moon BaseZ'));
    await tester.tap(find.text('Moon BaseZ'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('coming_soon'));
    await tester.tap(find.text('coming_soon'));
    await tester.pumpAndSettle();

    expect(find.text('A Message from Space'), findsOneWidget);
    expect(
      find.text('Moon BaseZ Part 2 is coming soon. Keep a lookout!'),
      findsOneWidget,
    );
  });

  testWidgets('rift theme list uses icons and opens target details', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(360, 900);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      _localizedApp(
        RiftThemeSelectionScreen(
          initialSelectedIds: const [],
          accentColor: Colors.purple,
          onThemesConfirmed: (_) {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(RiftThemeIcon), findsWidgets);
    expect(find.byIcon(Icons.palette_outlined), findsNothing);

    await tester.longPress(find.text('Fully Armored'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Unarmored basic zombies in the level receive bucket armor.'),
      findsOneWidget,
    );
    expect(find.text('Zombie list'), findsOneWidget);
    expect(find.text('roman'), findsOneWidget);
    expect(
      tester.getSize(find.byKey(const ValueKey('riftThemeTarget-roman'))).width,
      greaterThan(200),
    );
    expect(tester.widget<Text>(find.text('Roman Zombie')).maxLines, 2);
  });

  testWidgets('selected themes use a neutral list number and support details', (
    tester,
  ) async {
    final module = PvzObject(
      aliases: const ['RiftThemeModule'],
      objClass: 'RiftThemeDemoModuleProperties',
      objData: RiftThemeDemoModulePropertiesData(
        demoRiftThemeName: const ['zombie'],
      ).toJson(),
    );

    await tester.pumpWidget(
      _localizedApp(
        RiftThemeModuleScreen(
          rtid: 'RTID(RiftThemeModule@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [module]),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(CircleAvatar), findsNothing);
    expect(find.byType(RiftThemeIcon), findsOneWidget);
    final indexText = tester.widget<Text>(find.text('1.'));
    expect(indexText.style?.fontWeight, FontWeight.normal);
    expect(indexText.style?.color, isNotNull);
    final selectedThemeCard = find.ancestor(
      of: find.text('Fully Armored'),
      matching: find.byType(Card),
    );
    final interactiveSurface = tester
        .widgetList<InkWell>(
          find.descendant(
            of: selectedThemeCard,
            matching: find.byType(InkWell),
          ),
        )
        .where(
          (inkWell) =>
              inkWell.onLongPress != null && inkWell.onSecondaryTap != null,
        );
    expect(interactiveSurface, isNotEmpty);

    await tester.longPress(find.text('Fully Armored'));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Zombie list'), findsOneWidget);
  });

  testWidgets('theme details hide every zombie blacklist', (tester) async {
    for (final themeId in const ['invisible', 'gravestone']) {
      final targetList = RiftThemeRepository.targetLists[themeId];
      expect(targetList, isNotNull);
      expect(targetList!.type, RiftThemeTargetType.zombies);
      expect(targetList.isBlacklist, isTrue);

      await tester.pumpWidget(
        _localizedApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showRiftThemeDetailsDialog(context, themeId),
              child: Text(themeId),
            ),
          ),
        ),
      );
      await tester.tap(find.text(themeId));
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pumpAndSettle();

      expect(find.text('Zombie list'), findsNothing);
      for (final zombieId in targetList.ids) {
        expect(
          find.byKey(ValueKey('riftThemeTarget-${zombieId.trim()}')),
          findsNothing,
        );
      }

      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }
  });
}
