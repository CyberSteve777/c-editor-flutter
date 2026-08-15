import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/renai_module_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Renaissance wave hints wrap fully on narrow screens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(345, 1300);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: const ['RenaiModule'],
          objClass: 'RenaiModuleProperties',
          objData: RenaiModulePropertiesData(
            nightEnabled: true,
            statueInfos: [
              RenaiStatueInfoData(
                typeName: 'renai_statue_zombie1',
                waveNumber: 0,
              ),
            ],
          ).toJson(),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: RenaiModuleScreen(
          rtid: 'RTID(RenaiModule@CurrentLevel)',
          levelFile: level,
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    for (final key in const [
      ValueKey('renaiNightStartWaveField'),
      ValueKey('renaiStatueWaveField'),
    ]) {
      final field = tester.widget<TextField>(find.byKey(key));
      expect(field.decoration?.helperMaxLines, 5);
    }

    final hints = find.text('0 = Wave 1, 1 = Wave 2, ...');
    expect(hints, findsNWidgets(2));
    for (final hint in hints.evaluate()) {
      final paragraph = hint.renderObject as RenderParagraph;
      expect(paragraph.didExceedMaxLines, isFalse);
    }

    final nameBottom = tester.getBottomLeft(
      find.byKey(const ValueKey('renaiStatueItemName')),
    ).dy;
    final fieldTop = tester.getTopLeft(
      find.byKey(const ValueKey('renaiStatueWaveField')),
    ).dy;
    expect(fieldTop - nameBottom, greaterThanOrEqualTo(12));
    expect(tester.takeException(), isNull);
  });
}
