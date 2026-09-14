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
  final buttonBorders = <Rect>[];
  for (final (key, label) in [
    (_chooserKey, l10n.chooser),
    (_presetKey, l10n.preset),
  ]) {
    final chip = find.byKey(key);
    final chipWidget = tester.widget<FilterChip>(chip);
    final text = find.descendant(of: chip, matching: find.text(label));
    expect(text, findsOneWidget);
    final paragraph = tester.renderObject<RenderParagraph>(text);
    final colors = Theme.of(tester.element(chip)).colorScheme;
    final expectedLabelColor = chipWidget.onSelected == null
        ? colors.onSurface
        : chipWidget.selected
        ? colors.onSecondaryContainer
        : colors.onSurfaceVariant;
    expect(
      paragraph.text.style?.color,
      expectedLabelColor,
      reason: '$label must inherit the selected or disabled chip label color',
    );
    expect(
      paragraph.didExceedMaxLines,
      isFalse,
      reason: 'The complete selection mode must be visible: $label',
    );
    final chipRect = tester.getRect(chip);
    final materialFinder = find
        .descendant(of: chip, matching: find.byType(Material))
        .first;
    final material = tester.widget<Material>(materialFinder);
    final borderBox = tester.renderObject<RenderBox>(materialFinder);
    final borderRect = tester.getRect(materialFinder);
    buttonBorders.add(borderRect);
    final borderShape = material.shape;
    expect(borderShape, isNotNull);
    final insideBorder = borderShape!.getInnerPath(
      Offset.zero & borderBox.size,
      textDirection: Directionality.of(tester.element(materialFinder)),
    );
    final labelRect = tester.getRect(text);
    expect(chipRect.left, greaterThanOrEqualTo(0));
    expect(chipRect.right, lessThanOrEqualTo(windowWidth));
    expect(labelRect.left, greaterThanOrEqualTo(chipRect.left));
    expect(labelRect.right, lessThanOrEqualTo(chipRect.right));
    expect(labelRect.top, greaterThanOrEqualTo(chipRect.top));
    expect(labelRect.bottom, lessThanOrEqualTo(chipRect.bottom));
    // A wrapped line's trailing space may have a selection box beyond its ink.
    // Check every painted word so those empty boxes do not hide real overflow.
    final textBoxes = [
      for (final word in RegExp(r'\S+').allMatches(label))
        ...paragraph.getBoxesForSelection(
          TextSelection(baseOffset: word.start, extentOffset: word.end),
        ),
    ];
    expect(textBoxes, isNotEmpty);
    for (final box in textBoxes) {
      final glyphRect = Rect.fromPoints(
        paragraph.localToGlobal(box.toRect().topLeft),
        paragraph.localToGlobal(box.toRect().bottomRight),
      );
      expect(
        glyphRect.top,
        greaterThanOrEqualTo(borderRect.top - .01),
        reason: '$label glyphs must start inside the painted button border',
      );
      expect(
        glyphRect.bottom,
        lessThanOrEqualTo(borderRect.bottom + .01),
        reason: '$label glyphs must finish inside the painted button border',
      );
      expect(glyphRect.left, greaterThanOrEqualTo(borderRect.left - .01));
      expect(
        glyphRect.right,
        lessThanOrEqualTo(borderRect.right + .01),
        reason: '$label glyphs must stay inside the painted button border',
      );
      final interior = glyphRect.deflate(.1);
      for (final point in [
        interior.topLeft,
        interior.topRight,
        interior.bottomLeft,
        interior.bottomRight,
      ]) {
        expect(
          insideBorder.contains(borderBox.globalToLocal(point)),
          isTrue,
          reason:
              '$label glyph box $glyphRect must stay within the button shape',
        );
      }
    }
    final check = find.descendant(of: chip, matching: find.byIcon(Icons.check));
    if (chipWidget.selected) {
      expect(check, findsOneWidget);
      final checkWidget = tester.widget<Icon>(check);
      expect(
        checkWidget.color ?? IconTheme.of(tester.element(check)).color,
        expectedLabelColor,
        reason: 'The check must inherit the same chip state color as its label',
      );
      final checkRect = tester.getRect(check).deflate(.1);
      for (final point in [
        checkRect.topLeft,
        checkRect.topRight,
        checkRect.bottomLeft,
        checkRect.bottomRight,
      ]) {
        expect(
          insideBorder.contains(borderBox.globalToLocal(point)),
          isTrue,
          reason: 'The selected check must stay inside the painted chip border',
        );
      }
    } else {
      expect(check, findsNothing);
    }
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
  expect(
    buttonBorders[0].overlaps(buttonBorders[1]),
    isFalse,
    reason: 'The two painted selection buttons must not overlap',
  );
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
    for (final (width, textScale) in [
      (320.0, 1.0),
      (320.0, 2.0),
      (360.0, 2.0),
      (390.0, 2.0),
    ]) {
      testWidgets('$locale seed bank modes show full labels and save selection '
          'at ${width.toInt()}px with text scale $textScale', (tester) async {
        tester.view.physicalSize = Size(width, 720);
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
          width,
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
          width,
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
        _expectCompleteLabels(
          tester,
          l10n,
          width,
          expectWrapping: locale == 'en' && textScale > 1,
        );
        expect(tester.takeException(), isNull);
      });
    }
  }

  for (final locale in ['en', 'zh', 'ru']) {
    for (final width in [320.0, 390.0]) {
      testWidgets(
        locale == 'en' && width == 320
            ? 'wrapped mode chips remain disabled and preset in I, Zombie mode'
            : '$locale wrapped mode chips remain disabled and preset '
                  'in I, Zombie mode at ${width.toInt()}px',
        (tester) async {
          tester.view.physicalSize = Size(width, 720);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          final level = _level(zombieMode: true);
          var writes = 0;
          await tester.pumpWidget(
            _app(
              level,
              locale: locale,
              textScale: 2,
              onChanged: () => writes++,
            ),
          );
          await tester.pumpAndSettle();
          _expectCompleteLabels(
            tester,
            lookupAppLocalizations(Locale(locale)),
            width,
            expectWrapping: locale == 'en',
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
          _expectCompleteLabels(
            tester,
            lookupAppLocalizations(Locale(locale)),
            width,
            expectWrapping: locale == 'en',
          );
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}
