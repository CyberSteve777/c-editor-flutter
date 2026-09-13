import 'package:c_editor/screens/level_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('template dialog keeps labels readable on a narrow screen', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 2;
    tester.view.physicalSize = const Size(570, 1300);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: LevelTemplateSelectionDialog(
            title: 'New level - Select template',
            cancelLabel: 'Cancel',
            templates: const ['blank', 'regular'],
            displayName: (template) => switch (template) {
              'blank' => 'Blank level',
              _ => 'Regular level template',
            },
            onSelected: (_) {},
            onCancel: () {},
          ),
        ),
      ),
    );

    expect(tester.takeException(), isNull);
    expect(tester.getSize(find.byType(AlertDialog)).width, greaterThan(250));
    expect(
      tester.getSize(find.text('New level - Select template')).height,
      lessThan(90),
    );
    expect(tester.getSize(find.text('Blank level')).height, lessThan(40));
    expect(
      tester.getSize(find.text('Regular level template')).height,
      lessThanOrEqualTo(40),
    );
  });
}
