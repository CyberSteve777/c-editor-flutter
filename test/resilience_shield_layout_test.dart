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
          onTap: () {},
        ),
      ),
    );

    final labelRect = tester.getRect(find.text(label));
    final valueRect = tester.getRect(find.text(value));

    expect(valueRect.top, greaterThan(labelRect.bottom));
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
}
