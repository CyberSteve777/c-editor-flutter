import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_fonts.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_generator_screen.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_rich_text_controller.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Host extends Fake implements CPluginHost {
  @override
  String localize(
    BuildContext context,
    String key, [
    String? fallback,
    Map<String, Object?>? args,
  ]) => fallback ?? key;
}

PreviewCanvas _canvas(WidgetTester tester) =>
    tester.widget<PreviewCanvas>(find.byType(PreviewCanvas));

Future<void> _open(
  WidgetTester tester, {
  TargetPlatform platform = TargetPlatform.android,
  Size size = const Size(1400, 1100),
}) async {
  SharedPreferences.setMockInitialValues({});
  rootBundle.clear();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final bank = PvzObject(
    aliases: ['SeedBank'],
    objClass: 'SeedBankProperties',
    objData: {
      'PresetPlantList': ['peashooter'],
    },
  );
  final lastStand = PvzObject(
    aliases: ['LastStand'],
    objClass: 'LastStandMinigameProperties',
    objData: {},
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PreviewGeneratorScreen(
        host: _Host(),
        levelFile: PvzLevelFile(objects: [bank, lastStand]),
        parsed: ParsedLevelData(
          objectMap: {'SeedBank': bank, 'LastStand': lastStand},
        ),
        fileName: 'font-test.json',
        initialStyle: PreviewAutoStyle.normal,
      ),
    ),
  );
  for (
    var i = 0;
    i < 200 && find.byType(PreviewCanvas).evaluate().isEmpty;
    i++
  ) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 25));
  }
  expect(find.byType(PreviewCanvas), findsOneWidget);
  await tester.pumpAndSettle();
}

