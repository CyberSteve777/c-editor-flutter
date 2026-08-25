import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/stage_catalog_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/others/custom_stage_properties_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() async {
    await ResourceNames.ensureLoaded();
    await StageCatalogRepository.init();
  });

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

  testWidgets('Moon custom stage exposes the cosmic Plant Food interval', (
    tester,
  ) async {
    final stage = PvzObject(
      aliases: const ['CustomMoonStage'],
      objClass: 'MoonStageProperties',
      objData: {
        'CosmicPlantfoodFillSeconds': 40.0,
        'MusicSuffix': 'Moon',
        'ResourceGroupNames': <String>[],
        'GroupsToUnloadForAds': <String>[],
        'DisabledStreetCells': <Map<String, dynamic>>[],
      },
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: CustomStagePropertiesScreen(
          alias: 'CustomMoonStage',
          levelFile: PvzLevelFile(objects: [stage]),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    final intervalField = find.byKey(
      const ValueKey('cosmicPlantfoodFillSecondsField'),
    );
    expect(intervalField, findsOneWidget);
    await tester.ensureVisible(intervalField);
    await tester.enterText(intervalField, '25.5');
    await tester.pump();

    expect(
      (stage.objData as Map<String, dynamic>)[
        'CosmicPlantfoodFillSeconds'
      ],
      25.5,
    );
  });
}
