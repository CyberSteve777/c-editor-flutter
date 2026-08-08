import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/separated_option_picker_field.dart';
import 'package:c_editor/widgets/zomboss_mech_action_fields.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(Widget child) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );
}

void main() {
  test('time fields use decimal input without treating SpawnTimes as time', () {
    const duration = ZombossMechFieldSpec(name: 'TossDuration', type: 'int');
    const count = ZombossMechFieldSpec(name: 'SpawnTimes', type: 'int');

    expect(ZombossMechActionUtils.usesDecimalInput(duration), isTrue);
    expect(ZombossMechActionUtils.usesSecondsUnit(duration), isTrue);
    expect(ZombossMechActionUtils.usesDecimalInput(count), isFalse);
    expect(ZombossMechActionUtils.usesSecondsUnit(count), isFalse);
  });

  testWidgets('object list cards show stable group numbers', (tester) async {
    final data = <String, dynamic>{
      'ZombieHordes': [
        {'Name': 'first'},
        {'Name': 'second'},
      ],
    };
    await tester.pumpWidget(
      _app(
        ZombossMechActionFieldsEditor(
          mechId: '',
          objclass: '',
          fields: const [
            ZombossMechFieldSpec(
              name: 'ZombieHordes',
              type: 'List<object>',
              objectFields: [
                ZombossMechFieldSpec(name: 'Name', type: 'string'),
              ],
            ),
          ],
          data: data,
          onChanged: () {},
        ),
      ),
    );

    expect(find.text('#1'), findsOneWidget);
    expect(find.text('#2'), findsOneWidget);
  });

  testWidgets('duration fields accept decimals and show seconds', (
    tester,
  ) async {
    final data = <String, dynamic>{'TossDuration': 2};
    await tester.pumpWidget(
      _app(
        ZombossMechActionFieldsEditor(
          mechId: '',
          objclass: '',
          fields: const [
            ZombossMechFieldSpec(name: 'TossDuration', type: 'int'),
          ],
          data: data,
          onChanged: () {},
        ),
      ),
    );

    expect(find.textContaining('unit: seconds'), findsOneWidget);
    await tester.enterText(find.byType(TextFormField), '2.5');
    expect(data['TossDuration'], 2.5);
  });

  testWidgets('option picker uses separated rows on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 640);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _app(
        SeparatedOptionPickerField<String>(
          labelText: 'Base Action',
          value: 'one',
          items: const [
            SeparatedOptionPickerItem(value: 'one', label: 'First phase'),
            SeparatedOptionPickerItem(value: 'two', label: 'Second phase'),
          ],
          onChanged: (_) {},
        ),
      ),
    );

    await tester.tap(find.text('First phase'));
    await tester.pumpAndSettle();
    expect(find.byType(Divider), findsAtLeastNWidgets(2));
    expect(find.text('Second phase'), findsOneWidget);
  });
}
