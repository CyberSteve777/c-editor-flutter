import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/screens/editor/others/zomboss_mech_action_detail_screen.dart';
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
    final externalLabel = tester.widget<Text>(find.text(label));
    final theme = Theme.of(tester.element(find.text(label)));
    expect(externalLabel.style?.fontSize, theme.textTheme.bodySmall?.fontSize);
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

  testWidgets('one oversized label moves every field on the page above', (
    tester,
  ) async {
    const shortFieldKey = Key('grouped-short-input');
    const longFieldKey = Key('grouped-long-input');
    const longLabel =
        'A very long localized label that cannot fit inside this input';

    await tester.pumpWidget(
      _testApp(
        width: 250,
        child: Column(
          children: [
            EditorResponsiveInputField(
              label: 'Value',
              builder: (context, decoration) =>
                  TextField(key: shortFieldKey, decoration: decoration),
            ),
            const SizedBox(height: 12),
            EditorResponsiveInputField(
              label: longLabel,
              builder: (context, decoration) =>
                  TextField(key: longFieldKey, decoration: decoration),
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    final shortField = tester.widget<TextField>(find.byKey(shortFieldKey));
    final longField = tester.widget<TextField>(find.byKey(longFieldKey));
    expect(shortField.decoration?.labelText, isNull);
    expect(longField.decoration?.labelText, isNull);
    expect(find.text('Value'), findsOneWidget);
    expect(find.text(longLabel), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'external labels share height and center shorter labels in a field row',
    (tester) async {
      const shortFieldKey = Key('aligned-short-input');
      const longFieldKey = Key('aligned-long-input');
      const shortLabel = 'Group size';
      const longLabel =
          'A longer localized label that wraps onto multiple lines';

      await tester.pumpWidget(
        _testApp(
          width: 600,
          child: EditorResponsiveFieldRow(
            breakpoint: 500,
            children: [
              EditorResponsiveInputField(
                label: shortLabel,
                builder: (context, decoration) =>
                    TextField(key: shortFieldKey, decoration: decoration),
              ),
              EditorResponsiveInputField(
                label: longLabel,
                builder: (context, decoration) =>
                    TextField(key: longFieldKey, decoration: decoration),
              ),
            ],
          ),
        ),
      );
      await tester.pump();

      final shortFieldRect = tester.getRect(find.byKey(shortFieldKey));
      final longFieldRect = tester.getRect(find.byKey(longFieldKey));
      final shortLabelRect = tester.getRect(find.text(shortLabel));
      final longLabelRect = tester.getRect(find.text(longLabel));

      expect(shortFieldRect.top, closeTo(longFieldRect.top, 1));
      expect(shortLabelRect.center.dy, closeTo(longLabelRect.center.dy, 1));
      expect(shortLabelRect.top, greaterThan(longLabelRect.top));
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('input fields in a plain row align below wrapped labels', (
    tester,
  ) async {
    const shortFieldKey = Key('plain-row-short-input');
    const longFieldKey = Key('plain-row-long-input');

    await tester.pumpWidget(
      _testApp(
        width: 360,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: EditorResponsiveInputField(
                label: 'Damage to plants',
                builder: (context, decoration) =>
                    TextField(key: shortFieldKey, decoration: decoration),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: EditorResponsiveInputField(
                label: 'Damage dealt to every zombie target',
                builder: (context, decoration) =>
                    TextField(key: longFieldKey, decoration: decoration),
              ),
            ),
          ],
        ),
      ),
    );
    await tester.pump();

    final shortFieldRect = tester.getRect(find.byKey(shortFieldKey));
    final longFieldRect = tester.getRect(find.byKey(longFieldKey));
    expect(shortFieldRect.top, closeTo(longFieldRect.top, 1));
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

  testWidgets('responsive stepper gives a long label the full narrow width', (
    tester,
  ) async {
    const labelKey = Key('stepper-label');
    const controlsKey = Key('stepper-controls');

    await tester.pumpWidget(
      _testApp(
        width: 320,
        child: EditorResponsiveStepperRow(
          label: 'A very long localized setting name that must stay readable',
          value: 5,
          onChanged: (_) {},
          labelKey: labelKey,
          controlsKey: controlsKey,
        ),
      ),
    );

    final labelRect = tester.getRect(find.byKey(labelKey));
    final controlsRect = tester.getRect(find.byKey(controlsKey));
    expect(labelRect.width, greaterThan(250));
    expect(controlsRect.top, greaterThan(labelRect.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('responsive stepper remains horizontal when it fits', (
    tester,
  ) async {
    const labelKey = Key('wide-stepper-label');
    const controlsKey = Key('wide-stepper-controls');

    await tester.pumpWidget(
      _testApp(
        width: 700,
        child: EditorResponsiveStepperRow(
          label: 'Localized setting',
          value: 5,
          onChanged: (_) {},
          labelKey: labelKey,
          controlsKey: controlsKey,
        ),
      ),
    );

    final labelRect = tester.getRect(find.byKey(labelKey));
    final controlsRect = tester.getRect(find.byKey(controlsKey));
    expect(labelRect.right, lessThan(controlsRect.left));
    expect(labelRect.center.dy, closeTo(controlsRect.center.dy, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('responsive switch moves below a long label on narrow screens', (
    tester,
  ) async {
    const labelKey = Key('responsive-switch-label');
    const switchKey = Key('responsive-switch-control');

    await tester.pumpWidget(
      _testApp(
        width: 320,
        child: EditorResponsiveSwitchRow(
          label: 'Can die immediately at the end if no other zombies remain',
          value: false,
          onChanged: (_) {},
          labelKey: labelKey,
          switchKey: switchKey,
        ),
      ),
    );

    final labelRect = tester.getRect(find.byKey(labelKey));
    final switchRect = tester.getRect(find.byKey(switchKey));
    expect(labelRect.width, greaterThan(250));
    expect(switchRect.top, greaterThan(labelRect.bottom));
    expect(tester.takeException(), isNull);
  });

  testWidgets('responsive switch stays horizontal when space is available', (
    tester,
  ) async {
    const labelKey = Key('wide-responsive-switch-label');
    const switchKey = Key('wide-responsive-switch-control');

    await tester.pumpWidget(
      _testApp(
        width: 700,
        child: EditorResponsiveSwitchRow(
          label: 'Can spawn Plant Food',
          value: true,
          onChanged: (_) {},
          labelKey: labelKey,
          switchKey: switchKey,
        ),
      ),
    );

    final labelRect = tester.getRect(find.byKey(labelKey));
    final switchRect = tester.getRect(find.byKey(switchKey));
    expect(labelRect.right, lessThan(switchRect.left));
    expect(labelRect.center.dy, closeTo(switchRect.center.dy, 1));
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

  testWidgets('action details stack labels and values on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    const actionAlias = 'ZombossLostCityTriggerTrapTier3';
    const longField = 'AnExtremelyLongActionFieldNameThatMustStayReadable';
    const catalog = ZombossMechCatalogEntry(
      id: 'ResponsiveMech',
      icon: 'unknown.webp',
      defaultPhaseCount: 1,
      variations: [],
      editableInstance: 'responsive_mech',
      editableInstancePropsName: 'ResponsiveMechProps',
      actions: [
        ZombossMechObjclassGroup(
          objclass: 'ZombossDropSandbagActionDefinition',
          tag: 'attack',
          fields: [ZombossMechFieldSpec(name: longField, type: 'string')],
          implementations: {
            actionAlias: {longField: 'Readable value'},
          },
        ),
      ],
      properties: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: ZombossMechActionDetailScreen(
          catalog: catalog,
          levelFile: PvzLevelFile(objects: []),
          rtid: 'RTID($actionAlias@ZombieActions)',
        ),
      ),
    );
    await tester.pump();

    final aliasLabel = find.text('Alias:');
    final aliasValue = find.text(actionAlias).last;
    expect(
      tester.getTopLeft(aliasValue).dy,
      greaterThan(tester.getBottomLeft(aliasLabel).dy),
    );
    final field = tester.widget<TextField>(find.byType(TextField));
    expect(field.decoration?.labelText, isNull);
    expect(find.text(longField), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
