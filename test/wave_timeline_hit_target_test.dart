import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('wave number strip opens event management on narrow desktop', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(480, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const alias = 'Wave1Event';
    final event = PvzObject(
      aliases: const [alias],
      objClass: 'SpawnZombiesJitteredWaveActionProps',
      objData: const <String, dynamic>{'Zombies': <dynamic>[]},
    );
    final waveManager = WaveManagerData(
      waveCount: 1,
      waves: [
        [RtidParser.build(alias, 'CurrentLevel')],
      ],
    );
    final level = PvzLevelFile(objects: [event]);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: Scaffold(
          body: WaveTimelineTab(
            levelFile: level,
            parsed: ParsedLevelData(
              waveManager: waveManager,
              objectMap: {alias: event},
            ),
            onChanged: () {},
            onEditEvent: (_, _) async {},
            onAddEvent: (_) {},
            onEditWaveManagerSettings: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    final waveNumberStrip = find.byKey(
      const ValueKey('waveTimelineWaveNumberTap-1'),
    );
    await tester.scrollUntilVisible(waveNumberStrip, 300);
    await tester.tap(waveNumberStrip);
    await tester.pumpAndSettle();

    expect(find.text('Wave 1 events'), findsOneWidget);
    expect(find.text('Add event'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
