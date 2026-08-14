import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/json_viewer_screen.dart';
import 'package:c_editor/screens/editor/events/dino_event_screen.dart';
import 'package:c_editor/screens/editor/events/frost_wind_event_screen.dart';
import 'package:c_editor/screens/editor/modules/bowling_minigame_screen.dart';
import 'package:c_editor/screens/editor/modules/seed_bank_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/tunnel_defend_module_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _localizedApp(Widget home, {Locale locale = const Locale('en')}) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  for (final testCase
      in <({Locale locale, String title, bool isEvent, String expected})>[
        (
          locale: const Locale('en'),
          title: 'Dino Summon',
          isEvent: true,
          expected: 'Dino Summon event',
        ),
        (
          locale: const Locale('en'),
          title: 'Manhole Pipeline',
          isEvent: false,
          expected: 'Manhole Pipeline module',
        ),
        (
          locale: const Locale('zh'),
          title: '事件类型：恐龙召唤',
          isEvent: true,
          expected: '恐龙召唤事件说明',
        ),
        (
          locale: const Locale('zh'),
          title: '复兴时代模块',
          isEvent: false,
          expected: '复兴时代模块说明',
        ),
      ]) {
    testWidgets('standardizes ${testCase.expected}', (tester) async {
      await tester.pumpWidget(
        _localizedApp(
          Builder(
            builder: (context) => TextButton(
              onPressed: () => showEditorHelpDialog(
                context,
                title: testCase.title,
                isEvent: testCase.isEvent,
                sections: const [
                  HelpSectionData(title: 'Overview', body: 'Body'),
                ],
              ),
              child: const Text('Open'),
            ),
          ),
          locale: testCase.locale,
        ),
      );

      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();

      expect(find.text(testCase.expected), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('Seed Bank help uses five structured sections', (tester) async {
    await tester.pumpWidget(
      _localizedApp(
        SeedBankPropertiesScreen(
          rtid: 'RTID(SeedBank@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
          onRequestPlantSelection:
              (
                _, {
                excludeIds,
                initialSelectedIds,
                blockRealmExclusiveInChooser = false,
                blockHiddenPlantsInChooser = false,
                allowDuplicateSelection = false,
              }) {},
          onRequestZombieSelection: (_) {},
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    for (final title in [
      '• Overview',
      '• Whitelist and blacklist',
      '• I, Zombie mode',
      '• Slot occupancy',
      '• Advanced gameplay',
    ]) {
      expect(find.descendant(of: dialog, matching: find.text(title)), findsOne);
    }
    expect(find.text('Seed Bank module'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dino summon help omits the dinosaur type section', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        DinoEventScreen(
          rtid: 'RTID(DinoTimeEvent@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(find.text('Dino Summon event'), findsOneWidget);
    expect(
      find.descendant(of: dialog, matching: find.text('• Dinosaur type')),
      findsNothing,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('Bowling uses a stepper and a red foul-line preview', (
    tester,
  ) async {
    final level = PvzLevelFile(objects: []);
    await tester.pumpWidget(
      _localizedApp(
        BowlingMinigameScreen(
          rtid: 'RTID(BowlingMinigame@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    final stepper = find.byKey(const ValueKey('bowlingFoulLineStepper'));
    expect(stepper, findsOneWidget);
    expect(
      find.byKey(const ValueKey('bowlingFoulLinePreviewLine')),
      findsOneWidget,
    );
    await tester.tap(
      find.descendant(of: stepper, matching: find.byIcon(Icons.add)),
    );
    await tester.pump();

    expect((level.objects.single.objData as Map)['BowlingFoulLine'], 3);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Underwater Bowling offsets the range and preview by one', (
    tester,
  ) async {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['LevelDefinition'],
          objClass: 'LevelDefinition',
          objData: LevelDefinitionData(
            stageModule: 'RTID(DeepseaStage@CurrentLevel)',
          ).toJson(),
        ),
        PvzObject(
          aliases: ['DeepseaStage'],
          objClass: 'DeepseaStageProperties',
          objData: <String, dynamic>{},
        ),
      ],
    );
    await tester.pumpWidget(
      _localizedApp(
        BowlingMinigameScreen(
          rtid: 'RTID(BowlingMinigame@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    final stepper = find.byKey(const ValueKey('bowlingFoulLineStepper'));
    final remove = find.descendant(
      of: stepper,
      matching: find.byIcon(Icons.remove),
    );
    for (var i = 0; i < 2; i++) {
      await tester.tap(remove);
      await tester.pump();
    }

    final module = level.objects.firstWhere(
      (object) => object.objClass == 'BowlingMinigameProperties',
    );
    expect((module.objData as Map)['BowlingFoulLine'], 0);
    final grid = find.byKey(const ValueKey('bowlingFoulLinePreviewGrid'));
    final line = find.byKey(const ValueKey('bowlingFoulLinePreviewLine'));
    expect(
      tester.getCenter(line).dx,
      closeTo(
        tester.getTopLeft(grid).dx + tester.getSize(grid).width / 10,
        0.1,
      ),
    );

    await tester.tap(remove);
    await tester.pump();
    expect((module.objData as Map)['BowlingFoulLine'], -1);
    expect(
      tester.getTopLeft(line).dx,
      closeTo(tester.getTopLeft(grid).dx, 0.1),
    );

    for (var i = 0; i < 10; i++) {
      await tester.tap(
        find.descendant(of: stepper, matching: find.byIcon(Icons.add)),
      );
      await tester.pump();
    }
    expect((module.objData as Map)['BowlingFoulLine'], 9);
    final addButton = tester.widget<IconButton>(
      find.ancestor(
        of: find.descendant(of: stepper, matching: find.byIcon(Icons.add)),
        matching: find.byType(IconButton),
      ),
    );
    expect(addButton.onPressed, isNull);

    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();
    expect(find.textContaining('automatically adds 1'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Frost wind rows and direction controls stay grouped', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        FrostWindEventScreen(
          rtid: 'RTID(FrostWind@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();

    expect(find.byKey(const ValueKey('frostWindRowStepper-0')), findsOneWidget);
    final direction = find.byKey(const ValueKey('frostWindDirection-0'));
    expect(direction, findsOneWidget);
    expect(
      find.descendant(of: direction, matching: find.text('Direction')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('tunnel layout preview is horizontally centered', (tester) async {
    tester.view.physicalSize = const Size(1000, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _localizedApp(
        TunnelDefendModuleScreen(
          rtid: 'RTID(SouDaCheTunnelDefendDefault@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    final center = find.byKey(const ValueKey('tunnelLayoutPreviewCenter'));
    final preview = find
        .descendant(of: center, matching: find.byType(AspectRatio))
        .first;
    expect(tester.getCenter(preview).dx, closeTo(500, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('saving JSON immediately refreshes the plain-text view', (
    tester,
  ) async {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['TestObject'],
          objClass: 'TestClass',
          objData: {'Value': 'before'},
        ),
      ],
    );
    await tester.pumpWidget(
      _localizedApp(
        JsonViewerScreen(
          fileName: 'test.json',
          filePath: 'test.json',
          levelFile: level,
          onBack: () {},
          saveLevel: (_, _) async {},
        ),
      ),
    );
    await tester.pump();
    expect(find.textContaining('before'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final editor = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.controller?.text.contains('"objects"') == true,
    );
    expect(editor, findsOneWidget);
    await tester.enterText(
      editor,
      '{"objects":[{"aliases":["TestObject"],"objclass":"TestClass","objdata":{"Value":"after"}}],"version":1}',
    );
    await tester.tap(find.byIcon(Icons.save));
    await tester.pumpAndSettle();

    expect(find.textContaining('after'), findsOneWidget);
    expect(find.textContaining('before'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