Future<void> _font(WidgetTester tester, String label) async {
  final picker = find.byKey(const ValueKey('previewTextFontPicker'));
  await tester.ensureVisible(picker);
  await tester.pumpAndSettle();
  await tester.tap(picker);
  await tester.pumpAndSettle();
  await tester.tap(find.text(label).last);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

void main() {
  testWidgets(
    'generated Features content is editable in a plain toolbar field',
    (tester) async {
      await _open(tester);
      final subtitle = _canvas(tester).document.layerById('subtitle')!;
      expect(subtitle.plainText, startsWith('Features:'));
      final original = subtitle.textStyle!.copy();
      _canvas(tester).onSelectLayer!(subtitle.id);
      await tester.pumpAndSettle();
      final field = find.byKey(const ValueKey('previewTextContentField'));
      final input = tester.widget<TextField>(field);
      expect(input.controller!.text, subtitle.plainText);
      expect(input.controller, isNot(isA<PreviewRichTextController>()));
      expect(input.style!.fontFamily, isNot(original.fontFamily));
      expect(input.style!.foreground, isNull);
      expect(input.style!.shadows, isNull);
      expect(input.style!.color, isNot(original.color));
      await tester.ensureVisible(field);
      await tester.pumpAndSettle();
      await tester.enterText(field, 'Features: Custom feature');
      await tester.pumpAndSettle();
      expect(subtitle.plainText, 'Features: Custom feature');
      expect(subtitle.textStyle!.fontFamily, original.fontFamily);
      expect(subtitle.textStyle!.fontSize, original.fontSize);
      expect(subtitle.textStyle!.color, original.color);
      expect(subtitle.textStyle!.outline, original.outline);
      expect(subtitle.textStyle!.outlineWidth, original.outlineWidth);
      expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'mobile generated text scrolls into the toolbar and stays above keyboard',
    (tester) async {
      await _open(tester, size: const Size(1000, 700));
      _canvas(tester).onBeginTextEdit!('subtitle');
      await tester.pumpAndSettle();
      final field = find.byKey(const ValueKey('previewTextContentField'));
      expect(field.hitTestable(), findsOneWidget);
      expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);
      expect(_canvas(tester).editingTextLayerId, isNull);
      tester.view.viewInsets = const FakeViewPadding(bottom: 240);
      await tester.pumpAndSettle();
      tester.testTextInput.updateEditingValue(
        const TextEditingValue(
          text: 'Features: Mobile editing',
          selection: TextSelection.collapsed(offset: 24),
          composing: TextRange(start: 10, end: 24),
        ),
      );
      await tester.pumpAndSettle();
      expect(field.hitTestable(), findsOneWidget);
      expect(tester.getBottomRight(field).dy, lessThanOrEqualTo(460));
      expect(
        _canvas(tester).document.layerById('subtitle')!.plainText,
        'Features: Mobile editing',
      );
      expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'canvas edits mirror plain toolbar content and preserve mixed styles',
    (tester) async {
      await _open(tester, platform: TargetPlatform.windows);
      final subtitle = _canvas(tester).document.layerById('subtitle')!;
      subtitle.textRuns = [
        PreviewTextRun(
          text: 'Features: ',
          style: PreviewTextStyleData(
            fontFamily: PreviewFonts.familyPvZ,
            color: Colors.yellow,
            outline: true,
          ),
        ),
        PreviewTextRun(
          text: 'Custom',
          style: PreviewTextStyleData(
            fontFamily: null,
            color: Colors.cyan,
            italic: true,
            outline: false,
          ),
        ),
      ];
      _canvas(tester).onBeginTextEdit!('subtitle');
      await tester.pumpAndSettle();
      final rich = _canvas(tester).textEditingController!;
      rich.value = const TextEditingValue(
        text: 'Features: Custom mode',
        selection: TextSelection.collapsed(offset: 21),
      );
      await tester.pumpAndSettle();
      final field = find.byKey(const ValueKey('previewTextContentField'));
      expect(tester.widget<TextField>(field).controller!.text, rich.text);
      await tester.ensureVisible(field);
      await tester.pumpAndSettle();
      await tester.enterText(field, 'Features: Custom mode updated');
      await tester.pumpAndSettle();
      expect(subtitle.plainText, 'Features: Custom mode updated');
      expect(subtitle.textRuns.first.text, 'Features: ');
      expect(subtitle.textRuns.first.style.fontFamily, PreviewFonts.familyPvZ);
      expect(subtitle.textRuns.first.style.color, Colors.yellow);
      expect(subtitle.textRuns.last.style.fontFamily, isNull);
      expect(subtitle.textRuns.last.style.color, Colors.cyan);
      expect(subtitle.textRuns.last.style.italic, isTrue);
      expect(_canvas(tester).editingTextLayerId, isNull);
      expect(tester.widget<TextField>(field).focusNode!.hasFocus, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'generated panel labels have independent fonts and plain content fields',
    (tester) async {
      await _open(tester);
      final panel = _canvas(tester).document.layerById('plants')!;
      final originalItems = panel.sections
          .expand((s) => s.items)
          .map((i) => i.id)
          .toList();
      panel.sections.first.title = 'Level 2';
      for (final kind in [
        PreviewTextPartKind.gridTitle,
        PreviewTextPartKind.sourceLabel,
        PreviewTextPartKind.sectionTitle,
      ]) {
        _canvas(tester).onSelectTextPart!(
          PreviewTextPartSelection(
            layerId: 'plants',
            kind: kind,
            sectionIndex: kind == PreviewTextPartKind.sectionTitle ? 0 : null,
          ),
        );
        await tester.pumpAndSettle();
        final field = find.byKey(const ValueKey('previewTextContentField'));
        final controller = tester.widget<TextField>(field).controller!;
        expect(controller, isNot(isA<PreviewRichTextController>()));
        final text = controller.text;
        PreviewTextStyleData? style() => switch (kind) {
          PreviewTextPartKind.gridTitle => panel.gridTitleStyle,
          PreviewTextPartKind.sourceLabel => panel.sourceLabelStyle,
          PreviewTextPartKind.sectionTitle => panel.sections.first.titleStyle,
          _ => null,
        };
        await _font(tester, 'PvZ Preview');
        expect(style()!.fontFamily, PreviewFonts.familyPvZ);
        expect(controller.text, text);
        final span = controller.buildTextSpan(
          context: tester.element(field),
          style: const TextStyle(fontFamily: 'Editor UI', fontSize: 14),
          withComposing: false,
        );
        expect(span.style!.fontFamily, 'Editor UI');
        expect(span.style!.fontSize, 14);
        expect(span.children, isNull);
        await _font(tester, 'System default');
        expect(style()!.fontFamily, isNull);
        expect(
          tester
              .widget<DropdownButton<String>>(
                find.byKey(const ValueKey('previewTextFontPicker')),
              )
              .value,
          '',
        );
        expect(controller.text, text);
        final red = find.byWidgetPredicate((widget) {
          if (widget is! GestureDetector || widget.child is! Container) {
            return false;
          }
          final decoration = (widget.child! as Container).decoration;
          return decoration is BoxDecoration &&
              decoration.color == Colors.red &&
              decoration.shape == BoxShape.circle;
        });
        await tester.ensureVisible(red);
        await tester.pumpAndSettle();
        await tester.tap(red);
        await tester.pumpAndSettle();
        expect(style()!.color, Colors.red);
        await tester.ensureVisible(field);
        await tester.pumpAndSettle();
        await tester.enterText(field, '$text updated');
        await tester.pumpAndSettle();
        expect(style()!.fontFamily, isNull);
        expect(tester.takeException(), isNull);
      }
      expect(panel.gridTitle, endsWith(' updated'));
      expect(panel.sourceLabel, endsWith(' updated'));
      expect(panel.sections.first.title, endsWith(' updated'));
      expect(
        panel.sections.expand((s) => s.items).map((i) => i.id).toList(),
        originalItems,
      );
    },
  );

  testWidgets(
    'generated text layer fonts change without editing their content',
    (tester) async {
      await _open(tester);
      final theme = _canvas(tester).document.layerById('title')!;
      final text = theme.plainText;
      _canvas(tester).onSelectLayer!('title');
      await tester.pumpAndSettle();
      await _font(tester, 'System default');
      expect(
        theme.effectiveTextRuns().every((r) => r.style.fontFamily == null),
        isTrue,
      );
      await _font(tester, 'PvZ Preview');
      expect(
        theme.effectiveTextRuns().every(
          (r) => r.style.fontFamily == PreviewFonts.familyPvZ,
        ),
        isTrue,
      );
      expect(theme.plainText, text);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'font picker preserves a selected range while editing generated text',
    (tester) async {
      await _open(tester);
      final title = _canvas(tester).document.layerById('title')!;
      final text = title.plainText;
      expect(text.length, greaterThan(4));
      _canvas(tester).onBeginTextEdit!('title');
      await tester.pumpAndSettle();
      final controller = tester
          .widget<TextField>(
            find.byKey(const ValueKey('previewTextContentField')),
          )
          .controller!;
      controller.selection = const TextSelection(
        baseOffset: 0,
        extentOffset: 4,
      );
      await tester.pump();
      await _font(tester, 'System default');
      expect(title.textRuns.first.text, text.substring(0, 4));
      expect(title.textRuns.first.style.fontFamily, isNull);
      expect(title.textRuns.last.style.fontFamily, PreviewFonts.familyPvZ);
      expect(
        controller.selection,
        const TextSelection(baseOffset: 0, extentOffset: 4),
      );
      expect(title.plainText, text);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'contained text can switch fonts without styling its content input',
    (tester) async {
      await _open(tester);
      final label = PreviewContainedText(id: 'label', text: 'Inside the shape');
      _canvas(tester).document.layers.add(
        PreviewLayer(
          id: 'shape',
          kind: PreviewLayerKind.shape,
          bounds: const Rect.fromLTWH(.05, .5, .35, .3),
          shapeKind: PreviewShapeKind.rect,
          containedTexts: [label],
        ),
      );
      _canvas(tester).onSelectTextPart!(
        const PreviewTextPartSelection(
          layerId: 'shape',
          kind: PreviewTextPartKind.contained,
          containedTextId: 'label',
        ),
      );
      await tester.pumpAndSettle();
      await _font(tester, 'System default');
      expect(label.style.fontFamily, isNull);
      await _font(tester, 'PvZ Preview');
      expect(label.style.fontFamily, PreviewFonts.familyPvZ);
      final field = find.byKey(const ValueKey('previewTextContentField'));
      final controller = tester.widget<TextField>(field).controller!;
      expect(controller, isNot(isA<PreviewRichTextController>()));
      expect(controller.text, 'Inside the shape');
      expect(tester.takeException(), isNull);
    },
  );
}
