import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PreviewLayer _panel({bool lawn = false}) => PreviewLayer(
  id: 'panel',
  kind: PreviewLayerKind.iconGrid,
  bounds: const Rect.fromLTWH(0.02, 0.02, 0.6, 0.85),
  gridTitle: 'Zombies',
  sourceLabel: 'Waves',
  lawnRows: lawn ? 5 : null,
  lawnCols: lawn ? 9 : null,
  sections: [
    PreviewIconSection(
      title: 'Wave zombies',
      iconSize: 36,
      items: [
        PreviewItem(
          id: 'zombie',
          assetPath: 'assets/meta/icon.png',
          gridX: lawn ? 0 : null,
          gridY: lawn ? 0 : null,
        ),
      ],
    ),
  ],
);

Size _intrinsic(PreviewLayer layer) => previewIconGridIntrinsicSize(
  maxWidth: 400,
  sections: layer.sections,
  showChrome: layer.showChrome,
  gridTitle: layer.gridTitle,
  gridTitleStyle: layer.gridTitleStyle,
  sourceLabel: layer.sourceLabel,
  sourceLabelStyle: layer.sourceLabelStyle,
  lawnRows: layer.lawnRows,
  lawnCols: layer.lawnCols,
);

void _setStyle(
  PreviewLayer layer,
  PreviewTextPartKind kind,
  PreviewTextStyleData style,
) {
  switch (kind) {
    case PreviewTextPartKind.gridTitle:
      layer.gridTitleStyle = style;
    case PreviewTextPartKind.sourceLabel:
      layer.sourceLabelStyle = style;
    case PreviewTextPartKind.sectionTitle:
      layer.sections.single.titleStyle = style;
    case PreviewTextPartKind.contained:
      throw ArgumentError.value(kind);
  }
}

Finder _part(String suffix) =>
    find.byKey(ValueKey('preview-text-part-panel-$suffix'));

Finder _partText(String suffix) =>
    find.descendant(of: _part(suffix), matching: find.byType(Text));

