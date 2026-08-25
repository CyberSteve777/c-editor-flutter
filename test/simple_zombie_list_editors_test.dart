import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/events/barrel_wave_event_screen.dart';
import 'package:c_editor/screens/editor/events/school_bus_event_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _localizedApp(Widget home) => MaterialApp(
  locale: const Locale('zh'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ResourceNames.ensureLoaded(),
      ZombieRepository().init(),
    ]);
  });

  testWidgets('ice cream truck numeric fields keep focus and reject text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final module = PvzObject(
      aliases: const ['SchoolBusEvent'],
      objClass: 'SchoolBusWaveActionProps',
      objData: SchoolBusWaveActionPropsData(
        des: SchoolBusDesData(
          params: SchoolBusParamsData(
            zombies: [SchoolBusZombieData(typeName: 'mummy', level: 3)],
          ),
        ),
      ).toJson(),
    );
    final level = PvzLevelFile(objects: [module]);

    await tester.pumpWidget(
      _localizedApp(
        SchoolBusEventScreen(
          rtid: 'RTID(SchoolBusEvent@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
          onRequestZombieSelection: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final hpField = find.byKey(const ValueKey('schoolBusHitPointsField'));
    await tester.tap(hpField);
    await tester.enterText(hpField, '1');
    await tester.pump();
    expect(
      tester
          .widget<EditableText>(
            find.descendant(of: hpField, matching: find.byType(EditableText)),
          )
          .focusNode
          .hasFocus,
      isTrue,
    );

    await tester.enterText(hpField, '12abc');
    await tester.pump();
    final editable = tester.widget<EditableText>(
      find.descendant(of: hpField, matching: find.byType(EditableText)),
    );
    expect(editable.controller.text, '12');
    expect(editable.focusNode.hasFocus, isTrue);
    expect(
      SchoolBusWaveActionPropsData.fromJson(
        Map<String, dynamic>.from(module.objData as Map),
      ).des.params.schoolBusHitPoints,
      12,
    );

    await tester.tap(find.byKey(const ValueKey('schoolBusZombieCopy_mummy')));
    await tester.pump();
    expect(
      SchoolBusWaveActionPropsData.fromJson(
        Map<String, dynamic>.from(module.objData as Map),
      ).des.params.zombies,
      hasLength(2),
    );
    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('barrel zombie level uses a wide 0-10 picker and can copy', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final module = PvzObject(
      aliases: const ['BarrelEvent'],
      objClass: 'BarrelWaveActionProps',
      objData: BarrelWaveEventData(
        barrels: [
          BarrelEntryData(
            row: 1,
            type: 'barrelmoster',
            params: BarrelParamsData(
              zombies: [BarrelZombieData(typeName: 'mummy', level: 1)],
            ),
          ),
        ],
      ).toJson(),
    );
    final level = PvzLevelFile(objects: [module]);

    await tester.pumpWidget(
      _localizedApp(
        BarrelWaveEventScreen(
          rtid: 'RTID(BarrelEvent@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
          onRequestZombieSelection: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final levelField = find.byKey(const ValueKey('barrelZombieLevel_mummy'));
    expect(tester.getSize(levelField).width, greaterThanOrEqualTo(190));
    await tester.tap(levelField);
    await tester.pumpAndSettle();
    final levels = tester
        .widgetList<DropdownMenuItem<int>>(
          find.byWidgetPredicate((widget) => widget is DropdownMenuItem<int>),
        )
        .map((item) => item.value)
        .whereType<int>()
        .toSet();
    expect(levels, containsAll(List<int>.generate(11, (value) => value)));
    await tester.tap(find.text('0').last);
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('barrelZombieCopy_mummy')));
    await tester.pump();
    final zombies = BarrelWaveEventData.fromJson(
      Map<String, dynamic>.from(module.objData as Map),
    ).barrels.single.params!.zombies;
    expect(zombies, hasLength(2));
    expect(zombies.every((zombie) => zombie.level == 0), isTrue);
    expect(find.byIcon(Icons.close), findsNothing);
    expect(find.byIcon(Icons.delete_outline), findsWidgets);

    final hitPointLabel = tester.widget<Text>(
      find.text('滚桶生命值 (BarrelHitPoints)'),
    );
    expect(hitPointLabel.maxLines, isNull);
    expect(hitPointLabel.overflow, isNull);
    expect(tester.takeException(), isNull);
  });
}
