import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/app_localizations_en.dart';
import 'package:c_editor/screens/editor/modules/radiation_meteor_module_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/grid_override_placement_grid.dart';
import 'package:c_editor/widgets/grid_override_wave_groups_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PvzObject _module({List<Map<String, int>>? schedule}) => PvzObject(
  aliases: const ['RadiationMeteorModule'],
  objClass: 'RadiationMeteorModuleProperties',
  objData: RadiationMeteorModulePropertiesData.fromJson({
    'SpawnSchedule':
        schedule ??
        [
          {'Wave': 3, 'GridX': 0, 'GridY': 0},
          {'Wave': 3, 'GridX': 2, 'GridY': 1},
          {'Wave': 90, 'GridX': 4, 'GridY': 2},
        ],
  }).toJson(),
);

Finder _waveField(int groupIndex) =>
    find.byKey(ValueKey('meteor-wave-$groupIndex'));

Finder _editableWithin(Finder field) =>
    find.descendant(of: field, matching: find.byType(EditableText));

Future<void> _pumpModule(WidgetTester tester, PvzObject module) async {
  await tester.binding.setSurfaceSize(const Size(1000, 1800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: RadiationMeteorModuleScreen(
        rtid: 'RTID(RadiationMeteorModule@CurrentLevel)',
        levelFile: PvzLevelFile(objects: [module]),
        onChanged: () {},
        onBack: () {},
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<EditableTextState> _startEditing(
  WidgetTester tester,
  Finder field,
) async {
  await tester.ensureVisible(field);
  await tester.showKeyboard(field);
  await tester.pump();
  final state = tester.state<EditableTextState>(_editableWithin(field));
  expect(state.widget.focusNode.hasFocus, isTrue);
  return state;
}

/// Sends one keyboard editing update at a time without reopening the keyboard.
/// Whole-string enterText would hide field replacement and lost input focus.
Future<void> _sendValue(
  WidgetTester tester,
  Finder field,
  EditableTextState originalState,
  String text, {
  int? caret,
}) async {
  expect(tester.testTextInput.isRegistered, isTrue);
  final selection = TextSelection.collapsed(offset: caret ?? text.length);
  tester.testTextInput.updateEditingValue(
    TextEditingValue(text: text, selection: selection),
  );
  await tester.pump();
  final state = tester.state<EditableTextState>(_editableWithin(field));
  expect(state, same(originalState));
  expect(state.widget.focusNode.hasFocus, isTrue);
  expect(state.widget.controller.text, text);
  expect(state.widget.controller.selection, selection);
  expect(tester.testTextInput.isRegistered, isTrue);
}

void _expectWaveAt(PvzObject module, int x, int y, int expectedWave) {
  final schedule = (module.objData['SpawnSchedule'] as List).cast<Map>();
  final entry = schedule.singleWhere(
    (entry) => entry['GridX'] == x && entry['GridY'] == y,
  );
  expect(entry['Wave'], expectedWave);
}

void _expectFirstGroupWave(PvzObject module, int expectedWave) {
  _expectWaveAt(module, 0, 0, expectedWave);
  _expectWaveAt(module, 2, 1, expectedWave);
  _expectWaveAt(module, 4, 2, 90);
  expect(module.objData['SpawnSchedule'], hasLength(3));
}

Future<void> _selectGroup(WidgetTester tester, int index) async {
  final chipLabel = find.descendant(
    of: find.byType(GridOverrideWaveGroupsBar),
    matching: find.text('Group ${index + 1}'),
  );
  await tester.ensureVisible(chipLabel);
  await tester.tap(chipLabel);
  await tester.pumpAndSettle();
}

Future<void> _deleteGroup(WidgetTester tester, int index) async {
  final deleteButton = find
      .descendant(
        of: find.byType(GridOverrideWaveGroupsBar),
        matching: find.byIcon(Icons.delete_outline),
      )
      .at(index);
  await tester.ensureVisible(deleteButton);
  await tester.tap(deleteButton);
  await tester.pumpAndSettle();
  await tester.tap(
    find.widgetWithText(TextButton, AppLocalizationsEn().remove),
  );
  await tester.pumpAndSettle();
}

Future<void> _tapCell(WidgetTester tester, int col, int row) async {
  final finder = find.byType(GridOverridePlacementGrid);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  final grid = tester.widget<GridOverridePlacementGrid>(finder);
  final rect = tester.getRect(finder);
  await tester.tapAt(
    Offset(
      rect.left + rect.width * (col + 0.5) / grid.gridCols,
      rect.top + rect.height * (row + 0.5) / grid.gridRows,
    ),
  );
  await tester.pump();
}

void main() {
  testWidgets(
    'wave digits retain field identity, focus and caret after rebuild',
    (tester) async {
      final module = _module();
      await _pumpModule(tester, module);
      final field = _waveField(0);
      final state = await _startEditing(tester, field);

      await _sendValue(tester, field, state, '1');
      _expectFirstGroupWave(module, 1);
      await _sendValue(tester, field, state, '12');
      _expectFirstGroupWave(module, 12);
      await _sendValue(tester, field, state, '123');
      _expectFirstGroupWave(module, 123);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('wave text supports clearing, insertion and deletion in place', (
    tester,
  ) async {
    final module = _module();
    await _pumpModule(tester, module);
    final field = _waveField(0);
    final state = await _startEditing(tester, field);

    await _sendValue(tester, field, state, '');
    _expectFirstGroupWave(module, 3);
    await _sendValue(tester, field, state, '4');
    _expectFirstGroupWave(module, 4);
    await _sendValue(tester, field, state, '45');
    _expectFirstGroupWave(module, 45);

    // Insert at the front, then in the middle; keep the reported caret rather
    // than moving it to the end when the serialized model triggers a rebuild.
    state.widget.controller.selection = const TextSelection.collapsed(
      offset: 0,
    );
    await _sendValue(tester, field, state, '145', caret: 1);
    _expectFirstGroupWave(module, 145);
    await _sendValue(tester, field, state, '1245', caret: 2);
    _expectFirstGroupWave(module, 1245);
    await _sendValue(tester, field, state, '145', caret: 1);
    _expectFirstGroupWave(module, 145);
    state.widget.controller.selection = const TextSelection.collapsed(
      offset: 3,
    );
    await _sendValue(tester, field, state, '14');
    _expectFirstGroupWave(module, 14);
    await _sendValue(tester, field, state, '');
    _expectFirstGroupWave(module, 14);
    await _sendValue(tester, field, state, '7');
    await _sendValue(tester, field, state, '78');
    _expectFirstGroupWave(module, 78);
    expect(tester.takeException(), isNull);
  });

  testWidgets('an intermediate duplicate wave does not block further typing', (
    tester,
  ) async {
    final module = _module(
      schedule: [
        {'Wave': 0, 'GridX': 0, 'GridY': 0},
        {'Wave': 0, 'GridX': 2, 'GridY': 1},
        {'Wave': 1, 'GridX': 4, 'GridY': 2},
      ],
    );
    await _pumpModule(tester, module);
    final field = _waveField(0);
    final state = await _startEditing(tester, field);

    await _sendValue(tester, field, state, '');
    await _sendValue(tester, field, state, '1');
    _expectWaveAt(module, 0, 0, 0);
    _expectWaveAt(module, 2, 1, 0);
    _expectWaveAt(module, 4, 2, 1);
    await _sendValue(tester, field, state, '12');
    _expectWaveAt(module, 0, 0, 12);
    _expectWaveAt(module, 2, 1, 12);
    _expectWaveAt(module, 4, 2, 1);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching, adding and deleting groups show the correct wave', (
    tester,
  ) async {
    final module = _module(
      schedule: [
        {'Wave': 2, 'GridX': 0, 'GridY': 0},
        {'Wave': 2, 'GridX': 2, 'GridY': 1},
        {'Wave': 8, 'GridX': 4, 'GridY': 2},
        {'Wave': 20, 'GridX': 5, 'GridY': 3},
      ],
    );
    await _pumpModule(tester, module);
    var field = _waveField(0);
    var state = await _startEditing(tester, field);
    await _sendValue(tester, field, state, '3');
    await _sendValue(tester, field, state, '30');

    await _selectGroup(tester, 1);
    field = _waveField(1);
    expect(
      tester.widget<EditableText>(_editableWithin(field)).controller.text,
      '8',
    );
    state = await _startEditing(tester, field);
    await _sendValue(tester, field, state, '81');
    _expectWaveAt(module, 0, 0, 30);
    _expectWaveAt(module, 2, 1, 30);
    _expectWaveAt(module, 4, 2, 81);
    _expectWaveAt(module, 5, 3, 20);

    await _selectGroup(tester, 0);
    expect(
      tester
          .widget<EditableText>(_editableWithin(_waveField(0)))
          .controller
          .text,
      '30',
    );
    final addButton = find.byKey(const ValueKey('addGridOverrideWaveGroup'));
    await tester.ensureVisible(addButton);
    await tester.tap(addButton);
    await tester.pumpAndSettle();
    field = _waveField(3);
    // Editing group values need not leave them sorted: allocate max + 1,
    // not last + 1, so a new group never accidentally reuses an existing wave.
    expect(
      tester.widget<EditableText>(_editableWithin(field)).controller.text,
      '82',
    );
    await _tapCell(tester, 0, 2);
    _expectWaveAt(module, 0, 2, 82);
    state = await _startEditing(tester, field);
    await _sendValue(tester, field, state, '9');
    await _sendValue(tester, field, state, '92');

    // Removing a preceding group must keep the same logical group selected.
    await _deleteGroup(tester, 0);
    expect(
      tester
          .widget<EditableText>(_editableWithin(_waveField(2)))
          .controller
          .text,
      '92',
    );
    _expectWaveAt(module, 0, 2, 92);
    _expectWaveAt(module, 4, 2, 81);
    _expectWaveAt(module, 5, 3, 20);
    expect(module.objData['SpawnSchedule'], hasLength(3));

    await _deleteGroup(tester, 2);
    expect(
      tester
          .widget<EditableText>(_editableWithin(_waveField(1)))
          .controller
          .text,
      '20',
    );
    expect(module.objData['SpawnSchedule'], hasLength(2));
    await _deleteGroup(tester, 1);
    expect(
      tester
          .widget<EditableText>(_editableWithin(_waveField(0)))
          .controller
          .text,
      '81',
    );
    await _deleteGroup(tester, 0);
    expect(find.byType(TextFormField), findsNothing);
    expect(module.objData['SpawnSchedule'], isEmpty);

    await tester.tap(addButton);
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<EditableText>(_editableWithin(_waveField(0)))
          .controller
          .text,
      '0',
    );
    await _tapCell(tester, 1, 0);
    _expectWaveAt(module, 1, 0, 0);
    expect(module.objData['SpawnSchedule'], hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('all four parameter fields accept consecutive numeric updates', (
    tester,
  ) async {
    final module = _module();
    await _pumpModule(tester, module);
    final l10n = AppLocalizationsEn();
    final parameters = [
      (l10n.radiationMeteorWarningDuration, 'WarningDuration', true),
      (l10n.radiationMeteorPollutionInterval, 'PollutionInterval', true),
      (l10n.radiationMeteorMiningDuration, 'MiningDurationRequired', true),
      (l10n.radiationMeteorPowerReward, 'PowerRewardOnDestroy', false),
    ];

    for (final (label, jsonKey, decimal) in parameters) {
      final wrapper = find.byWidgetPredicate(
        (widget) =>
            widget is EditorResponsiveInputField && widget.label == label,
      );
      final field = find.descendant(
        of: wrapper,
        matching: find.byType(TextField),
      );
      final state = await _startEditing(tester, field);
      await _sendValue(tester, field, state, '');
      await _sendValue(tester, field, state, '1');
      expect(module.objData[jsonKey], 1);
      await _sendValue(tester, field, state, '12');
      expect(module.objData[jsonKey], 12);
      if (decimal) {
        await _sendValue(tester, field, state, '12.');
        await _sendValue(tester, field, state, '12.5');
        expect(module.objData[jsonKey], 12.5);
      } else {
        await _sendValue(tester, field, state, '123');
        expect(module.objData[jsonKey], 123);
      }
    }
    for (final (_, jsonKey, decimal) in parameters) {
      expect(module.objData[jsonKey], decimal ? 12.5 : 123);
    }
    _expectFirstGroupWave(module, 3);
    expect(tester.takeException(), isNull);
  });
}