Future<void> _pumpCanvas(
  WidgetTester tester,
  PreviewLayer layer, {
  ValueChanged<PreviewTextPartSelection>? onSelected,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1300, 600);
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: PreviewCanvas(
          document: PreviewDocument(
            banner: PreviewBannerRef(
              kind: PreviewBannerSourceKind.assetStem,
              assetPath: 'assets/meta/icon.png',
            ),
            layers: [layer],
          ),
          interactive: true,
          onSelectTextPart: onSelected,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('panel defaults match legacy labels and return independent drafts', () {
    final title = previewDefaultPanelTextStyle(PreviewTextPartKind.gridTitle);
    final source = previewDefaultPanelTextStyle(
      PreviewTextPartKind.sourceLabel,
    );
    final section = previewDefaultPanelTextStyle(
      PreviewTextPartKind.sectionTitle,
    );
    final boss = previewDefaultPanelTextStyle(
      PreviewTextPartKind.sectionTitle,
      sectionIconSize: 64,
    );
    expect(
      [title.fontSize, source.fontSize, section.fontSize, boss.fontSize],
      [16, 11, 13, 15],
    );
    expect(title.fontWeight, FontWeight.w600);
    expect(source.fontWeight, FontWeight.w400);
    expect(section.fontWeight, FontWeight.w600);
    expect(title.color, Colors.white);
    expect(source.color.a, closeTo(0.85, 0.001));
    expect(section.color.a, closeTo(0.95, 0.001));
    for (final style in [title, source, section, boss]) {
      expect(style.fontFamily, isNull);
      expect(style.outline, false);
    }
    title.fontSize = 80;
    expect(
      previewDefaultPanelTextStyle(PreviewTextPartKind.gridTitle).fontSize,
      16,
    );
  });

  test('document snapshots deep-copy every independent panel text style', () {
    final layer = _panel();
    layer.gridTitleStyle = PreviewTextStyleData(
      fontFamily: 'Ahem',
      fontSize: 28,
      color: Colors.red,
      italic: true,
      underline: true,
      outlineWidth: 7,
    );
    layer.sourceLabelStyle = PreviewTextStyleData(
      fontFamily: null,
      fontSize: 14,
    );
    layer.sections.single.titleStyle = PreviewTextStyleData(fontSize: 18);
    final document = PreviewDocument(
      banner: PreviewBannerRef(kind: PreviewBannerSourceKind.assetStem),
      layers: [layer],
    );
    final copied = document.copy().layers.single;
    expect(copied.gridTitleStyle, isNot(same(layer.gridTitleStyle)));
    expect(copied.sourceLabelStyle, isNot(same(layer.sourceLabelStyle)));
    expect(
      copied.sections.single.titleStyle,
      isNot(same(layer.sections.single.titleStyle)),
    );
    expect(copied.gridTitleStyle!.fontFamily, 'Ahem');
    expect(copied.gridTitleStyle!.color, Colors.red);
    expect(copied.gridTitleStyle!.italic, true);
    expect(copied.gridTitleStyle!.underline, true);
    expect(copied.gridTitleStyle!.outlineWidth, 7);
    copied.gridTitleStyle!.fontSize = 72;
    copied.sourceLabelStyle!.fontFamily = kPreviewCustomFontFamily;
    copied.sections.single.titleStyle!.color = Colors.green;
    expect(layer.gridTitleStyle!.fontSize, 28);
    expect(layer.sourceLabelStyle!.fontFamily, isNull);
    expect(layer.sections.single.titleStyle!.color, Colors.white);
    final legacy = _panel().copy();
    expect(legacy.gridTitleStyle, isNull);
    expect(legacy.sourceLabelStyle, isNull);
    expect(legacy.sections.single.titleStyle, isNull);
  });

  for (final kind in [
    PreviewTextPartKind.gridTitle,
    PreviewTextPartKind.sourceLabel,
    PreviewTextPartKind.sectionTitle,
  ]) {
    for (final lawn in [false, true]) {
      testWidgets('$kind intrinsic height follows edited size, lawn=$lawn', (
        tester,
      ) async {
        final layer = _panel(lawn: lawn);
        final legacy = _intrinsic(layer);
        _setStyle(
          layer,
          kind,
          PreviewTextStyleData(
            fontFamily: 'Ahem',
            fontSize: 48,
            outline: false,
          ),
        );
        final large = _intrinsic(layer);
        expect(large.height, greaterThan(legacy.height));
        _setStyle(
          layer,
          kind,
          PreviewTextStyleData(
            fontFamily: 'Ahem',
            fontSize: 80,
            outline: true,
            outlineWidth: 8,
          ),
        );
        expect(_intrinsic(layer).height, greaterThan(large.height));
        expect(tester.takeException(), isNull);
      });
    }
  }

  testWidgets('unmodified canvas panel labels retain legacy appearance', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _pumpCanvas(tester, _panel());
    final title = tester.widget<Text>(_partText('grid-title'));
    final source = tester.widget<Text>(_partText('source-label'));
    final section = tester.widget<Text>(_partText('section-title-0'));
    expect(title.style!.fontSize, 16);
    expect(source.style!.fontSize, 11);
    expect(section.style!.fontSize, 13);
    expect([title.maxLines, source.maxLines, section.maxLines], [1, 6, 2]);
    for (final text in [title, source, section]) {
      expect(text.style!.height, 1.25);
      expect(text.style!.fontFamily, isNull);
      expect(text.overflow, TextOverflow.ellipsis);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('each panel label renders its own font and remains selectable', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final layer = _panel();
    layer.gridTitleStyle = PreviewTextStyleData(
      fontFamily: 'Ahem',
      fontSize: 40,
      color: Colors.red,
      outline: false,
    );
    layer.sourceLabelStyle = PreviewTextStyleData(
      fontFamily: kPreviewCustomFontFamily,
      fontSize: 24,
      color: Colors.yellow,
      fontWeight: FontWeight.w400,
      outline: false,
    );
    layer.sections.single.titleStyle = PreviewTextStyleData(
      fontFamily: null,
      fontSize: 30,
      color: Colors.cyan,
      outline: true,
      outlineWidth: 5,
    );
    PreviewTextPartSelection? selected;
    await _pumpCanvas(tester, layer, onSelected: (value) => selected = value);
    final title = tester.widget<Text>(_partText('grid-title'));
    final source = tester.widget<Text>(_partText('source-label'));
    expect(title.style!.fontFamily, 'Ahem');
    expect(title.style!.fontSize, 40);
    expect(title.style!.color, Colors.red);
    expect(source.style!.fontFamily, kPreviewCustomFontFamily);
    expect(source.style!.fontSize, 24);
    expect(source.style!.color, Colors.yellow);
    final outlined = tester
        .widgetList<Text>(_partText('section-title-0'))
        .toList();
    expect(outlined, hasLength(2));
    expect(outlined.first.style!.foreground!.style, PaintingStyle.stroke);
    expect(outlined.first.style!.foreground!.strokeWidth, 5);
    expect(outlined.last.style!.color, Colors.cyan);
    expect(outlined.last.style!.fontSize, 30);
    for (final suffix in ['grid-title', 'source-label', 'section-title-0']) {
      final part = _part(suffix);
      await tester.tap(part);
      expect(selected!.layerId, layer.id);
    }
    layer.gridTitleStyle!.fontFamily = null;
    layer.gridTitleStyle!.fontSize = 60;
    await _pumpCanvas(tester, layer);
    final changed = tester.widget<Text>(_partText('grid-title'));
    expect(changed.style!.fontFamily, isNull);
    expect(changed.style!.fontSize, 60);
    expect(changed.maxLines, isNull);
    expect(tester.takeException(), isNull);
  });
}
