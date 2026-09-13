import 'dart:math' as math;

import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_generator_screen.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

PreviewItem _item(int index) =>
    PreviewItem(id: 'item_$index', assetPath: 'assets/meta/icon.png');

PreviewDocument _document({
  bool showChrome = true,
  PreviewAutoStyle autoStyle = PreviewAutoStyle.simple,
}) => PreviewDocument(
  autoStyle: autoStyle,
  banner: PreviewBannerRef(
    kind: PreviewBannerSourceKind.assetStem,
    assetPath: 'assets/meta/icon.png',
  ),
  layers: [
    PreviewLayer(
      id: 'icons',
      kind: PreviewLayerKind.iconGrid,
      bounds: const Rect.fromLTWH(0.08, 0.1, 0.4, 0.8),
      showChrome: showChrome,
      gridTitle: showChrome ? 'Plants' : null,
      sourceLabel: showChrome ? 'Seed bank' : null,
      sections: [
        PreviewIconSection(
          title: showChrome ? 'Wave zombies' : null,
          iconSize: 56,
          items: [for (var i = 0; i < 8; i++) _item(i)],
        ),
        PreviewIconSection(
          title: showChrome ? 'Bosses' : null,
          iconSize: 28,
          items: [_item(20), _item(21)],
        ),
      ],
    ),
  ],
);

class _GroupHarness extends StatefulWidget {
  const _GroupHarness({super.key, required this.document, this.textScale = 1});

  final PreviewDocument document;
  final double textScale;

  @override
  State<_GroupHarness> createState() => _GroupHarnessState();
}

class _GroupHarnessState extends State<_GroupHarness> {
  String? selectedLayer;
  PreviewTextPartSelection? selectedText;
  int? selectedSection;
  int? selectedRow;

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(textScaler: TextScaler.linear(widget.textScale)),
      child: Scaffold(
        body: PreviewCanvas(
          document: widget.document,
          interactive: true,
          selectedLayerId: selectedLayer,
          selectedIconSectionIndex: selectedSection,
          selectedIconRowIndex: selectedRow,
          selectedTextPart: selectedText,
          onSelectLayer: (id) => setState(() {
            selectedLayer = id;
            selectedText = null;
            selectedSection = null;
            selectedRow = null;
          }),
          onSelectIconRow: (id, section, row) => setState(() {
            selectedLayer = id;
            selectedSection = section;
            selectedRow = row;
            selectedText = null;
          }),
          onIconRowScaled: (id, section, row, size) => setState(() {
            resizePreviewIconRow(
              widget.document.layerById(id)!,
              section,
              row,
              size,
            );
          }),
          iconRowResizeLabel: 'Icon size',
          onSelectTextPart: (selection) => setState(() {
            selectedLayer = selection.layerId;
            selectedText = selection;
            selectedSection = null;
            selectedRow = null;
          }),
          onLayerMoved: (id, bounds) =>
              setState(() => widget.document.layerById(id)!.bounds = bounds),
          onLayerScaled: (id, scale) =>
              setState(() => widget.document.layerById(id)!.scale = scale),
        ),
      ),
    ),
  );
}

