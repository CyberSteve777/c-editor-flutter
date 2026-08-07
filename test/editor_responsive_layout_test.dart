import 'package:c_editor/widgets/editor_components.dart';
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
  testWidgets('responsive field row unwraps flex children and stacks them', (
    tester,
  ) async {
    const firstKey = Key('first-field');
    const secondKey = Key('second-field');

    await tester.pumpWidget(
      _testApp(
        width: 320,
        child: const EditorResponsiveFieldRow(
          children: [
            Expanded(child: SizedBox(key: firstKey, height: 48)),
            SizedBox(width: 16),
            Expanded(child: SizedBox(key: secondKey, height: 48)),
          ],
        ),
      ),
    );

    final firstRect = tester.getRect(find.byKey(firstKey));
    final secondRect = tester.getRect(find.byKey(secondKey));

    expect(secondRect.top, greaterThan(firstRect.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('responsive label field separates long labels from values', (
    tester,
  ) async {
    const label = 'A very long localized editor property label';
    const value = '1500.0';

    await tester.pumpWidget(
      _testApp(
        width: 320,
        child: const EditorResponsiveLabelField(
          label: Text(label),
          field: Text(value),
        ),
      ),
    );

    expect(
      tester.getRect(find.text(value)).top,
      greaterThan(tester.getRect(find.text(label)).bottom),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('responsive input field moves an oversized label above', (
    tester,
  ) async {
    const fieldKey = Key('responsive-input');
    const label =
        'A very long localized input label that must remain fully visible';

    await tester.pumpWidget(
      _testApp(
        width: 240,
        child: EditorResponsiveInputField(
          label: label,
          builder: (context, decoration) =>
              TextField(key: fieldKey, decoration: decoration),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byKey(fieldKey));
    expect(field.decoration?.labelText, isNull);
    expect(find.text(label), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('responsive input field keeps a short inline label', (
    tester,
  ) async {
    const fieldKey = Key('short-responsive-input');

    await tester.pumpWidget(
      _testApp(
        width: 500,
        child: EditorResponsiveInputField(
          label: 'Value',
          builder: (context, decoration) =>
              TextField(key: fieldKey, decoration: decoration),
        ),
      ),
    );

    final field = tester.widget<TextField>(find.byKey(fieldKey));
    expect(field.decoration?.labelText, 'Value');
    expect(tester.takeException(), isNull);
  });

  testWidgets('responsive action row moves the action below long content', (
    tester,
  ) async {
    const label = 'A long localized section title with an attached action';
    const action = 'Clear everything outside the lawn';

    await tester.pumpWidget(
      _testApp(
        width: 320,
        child: EditorResponsiveActionRow(
          content: const Text(label),
          action: FilledButton(onPressed: () {}, child: const Text(action)),
        ),
      ),
    );

    expect(
      tester.getRect(find.text(action)).top,
      greaterThan(tester.getRect(find.text(label)).bottom),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('labeled add button bounds long localized text', (tester) async {
    await tester.pumpWidget(
      _testApp(
        width: 240,
        child: PvzAddButton(
          onPressed: () {},
          label: 'Add a very long localized editor item name',
        ),
      ),
    );

    expect(tester.takeException(), isNull);
  });
}
