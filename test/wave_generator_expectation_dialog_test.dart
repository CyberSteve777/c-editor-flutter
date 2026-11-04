import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/wave_generator_expectation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(ZombiePropertiesRepository.init);

  testWidgets(
    'random-spawn preview remains readable on narrow screens without fixed-spawn summary',
    (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final data = WaveGeneratorPropertiesData(
        waveSpendingPoints: 100,
        addToZombiePool: [WaveGeneratorPoolEntryData(type: 'tutorial')],
        waves: [
          WaveGeneratorWaveData(
            disableRandomSpawns: false,
            zombies: [WaveGeneratorZombieEntryData(type: 'tutorial', row: '1')],
          ),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showWaveGeneratorExpectationDialog(
                  context,
                  data: data,
                  waveIndex: 1,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('第1波随机出怪预览'), findsOneWidget);
      expect(find.textContaining('固定出怪：'), findsNothing);
      expect(find.byTooltip('关闭'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'a no-data pool zombie does not hide the remaining preview rows',
    (tester) async {
      final data = WaveGeneratorPropertiesData(
        waveSpendingPoints: 400,
        addToZombiePool: [
          WaveGeneratorPoolEntryData(type: 'RTID(tutorial@ZombieTypes)'),
          WaveGeneratorPoolEntryData(type: 'RTID(my_custom@CurrentLevel)'),
        ],
        waves: [WaveGeneratorWaveData(disableRandomSpawns: false)],
      );

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => showWaveGeneratorExpectationDialog(
                  context,
                  data: data,
                  waveIndex: 1,
                ),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));

      // The custom zombie is only reported as missing data…
      expect(find.textContaining('my_custom'), findsWidgets);
      expect(
        find.textContaining('Random-spawn preview unavailable'),
        findsNothing,
      );
      // …while the bundled zombie still gets a preview row.
      expect(find.text('tutorial'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('preview rows with a 0.00 average for this wave are hidden', (
    tester,
  ) async {
    final data = WaveGeneratorPropertiesData(
      waveSpendingPoints: 100,
      addToZombiePool: [
        // Costs 400: never affordable with a 100 point budget.
        WaveGeneratorPoolEntryData(type: 'RTID(modern_balloon@ZombieTypes)'),
      ],
      waves: [WaveGeneratorWaveData(disableRandomSpawns: false)],
    );

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showWaveGeneratorExpectationDialog(
                context,
                data: data,
                waveIndex: 1,
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.text('modern_balloon'), findsNothing);
    expect(
      find.text(
        "This wave's zombie pool has no zombies eligible for random "
        'spawning.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
