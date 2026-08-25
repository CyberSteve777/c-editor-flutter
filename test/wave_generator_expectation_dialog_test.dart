import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/wave_generator_expectation_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
}
