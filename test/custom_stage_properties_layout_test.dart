import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/others/custom_stage_properties_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(ResourceNames.ensureLoaded);

  testWidgets('custom stage bounded text stays inside a narrow large UI', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final stage = PvzObject(
      aliases: const ['CustomStage'],
      objClass: 'ModernStageProperties',
      objData: {
        'AmbientAudioSuffix': CustomStageLevelUtils.ambientAudioOptions.first,
        'MusicSuffix': 'egypt',
        'ResourceGroupNames': <String>[],
        'GroupsToUnloadForAds': <String>[],
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: CustomStagePropertiesScreen(
          alias: 'CustomStage',
          levelFile: PvzLevelFile(objects: [stage]),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    final ambientText = tester.widgetList<Text>(
      find.text('Tutorial & Modern Day Ambient Sound'),
    );
    expect(ambientText, isNotEmpty);
    expect(
      ambientText.every((text) => text.overflow == TextOverflow.ellipsis),
      isTrue,
    );
  });
}
