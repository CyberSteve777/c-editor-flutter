import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/pirate_plank_properties_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('pickup tutorial defaults to the mummy zombie', () {
    expect(PickupCollectableTutorialData().dropperZombieType, 'mummy');
    expect(
      PickupCollectableTutorialData.fromJson(
        const <String, dynamic>{},
      ).dropperZombieType,
      'mummy',
    );
  });

  testWidgets('pirate plank preview uses the available narrow-screen width', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(platform: TargetPlatform.windows),
        home: PiratePlankPropertiesScreen(
          rtid: 'RTID(PiratePlanks@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          levelDef: LevelDefinitionData(),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();

    final preview = find.byKey(const ValueKey('piratePlankPreviewGrid'));
    expect(preview, findsOneWidget);
    expect(tester.getSize(preview).width, greaterThan(300));
    expect(tester.takeException(), isNull);
  });
}
