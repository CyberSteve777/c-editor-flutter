import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/pvz1_copycats_module_screen.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('copycats fields and registry cards stay readable when narrow', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(360, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['PVZ1CopycatsModule'],
          objClass: 'PVZ1CopycatsModuleProperties',
          objData: PVZ1CopycatsModulePropertiesData(
            plantBlackList: ['powerlily'],
            zombieWhiteList: ['future'],
          ).toJson(),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.dark,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PVZ1CopycatsModuleScreen(
          rtid: 'RTID(PVZ1CopycatsModule@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    const zombieWeightLabel = '召唤僵尸权重 (ZombieWeight)';
    const spawnPlantLevelLabel = '召唤植物阶级 (SpawnPlantLevel)';
    final zombieWeightInput = find.byKey(
      const ValueKey('copycatsZombieWeightInput'),
    );
    final spawnPlantLevelInput = find.byKey(
      const ValueKey('copycatsSpawnPlantLevelInput'),
    );
    expect(
      tester.widget<TextField>(zombieWeightInput).decoration?.labelText,
      isNull,
    );
    expect(
      tester.widget<TextField>(spawnPlantLevelInput).decoration?.labelText,
      isNull,
    );
    expect(
      tester.getBottomLeft(find.text(zombieWeightLabel)).dy,
      lessThan(tester.getTopLeft(zombieWeightInput).dy),
    );
    expect(
      tester.getBottomLeft(find.text(spawnPlantLevelLabel)).dy,
      lessThan(tester.getTopLeft(spawnPlantLevelInput).dy),
    );

    final plantText = find.byKey(const ValueKey('copycatsPlantText0'));
    final plantDelete = find.byKey(const ValueKey('copycatsPlantDelete0'));
    final zombieText = find.byKey(const ValueKey('copycatsZombieText0'));
    final zombieDelete = find.byKey(const ValueKey('copycatsZombieDelete0'));
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('copycatsPlantName0')))
          .data,
      isNotEmpty,
    );
    expect(
      tester
          .widget<Text>(find.byKey(const ValueKey('copycatsZombieName0')))
          .data,
      isNotEmpty,
    );
    expect(tester.getSize(plantText).width, greaterThan(80));
    expect(tester.getSize(zombieText).width, greaterThan(80));
    expect(
      tester.getRect(plantText).right,
      lessThanOrEqualTo(tester.getRect(plantDelete).left),
    );
    expect(
      tester.getRect(zombieText).right,
      lessThanOrEqualTo(tester.getRect(zombieDelete).left),
    );
    expect(tester.takeException(), isNull);
  });
}
