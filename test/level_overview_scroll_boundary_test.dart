import 'dart:math' as math;

import 'package:c_editor/data/level_parser.dart';
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

  for (final configuration in [
    (TargetPlatform.iOS, const Size(390, 844), 1.0),
    (TargetPlatform.iOS, const Size(390, 360), 2.0),
    (TargetPlatform.android, const Size(390, 844), 1.0),
  ]) {
    testWidgets('overview stays at the top after a drag $configuration', (
      tester,
    ) async {
      final (platform, size, scale) = configuration;
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = size;
      addTearDown(tester.view.reset);
      final level = PvzLevelFile(
        objects: [
          PvzObject(
            aliases: const ['LevelDefinition'],
            objClass: 'LevelDefinition',
            objData: LevelDefinitionData().toJson(),
          ),
          PvzObject(
            aliases: const ['SeedBank'],
            objClass: 'SeedBankProperties',
            objData: {'PresetPlantList': List.filled(40, 'peashooter')},
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(platform: platform),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: LevelOverviewDialog(
            levelFile: level,
            parsed: LevelParser.parseLevel(level),
            fileName: 'overview.json',
            onClose: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final scroll = find.byKey(const ValueKey('levelOverviewScroll'));
      final controller = tester
          .widget<Scrollbar>(
            find.byKey(const ValueKey('levelOverviewScrollbar')),
          )
          .controller!;
      final viewport = tester.getRect(scroll);
      final l10n = lookupAppLocalizations(const Locale('en'));
      final title = find.text('${l10n.levelOverview}: overview.json');
      final topTitleRect = tester.getRect(title);
      final closeRect = tester.getRect(find.text(l10n.close));
      final samples = <double>[];
      void recordOffset() => samples.add(controller.offset);
      controller.addListener(recordOffset);
      addTearDown(() => controller.removeListener(recordOffset));

      controller.jumpTo(math.min(120, controller.position.maxScrollExtent));
      await tester.pump();
      expect(controller.offset, greaterThan(0));
      final gesture = await tester.startGesture(
        Offset(viewport.center.dx, viewport.top + viewport.height * 0.2),
      );
      await gesture.moveBy(Offset(0, viewport.height * 0.7));
      await tester.pump(const Duration(milliseconds: 80));
      await gesture.moveBy(const Offset(0, 120));
      await tester.pump(const Duration(milliseconds: 80));
      expect(
        controller.offset,
        closeTo(controller.position.minScrollExtent, 0.01),
        reason: 'The header must remain at the top while the finger is held',
      );
      expect(tester.getRect(title), topTitleRect);
      await gesture.up();
      await tester.pumpAndSettle();
      expect(samples, isNotEmpty);
      expect(
        samples.every((offset) => offset >= 0),
        isTrue,
        reason: 'Top-edge dragging must not move the header into overscroll',
      );
      expect(controller.offset, closeTo(0, 0.01));
      expect(tester.getRect(title), topTitleRect);
      expect(title.hitTestable(at: Alignment.topLeft), findsOneWidget);
      expect(tester.getRect(find.text(l10n.close)), closeRect);
      // A fresh gesture must still scroll the content after reaching the top.
      await tester.drag(scroll, Offset(0, -viewport.height * 0.5));
      await tester.pumpAndSettle();
      expect(controller.offset, greaterThan(0));
      expect(tester.takeException(), isNull);
    });
  }
}
