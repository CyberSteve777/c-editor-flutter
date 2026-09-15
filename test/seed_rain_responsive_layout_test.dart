import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/seed_rain_properties_screen.dart';
import 'package:c_editor/screens/editor/modules/last_stand_minigame_screen.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

Widget localizedApp(Widget home, {String locale = 'en', double scale = 1.8}) {
  return MaterialApp(
    theme: darkTheme,
    locale: Locale(locale),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(
        context,
      ).copyWith(textScaler: TextScaler.linear(scale)),
      child: child!,
    ),
    home: home,
  );
}

void expectTextInside(WidgetTester tester, Finder text, Rect bounds) {
  final rect = tester.getRect(text);
  expect(rect.left, greaterThanOrEqualTo(bounds.left - .1));
  expect(rect.right, lessThanOrEqualTo(bounds.right + .1));
  expect(rect.top, greaterThanOrEqualTo(bounds.top - .1));
  expect(rect.bottom, lessThanOrEqualTo(bounds.bottom + .1));
  final paragraph = tester.renderObject<RenderParagraph>(text);
  expect(paragraph.didExceedMaxLines, isFalse);
}

void main() {
  for (final locale in ['en', 'zh', 'ru']) {
    testWidgets('seed rain wraps labels and add action in $locale', (
      tester,
    ) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(240, 1000);
      addTearDown(tester.view.reset);
      final l10n = await AppLocalizations.delegate.load(Locale(locale));
      final module = PvzObject(
        aliases: ['SeedRain'],
        objClass: 'SeedRainProperties',
        objData: SeedRainPropertiesData().toJson(),
      );
      await tester.pumpWidget(
        localizedApp(
          SeedRainPropertiesScreen(
            rtid: 'RTID(SeedRain@CurrentLevel)',
            levelFile: PvzLevelFile(objects: [module]),
            onChanged: () {},
            onBack: () {},
          ),
          locale: locale,
        ),
      );
      await tester.pumpAndSettle();

      final input = find.byKey(const ValueKey('seedRainInterval'));
      expect(tester.widget<TextField>(input).decoration?.labelText, isNull);
      final label = find.text(l10n.rainIntervalSeconds);
      expect(
        tester.getBottomLeft(label).dy,
        lessThan(tester.getTopLeft(input).dy),
      );
      expect(
        tester.renderObject<RenderParagraph>(label).didExceedMaxLines,
        isFalse,
      );

      final button = find.byKey(const ValueKey('seedRainAddItem'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      final buttonRect = tester.getRect(
        find.descendant(of: button, matching: find.byType(FilledButton)),
      );
      expectTextInside(
        tester,
        find.text(l10n.addDropItem),
        buttonRect.deflate(10),
      );
      expect(tester.takeException(), isNull);

      await tester.tap(button);
      await tester.pumpAndSettle();
      await tester.ensureVisible(
        find.byKey(const ValueKey('editorChoiceOption_collectable')),
      );
      await tester.tap(
        find.byKey(const ValueKey('editorChoiceOption_collectable')),
      );
      await tester.pumpAndSettle();
      expect(
        SeedRainPropertiesData.fromJson(
          Map<String, dynamic>.from(module.objData as Map),
        ).seedRains.single.seedRainType,
        2,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'seed rain preserves focused interval draft across label relocation',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(1000, 900);
      addTearDown(tester.view.reset);
      await tester.pumpWidget(
        localizedApp(
          SeedRainPropertiesScreen(
            rtid: 'RTID(SeedRain@CurrentLevel)',
            levelFile: PvzLevelFile(objects: []),
            onChanged: () {},
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      final input = find.byKey(const ValueKey('seedRainInterval'));
      await tester.enterText(input, '-');
      final editable = find.descendant(
        of: input,
        matching: find.byType(EditableText),
      );
      final original = tester.widget<EditableText>(editable);
      for (final width in [240.0, 1000.0]) {
        tester.view.physicalSize = Size(width, 900);
        await tester.pumpAndSettle();
        final current = tester.widget<EditableText>(editable);
        expect(current.controller, same(original.controller));
        expect(current.controller.text, '-');
        expect(current.focusNode, same(original.focusNode));
        expect(current.focusNode.hasFocus, isTrue);
        expect(
          tester.widget<TextField>(input).decoration?.labelText,
          width == 240 ? isNull : isNotNull,
        );
        expect(tester.takeException(), isNull);
      }
    },
  );

  testWidgets(
    'seed rain item dialog keeps fields reachable and saves on a short screen',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 800);
      addTearDown(tester.view.reset);
      final module = PvzObject(
        aliases: ['SeedRain'],
        objClass: 'SeedRainProperties',
        objData: SeedRainPropertiesData(
          seedRains: [SeedRainItem(seedRainType: 2)],
        ).toJson(),
      );
      await tester.pumpWidget(
        localizedApp(
          SeedRainPropertiesScreen(
            rtid: 'RTID(SeedRain@CurrentLevel)',
            levelFile: PvzLevelFile(objects: [module]),
            onChanged: () {},
            onBack: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Plant Food'));
      await tester.tap(find.text('Plant Food'));
      await tester.pumpAndSettle();
      tester.view.physicalSize = const Size(320, 420);
      await tester.pumpAndSettle();
      final fields = find.descendant(
        of: find.byType(AlertDialog),
        matching: find.byType(TextFormField),
      );
      for (var i = 0; i < 2; i++) {
        await tester.ensureVisible(fields.at(i));
        await tester.enterText(fields.at(i), i == 0 ? '30' : '4');
      }
      await tester.ensureVisible(find.text('Save'));
      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle();
      final item = SeedRainPropertiesData.fromJson(
        Map<String, dynamic>.from(module.objData as Map),
      ).seedRains.single;
      expect(item.weight, 30);
      expect(item.maxCount, 4);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('last stand uses full external labels on narrow screens', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(240, 1000);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      localizedApp(
        LastStandMinigameScreen(
          rtid: 'RTID(LastStand@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    for (final field in tester.widgetList<TextField>(find.byType(TextField))) {
      expect(field.decoration?.labelText, isNull);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('add buttons wrap within their actual allocation', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(600, 800);
    addTearDown(tester.view.reset);
    for (final width in [160.0, 400.0]) {
      await tester.pumpWidget(
        localizedApp(
          Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: width,
                child: Column(
                  children: [
                    EditorFilledButton(
                      onPressed: () {},
                      icon: const Icon(Icons.add),
                      label: const Text('Add drop item'),
                    ),
                    PvzAddButton(
                      onPressed: () {},
                      label: 'Add a long localized item name',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final buttonRect = tester.getRect(find.byType(FilledButton));
      expectTextInside(
        tester,
        find.text('Add drop item'),
        buttonRect.deflate(10),
      );
      final icon = tester.getRect(
        find.descendant(
          of: find.byType(EditorFilledButton),
          matching: find.byIcon(Icons.add),
        ),
      );
      final text = tester.getRect(find.text('Add drop item'));
      if (width == 160) {
        expect(icon.bottom, lessThan(text.top));
      } else {
        expect(icon.center.dy, closeTo(text.center.dy, 1));
      }
      expect(tester.takeException(), isNull);
    }
  });
}
