import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_rich_text_controller.dart';

PreviewDocument _document() => PreviewDocument(
  banner: PreviewBannerRef(
    kind: PreviewBannerSourceKind.assetStem,
    assetPath: 'assets/meta/icon.png',
  ),
  layers: [
    PreviewLayer(
      id: 'title',
      kind: PreviewLayerKind.text,
      bounds: const Rect.fromLTWH(0.05, 0.1, 0.35, 0.2),
      text: 'Preview title',
      textStyle: PreviewTextStyleData(fontSize: 28),
    ),
    PreviewLayer(
      id: 'icons',
      kind: PreviewLayerKind.iconGrid,
      bounds: const Rect.fromLTWH(0.5, 0.1, 0.4, 0.6),
      gridTitle: 'Plants',
      sections: [
        PreviewIconSection(
          iconSize: 50,
          items: [
            PreviewItem(id: 'one', assetPath: 'assets/meta/icon.png'),
            PreviewItem(id: 'two', assetPath: 'assets/meta/icon.png'),
          ],
        ),
      ],
    ),
  ],
);

class _CanvasHarness extends StatefulWidget {
  const _CanvasHarness({
    super.key,
    required this.document,
    this.initialLayer = 'title',
    this.initialSection,
    this.onSectionScaled,
    this.onLayerScaled,
  });

  final PreviewDocument document;
  final String initialLayer;
  final int? initialSection;
  final ValueChanged<double>? onSectionScaled;
  final ValueChanged<double>? onLayerScaled;

  @override
  State<_CanvasHarness> createState() => _CanvasHarnessState();
}

class _CanvasHarnessState extends State<_CanvasHarness> {
  final _controller = PreviewRichTextController();
  final _focus = FocusNode();
  late String? selectedLayer;
  int? selectedSection;
  String? editingLayer;

  @override
  void initState() {
    super.initState();
    selectedLayer = widget.initialLayer;
    selectedSection = widget.initialSection;
    _controller.loadFromLayer(widget.document.layerById('title')!);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    home: Scaffold(
      body: PreviewCanvas(
        document: widget.document,
        interactive: true,
        selectedLayerId: selectedLayer,
        selectedIconSectionIndex: selectedSection,
        editingTextLayerId: editingLayer,
        textEditingController: _controller,
        textFocusNode: _focus,
        onSelectLayer: (id) => setState(() {
          selectedLayer = id;
          selectedSection = null;
          editingLayer = null;
        }),
        onBeginTextEdit: (id) => setState(() => editingLayer = id),
        onEndTextEdit: () {
          _focus.unfocus();
          setState(() => editingLayer = null);
        },
        onTextEdited: (_) => setState(() {
          _controller.applyToLayer(widget.document.layerById(editingLayer!)!);
        }),
        onSelectIconSection: (id, index) {
          _focus.unfocus();
          setState(() {
            selectedLayer = id;
            selectedSection = index;
            editingLayer = null;
          });
        },
        onIconSectionScaled: (id, index, size) {
          widget.onSectionScaled?.call(size);
          setState(
            () =>
                widget.document.layerById(id)!.sections[index].iconSize = size,
          );
        },
        onLayerScaled: (_, scale) => widget.onLayerScaled?.call(scale),
      ),
    ),
  );
}

void main() {
  testWidgets(
    'direct text editing and handles coexist with section selection',
    (tester) async {
      final document = _document();
      final harnessKey = GlobalKey<_CanvasHarnessState>();
      await tester.pumpWidget(
        _CanvasHarness(key: harnessKey, document: document),
      );
      await tester.pump();
      expect(find.byIcon(Icons.rotate_right), findsOneWidget);

      // Outlined text paints stroke and fill as separate Text widgets.
      final titlePosition = tester.getCenter(find.text('Preview title').first);
      await tester.tapAt(titlePosition);
      await tester.pump(const Duration(milliseconds: 60));
      await tester.tapAt(titlePosition);
      await tester.pump();

      expect(harnessKey.currentState!.editingLayer, 'title');
      expect(find.byType(TextField), findsOneWidget);
      expect(find.byIcon(Icons.rotate_right), findsOneWidget);
      await tester.enterText(find.byType(TextField), 'Edited directly');
      await tester.pump();
      expect(document.layerById('title')!.plainText, 'Edited directly');

      await tester.tap(
        find.byKey(const ValueKey('preview-icon-section-icons-0')),
      );
      await tester.pump();
      expect(harnessKey.currentState!.selectedLayer, 'icons');
      expect(harnessKey.currentState!.selectedSection, 0);
      expect(harnessKey.currentState!.editingLayer, isNull);
      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(Icons.rotate_right), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Ctrl wheel scales the selected section, not the whole layer', (
    tester,
  ) async {
    final sectionSizes = <double>[];
    final layerScales = <double>[];
    await tester.pumpWidget(
      _CanvasHarness(
        document: _document(),
        initialLayer: 'icons',
        initialSection: 0,
        onSectionScaled: sectionSizes.add,
        onLayerScaled: layerScales.add,
      ),
    );
    await tester.pump();
    final position = tester.getCenter(
      find.byKey(const ValueKey('preview-icon-section-icons-0')),
    );

    await tester.sendKeyDownEvent(LogicalKeyboardKey.controlLeft);
    try {
      await tester.sendEventToBinding(
        PointerScrollEvent(
          position: position,
          scrollDelta: const Offset(0, -40),
        ),
      );
      await tester.pump();
      expect(sectionSizes, hasLength(1));
      expect(sectionSizes.single, closeTo(54, 0.001));
      expect(layerScales, isEmpty);
    } finally {
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('section pinch uses its starting icon size for every update', (
    tester,
  ) async {
    final document = _document();
    final sectionSizes = <double>[];
    final layerScales = <double>[];
    await tester.pumpWidget(
      _CanvasHarness(
        document: document,
        initialLayer: 'icons',
        initialSection: 0,
        onSectionScaled: sectionSizes.add,
        onLayerScaled: layerScales.add,
      ),
    );
    await tester.pump();
    final section = find.byKey(const ValueKey('preview-icon-section-icons-0'));
    final gesture = tester.widget<GestureDetector>(section);
    expect(gesture.onScaleStart, isNotNull);
    expect(gesture.onScaleUpdate, isNotNull);
    gesture.onScaleStart!(ScaleStartDetails(pointerCount: 2));
    await tester.pump();

    gesture.onScaleUpdate!(ScaleUpdateDetails(scale: 1.5, pointerCount: 2));
    await tester.pump();
    expect(document.layerById('icons')!.sections.single.iconSize, 75);
    tester.widget<GestureDetector>(section).onScaleUpdate!(
      ScaleUpdateDetails(scale: 2, pointerCount: 2),
    );
    await tester.pump();
    expect(sectionSizes, [75, 100]);
    expect(document.layerById('icons')!.sections.single.iconSize, 100);
    expect(layerScales, isEmpty);
    expect(tester.takeException(), isNull);
  });
}
