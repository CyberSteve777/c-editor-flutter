import 'package:c_editor/data/repository/zombie_title_catalog_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/zombie_ztalemate_perks_editor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpPerks(
  WidgetTester tester, {
  required Size size,
  required List<String> titles,
  required ValueChanged<List<String>> onChanged,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context).copyWith(textScaler: TextScaler.linear(2)),
        child: child!,
      ),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: ZombieZtalematePerksEditor(
              titles: titles,
              onChanged: onChanged,
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _option(String alias) => find.byKey(ValueKey('zombiePerkOption_$alias'));

Finder _choiceScrollable() => find.descendant(
  of: find.byType(ListView),
  matching: find.byType(Scrollable),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await ZombieTitleCatalogRepository.init();
    await ResourceNames.ensureLoaded();
  });

  for (final size in [const Size(240, 700), const Size(900, 240)]) {
    testWidgets('perk names and final choice remain usable at $size', (
      tester,
    ) async {
      var selected = <String>[];
      await _pumpPerks(
        tester,
        size: size,
        titles: selected,
        onChanged: (value) => selected = value,
      );
      final editorContext = tester.element(
        find.byType(ZombieZtalematePerksEditor),
      );
      final strings = AppLocalizations.of(editorContext)!;
      await tester.ensureVisible(find.text(strings.ztPerksAdd));
      await tester.tap(find.text(strings.ztPerksAdd));
      await tester.pumpAndSettle();
      expect(_choiceScrollable(), findsOneWidget);
      final listRect = tester.getRect(find.byType(ListView));
      expect(listRect.top, greaterThanOrEqualTo(0));
      expect(listRect.bottom, lessThanOrEqualTo(size.height));
      expect(listRect.width, lessThanOrEqualTo(size.width - 32));

      final last = ZombieTitleCatalogRepository.getAll().last;
      await tester.scrollUntilVisible(
        _option(last.alias),
        180,
        scrollable: _choiceScrollable(),
      );
      await tester.pumpAndSettle();
      final tile = tester.widget<EditorOptionTile>(_option(last.alias));
      final title = tile.title as Text;
      expect(title.data, ResourceNames.lookup(editorContext, last.nameKey));
      expect(title.maxLines, isNull);
      expect(title.overflow, isNot(TextOverflow.ellipsis));
      final titleFinder = find.descendant(
        of: _option(last.alias),
        matching: find.text(title.data!),
      );
      if (size.width < 400) {
        expect(
          tester.getSize(titleFinder).width,
          greaterThan(tester.getSize(_option(last.alias)).width * 0.8),
        );
        final image = find.descendant(
          of: _option(last.alias),
          matching: find.byType(AssetImageWidget),
        );
        expect(
          tester.getRect(image).bottom,
          lessThan(tester.getRect(titleFinder).top),
        );
      }
      expect(tester.takeException(), isNull);
      await tester.tap(titleFinder);
      await tester.pumpAndSettle();
      expect(selected, [last.alias]);
      expect(find.byType(ListView), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('perk selection keeps same-type blocking and stats actions', (
    tester,
  ) async {
    var selected = ['ZTShield1'];
    var changed = 0;
    await _pumpPerks(
      tester,
      size: const Size(900, 260),
      titles: selected,
      onChanged: (value) {
        selected = value;
        changed++;
      },
    );
    final strings = AppLocalizations.of(
      tester.element(find.byType(ZombieZtalematePerksEditor)),
    )!;
    await tester.ensureVisible(find.text(strings.ztPerksAdd));
    await tester.tap(find.text(strings.ztPerksAdd));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      _option('ZTShield2'),
      160,
      scrollable: _choiceScrollable(),
    );
    await tester.pumpAndSettle();
    final blocked = tester.widget<EditorOptionTile>(_option('ZTShield2'));
    expect(blocked.enabled, false);
    await tester.tap(_option('ZTShield2'));
    await tester.pumpAndSettle();
    expect(selected, ['ZTShield1']);
    expect(changed, 0);
    final statsAction = find.descendant(
      of: _option('ZTShield2'),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is IconButton && widget.tooltip == strings.ztPerksViewStats,
      ),
    );
    expect(tester.widget<IconButton>(statsAction).onPressed, isNotNull);
    await tester.tap(statsAction);
    await tester.pumpAndSettle();
    expect(
      find.textContaining('${strings.ztPerkPropShieldNum}:'),
      findsOneWidget,
    );
    final statsScroll = find.byKey(
      const ValueKey('zombiePerkStatsScroll_ZTShield2'),
    );
    final lastProperty = find
        .descendant(of: statsScroll, matching: find.byType(Text))
        .last;
    await Scrollable.ensureVisible(tester.element(lastProperty), alignment: 1);
    await tester.pumpAndSettle();
    expect(
      tester.getRect(lastProperty).bottom,
      lessThanOrEqualTo(tester.getRect(statsScroll).bottom),
    );
    expect(changed, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'perk category descriptions scroll to their last hint in landscape',
    (tester) async {
      var changed = 0;
      await _pumpPerks(
        tester,
        size: const Size(900, 260),
        titles: const [],
        onChanged: (_) => changed++,
      );
      final strings = AppLocalizations.of(
        tester.element(find.byType(ZombieZtalematePerksEditor)),
      )!;
      await tester.ensureVisible(find.text(strings.ztPerksAdd));
      await tester.tap(find.text(strings.ztPerksAdd));
      await tester.pumpAndSettle();
      final category = find.byWidgetPredicate(
        (widget) =>
            widget is EditorOptionTile &&
            widget.title is Text &&
            (widget.title as Text).data == strings.ztPerkCategoryCrystal,
      );
      await tester.scrollUntilVisible(
        category,
        160,
        scrollable: _choiceScrollable(),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(of: category, matching: find.byType(IconButton)),
      );
      await tester.pumpAndSettle();
      final categoryScroll = find.byKey(
        const ValueKey('zombiePerkCategoryScroll_zombie_title_crystal'),
      );
      expect(categoryScroll, findsOneWidget);
      final scrollState = tester.state<ScrollableState>(
        find.descendant(of: categoryScroll, matching: find.byType(Scrollable)),
      );
      expect(scrollState.position.maxScrollExtent, greaterThan(0));
      final lastHint = find.descendant(
        of: categoryScroll,
        matching: find.text(strings.ztPerkCategoryDescNumericHint),
      );
      await tester.drag(categoryScroll, const Offset(0, -180));
      await tester.pumpAndSettle();
      expect(scrollState.position.pixels, greaterThan(0));
      await Scrollable.ensureVisible(tester.element(lastHint), alignment: 1);
      await tester.pumpAndSettle();
      expect(
        tester.getRect(lastHint).bottom,
        lessThanOrEqualTo(tester.getRect(categoryScroll).bottom),
      );
      expect(changed, 0);
      expect(tester.takeException(), isNull);
    },
  );
}
