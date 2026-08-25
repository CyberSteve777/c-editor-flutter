import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/seed_bank_properties_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _testApp(SeedBankPropertiesScreen screen) {
  return MaterialApp(
    locale: const Locale('zh'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: screen,
  );
}

SeedBankPropertiesScreen _screen(PvzLevelFile level) {
  return SeedBankPropertiesScreen(
    rtid: 'RTID(SeedBank@CurrentLevel)',
    levelFile: level,
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
  );
}

PvzLevelFile _level(SeedBankData data) {
  return PvzLevelFile(
    objects: [
      PvzObject(
        aliases: const ['SeedBank'],
        objClass: 'SeedBankProperties',
        objData: data.toJson(),
      ),
    ],
  );
}

void main() {
  testWidgets('grid item controls are shown only in preset mode', (
    tester,
  ) async {
    final level = _level(SeedBankData(selectionMethod: 'chooser'));
    await tester.pumpWidget(_testApp(_screen(level)));
    await tester.pumpAndSettle();

    expect(find.text('添加障碍物'), findsNothing);

    await tester.tap(find.text('预设 (Preset)'));
    await tester.pumpAndSettle();

    expect(find.text('添加障碍物'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching an enabled grid item mode to chooser confirms first', (
    tester,
  ) async {
    final level = _level(
      SeedBankData(
        selectionMethod: 'preset',
        gridItemMode: true,
        presetPlantList: [kSeedBankGridItemIds.first],
      ),
    );
    await tester.pumpWidget(_testApp(_screen(level)));
    await tester.pumpAndSettle();

    expect(find.text('预选列表中已有1个'), findsOneWidget);

    await tester.tap(find.text('自选 (Chooser)'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        '添加障碍物功能仅在预选模式下生效，切换至自选模式后，该功能将被关闭。是否继续切换？',
      ),
      findsOneWidget,
    );

    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    var saved = SeedBankData.fromJson(
      Map<String, dynamic>.from(level.objects.single.objData as Map),
    );
    expect(saved.selectionMethod, 'preset');
    expect(saved.gridItemMode, isTrue);
    expect(saved.presetPlantList, [kSeedBankGridItemIds.first]);
    expect(find.text('添加障碍物'), findsOneWidget);

    await tester.tap(find.text('自选 (Chooser)'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('仍然继续'));
    await tester.pumpAndSettle();

    saved = SeedBankData.fromJson(
      Map<String, dynamic>.from(level.objects.single.objData as Map),
    );
    expect(saved.selectionMethod, 'chooser');
    expect(saved.gridItemMode, isNot(true));
    expect(saved.presetPlantList, isEmpty);
    expect(find.text('添加障碍物'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
