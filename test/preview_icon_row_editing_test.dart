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

PreviewDocument _document({bool showChrome = true}) => PreviewDocument(
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

PreviewDocument _rotatedDocument(
  double rotation, {
  double scale = 1,
  bool extraHeight = false,
}) {
  final document = _document(showChrome: false);
  final layer = document.layers.single;
  layer.rotation = rotation;
  layer.scale = scale;
  layer.sections = [
    PreviewIconSection(
      iconSize: 40,
      items: [for (var i = 0; i < 3; i++) _item(i)],
    ),
  ];
  layer.bounds = Rect.fromLTWH(
    400 / kPreviewCanvasSize.width,
    (extraHeight ? 10 : 100) / kPreviewCanvasSize.height,
    140 / kPreviewCanvasSize.width,
    (extraHeight ? 150 : 56) / kPreviewCanvasSize.height,
  );
  return document;
}

void _fitIconGridHeight(PreviewLayer layer) {
  final intrinsic = previewIconGridIntrinsicSize(
    maxWidth: layer.bounds.width * kPreviewCanvasSize.width,
    sections: layer.sections,
    showChrome: layer.showChrome,
    gridTitle: layer.gridTitle,
    sourceLabel: layer.sourceLabel,
    iconAlign: layer.iconAlign,
  );
  var height = intrinsic.height / kPreviewCanvasSize.height;
  if (layer.rotation != 0) height = math.max(layer.bounds.height, height);
  layer.bounds = Rect.fromLTWH(
    layer.bounds.left,
    layer.bounds.top,
    layer.bounds.width,
    height,
  );
}

Rect _rotatedFootprint(PreviewLayer layer) {
  final width = layer.bounds.width * kPreviewCanvasSize.width * layer.scale;
  final height = layer.bounds.height * kPreviewCanvasSize.height * layer.scale;
  final cosine = math.cos(layer.rotation).abs();
  final sine = math.sin(layer.rotation).abs();
  return Rect.fromCenter(
    center: Offset(
      layer.bounds.left * kPreviewCanvasSize.width + width / 2,
      layer.bounds.top * kPreviewCanvasSize.height + height / 2,
    ),
    width: cosine * width + sine * height,
    height: sine * width + cosine * height,
  );
}

void _expectFootprintInsideCanvas(PreviewLayer layer) {
  final footprint = _rotatedFootprint(layer);
  expect(footprint.left, greaterThanOrEqualTo(-0.0001));
  expect(footprint.top, greaterThanOrEqualTo(-0.0001));
  expect(footprint.right, lessThanOrEqualTo(kPreviewCanvasSize.width + 0.0001));
  expect(
    footprint.bottom,
    lessThanOrEqualTo(kPreviewCanvasSize.height + 0.0001),
  );
}

void _expectHitTarget(WidgetTester tester, Finder target) {
  final point = tester.getCenter(target);
  final renderObject = tester.renderObject(target);
  expect(
    tester
        .hitTestOnBinding(point)
        .path
        .any((entry) => identical(entry.target, renderObject)),
    isTrue,
    reason: 'An icon or row handle must receive hits at its painted center',
  );
}

class _RowHarness extends StatefulWidget {
  const _RowHarness({super.key, required this.document, this.textScale = 1});

  final PreviewDocument document;
  final double textScale;

  @override
  State<_RowHarness> createState() => _RowHarnessState();
}

class _RowHarnessState extends State<_RowHarness> {
  String? selectedLayer;
  int? selectedSection;
  int? selectedRow;
  PreviewTextPartSelection? selectedText;
  final scaledRows = <(int, int, double)>[];

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
          iconRowResizeLabel: 'Icon size',
          onSelectLayer: (id) => setState(() {
            selectedLayer = id;
            selectedSection = null;
            selectedRow = null;
            selectedText = null;
          }),
          onSelectIconSection: (id, section) => setState(() {
            selectedLayer = id;
            selectedSection = section;
            selectedRow = null;
            selectedText = null;
          }),
          onSelectIconRow: (id, section, row) => setState(() {
            selectedLayer = id;
            selectedSection = section;
            selectedRow = row;
            selectedText = null;
          }),
          onSelectTextPart: (selection) => setState(() {
            selectedLayer = selection.layerId;
            selectedSection = null;
            selectedRow = null;
            selectedText = selection;
          }),
          onIconRowScaled: (id, section, row, size) => setState(() {
            scaledRows.add((section, row, size));
            final layer = widget.document.layerById(id)!;
            resizePreviewIconRow(layer, section, row, size);
            _fitIconGridHeight(layer);
          }),
          onLayerMoved: (id, bounds) =>
              setState(() => widget.document.layerById(id)!.bounds = bounds),
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

  test(
    'unmodified sections reflow, row edits fix membership and grow width',
    () {
      final layer = _document(showChrome: false).layers.single;
      final section = layer.sections.first;
      expect(previewIconSectionRows(section, maxWidth: 180), hasLength(3));
      expect(previewIconSectionRows(section, maxWidth: 300), hasLength(2));
      expect(section.rows, isEmpty);
      final initialWidth = layer.bounds.width;
      final initialRows = previewIconSectionRows(
        section,
        maxWidth: initialWidth * kPreviewCanvasSize.width,
      );
      final members = [
        for (final row in initialRows) [for (final item in row.items) item.id],
      ];

      resizePreviewIconRow(layer, 0, 0, 80);
      expect(section.rows, hasLength(2));
      expect(section.rows[0].iconSize, 80);
      expect(section.rows[1].iconSize, 56);
      expect(layer.sections[1].iconSize, 28);
      expect(layer.bounds.width, greaterThan(initialWidth));
      expect(layer.bounds.right, lessThanOrEqualTo(1));
      expect([
        for (final row in section.rows) [for (final item in row.items) item.id],
      ], members);
      expect(
        previewIconSectionRows(section, maxWidth: 180),
        same(section.rows),
      );
    },
  );

  test(
    'row snapshots are independent and whole-section compatibility reflows',
    () {
      final document = _document();
      final layer = document.layers.single;
      resizePreviewIconRow(layer, 0, 1, 90);
      final snapshot = document.copy();
      layer.sections[0].rows[1].iconSize = 100;
      layer.sections[0].rows[0].items.removeLast();
      expect(snapshot.layers.single.sections[0].rows[1].iconSize, 90);
      expect(snapshot.layers.single.sections[0].rows[0].items, hasLength(7));
      expect(snapshot.layers.single.sections[0].title, 'Wave zombies');
      resizePreviewIconSection(layer, 0, 40);
      expect(layer.sections[0].rows, isEmpty);
      expect(layer.sections[0].iconSize, 40);
      expect(layer.sections[1].iconSize, 28);
    },
  );

  test('legacy item-only grids persist independent row changes', () {
    final layer = PreviewLayer(
      id: 'legacy',
      kind: PreviewLayerKind.iconGrid,
      bounds: const Rect.fromLTWH(0.05, 0.05, 0.3, 0.6),
      showChrome: false,
      items: [for (var i = 0; i < 8; i++) _item(i)],
    );
    resizePreviewIconRow(layer, 0, 0, 32);
    expect(layer.sections, hasLength(1));
    expect(layer.sections.single.rows[0].iconSize, 32);
    expect(previewEffectiveSections(layer).single.rows[0].iconSize, 32);
    expect(layer.items, hasLength(8));
  });

  for (final rotation in [math.pi / 2, -math.pi / 2, math.pi / 4]) {
    test('rotated row enlargement stays inside canvas at $rotation', () {
      final layer = _rotatedDocument(rotation).layers.single;
      _expectFootprintInsideCanvas(layer);
      final row = previewIconSectionRows(
        layer.sections.single,
        maxWidth: layer.bounds.width * kPreviewCanvasSize.width,
      ).single;
      final maximum = previewIconRowMaximumSizeInLayer(layer, row);
      expect(maximum, greaterThan(40));
      expect(maximum, lessThan(152));
      resizePreviewIconRow(layer, 0, 0, 152);
      _fitIconGridHeight(layer);
      expect(
        layer.sections.single.rows.single.iconSize,
        closeTo(maximum, 0.001),
      );
      _expectFootprintInsideCanvas(layer);
    });
  }

  test('rotated row resizing preserves existing empty panel height', () {
    final layer = _rotatedDocument(
      math.pi / 2,
      extraHeight: true,
    ).layers.single;
    _expectFootprintInsideCanvas(layer);
    final originalHeight = layer.bounds.height;
    resizePreviewIconRow(layer, 0, 0, 100);
    _fitIconGridHeight(layer);
    expect(layer.sections.single.rows.single.iconSize, greaterThan(40));
    expect(layer.sections.single.rows.single.iconSize, lessThan(100));
    expect(layer.bounds.height, originalHeight);
    _expectFootprintInsideCanvas(layer);
  });

  for (final showChrome in [false, true]) {
    testWidgets(
      'visual row selection and visible resize handle work with chrome=$showChrome',
      (tester) async {
        final document = _document(showChrome: showChrome);
        final key = GlobalKey<_RowHarnessState>();
        await tester.pumpWidget(_RowHarness(key: key, document: document));
        await tester.pump();
        final firstRow = find.byKey(
          const ValueKey('preview-icon-row-icons-0-0'),
        );
        final secondRow = find.byKey(
          const ValueKey('preview-icon-row-icons-0-1'),
        );
        expect(firstRow, findsOneWidget);
        expect(secondRow, findsOneWidget);
        await tester.tap(
          find.byKey(const ValueKey('preview-icon-item-icons-0-0-0')),
        );
        await tester.pump();
        expect(key.currentState!.selectedSection, 0);
        expect(key.currentState!.selectedRow, 0);
        final handle = find.byKey(
          const ValueKey('preview-icon-row-resize-icons-0-0'),
        );
        expect(handle, findsOneWidget);
        _expectHitTarget(tester, handle);
        final initialWidth = document.layers.single.bounds.width;
        await tester.drag(handle, const Offset(25, 25));
        await tester.pump();
        final section = document.layers.single.sections[0];
        expect(section.rows, hasLength(2));
        expect(section.rows[0].iconSize, greaterThan(56));
        expect(section.rows[1].iconSize, 56);
        expect(document.layers.single.bounds.width, greaterThan(initialWidth));
        expect(document.layers.single.sections[1].iconSize, 28);
        expect(
          tester.getSize(
            find.byKey(const ValueKey('preview-icon-item-icons-0-1-0')),
          ),
          const Size(56, 56),
        );
        await tester.tap(
          find.byKey(const ValueKey('preview-icon-item-icons-0-1-0')),
        );
        await tester.pump();
        expect(key.currentState!.selectedRow, 1);
        expect(
          find.byKey(const ValueKey('preview-icon-row-resize-icons-0-0')),
          findsNothing,
        );
        expect(
          find.byKey(const ValueKey('preview-icon-row-resize-icons-0-1')),
          findsOneWidget,
        );
        if (showChrome) {
          await tester.tap(
            find.byKey(
              const ValueKey('preview-text-part-icons-section-title-0'),
            ),
          );
          await tester.pump();
          expect(
            key.currentState!.selectedText?.kind,
            PreviewTextPartKind.sectionTitle,
          );
          expect(key.currentState!.selectedText?.sectionIndex, 0);
          expect(key.currentState!.selectedRow, isNull);
        }
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('rotated short row-handle drag uses the row local axes', (
    tester,
  ) async {
    final document = _rotatedDocument(math.pi / 2);
    final key = GlobalKey<_RowHarnessState>();
    await tester.pumpWidget(_RowHarness(key: key, document: document));
    await tester.pump();
    final boundaryFinder = find.descendant(
      of: find.byType(PreviewCanvas),
      matching: find.byType(RepaintBoundary),
    );
    expect(boundaryFinder, findsOneWidget);
    final boundary = tester.renderObject<RenderBox>(boundaryFinder);
    expect(boundary.size, kPreviewCanvasSize);
    final icon = find.byKey(const ValueKey('preview-icon-item-icons-0-0-0'));
    // The expanded hit box must not move the original rotated design point.
    expect(
      (tester.getCenter(icon) - boundary.localToGlobal(const Offset(478, 78)))
          .distance,
      lessThan(0.001),
    );
    _expectHitTarget(tester, icon);
    await tester.tap(
      find.byKey(const ValueKey('preview-icon-item-icons-0-0-0')),
    );
    await tester.pump();
    final handle = find.byKey(
      const ValueKey('preview-icon-row-resize-icons-0-0'),
    );
    _expectHitTarget(tester, handle);
    final originalBounds = document.layers.single.bounds;
    await tester.drag(handle, const Offset(-25, 25));
    await tester.pump();
    final layer = document.layers.single;
    expect(layer.sections.single.rows, hasLength(1));
    expect(layer.sections.single.rows.single.iconSize, greaterThan(40));
    expect(key.currentState!.scaledRows, isNotEmpty);
    expect(layer.bounds.topLeft, originalBounds.topLeft);
    _expectFootprintInsideCanvas(layer);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Ctrl and Command wheel resize only the selected visual row', (
    tester,
  ) async {
    final document = _document();
    final key = GlobalKey<_RowHarnessState>();
    await tester.pumpWidget(_RowHarness(key: key, document: document));
    await tester.pump();
    final row = find.byKey(const ValueKey('preview-icon-row-icons-0-1'));
    await tester.tap(
      find.byKey(const ValueKey('preview-icon-item-icons-0-1-0')),
    );
    await tester.pump();
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
    expect(document.layers.single.sections[0].rows[0].iconSize, 56);
    expect(
      document.layers.single.sections[0].rows[1].iconSize,
      closeTo(56 * 1.08 * 1.08, 0.001),
    );
    expect(document.layers.single.sections[1].iconSize, 28);
    expect(key.currentState!.scaledRows, hasLength(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('visual row pinch stays anchored to its starting size', (
    tester,
  ) async {
    final document = _document(showChrome: false);
    await tester.pumpWidget(_RowHarness(document: document));
    await tester.pump();
    final row = find.byKey(const ValueKey('preview-icon-row-icons-0-1'));
    final gesture = tester.widget<GestureDetector>(row);
    gesture.onScaleStart!(ScaleStartDetails(pointerCount: 2));
    gesture.onScaleUpdate!(ScaleUpdateDetails(scale: 1.5, pointerCount: 2));
    await tester.pump();
    expect(document.layers.single.sections[0].rows[1].iconSize, 84);
    tester.widget<GestureDetector>(row).onScaleUpdate!(
      ScaleUpdateDetails(scale: 2, pointerCount: 2),
    );
    await tester.pump();
    expect(document.layers.single.sections[0].rows[1].iconSize, 112);
    expect(document.layers.single.sections[0].rows[0].iconSize, 56);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'scaled tall grid dragging clamps the visible rather than base box',
    (tester) async {
      final document = _document(showChrome: false);
      final layer = document.layers.single;
      layer.bounds = const Rect.fromLTWH(0.1, 0.1, 0.8, 1.4);
      layer.scale = 0.5;
      await tester.pumpWidget(_RowHarness(document: document));
      await tester.pump();
      final row = find.byKey(const ValueKey('preview-icon-row-icons-0-0'));
      final gesture = tester.widget<GestureDetector>(row);
      gesture.onScaleStart!(ScaleStartDetails(pointerCount: 1));
      gesture.onScaleUpdate!(
        ScaleUpdateDetails(
          focalPointDelta: const Offset(20, 10),
          pointerCount: 1,
        ),
      );
      await tester.pump();
      expect(layer.bounds.left, closeTo(0.1 + 10 / 1144, 0.001));
      expect(layer.bounds.top, closeTo(0.1 + 5 / 439, 0.001));
      expect(layer.bounds.height, 1.4);
      expect(
        layer.bounds.top + layer.bounds.height * layer.scale,
        lessThanOrEqualTo(1),
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'source measurement includes wrapping and ignores system text scale',
    (tester) async {
      final document = _document();
      final layer = document.layers.single;
      layer.sourceLabel = List.filled(
        30,
        'Long localized source label',
      ).join(' ');
      final key = GlobalKey<_RowHarnessState>();
      await tester.pumpWidget(_RowHarness(key: key, document: document));
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
        _RowHarness(key: key, document: document, textScale: 3),
      );
      await tester.pump();
      expect(tester.getSize(source).height, normalHeight);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'generator exposes row controls and deletes only that row with undo',
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
            fileName: 'row-edit.json',
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
      final initialCanvas = tester.widget<PreviewCanvas>(
        find.byType(PreviewCanvas),
      );
      final plants = initialCanvas.document.layerById('plants')!;
      final section = plants.sections[0];
      final initialRows = previewIconSectionRows(
        section,
        maxWidth: plants.bounds.width * kPreviewCanvasSize.width,
      );
      expect(initialRows.length, greaterThan(1));
      final oldTitle = section.title;
      final itemCount = section.items.length;
      final removedCount = initialRows[1].items.length;
      await tester.tap(
        find.byKey(const ValueKey('preview-icon-item-plants-0-1-0')),
      );
      await tester.pumpAndSettle();
      final toolbar = find.byKey(const ValueKey('previewToolbarViewport'));
      final label = find.descendant(
        of: toolbar,
        matching: find.text('Icon size'),
      );
      expect(label, findsOneWidget);
      expect(tester.getRect(toolbar).contains(tester.getCenter(label)), isTrue);
      final control = find
          .ancestor(of: label, matching: find.byType(SizedBox))
          .first;
      final slider = tester.widget<Slider>(
        find.descendant(of: control, matching: find.byType(Slider)),
      );
      final targetSize = math.min(slider.max, slider.value + 12);
      expect(targetSize, greaterThan(slider.value));
      slider.onChangeStart!(slider.value);
      slider.onChanged!(targetSize);
      await tester.pumpAndSettle();
      expect(section.rows[1].iconSize, closeTo(targetSize, 0.001));
      expect(section.rows[0].iconSize, initialRows[0].iconSize);
      expect(section.title, oldTitle);

      final delete = find.text('Delete element (Del)');
      await tester.ensureVisible(delete);
      await tester.tap(delete);
      await tester.pumpAndSettle();
      expect(plants.sections, hasLength(1));
      expect(section.items, hasLength(itemCount - removedCount));
      expect(section.title, oldTitle);
      await tester.tap(find.byIcon(Icons.undo));
      await tester.pumpAndSettle();
      final restored = tester
          .widget<PreviewCanvas>(find.byType(PreviewCanvas))
          .document
          .layerById('plants')!;
      expect(restored.sections[0].items, hasLength(itemCount));
      expect(restored.sections[0].rows[1].iconSize, closeTo(targetSize, 0.001));
      expect(restored.sections[0].title, oldTitle);
      expect(tester.takeException(), isNull);
    },
  );
}