class _Host extends Fake implements CPluginHost {
  @override
  String localize(
    BuildContext context,
    String key, [
    String? fallback,
    Map<String, Object?>? args,
  ]) => fallback ?? key;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    // Asset-cache Futures belong to the previous test's fake-async zone.
    // Each generator fixture must load them in its own zone.
    rootBundle.clear();
  });

  test('whole-group icon sizing updates every section and keeps reflow', () {
    final layer = _document(showChrome: false).layers.single;
    final sections = layer.sections;
    final originalIds = [
      for (final section in sections)
        [for (final item in section.items) item.id],
    ];
    final originalBounds = layer.bounds;

    resizePreviewIconGroup(layer, 40);

    expect(sections.map((section) => section.iconSize), [40, 40]);
    expect(sections.every((section) => section.rows.isEmpty), isTrue);
    expect([
      for (final section in sections)
        [for (final item in section.items) item.id],
    ], originalIds);
    expect(layer.bounds, originalBounds);
    expect(previewIconSectionRows(sections.first, maxWidth: 180), hasLength(2));
    expect(previewIconSectionRows(sections.first, maxWidth: 400), hasLength(1));
  });

  test(
    'group sizing migrates old explicit rows and preserves undo snapshots',
    () {
      final document = _document();
      final section = document.layers.single.sections.first;
      section.rows = [
        PreviewIconRow(items: [_item(2), _item(4)], iconSize: 60),
        PreviewIconRow(items: [_item(6)], iconSize: 80),
      ];
      final snapshot = document.copy();

      resizePreviewIconGroup(document.layers.single, 32);

      expect(section.items.map((item) => item.id), [
        'item_2',
        'item_4',
        'item_6',
      ]);
      expect(section.rows, isEmpty);
      expect(section.iconSize, 32);
      expect(document.layers.single.sections.last.iconSize, 32);
      expect(section.title, 'Wave zombies');
      expect(
        snapshot.layers.single.sections.first.rows.map((row) => row.iconSize),
        [60, 80],
      );
      expect(snapshot.layers.single.sections.last.iconSize, 28);
      section.items.removeAt(0);
      expect(
        snapshot.layers.single.sections.first.rows.first.items.first.id,
        'item_2',
      );
    },
  );

  test('legacy item-only groups materialize one uniformly sized section', () {
    final layer = PreviewLayer(
      id: 'legacy',
      kind: PreviewLayerKind.iconGrid,
      bounds: const Rect.fromLTWH(0.05, 0.05, 0.3, 0.6),
      showChrome: false,
      items: [for (var i = 0; i < 8; i++) _item(i)],
    );

    resizePreviewIconGroup(layer, 32);

    expect(layer.sections, hasLength(1));
    expect(layer.sections.single.iconSize, 32);
    expect(layer.sections.single.rows, isEmpty);
    expect(layer.sections.single.items, hasLength(8));
    expect(layer.items, hasLength(8));
  });

  test('row sizing preserves row membership and other section sizes', () {
    final document = _document(autoStyle: PreviewAutoStyle.normal);
    final layer = document.layers.single;
    final section = layer.sections.first;
    final originalRows = previewIconSectionRows(
      section,
      maxWidth:
          layer.bounds.width * kPreviewCanvasSize.width -
          kPreviewIconGridChromeInset,
    );
    final snapshot = document.copy();

    resizePreviewIconRow(layer, 0, 1, 72);

    expect(section.rows, hasLength(originalRows.length));
    expect(section.rows[0].iconSize, 56);
    expect(section.rows[1].iconSize, 72);
    expect(
      section.rows[1].items.map((item) => item.id),
      originalRows[1].items.map((item) => item.id),
    );
    expect(layer.sections.last.iconSize, 28);
    expect(snapshot.layers.single.sections.first.rows, isEmpty);

    resizePreviewIconGroup(layer, 40);
    expect(section.rows, isEmpty);
    expect(layer.sections.map((section) => section.iconSize), [40, 40]);
    expect(section.items, hasLength(8));
  });

  testWidgets('detailed rows resize independently and can return to group', (
    tester,
  ) async {
    final document = _document(autoStyle: PreviewAutoStyle.normal);
    final key = GlobalKey<_GroupHarnessState>();
    await tester.pumpWidget(_GroupHarness(key: key, document: document));
    await tester.pump();
    final icon = find.byKey(const ValueKey('preview-icon-item-icons-0-0-0'));
    await tester.tap(icon);
    await tester.pump();
    expect(key.currentState!.selectedSection, 0);
    expect(key.currentState!.selectedRow, 0);
    final handle = find.byKey(
      const ValueKey('preview-icon-row-resize-icons-0-0'),
    );
    expect(handle, findsOneWidget);
    // Whole-group handles stay available even while a row is selected.
    expect(find.byIcon(Icons.rotate_right), findsOneWidget);
    await tester.drag(handle, const Offset(25, 25));
    await tester.pump();
    final section = document.layers.single.sections.first;
    expect(section.rows[0].iconSize, greaterThan(56));
    expect(section.rows[1].iconSize, 56);
    expect(document.layers.single.sections.last.iconSize, 28);

    await tester.tap(icon);
    await tester.pump();
    expect(key.currentState!.selectedLayer, 'icons');
    expect(key.currentState!.selectedRow, isNull);
    expect(handle, findsNothing);

    await tester.tap(icon);
    await tester.pump();
    expect(key.currentState!.selectedRow, 0);
    await tester.tap(find.byIcon(Icons.rotate_right));
    await tester.pump();
    expect(key.currentState!.selectedRow, isNull);
    expect(key.currentState!.selectedLayer, 'icons');
    expect(tester.takeException(), isNull);
  });

  testWidgets('detailed row pinch and modifier wheel resize only that row', (
    tester,
  ) async {
    final document = _document(autoStyle: PreviewAutoStyle.normal);
    final key = GlobalKey<_GroupHarnessState>();
    await tester.pumpWidget(_GroupHarness(key: key, document: document));
    await tester.pump();
    final row = find.byKey(const ValueKey('preview-icon-row-icons-0-1'));
    final gesture = tester.widget<GestureDetector>(row);
    gesture.onScaleStart!(ScaleStartDetails(pointerCount: 2));
    gesture.onScaleUpdate!(ScaleUpdateDetails(scale: 1.2, pointerCount: 2));
    await tester.pump();
    expect(
      document.layers.single.sections.first.rows[1].iconSize,
      closeTo(56 * 1.2, 0.001),
    );
    tester.widget<GestureDetector>(row).onScaleUpdate!(
      ScaleUpdateDetails(scale: 1.5, pointerCount: 2),
    );
    await tester.pump();
    expect(document.layers.single.sections.first.rows[1].iconSize, 84);
    for (final modifier in [
      LogicalKeyboardKey.controlLeft,
      LogicalKeyboardKey.metaLeft,
    ]) {
      await tester.sendKeyDownEvent(modifier);
      try {
        await tester.sendEventToBinding(
          PointerScrollEvent(
            position: tester.getCenter(row),
            scrollDelta: const Offset(0, -40),
          ),
        );
        await tester.pump();
      } finally {
        await tester.sendKeyUpEvent(modifier);
      }
    }
    expect(document.layers.single.sections.first.rows[0].iconSize, 56);
    expect(
      document.layers.single.sections.first.rows[1].iconSize,
      closeTo(84 * 1.08 * 1.08, 0.001),
    );
    expect(document.layers.single.sections.last.iconSize, 28);
    expect(tester.takeException(), isNull);
  });

  for (final showChrome in [false, true]) {
    testWidgets('any icon selects the entire group with chrome=$showChrome', (
      tester,
    ) async {
      final document = _document(showChrome: showChrome);
      final key = GlobalKey<_GroupHarnessState>();
      await tester.pumpWidget(_GroupHarness(key: key, document: document));
      await tester.pump();
      for (final suffix in ['0-0-0', '0-1-0', '1-0-0']) {
        await tester.tap(
          find.byKey(ValueKey('preview-icon-item-icons-$suffix')),
        );
        await tester.pump();
        expect(key.currentState!.selectedLayer, 'icons');
        expect(key.currentState!.selectedText, isNull);
        expect(find.byIcon(Icons.rotate_right), findsOneWidget);
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget.key.toString().contains('preview-icon-row-resize-'),
          ),
          findsNothing,
        );
      }

      if (showChrome) {
        for (final entry in {
          'grid-title': PreviewTextPartKind.gridTitle,
          'source-label': PreviewTextPartKind.sourceLabel,
          'section-title-0': PreviewTextPartKind.sectionTitle,
        }.entries) {
          await tester.tap(
            find.byKey(ValueKey('preview-text-part-icons-${entry.key}')),
          );
          await tester.pump();
          expect(key.currentState!.selectedText?.kind, entry.value);
          expect(find.byIcon(Icons.rotate_right), findsNothing);
          await tester.tap(
            find.byKey(const ValueKey('preview-icon-item-icons-0-1-0')),
          );
          await tester.pump();
          expect(key.currentState!.selectedText, isNull);
          expect(find.byIcon(Icons.rotate_right), findsOneWidget);
        }
      }
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('rotated icon hit area still selects and drags the whole group', (
    tester,
  ) async {
    final document = _document(showChrome: false);
    final layer = document.layers.single;
    layer.rotation = math.pi / 2;
    layer.sections = [
      PreviewIconSection(
        iconSize: 40,
        items: [for (var i = 0; i < 3; i++) _item(i)],
      ),
    ];
    layer.bounds = Rect.fromLTWH(400 / 1144, 100 / 439, 140 / 1144, 56 / 439);
    final key = GlobalKey<_GroupHarnessState>();
    await tester.pumpWidget(_GroupHarness(key: key, document: document));
    await tester.pump();

    final icon = find.byKey(const ValueKey('preview-icon-item-icons-0-0-0'));
    await tester.tap(icon);
    await tester.pump();
    expect(key.currentState!.selectedLayer, 'icons');
    final before = layer.bounds.topLeft;
    await tester.drag(icon, const Offset(30, 25));
    await tester.pump();
    expect(layer.bounds.topLeft, isNot(before));
    expect(layer.sections.single.iconSize, 40);
    expect(layer.sections.single.rows, isEmpty);
    expect(tester.takeException(), isNull);
  });

  testWidgets('scaled tall grid dragging clamps its visible footprint', (
    tester,
  ) async {
    final document = _document(showChrome: false);
    final layer = document.layers.single;
    layer.bounds = const Rect.fromLTWH(0.1, 0.1, 0.8, 1.4);
    layer.scale = 0.5;
    await tester.pumpWidget(_GroupHarness(document: document));
    await tester.pump();
    final gesture = tester.widget<GestureDetector>(
      find.byKey(const ValueKey('preview-layer-gesture-icons')),
    );
    gesture.onScaleStart!(ScaleStartDetails(pointerCount: 1));
    gesture.onScaleUpdate!(
      ScaleUpdateDetails(
        focalPointDelta: const Offset(20, 10),
        pointerCount: 1,
      ),
    );
    await tester.pump();

    expect(layer.bounds.left, closeTo(0.1 + 20 / 1144, 0.001));
    expect(layer.bounds.top, closeTo(0.1 + 10 / 439, 0.001));
    expect(layer.bounds.height, 1.4);
    expect(
      layer.bounds.top + layer.bounds.height * layer.scale,
      lessThanOrEqualTo(1),
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'source measurement includes wrapping and ignores system text scale',
    (tester) async {
      final document = _document();
      final layer = document.layers.single;
      layer.sourceLabel = List.filled(
        30,
        'Long localized source label',
      ).join(' ');
      final key = GlobalKey<_GroupHarnessState>();
      await tester.pumpWidget(_GroupHarness(key: key, document: document));
      await tester.pump();
      final source = find.byKey(
        const ValueKey('preview-text-part-icons-source-label'),
      );
      final normalHeight = tester.getSize(source).height;
      expect(normalHeight, greaterThan(14));
      final intrinsic = previewIconGridIntrinsicSize(
        maxWidth: layer.bounds.width * kPreviewCanvasSize.width,
        sections: layer.sections,
        sourceLabel: layer.sourceLabel,
        gridTitle: layer.gridTitle,
      );
      expect(intrinsic.height, greaterThan(normalHeight + 56 * 2 + 28));
      await tester.pumpWidget(
        _GroupHarness(key: key, document: document, textScale: 3),
      );
      await tester.pump();
      expect(tester.getSize(source).height, normalHeight);
      expect(tester.takeException(), isNull);
    },
  );

  for (final style in PreviewAutoStyle.values) {
    testWidgets(
      'generator row/group controls preserve whole-group editing: $style',
      (tester) async {
        SharedPreferences.setMockInitialValues({});
        await tester.binding.setSurfaceSize(const Size(1100, 800));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final seedBank = PvzObject(
          aliases: const ['SeedBank'],
          objClass: 'SeedBankProperties',
          objData: {
            'PresetPlantList': [for (var i = 0; i < 30; i++) 'test_plant_$i'],
          },
        );
        await tester.pumpWidget(
          MaterialApp(
            home: PreviewGeneratorScreen(
              host: _Host(),
              levelFile: PvzLevelFile(objects: [seedBank]),
              parsed: ParsedLevelData(objectMap: {'SeedBank': seedBank}),
              fileName: 'group-edit.json',
              initialStyle: style,
            ),
          ),
        );
        for (
          var attempt = 0;
          attempt < 200 && find.byType(PreviewCanvas).evaluate().isEmpty;
          attempt++
        ) {
          await tester.runAsync(
            () => Future<void>.delayed(const Duration(milliseconds: 25)),
          );
          await tester.pump();
        }
        expect(find.byType(PreviewCanvas), findsOneWidget);
        await tester.pumpAndSettle();
        final plants = tester
            .widget<PreviewCanvas>(find.byType(PreviewCanvas))
            .document
            .layerById('plants')!;
        final itemCount = plants.sections.first.items.length;
        await tester.tap(
          find.byKey(const ValueKey('preview-icon-item-plants-0-1-0')),
        );
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<PreviewCanvas>(find.byType(PreviewCanvas))
              .selectedLayerId,
          'plants',
        );
        expect(find.byIcon(Icons.rotate_right), findsOneWidget);

        final toolbar = find.byKey(const ValueKey('previewToolbarViewport'));
        var canvas = tester.widget<PreviewCanvas>(find.byType(PreviewCanvas));
        if (style == PreviewAutoStyle.normal) {
          expect(canvas.selectedIconSectionIndex, 0);
          expect(canvas.selectedIconRowIndex, 1);
          final firstSize = plants.sections.first.iconSize;
          final rowLabel = find.descendant(
            of: toolbar,
            matching: find.text('Icon size'),
          );
          final rowControl = find
              .ancestor(of: rowLabel, matching: find.byType(SizedBox))
              .first;
          final rowSlider = tester.widget<Slider>(
            find.descendant(of: rowControl, matching: find.byType(Slider)),
          );
          final rowSize = math.min(rowSlider.max, rowSlider.value + 4);
          expect(rowSize, greaterThan(rowSlider.value));
          rowSlider.onChangeStart!(rowSlider.value);
          rowSlider.onChanged!(rowSize);
          rowSlider.onChangeEnd?.call(rowSize);
          await tester.pumpAndSettle();
          expect(plants.sections.first.rows[1].iconSize, rowSize);
          expect(plants.sections.first.rows[0].iconSize, firstSize);
          expect(plants.sections.first.items, hasLength(itemCount));

          await tester.tap(
            find.byKey(const ValueKey('preview-icon-item-plants-0-1-0')),
          );
          await tester.pumpAndSettle();
          canvas = tester.widget<PreviewCanvas>(find.byType(PreviewCanvas));
        }
        expect(canvas.selectedIconRowIndex, isNull);
        expect(
          find.byKey(const ValueKey('previewIconGroupSize')),
          findsOneWidget,
        );
        final label = find.descendant(
          of: toolbar,
          matching: find.text('Icon size'),
        );
        expect(label, findsOneWidget);
        final control = find
            .ancestor(of: label, matching: find.byType(SizedBox))
            .first;
        final slider = tester.widget<Slider>(
          find.descendant(of: control, matching: find.byType(Slider)),
        );
        final targetSize = math.min(slider.max, slider.value + 12);
        slider.onChangeStart!(slider.value);
        slider.onChanged!(targetSize);
        await tester.pumpAndSettle();
        expect(
          plants.sections.every((section) => section.iconSize == targetSize),
          isTrue,
        );
        expect(
          plants.sections.every((section) => section.rows.isEmpty),
          isTrue,
        );

        final delete = find.text('Delete element (Del)');
        await tester.ensureVisible(delete);
        await tester.tap(delete);
        await tester.pumpAndSettle();
        expect(
          tester
              .widget<PreviewCanvas>(find.byType(PreviewCanvas))
              .document
              .layerById('plants'),
          isNull,
        );
        await tester.ensureVisible(find.byIcon(Icons.undo));
        await tester.tap(find.byIcon(Icons.undo));
        await tester.pumpAndSettle();
        final restored = tester
            .widget<PreviewCanvas>(find.byType(PreviewCanvas))
            .document
            .layerById('plants')!;
        expect(restored.sections.first.items, hasLength(itemCount));
        expect(restored.sections.first.iconSize, targetSize);
        expect(tester.takeException(), isNull);
      },
    );
  }
}
