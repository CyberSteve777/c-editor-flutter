import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugins/plugin_host_hooks.dart';
import 'package:c_editor/screens/level_overview/level_overview_dialog.dart';
import 'package:flutter/gestures.dart';
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

  for (final configuration in [
    (const Size(390, 844), 1.0),
    (const Size(390, 360), 2.0),
    (const Size(844, 320), 2.0),
    (const Size(1200, 900), 2.0),
  ]) {
    testWidgets('valid overview header scrolls at $configuration', (
      tester,
    ) async {
      final (size, scale) = configuration;
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final previous = PluginHostHooks.openPreviewImageGenerator;
      addTearDown(() => PluginHostHooks.openPreviewImageGenerator = previous);
      var generated = false;
      PluginHostHooks.openPreviewImageGenerator =
          (
            context, {
            required levelFile,
            required parsed,
            required fileName,
          }) async {
            generated = true;
          };
      final level = PvzLevelFile(
        objects: [
          PvzObject(
            aliases: const ['LevelDefinition'],
            objClass: 'LevelDefinition',
            objData: LevelDefinitionData(
              modules: ['RTID(SeedBank@CurrentLevel)'],
            ).toJson(),
          ),
          PvzObject(
            aliases: const ['SeedBank'],
            objClass: 'SeedBankProperties',
            objData: {'PresetPlantList': List.filled(40, 'peashooter')},
          ),
        ],
      );
      const fileName = 'A long mobile level filename for the overview.json';
      var closed = false;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          theme: ThemeData(
            platform: size.width >= 1200
                ? TargetPlatform.windows
                : TargetPlatform.iOS,
          ),
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(scale)),
            child: child!,
          ),
          home: LevelOverviewDialog(
            levelFile: level,
            parsed: LevelParser.parseLevel(level),
            fileName: fileName,
            filePath: 'overview.json',
            showOpenLevel: true,
            onClose: () => closed = true,
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final l10n = lookupAppLocalizations(const Locale('en'));
      final title = find.text('${l10n.levelOverview}: $fileName');
      final generate = find.text(l10n.previewGenerateImagePreview);
      final close = find.text(l10n.close);
      final scroll = find.byKey(const ValueKey('levelOverviewScroll'));
      final scrollbar = find.byKey(const ValueKey('levelOverviewScrollbar'));
      final controller = tester.widget<Scrollbar>(scrollbar).controller!;
      expect(title.hitTestable(at: Alignment.topLeft), findsOneWidget);
      expect(close.hitTestable(), findsOneWidget);
      expect(
        find.text(l10n.levelOverviewOpenLevel).hitTestable(),
        findsOneWidget,
      );
      final closeRect = tester.getRect(close);
      final viewport = tester.getRect(scroll);
      expect(viewport.height, greaterThan(0));
      expect(controller.position.maxScrollExtent, greaterThan(0));
      // Scrolling the details also frees the space occupied by the header.
      for (
        var attempt = 0;
        attempt < 12 &&
            (tester.getRect(title).bottom > viewport.top ||
                tester.getRect(generate).bottom > viewport.top);
        attempt++
      ) {
        await tester.dragFrom(
          Offset(viewport.left + 4, viewport.center.dy),
          Offset(0, -viewport.height * 0.75),
        );
        await tester.pumpAndSettle();
      }
      expect(
        tester.getRect(title).bottom,
        lessThanOrEqualTo(viewport.top),
        reason:
            'offset=${controller.offset}; max=${controller.position.maxScrollExtent}; viewport=$viewport; title=${tester.getRect(title)}',
      );
      expect(generate.hitTestable(), findsNothing);
      expect(tester.getRect(close), closeRect);
      expect(close.hitTestable(), findsOneWidget);
      // Drag the painted iOS thumb back to the top, rather than invoking a
      // controller callback, to verify the user's scroll-bar gesture.
      final paint = find
          .descendant(
            of: scrollbar,
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is CustomPaint &&
                  widget.foregroundPainter is ScrollbarPainter,
            ),
          )
          .first;
      final painter =
          tester.widget<CustomPaint>(paint).foregroundPainter!
              as ScrollbarPainter;
      final box = tester.renderObject<RenderBox>(paint);
      final thumb = <Offset>[];
      for (var y = 0.0; y < box.size.height; y++) {
        final point = Offset(box.size.width - 2, y);
        if (painter.hitTestOnlyThumbInteractive(
          point,
          PointerDeviceKind.touch,
        )) {
          thumb.add(point);
        }
      }
      expect(thumb, isNotEmpty);
      final gesture = await tester.createGesture(kind: PointerDeviceKind.touch);
      await gesture.down(box.localToGlobal(thumb[thumb.length ~/ 2]));
      await tester.pump(const Duration(milliseconds: 100));
      await gesture.moveTo(box.localToGlobal(const Offset(0, 2)));
      await tester.pump(const Duration(milliseconds: 200));
      await gesture.up();
      await tester.pumpAndSettle();
      expect(controller.offset, lessThan(1));
      expect(title.hitTestable(at: Alignment.topLeft), findsOneWidget);
      final scrollable = find
          .descendant(of: scroll, matching: find.byType(Scrollable))
          .first;
      await tester.scrollUntilVisible(generate, 50, scrollable: scrollable);
      await tester.tap(generate);
      await tester.pumpAndSettle();
      expect(generated, isTrue);
      await tester.tap(close);
      expect(closed, isTrue);
      expect(tester.takeException(), isNull);
    });
  }
}
