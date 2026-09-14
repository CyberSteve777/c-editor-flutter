import 'dart:convert';

import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/minigame_imitater_properties_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/magic_hat_spawn_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> sunHatWhitelist;
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      PlantRepository().init(),
      MinigameImitaterPropertiesRepository.init(),
      ResourceNames.ensureLoaded(),
    ]);
    final propertySheets =
        jsonDecode(
              await rootBundle.loadString(
                'assets/reference/PropertySheets.json',
              ),
            )
            as Map<String, dynamic>;
    final sunHatProperty = (propertySheets['objects'] as List)
        .cast<Map>()
        .firstWhere(
          (obj) =>
              (obj['aliases'] as List?)?.contains(
                'MinigameImitaterSunDefault',
              ) ==
              true,
        );
    sunHatWhitelist =
        ((sunHatProperty['objdata'] as Map)['SpawnPlantWhiteList'] as List)
            .cast<String>();
  });

  testWidgets(
    'magic hat display follows its property list across locales and filtering',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 1000);
      addTearDown(tester.view.reset);

      Future<void> showHat(String locale, {PvzLevelFile? level}) async {
        await tester.pumpWidget(
          MaterialApp(
            locale: Locale(locale),
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: MagicHatSpawnPreviewScreen(
              key: ValueKey(locale),
              hatPlantId: 'minigame_imitater_sun',
              levelFile: level,
              onBack: () {},
            ),
          ),
        );
        await tester.pumpAndSettle();
      }

      List<String> displayedPlantIds() => tester
          .widgetList<ListTile>(find.byType(ListTile))
          .map((tile) => (tile.subtitle! as Text).data!)
          .toList();

      for (final locale in const ['en', 'zh', 'ru']) {
        await showHat(locale);
        expect(displayedPlantIds(), sunHatWhitelist, reason: locale);
        final firstPlant = PlantRepository().getPlantInfoById(
          sunHatWhitelist.first,
        )!;
        final firstTile = tester.widget<ListTile>(find.byType(ListTile).first);
        expect(
          (firstTile.title! as Text).data,
          ResourceNames.lookupWithLocale(locale, firstPlant.name),
        );
        expect(tester.takeException(), isNull);
      }

      await showHat(
        'en',
        level: PvzLevelFile(
          objects: [
            PvzObject(
              objClass: 'PVZ1CopycatsModuleProperties',
              objData: PVZ1CopycatsModulePropertiesData(
                plantBlackList: [
                  ' ${sunHatWhitelist.first.toUpperCase()} ',
                  sunHatWhitelist[2],
                ],
              ).toJson(),
            ),
          ],
        ),
      );
      expect(displayedPlantIds(), [
        for (var i = 0; i < sunHatWhitelist.length; i++)
          if (i != 0 && i != 2) sunHatWhitelist[i],
      ]);
      expect(tester.takeException(), isNull);
    },
  );
}
