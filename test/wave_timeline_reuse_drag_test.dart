import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/tabs/wave_timeline_tab.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PvzObject _event(String alias) => PvzObject(
  aliases: [alias],
  objClass: 'SpawnZombiesJitteredWaveActionProps',
  objData: const <String, dynamic>{'Zombies': <dynamic>[]},
);

Widget _buildTab({
  required WaveManagerData waveManager,
  required List<PvzObject> objects,
  required Map<String, PvzObject> objectMap,
}) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: Scaffold(
      body: WaveTimelineTab(
        levelFile: PvzLevelFile(
          objects: [
            ...objects,
            PvzObject(
              aliases: const ['WaveManager'],
              objClass: 'WaveManagerProperties',
              objData: waveManager.toJson(),
            ),
          ],
        ),
        parsed: ParsedLevelData(waveManager: waveManager, objectMap: objectMap),
        onChanged: () {},
        onEditEvent: (_, _) async {},
        onAddEvent: (_) {},
        onEditWaveManagerSettings: () {},
      ),
    ),
  );
}

void main() {
  testWidgets('reuse existing event adds RTID reference to wave', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const alias = 'SharedEvent';
    final event = _event(alias);
    final rtid = RtidParser.build(alias, 'CurrentLevel');
    final waveManager = WaveManagerData(
      waveCount: 2,
      waves: [
        [rtid],
        <String>[],
      ],
    );

    await tester.pumpWidget(
      _buildTab(
        waveManager: waveManager,
        objects: [event],
        objectMap: {alias: event},
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('waveTimelineWaveNumberTap-2')));
    await tester.pumpAndSettle();
    expect(find.text('Reuse event'), findsOneWidget);

    final addButton = find.byKey(const ValueKey('waveManageAddEventButton'));
    final reuseButton = find.byKey(
      const ValueKey('waveManageReuseEventButton'),
    );
    expect(tester.getRect(addButton).top, tester.getRect(reuseButton).top);
    expect(
      tester.getRect(addButton).right,
      lessThan(tester.getRect(reuseButton).left),
    );

    await tester.tap(find.text('Reuse event'));
    await tester.pumpAndSettle();
    expect(find.text('Reuse event for wave 2'), findsOneWidget);
    expect(find.text(alias), findsWidgets);

    await tester.tap(find.text(alias).first);
    await tester.pumpAndSettle();

    expect(waveManager.waves[1], [rtid]);
    expect(waveManager.waves[0], [rtid]);
  });

  testWidgets('long-press drag moves event across waves', (tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const alias = 'MoveMe';
    final event = _event(alias);
    final rtid = RtidParser.build(alias, 'CurrentLevel');
    final waveManager = WaveManagerData(
      waveCount: 2,
      waves: [
        [rtid],
        <String>[],
      ],
    );

    await tester.pumpWidget(
      _buildTab(
        waveManager: waveManager,
        objects: [event],
        objectMap: {alias: event},
      ),
    );
    await tester.pumpAndSettle();

    final chip = find.text(alias).first;
    final target = find.byKey(const ValueKey('waveTimelineDropTarget-2'));
    expect(target, findsOneWidget);
    final gesture = await tester.startGesture(
      tester.getCenter(chip),
      kind: PointerDeviceKind.touch,
    );
    await tester.pump(const Duration(milliseconds: 250));
    await gesture.moveTo(tester.getCenter(target));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(waveManager.waves[0], isEmpty);
    expect(waveManager.waves[1], [rtid]);
  });

  testWidgets('long-press drag reorders events inside a wave', (tester) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const aliasA = 'EventA';
    const aliasB = 'EventB';
    final eventA = _event(aliasA);
    final eventB = _event(aliasB);
    final rtidA = RtidParser.build(aliasA, 'CurrentLevel');
    final rtidB = RtidParser.build(aliasB, 'CurrentLevel');
    final waveManager = WaveManagerData(
      waveCount: 1,
      waves: [
        [rtidA, rtidB],
      ],
    );

    await tester.pumpWidget(
      _buildTab(
        waveManager: waveManager,
        objects: [eventA, eventB],
        objectMap: {aliasA: eventA, aliasB: eventB},
      ),
    );
    await tester.pumpAndSettle();

    final chipB = find.text(aliasB).first;
    final gesture = await tester.startGesture(
      tester.getCenter(chipB),
      kind: PointerDeviceKind.touch,
    );
    await tester.pump(const Duration(milliseconds: 250));
    // Slots appear after drag starts.
    await tester.pump();
    final slotBeforeA = find.byKey(
      const ValueKey('waveTimelineInsertSlot-1-0'),
    );
    expect(slotBeforeA, findsOneWidget);
    await gesture.moveTo(tester.getCenter(slotBeforeA));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(waveManager.waves[0], [rtidB, rtidA]);
  });

  testWidgets('copy reference to a range skips waves that already have it', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(900, 1200);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const alias = 'SharedEvent';
    final event = _event(alias);
    final rtid = RtidParser.build(alias, 'CurrentLevel');
    final waveManager = WaveManagerData(
      waveCount: 3,
      waves: [
        [rtid],
        <String>[],
        [rtid],
      ],
    );

    await tester.pumpWidget(
      _buildTab(
        waveManager: waveManager,
        objects: [event],
        objectMap: {alias: event},
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('waveTimelineWaveNumberTap-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.text(alias).last);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('waveEventCopyButton')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Copy reference'));
    await tester.pumpAndSettle();

    expect(find.text('Target wave'), findsOneWidget);
    await tester.enterText(find.byType(TextField).last, '1-3');
    await tester.tap(find.text('Copy').last);
    await tester.pumpAndSettle();

    expect(waveManager.waves[0], [rtid]);
    expect(waveManager.waves[1], [rtid]);
    expect(waveManager.waves[2], [rtid]);
  });
}
