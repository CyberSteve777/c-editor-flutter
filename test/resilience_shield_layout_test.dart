import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/screens/editor/others/resilience_shield_selection_screen.dart';
import 'package:c_editor/widgets/resilience_shield_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _testApp({required double width, required Widget child}) {
  return MaterialApp(
    home: Scaffold(
      body: MediaQuery(
        data: const MediaQueryData(
          size: Size(360, 800),
          textScaler: TextScaler.linear(2),
        ),
        child: Align(
          alignment: Alignment.topCenter,
          child: SizedBox(width: width, child: child),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('selected shield label and value use separate lines', (
    tester,
  ) async {
    const label = 'Selected Resilience shield';
    const value = 'ResilienceMagic3@ResilienceConfig';

    await tester.pumpWidget(
      _testApp(
        width: 320,
        child: ResilienceShieldSelectionCard(
          label: label,
          value: value,
          isCustom: true,
          onTap: () {},
        ),
      ),
    );

    final labelRect = tester.getRect(find.text(label));
    final valueRect = tester.getRect(find.text(value));

    expect(valueRect.top, greaterThan(labelRect.bottom));
    expect(find.text('C'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shield parameters stack labels above values on narrow layouts', (
    tester,
  ) async {
    const label =
        'Zombie damage threshold per second (DamageThresholdPerSecond)';
    const value = '1500.0';

    await tester.pumpWidget(
      _testApp(
        width: 320,
        child: const ResilienceShieldParameterRow(label: label, value: value),
      ),
    );

    final labelRect = tester.getRect(find.text(label));
    final valueRect = tester.getRect(find.text(value));

    expect(valueRect.top, greaterThan(labelRect.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('custom shield list items show the yellow C badge', (
    tester,
  ) async {
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['CustomResilience0'],
          objClass: 'ZombieResilience',
          objData: {'Amount': 300.0, 'WeakType': 4, 'RecoverSpeed': 25.0},
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ResilienceShieldSelectionScreen(
          levelFile: level,
          currentRtid: 'RTID(CustomResilience0@CurrentLevel)',
        ),
      ),
    );
    await tester.pump();

    expect(find.text('CustomResilience0'), findsOneWidget);
    expect(find.text('C'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
