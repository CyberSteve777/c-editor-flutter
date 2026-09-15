import 'dart:convert';

import 'package:c_editor/data/asset_loader.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([ResourceNames.ensureLoaded(), PlantRepository().init()]);
  });

  test(
    'Tier4 data maps to the Other category filter in the requested order',
    () async {
      final rawPlants =
          json.decode(await loadJsonString('assets/resources/Plants.json'))
              as List<dynamic>;
      final expectedIds = rawPlants
          .where(
            (item) =>
                ((item as Map<String, dynamic>)['tags'] as List<dynamic>?)
                    ?.contains('Tier4') ??
                false,
          )
          .map((item) => (item as Map<String, dynamic>)['id'] as String)
          .toSet();
      final filteredIds = PlantRepository()
          .search('', PlantTag.tier4, PlantCategory.other)
          .map((plant) => plant.id)
          .toSet();

      expect(expectedIds, isNotEmpty);
      expect(filteredIds, expectedIds);

      final otherTags = PlantTag.values
          .where((tag) => tag.category == PlantCategory.other)
          .toList();
      final hiddenIndex = otherTags.indexOf(PlantTag.hidden);
      expect(otherTags.sublist(hiddenIndex, hiddenIndex + 3), [
        PlantTag.hidden,
        PlantTag.tier4,
        PlantTag.chinese,
      ]);
    },
  );

  testWidgets('Other displays Level 4 Village between Hidden and China Only', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: PlantSelectionScreen(
          stateBucketId: 'tier4-category-test',
          onPlantSelected: (_) {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();

    final tagRow = tester.widget<AccentBarFilterTabRow>(
      find.byKey(const ValueKey('other_tags')),
    );
    final labels = tagRow.tabs.map((tab) {
      final row = tab as Row;
      return row.children.whereType<Text>().single.data;
    }).toList();

    expect(
      labels,
      containsAllInOrder(['Hidden Plants', 'Level 4 Village', 'China Only']),
    );
  });
}
