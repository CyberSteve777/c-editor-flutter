import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/wave_generator_module_screen.dart';
import 'package:c_editor/widgets/wave_generator_zombie_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('flag hint wraps and the initial pool has breathing room', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    final data = WaveGeneratorPropertiesData(
      flagWaveInterval: 5,
      waveSpendingPoints: 100,
      waveSpendingPointIncrement: 100,
      addToZombiePool: [WaveGeneratorPoolEntryData(type: 'tutorial')],
      waves: [WaveGeneratorWaveData()],
    );
    final module = PvzObject(
      aliases: const ['WaveGenerator'],
      objClass: 'WaveGeneratorProperties',
      objData: data.toJson(),
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: WaveGeneratorModuleScreen(
          rtid: 'RTID(WaveGenerator@CurrentLevel)',
          levelFile: PvzLevelFile(objects: [module]),
          onChanged: () {},
          onBack: () {},
          onRequestZombieSelection: (_) {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final l10n = lookupAppLocalizations(const Locale('en'));
    final flagDecorator = find.byWidgetPredicate(
      (widget) =>
          widget is InputDecorator &&
          widget.decoration.helperText == l10n.waveGeneratorFlagIntervalHint,
    );
    expect(flagDecorator, findsOneWidget);
    expect(
      tester.widget<InputDecorator>(flagDecorator).decoration.helperMaxLines,
      4,
    );

    await tester.scrollUntilVisible(
      find.byType(WaveGeneratorZombieTile),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    final heading = find.text(l10n.waveGeneratorInitialPool);
    final tile = find.byType(WaveGeneratorZombieTile);
    expect(
      tester.getTopLeft(tile).dy - tester.getBottomLeft(heading).dy,
      greaterThanOrEqualTo(12),
    );
    expect(tester.takeException(), isNull);
  });
}
