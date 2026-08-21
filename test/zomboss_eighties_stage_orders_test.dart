import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/others/custom_zomboss_mech_properties_screen.dart';
import 'package:c_editor/screens/editor/others/zomboss_mech_properties_view_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _localizedApp(Widget home) {
  return MaterialApp(
    locale: const Locale('zh'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

Map<String, dynamic> _props(
  PvzLevelFile level,
  ZombossMechCatalogEntry catalog,
) {
  final object = level.objects.singleWhere(
    (entry) =>
        entry.aliases?.contains(catalog.editableInstancePropsName) == true,
  );
  return Map<String, dynamic>.from(object.objData as Map);
}

List<dynamic> _list(Map<String, dynamic> props, String key) =>
    List<dynamic>.from(props[key] as List);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ZombiePropertiesRepository.init();
    ZombossMechRepository.resetForTest();
    await ZombossMechRepository.init();
  });

  testWidgets(
    'Eighties phase orders are localized and independently sortable',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 1400);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final catalog = ZombossMechRepository.getCatalog(
        'ZombieZombossMech_Eighties',
      )!;
      final level = PvzLevelFile(objects: []);
      await tester.pumpWidget(
        _localizedApp(
          CustomZombossMechPropertiesScreen(
            catalog: catalog,
            levelFile: level,
            onChanged: () {},
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      final jamCard = find.byKey(const ValueKey('stageJamOrderCard'));
      final animationCard = find.byKey(const ValueKey('zombossAnimOrderCard'));
      expect(jamCard, findsOneWidget);
      expect(animationCard, findsOneWidget);
      expect(find.text('音乐播放顺序 (StageJamOrder)'), findsOneWidget);
      expect(find.text('僵王动画顺序 (ZombossAnimOrder)'), findsOneWidget);
      expect(find.text('朋克 (Punk)'), findsNWidgets(2));
      expect(find.text('新浪潮 (New Wave)'), findsOneWidget);
      expect(find.text('jam_punk'), findsOneWidget);
      expect(find.text('idle_newwave'), findsOneWidget);

      var props = _props(level, catalog);
      expect(_list(props, 'Stages'), hasLength(5));
      expect(_list(props, 'StageJamOrder'), [
        'jam_punk',
        'jam_pop',
        'jam_rap',
        'jam_8bit',
        'jam_metal',
      ]);
      expect(_list(props, 'ZombossAnimOrder'), [
        'idle_punk',
        'idle_newwave',
        'idle_hiphop',
        'idle_8bit',
        'idle_metal',
      ]);

      final jamOrder = tester.widget<ReorderableListView>(
        find.descendant(
          of: jamCard,
          matching: find.byType(ReorderableListView),
        ),
      );
      expect(jamOrder.dragBoundaryProvider, isNotNull);
      expect(
        find.descendant(of: jamCard, matching: find.byType(DragBoundary)),
        findsOneWidget,
      );
      jamOrder.onReorderItem!(0, 4);
      await tester.pump();

      props = _props(level, catalog);
      expect(_list(props, 'StageJamOrder'), [
        'jam_pop',
        'jam_rap',
        'jam_8bit',
        'jam_metal',
        'jam_punk',
      ]);
      expect(_list(props, 'ZombossAnimOrder').first, 'idle_punk');
    },
  );

  testWidgets(
    'adding and deleting an Eighties phase keeps all orders aligned',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(800, 1400);
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final catalog = ZombossMechRepository.getCatalog(
        'ZombieZombossMech_Eighties',
      )!;
      final level = PvzLevelFile(objects: []);
      await tester.pumpWidget(
        _localizedApp(
          CustomZombossMechPropertiesScreen(
            catalog: catalog,
            levelFile: level,
            onChanged: () {},
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('添加阶段'));
      await tester.pumpAndSettle();

      expect(find.text('选择新阶段的音乐与僵王动画'), findsOneWidget);
      expect(
        tester.widget<AlertDialog>(find.byType(AlertDialog)).scrollable,
        isTrue,
      );
      FilledButton createButton() => tester.widget<FilledButton>(
        find.byKey(const ValueKey('confirmAddEightiesPhase')),
      );
      expect(createButton().onPressed, isNull);

      await tester.tap(find.byKey(const ValueKey('eightiesPhaseJamDropdown')));
      await tester.pumpAndSettle();
      await tester.tap(find.text('流行 (Pop) · jam_pop').last);
      await tester.pumpAndSettle();
      expect(createButton().onPressed, isNull);

      await tester.tap(
        find.byKey(const ValueKey('eightiesPhaseAnimationDropdown')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('嘻哈 (Hip-Hop) · idle_hiphop').last);
      await tester.pumpAndSettle();
      expect(createButton().onPressed, isNotNull);
      await tester.tap(find.byKey(const ValueKey('confirmAddEightiesPhase')));
      await tester.pumpAndSettle();

      var props = _props(level, catalog);
      expect(_list(props, 'Stages'), hasLength(6));
      expect(_list(props, 'StageJamOrder'), hasLength(6));
      expect(_list(props, 'ZombossAnimOrder'), hasLength(6));
      expect(_list(props, 'StageJamOrder').last, 'jam_pop');
      expect(_list(props, 'ZombossAnimOrder').last, 'idle_hiphop');

      final phaseSix = find.text('第 6 阶段');
      await tester.scrollUntilVisible(
        phaseSix,
        800,
        scrollable: find
            .descendant(
              of: find.byType(ListView).first,
              matching: find.byType(Scrollable),
            )
            .first,
      );
      final phaseCard = find.ancestor(
        of: phaseSix,
        matching: find.byType(Card),
      );
      final deleteButton = find.descendant(
        of: phaseCard,
        matching: find.byTooltip('删除阶段'),
      );
      await tester.tap(deleteButton);
      await tester.pumpAndSettle();

      expect(find.textContaining('对应的音乐和僵王动画'), findsOneWidget);
      expect(
        tester.widget<AlertDialog>(find.byType(AlertDialog)).scrollable,
        isTrue,
      );
      await tester.tap(find.widgetWithText(TextButton, '删除'));
      await tester.pumpAndSettle();

      props = _props(level, catalog);
      expect(_list(props, 'Stages'), hasLength(5));
      expect(_list(props, 'StageJamOrder'), hasLength(5));
      expect(_list(props, 'ZombossAnimOrder'), hasLength(5));
      expect(_list(props, 'StageJamOrder').last, 'jam_metal');
      expect(_list(props, 'ZombossAnimOrder').last, 'idle_metal');
    },
  );

  testWidgets('non-custom Eighties variants expose both phase orders', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 1400);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPhysicalSize);

    final catalog = ZombossMechRepository.getCatalog(
      'ZombieZombossMech_Eighties',
    )!;
    final mechType = catalog.variations.firstWhere((variation) {
      final data = ZombossMechRepository.propertiesDataForVariation(
        variation,
        catalog: catalog,
      );
      return data?['StageJamOrder'] is List &&
          data?['ZombossAnimOrder'] is List;
    });

    await tester.pumpWidget(
      _localizedApp(
        ZombossMechPropertiesViewScreen(
          catalog: catalog,
          levelFile: PvzLevelFile(objects: []),
          mechType: mechType,
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey('readOnlyStageJamOrderCard')),
      findsOneWidget,
    );
    expect(
      find.byKey(const ValueKey('readOnlyZombossAnimOrderCard')),
      findsOneWidget,
    );
    expect(find.text('音乐播放顺序 (StageJamOrder)'), findsOneWidget);
    expect(find.text('僵王动画顺序 (ZombossAnimOrder)'), findsOneWidget);
    expect(find.text('jam_punk'), findsOneWidget);
    expect(find.text('idle_punk'), findsOneWidget);
  });
}
