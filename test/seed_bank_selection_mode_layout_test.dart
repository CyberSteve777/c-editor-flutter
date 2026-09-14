import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/seed_bank_properties_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

const _chooserKey = ValueKey('seedBankChooserModeChip');
const _presetKey = ValueKey('seedBankPresetModeChip');

PvzLevelFile _level({bool zombieMode = false}) => PvzLevelFile(
  objects: [
    PvzObject(
      aliases: const ['SeedBank'],
      objClass: 'SeedBankProperties',
      objData: SeedBankData(
        selectionMethod: zombieMode ? 'preset' : 'chooser',
        zombieMode: zombieMode,
      ).toJson(),
    ),
  ],
);

Widget _app(
  PvzLevelFile level, {
  required String locale,
  required double textScale,
  required VoidCallback onChanged,
}) => MaterialApp(
  locale: Locale(locale),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  theme: ThemeData(platform: TargetPlatform.iOS),
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: SeedBankPropertiesScreen(
    rtid: 'RTID(SeedBank@CurrentLevel)',
    levelFile: level,
    onChanged: onChanged,
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
  ),
);

SeedBankData _saved(PvzLevelFile level) => SeedBankData.fromJson(
  Map<String, dynamic>.from(level.objects.single.objData as Map),
);

void _expectCompleteLabels(
  WidgetTester tester,
  AppLocalizations l10n,
  double windowWidth, {
  bool expectWrapping = false,
}) {
  for (final (key, label) in [
    (_chooserKey, l10n.chooser),
    (_presetKey, l10n.preset),
  ]) {
    final chip = find.byKey(key);
    final text = find.descendant(of: chip, matching: find.text(label));
    expect(text, findsOneWidget);
    final paragraph = tester.renderObject<RenderParagraph>(text);
    expect(
      paragraph.didExceedMaxLines,
      isFalse,
      reason: 'The complete selection mode must be visible: $label',
    );
    final chipRect = tester.getRect(chip);
    final labelRect = tester.getRect(text);
    expect(chipRect.left, greaterThanOrEqualTo(0));
    expect(chipRect.right, lessThanOrEqualTo(windowWidth));
    expect(labelRect.left, greaterThanOrEqualTo(chipRect.left));
    expect(labelRect.right, lessThanOrEqualTo(chipRect.right));
    expect(labelRect.top, greaterThanOrEqualTo(chipRect.top));
    expect(labelRect.bottom, lessThanOrEqualTo(chipRect.bottom));
    if (expectWrapping) {
      final lines = paragraph
          .getBoxesForSelection(
            TextSelection(baseOffset: 0, extentOffset: label.length),
          )
          .map((box) => box.top)
          .toSet();
      expect(
        lines.length,
        greaterThan(1),
        reason: '$label must use multiple lines.',
      );
    }
  }
}

Future<void> _tapMode(WidgetTester tester, Key key) async {
  final chip = find.byKey(key);
  await tester.ensureVisible(chip);
  await tester.pumpAndSettle();
  await tester.tap(chip);
  await tester.pumpAndSettle();
}

void main() {
  for (final locale in ['en', 'zh', 'ru']) {
    for (final textScale in [1.0, 2.0]) {
      testWidgets('$locale seed bank modes show full labels and save selection '
          'at 320px with text scale $textScale', (tester) async {
        tester.view.physicalSize = const Size(320, 720);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        final level = _level();
        var writes = 0;
        await tester.pumpWidget(
          _app(
            level,
            locale: locale,
            textScale: textScale,
            onChanged: () => writes++,
          ),
        );
        await tester.pumpAndSettle();
        final l10n = lookupAppLocalizations(Locale(locale));
        _expectCompleteLabels(
          tester,
          l10n,
          320,
          expectWrapping: locale == 'en' && textScale > 1,
        );
        expect(
          tester.widget<FilterChip>(find.byKey(_chooserKey)).selected,
          isTrue,
        );
        expect(
          tester.widget<FilterChip>(find.byKey(_presetKey)).selected,
          isFalse,
        );

        await _tapMode(tester, _presetKey);
        expect(_saved(level).selectionMethod, 'preset');
        expect(writes, 1);
        expect(
          tester.widget<FilterChip>(find.byKey(_chooserKey)).selected,
          isFalse,
        );
        expect(
          tester.widget<FilterChip>(find.byKey(_presetKey)).selected,
          isTrue,
        );
        _expectCompleteLabels(
          tester,
          l10n,
          320,
          expectWrapping: locale == 'en' && textScale > 1,
        );

        await _tapMode(tester, _chooserKey);
        expect(_saved(level).selectionMethod, 'chooser');
        expect(writes, 2);
        expect(
          tester.widget<FilterChip>(find.byKey(_chooserKey)).selected,
          isTrue,
        );
        expect(
          tester.widget<FilterChip>(find.byKey(_presetKey)).selected,
          isFalse,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets(
    'wrapped mode chips remain disabled and preset in I, Zombie mode',
    (tester) async {
      tester.view.physicalSize = const Size(320, 720);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      final level = _level(zombieMode: true);
      var writes = 0;
      await tester.pumpWidget(
        _app(level, locale: 'en', textScale: 2, onChanged: () => writes++),
      );
      await tester.pumpAndSettle();
      _expectCompleteLabels(
        tester,
        lookupAppLocalizations(const Locale('en')),
        320,
        expectWrapping: true,
      );
      expect(
        tester.widget<FilterChip>(find.byKey(_chooserKey)).onSelected,
        isNull,
      );
      expect(
        tester.widget<FilterChip>(find.byKey(_presetKey)).onSelected,
        isNull,
      );
      await _tapMode(tester, _chooserKey);
      await _tapMode(tester, _presetKey);
      expect(_saved(level).selectionMethod, 'preset');
      expect(_saved(level).zombieMode, isTrue);
      expect(writes, 0);
      expect(
        tester.widget<FilterChip>(find.byKey(_chooserKey)).selected,
        isFalse,
      );
      expect(
        tester.widget<FilterChip>(find.byKey(_presetKey)).selected,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
