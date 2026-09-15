import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/portal_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/others/custom_portal_properties_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PvzLevelFile _levelWithInterval() => PvzLevelFile(
  objects: [
    PvzObject(
      aliases: ['GridItemZombiePortalMemo'],
      objClass: 'GridItemZombiePortalProps',
      objData: {
        ...PortalRepository.blankPropertiesData(),
        'TimeBetweenSpawns': {'Min': 1.0, 'Max': 2.0},
      },
    ),
  ],
);

Future<void> _pumpEditor(
  WidgetTester tester,
  PvzLevelFile level, {
  required double width,
  required double textScale,
}) async {
  tester.view.physicalSize = Size(width, 1800);
  tester.view.devicePixelRatio = 1;
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: MediaQuery(
        data: MediaQueryData(
          size: Size(width, 1800),
          textScaler: TextScaler.linear(textScale),
        ),
        child: CustomPortalPropertiesScreen(
          levelFile: level,
          existingPortalType: 'memo',
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _propertyField(String code) => find.byWidgetPredicate(
  (widget) =>
      widget is EditorResponsiveInputField && widget.label.endsWith(' ($code)'),
);

Finder _decorator(String code) => find.descendant(
  of: _propertyField(code),
  matching: find.byType(InputDecorator),
);

const _propertyCodes = ['World', 'PopAnim', 'ZombieSpawnMethod', 'Min', 'Max'];

void main() {
  testWidgets('one wrapped portal label moves every input label above', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpEditor(tester, _levelWithInterval(), width: 360, textScale: 2);

    for (final code in _propertyCodes) {
      expect(_propertyField(code), findsOneWidget);
      final decorator = tester.widget<InputDecorator>(_decorator(code));
      expect(decorator.decoration.labelText, isNull, reason: code);
      final label = tester
          .widget<EditorResponsiveInputField>(_propertyField(code))
          .label;
      final externalLabel = find.descendant(
        of: _propertyField(code),
        matching: find.text(label),
      );
      expect(externalLabel, findsOneWidget);
      expect(
        tester.getRect(externalLabel).bottom,
        lessThan(tester.getRect(_decorator(code)).top),
        reason: code,
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('portal labels remain inline when the full form fits', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpEditor(tester, _levelWithInterval(), width: 1280, textScale: 1);

    for (final code in _propertyCodes) {
      expect(_propertyField(code), findsOneWidget);
      final field = tester.widget<EditorResponsiveInputField>(
        _propertyField(code),
      );
      expect(
        tester.widget<InputDecorator>(_decorator(code)).decoration.labelText,
        field.label,
        reason: code,
      );
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'portal label layout recovers after resize without losing edits',
    (tester) async {
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final level = _levelWithInterval();
      await _pumpEditor(tester, level, width: 360, textScale: 2);
      final minimumInput = find.descendant(
        of: _propertyField('Min'),
        matching: find.byType(TextField),
      );
      await tester.enterText(minimumInput, '12.5');
      await tester.pump();
      await _pumpEditor(tester, level, width: 1280, textScale: 1);

      for (final code in _propertyCodes) {
        expect(
          tester.widget<InputDecorator>(_decorator(code)).decoration.labelText,
          isNotNull,
          reason: code,
        );
      }
      final input = tester.widget<TextField>(minimumInput);
      expect(input.controller?.text, '12.5');
      expect(tester.takeException(), isNull);
    },
  );
}
