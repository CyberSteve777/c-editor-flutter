import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/level_overview/level_overview_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ReferenceRepository.init(),
      PlantRepository().init(),
      ZombieRepository().init(),
      GridItemRepository.init(),
      StageRepository.init(),
      ZombossMechRepository.ensureLoaded(),
      ZombossBattleRepository.init(),
    ]);
  });

  for (final height in [240.0, 180.0]) {
    testWidgets('invalid overview scrolls a long filename at height $height', (
      tester,
    ) async {
      await tester.binding.setSurfaceSize(Size(640, height));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final fileName =
          '${List.filled(8, 'A long localized level filename').join(' ')}.json';
      var closed = false;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: const TextScaler.linear(2)),
            child: child!,
          ),
          home: LevelOverviewDialog(
            levelFile: PvzLevelFile(objects: []),
            parsed: ParsedLevelData(objectMap: {}),
            fileName: fileName,
            onClose: () => closed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(
        tester.widget<AlertDialog>(find.byType(AlertDialog)).scrollable,
        isTrue,
      );
      expect(tester.getSize(find.text(fileName)).width, lessThan(640));
      final message = find.text(
        lookupAppLocalizations(const Locale('en')).noLevelDefinitionHint,
      );
      await tester.scrollUntilVisible(
        message,
        80,
        scrollable: find.byType(Scrollable),
      );
      final close = find.text(lookupAppLocalizations(const Locale('en')).close);
      expect(tester.getRect(close).bottom, lessThanOrEqualTo(height));
      await tester.tap(close);
      expect(closed, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
