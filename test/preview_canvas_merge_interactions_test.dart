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
    this.onLayerScaled,
  });

  final PreviewDocument document;
  final String initialLayer;
  final ValueChanged<double>? onLayerScaled;

  @override
  State<_CanvasHarness> createState() => _CanvasHarnessState();
}

class _CanvasHarnessState extends State<_CanvasHarness> {
  final _controller = PreviewRichTextController();
  final _focus = FocusNode();
  late String? selectedLayer;
  String? editingLayer;

  @override
  void initState() {
    super.initState();
    selectedLayer = widget.initialLayer;
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
        editingTextLayerId: editingLayer,
        textEditingController: _controller,
        textFocusNode: _focus,
        onSelectLayer: (id) => setState(() {
          selectedLayer = id;
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
        onLayerScaled: (id, scale) {
          widget.onLayerScaled?.call(scale);
          setState(() => widget.document.layerById(id)!.scale = scale);
        },
      ),
    ),
  );
}

void main() {
  testWidgets(
    'direct text editing and handles coexist with icon group selection',
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
        find.byKey(const ValueKey('preview-icon-item-icons-0-0-0')),
      );
      await tester.pump();
      expect(harnessKey.currentState!.selectedLayer, 'icons');
      expect(harnessKey.currentState!.editingLayer, isNull);
      expect(find.byType(TextField), findsNothing);
      expect(find.byIcon(Icons.rotate_right), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Ctrl wheel scales the whole selected icon group', (
    tester,
  ) async {
    final layerScales = <double>[];
    await tester.pumpWidget(
      _CanvasHarness(
        document: _document(),
        initialLayer: 'icons',
        onLayerScaled: layerScales.add,
      ),
    );
    await tester.pump();
    final position = tester.getCenter(
      find.byKey(const ValueKey('preview-icon-item-icons-0-0-0')),
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
      expect(layerScales, hasLength(1));
      expect(layerScales.single, closeTo(1.08, 0.001));
    } finally {
      await tester.sendKeyUpEvent(LogicalKeyboardKey.controlLeft);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('group pinch uses its starting scale for every update', (
    tester,
  ) async {
    final document = _document();
    final layerScales = <double>[];
    await tester.pumpWidget(
      _CanvasHarness(
        document: document,
        initialLayer: 'icons',
        onLayerScaled: layerScales.add,
      ),
    );
    await tester.pump();
    final group = find.byKey(const ValueKey('preview-layer-gesture-icons'));
    final gesture = tester.widget<GestureDetector>(group);
    expect(gesture.onScaleStart, isNotNull);
    expect(gesture.onScaleUpdate, isNotNull);
    gesture.onScaleStart!(ScaleStartDetails(pointerCount: 2));
    await tester.pump();

    gesture.onScaleUpdate!(ScaleUpdateDetails(scale: 1.5, pointerCount: 2));
    await tester.pump();
    expect(document.layerById('icons')!.scale, 1.5);
    tester.widget<GestureDetector>(group).onScaleUpdate!(
      ScaleUpdateDetails(scale: 2, pointerCount: 2),
    );
    await tester.pump();
    expect(layerScales, [1.5, 2]);
    expect(document.layerById('icons')!.scale, 2);
    expect(document.layerById('icons')!.sections.single.iconSize, 50);
    expect(tester.takeException(), isNull);
  });
}
