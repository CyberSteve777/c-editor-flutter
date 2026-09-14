import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/seed_bank_properties_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _testApp(SeedBankPropertiesScreen screen) {
  return MaterialApp(
    locale: const Locale('zh'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: screen,
  );
}

SeedBankPropertiesScreen _screen(PvzLevelFile level) {
  return SeedBankPropertiesScreen(
    rtid: 'RTID(SeedBank@CurrentLevel)',
    levelFile: level,
    onChanged: () {},
    onBack: () {},
    onRequestPlantSelection:
        (
          _, {
          excludeIds,
          initialSelectedIds,
          blockRealmExclusiveInChooser = false,
          blockHiddenPlantsInChooser = false,
          allowDuplicateSelection = false,
        }) {},
    onRequestZombieSelection: (_) {},
  );
}

PvzLevelFile _level(SeedBankData data) {
  return PvzLevelFile(
    objects: [
      PvzObject(
        aliases: const ['SeedBank'],
        objClass: 'SeedBankProperties',
        objData: data.toJson(),
      ),
    ],
  );
}

void main() {
  final l10n = lookupAppLocalizations(const Locale('zh'));

  testWidgets('grid item controls are shown only in preset mode', (
    tester,
  ) async {
    final level = _level(SeedBankData(selectionMethod: 'chooser'));
    await tester.pumpWidget(_testApp(_screen(level)));
    await tester.pumpAndSettle();

    expect(find.text(l10n.seedBankAddGridItemsTitle), findsNothing);

    await tester.tap(find.text(l10n.preset));
    await tester.pumpAndSettle();

    expect(find.text(l10n.seedBankAddGridItemsTitle), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('switching an enabled grid item mode to chooser confirms first', (
    tester,
  ) async {
    final level = _level(
      SeedBankData(
        selectionMethod: 'preset',
        gridItemMode: true,
        presetPlantList: [kSeedBankGridItemIds.first],
      ),
    );
    await tester.pumpWidget(_testApp(_screen(level)));
    await tester.pumpAndSettle();

    expect(find.text(l10n.seedBankGridItemCount(1)), findsOneWidget);

    await tester.tap(find.text(l10n.chooser));
    await tester.pumpAndSettle();
    expect(
      find.text(l10n.seedBankGridItemsPresetOnlySwitchWarning),
      findsOneWidget,
    );

    await tester.tap(find.text(l10n.cancel));
    await tester.pumpAndSettle();
    var saved = SeedBankData.fromJson(
      Map<String, dynamic>.from(level.objects.single.objData as Map),
    );
    expect(saved.selectionMethod, 'preset');
    expect(saved.gridItemMode, isTrue);
    expect(saved.presetPlantList, [kSeedBankGridItemIds.first]);
    expect(find.text(l10n.seedBankAddGridItemsTitle), findsOneWidget);

    await tester.tap(find.text(l10n.chooser));
    await tester.pumpAndSettle();
    await tester.tap(find.text(l10n.continueAnyway));
    await tester.pumpAndSettle();

    saved = SeedBankData.fromJson(
      Map<String, dynamic>.from(level.objects.single.objData as Map),
    );
    expect(saved.selectionMethod, 'chooser');
    expect(saved.gridItemMode, isNot(true));
    expect(saved.presetPlantList, isEmpty);
    expect(find.text(l10n.seedBankAddGridItemsTitle), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
