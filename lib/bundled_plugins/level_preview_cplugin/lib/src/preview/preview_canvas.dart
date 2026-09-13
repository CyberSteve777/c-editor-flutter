import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/gif_first_frame.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_file_image.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_fonts.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_rich_text_controller.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/lawn_grid.dart';

enum _BoxHandle { nw, n, ne, e, se, s, sw, w, rotate }

/// Extra space around the design banner so edge/rotate handles stay hittable.
/// Covers the rotate gap (28) plus half of the handle hit area (16).
const double kPreviewInteractPad = 48.0;

double _interactionPaddingForViewport(BoxConstraints constraints) {
  if (!constraints.hasBoundedWidth && !constraints.hasBoundedHeight) {
    return kPreviewInteractPad;
  }
  final shortestSide = math.min(constraints.maxWidth, constraints.maxHeight);
  final gutter = (shortestSide * 0.025).clamp(8.0, 16.0);
  final fitScale = math.min(
    (constraints.maxWidth - gutter * 2) /
        (kPreviewCanvasSize.width + kPreviewInteractPad * 2),
    (constraints.maxHeight - gutter * 2) /
        (kPreviewCanvasSize.height + kPreviewInteractPad * 2),
  );
  if (!fitScale.isFinite || fitScale <= 0) {
    return kPreviewInteractPad;
  }
  // Keep only a small, screen-space gutter beyond the editing handles, rather
  // than scaling a large fixed design-space margin together with the image.
  return kPreviewInteractPad + gutter / fitScale;
}

/// Renders a [PreviewDocument] at design size inside a [RepaintBoundary].
class PreviewCanvas extends StatefulWidget {
  const PreviewCanvas({
    super.key,
    required this.document,
    this.interactive = false,
    this.tool = PreviewEditTool.select,
    this.selectedLayerId,
    this.selectedIconSectionIndex,
    this.selectedTextPart,
    this.drawColor = Colors.white,
    this.drawStrokeWidth = 4,
    this.onSelectLayer,
    this.onSelectIconSection,
    this.onSelectTextPart,
    this.onIconSectionScaled,
    this.onLayerMoved,
    this.onLayerScaled,
    this.onLayerRotated,
    this.onStrokeStarted,
    this.onStrokeUpdated,
    this.onStrokeEnded,
    this.onEraseAt,
    this.onShapeDraft,
    this.textEditingController,
    this.textFocusNode,
    this.editingTextLayerId,
    this.onBeginTextEdit,
    this.onEndTextEdit,
    this.onTextEdited,
    this.boundaryKey,
  });

  final PreviewDocument document;
  final bool interactive;
  final PreviewEditTool tool;
  final String? selectedLayerId;
  final int? selectedIconSectionIndex;
  final PreviewTextPartSelection? selectedTextPart;
  final Color drawColor;
  final double drawStrokeWidth;
  final ValueChanged<String?>? onSelectLayer;
  final void Function(String layerId, int sectionIndex)? onSelectIconSection;
  final ValueChanged<PreviewTextPartSelection>? onSelectTextPart;

  /// Icon size (not cumulative layer scale) for a selected section.
  final void Function(String layerId, int sectionIndex, double iconSize)?
  onIconSectionScaled;
  final void Function(String id, Rect newBounds)? onLayerMoved;
  final void Function(String id, double newScale)? onLayerScaled;
  final void Function(String id, double rotation)? onLayerRotated;
  final void Function(Offset normalized)? onStrokeStarted;
  final void Function(Offset normalized)? onStrokeUpdated;
  final VoidCallback? onStrokeEnded;

  /// Eraser brush hit in normalized canvas coords.
  final void Function(Offset normalized)? onEraseAt;
  final void Function(Rect normalizedBounds)? onShapeDraft;

  /// When set and a text layer is selected, that layer edits in-place.
  final TextEditingController? textEditingController;
  final FocusNode? textFocusNode;

  /// Explicit in-place text edit target (PowerPoint-style).
  final String? editingTextLayerId;
  final ValueChanged<String>? onBeginTextEdit;
  final VoidCallback? onEndTextEdit;
  final ValueChanged<String>? onTextEdited;
  final GlobalKey? boundaryKey;

  @override
  State<PreviewCanvas> createState() => PreviewCanvasState();
}

class PreviewCanvasState extends State<PreviewCanvas> {
  final Map<String, ui.Image> _gifFrames = {};
  final Set<String> _gifLoading = {};
  final GlobalKey _canvasKey = GlobalKey();
  Offset? _shapeStart;

  @override
  void initState() {
    super.initState();
    _prefetchGifs();
  }

  @override
  void didUpdateWidget(covariant PreviewCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.document, widget.document)) {
      _prefetchGifs();
    }
  }

  void _prefetchGifs() {
    for (final layer in widget.document.layers) {
      final paths = <String>{};
      if (layer.kind == PreviewLayerKind.iconGrid) {
        paths.addAll({
          for (final item in layer.items) item.assetPath,
          for (final section in layer.sections)
            for (final item in section.items) item.assetPath,
        });
      } else if (layer.kind == PreviewLayerKind.image &&
          layer.imageAsset != null) {
        paths.add(layer.imageAsset!);
      }
      for (final assetPath in paths) {
        if (!isGifAssetPath(assetPath)) continue;
        if (_gifFrames.containsKey(assetPath)) continue;
        if (_gifLoading.contains(assetPath)) continue;
        _gifLoading.add(assetPath);
        decodeFirstFrameFromAsset(assetPath).then((img) {
          if (!mounted) {
            img?.dispose();
            return;
          }
          setState(() {
            _gifLoading.remove(assetPath);
            if (img != null) _gifFrames[assetPath] = img;
          });
        });
      }
    }
  }

  @override
  void dispose() {
    for (final img in _gifFrames.values) {
      img.dispose();
    }
    super.dispose();
  }

  Offset _toNorm(Offset local) => Offset(
    (local.dx / kPreviewCanvasSize.width).clamp(0.0, 1.0),
    (local.dy / kPreviewCanvasSize.height).clamp(0.0, 1.0),
  );

  PreviewLayer? get _selectedLayer {
    final id = widget.selectedLayerId;
    if (id == null) return null;
    return widget.document.layerById(id);
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.document;
    final w = kPreviewCanvasSize.width;
    final h = kPreviewCanvasSize.height;
    final drawing =
        widget.interactive &&
        (widget.tool == PreviewEditTool.pen ||
            widget.tool == PreviewEditTool.eraser ||
            widget.tool == PreviewEditTool.figures);
    final selected = _selectedLayer;

    final design = SizedBox(
      key: _canvasKey,
      width: w,
      height: h,
      child: RepaintBoundary(
        key: widget.boundaryKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          // Deselect is handled by a behind-layers hit target so it does not
          // race text Listener pointer-ups and cancel in-place editing.
          onPanStart: drawing
              ? (d) {
                  final n = _toNorm(d.localPosition);
                  if (widget.tool == PreviewEditTool.pen) {
                    widget.onStrokeStarted?.call(n);
                  } else if (widget.tool == PreviewEditTool.eraser) {
                    widget.onEraseAt?.call(n);
                  } else {
                    _shapeStart = n;
                  }
                }
              : null,
          onPanUpdate: drawing
              ? (d) {
                  final n = _toNorm(d.localPosition);
                  if (widget.tool == PreviewEditTool.pen) {
                    widget.onStrokeUpdated?.call(n);
                  } else if (widget.tool == PreviewEditTool.eraser) {
                    widget.onEraseAt?.call(n);
                  } else if (_shapeStart != null) {
                    final s = _shapeStart!;
                    final left = s.dx < n.dx ? s.dx : n.dx;
                    final top = s.dy < n.dy ? s.dy : n.dy;
                    final width = (s.dx - n.dx).abs().clamp(0.01, 1.0);
                    final height = (s.dy - n.dy).abs().clamp(0.01, 1.0);
                    widget.onShapeDraft?.call(
                      Rect.fromLTWH(left, top, width, height),
                    );
                  }
                }
              : null,
          onPanEnd: drawing
              ? (_) {
                  if (widget.tool == PreviewEditTool.pen) {
                    widget.onStrokeEnded?.call();
                  }
                  _shapeStart = null;
                }
              : null,
          child: Stack(
            fit: StackFit.expand,
            clipBehavior: Clip.none,
            children: [
              _buildBanner(doc),
              if (widget.interactive && widget.tool == PreviewEditTool.select)
                Positioned.fill(
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () {
                      widget.onEndTextEdit?.call();
                      widget.onSelectLayer?.call(null);
                    },
                  ),
                ),
              for (final layer in doc.sortedLayers)
                if (layer.visible)
                  _LayerWidget(
                    layer: layer,
                    canvasSize: kPreviewCanvasSize,
                    interactive:
                        widget.interactive &&
                        widget.tool == PreviewEditTool.select,
                    selected: widget.selectedLayerId == layer.id,
                    editingText: widget.editingTextLayerId == layer.id,
                    selectedIconSectionIndex: widget.selectedLayerId == layer.id
                        ? widget.selectedIconSectionIndex
                        : null,
                    selectedTextPart: widget.selectedLayerId == layer.id
                        ? widget.selectedTextPart
                        : null,
                    gifFrames: _gifFrames,
                    textEditingController:
                        widget.selectedLayerId == layer.id &&
                            layer.kind == PreviewLayerKind.text
                        ? widget.textEditingController
                        : null,
                    textFocusNode:
                        widget.selectedLayerId == layer.id &&
                            layer.kind == PreviewLayerKind.text
                        ? widget.textFocusNode
                        : null,
                    onTextEdited: widget.onTextEdited,
                    onSelect: () => widget.onSelectLayer?.call(layer.id),
                    onBeginTextEdit: () =>
                        widget.onBeginTextEdit?.call(layer.id),
                    onSelectIconSection: (index) =>
                        widget.onSelectIconSection?.call(layer.id, index),
                    onSelectTextPart: widget.onSelectTextPart,
                    onIconSectionScaled: widget.onIconSectionScaled == null
                        ? null
                        : (index, size) => widget.onIconSectionScaled?.call(
                            layer.id,
                            index,
                            size,
                          ),
                    onMoved: (bounds) =>
                        widget.onLayerMoved?.call(layer.id, bounds),
                    onScaled: (scale) =>
                        widget.onLayerScaled?.call(layer.id, scale),
                  ),
            ],
          ),
        ),
      ),
    );

    final showHandles =
        widget.interactive &&
        widget.tool == PreviewEditTool.select &&
        selected != null &&
        selected.kind != PreviewLayerKind.stroke &&
        widget.selectedIconSectionIndex == null &&
        widget.selectedTextPart == null;
    final editingText =
        widget.editingTextLayerId != null &&
        widget.editingTextLayerId == widget.selectedLayerId;

    // Outer size includes pad so handles past the banner still receive hits.
    // Export [RepaintBoundary] stays at design size only.
    return LayoutBuilder(
      builder: (context, constraints) {
        final pad = widget.interactive
            ? _interactionPaddingForViewport(constraints)
            : 0.0;
        // Center passes loose constraints: without an explicit viewport size,
        // FittedBox stops growing once it reaches the design's natural size.
        return SizedBox(
          width: constraints.hasBoundedWidth ? constraints.maxWidth : null,
          height: constraints.hasBoundedHeight ? constraints.maxHeight : null,
          child: FittedBox(
            fit: BoxFit.contain,
            child: SizedBox(
              width: w + pad * 2,
              height: h + pad * 2,
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerSignal: _onCanvasPointerSignal,
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      left: pad,
                      top: pad,
                      width: w,
                      height: h,
                      child: design,
                    ),
                    if (showHandles)
                      _SelectionHandlesOverlay(
                        layer: selected,
                        canvasSize: kPreviewCanvasSize,
                        canvasKey: _canvasKey,
                        originOffset: Offset(pad, pad),
                        stripedBorder: editingText,
                        onMoved: (bounds) =>
                            widget.onLayerMoved?.call(selected.id, bounds),
                        onRotated: (rotation) =>
                            widget.onLayerRotated?.call(selected.id, rotation),
                        onSelect: () => widget.onSelectLayer?.call(selected.id),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void _onCanvasPointerSignal(PointerSignalEvent event) {
    if (!widget.interactive) return;
    if (widget.tool != PreviewEditTool.select) return;
    if (event is! PointerScrollEvent) return;
    final ctrl =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (!ctrl) return;
    final layer = _selectedLayer;
    if (layer == null) return;
    if (widget.selectedTextPart != null) return;
    final delta = event.scrollDelta.dy;
    if (delta == 0) return;
    final sectionIndex = widget.selectedIconSectionIndex;
    if (layer.kind == PreviewLayerKind.iconGrid && sectionIndex != null) {
      final sections = previewEffectiveSections(layer);
      if (sectionIndex < 0 || sectionIndex >= sections.length) return;
      final next = (sections[sectionIndex].iconSize * (delta > 0 ? 0.92 : 1.08))
          .clamp(20.0, 152.0);
      widget.onIconSectionScaled?.call(layer.id, sectionIndex, next.toDouble());
      return;
    }
    if (layer.kind == PreviewLayerKind.text ||
        layer.kind == PreviewLayerKind.image ||
        layer.kind == PreviewLayerKind.stroke) {
      return;
    }
    final next = (layer.scale * (delta > 0 ? 0.92 : 1.08)).clamp(0.25, 4.0);
    widget.onLayerScaled?.call(layer.id, next.toDouble());
  }

  Widget _buildBanner(PreviewDocument doc) {
    final ref = doc.banner;
    if (ref.kind == PreviewBannerSourceKind.userFile &&
        ref.userFilePath != null) {
      final fileImg = fileBannerImage(
        ref.userFilePath!,
        fit: BoxFit.fill,
        width: kPreviewCanvasSize.width,
        height: kPreviewCanvasSize.height,
      );
      if (fileImg != null) return fileImg;
    }
    final asset =
        ref.assetPath ??
        'lib/bundled_plugins/level_preview_cplugin/assets/banners/Unknown.png';
    return Image.asset(
      asset,
      fit: BoxFit.cover,
      width: kPreviewCanvasSize.width,
      height: kPreviewCanvasSize.height,
      errorBuilder: (_, _, _) => Container(color: const Color(0xFF0B2A33)),
    );
  }
}

Rect _growIconGridBoundsIfNeeded(
  PreviewLayer layer,
  Rect proposed,
  Size canvas,
) {
  if (layer.kind != PreviewLayerKind.iconGrid) return proposed;
  final maxW = proposed.width * canvas.width;
  final intrinsic = previewIconGridIntrinsicSize(
    maxWidth: maxW,
    sections: previewEffectiveSections(layer),
    showChrome: layer.showChrome,
    gridTitle: layer.gridTitle,
    sourceLabel: layer.sourceLabel,
    lawnRows: layer.lawnRows,
    lawnCols: layer.lawnCols,
  );
  final needH = (intrinsic.height / canvas.height).clamp(
    0.04,
    1.0 - proposed.top,
  );
  final h = math.max(proposed.height, needH);
  return Rect.fromLTWH(proposed.left, proposed.top, proposed.width, h);
}

class _LayerWidget extends StatefulWidget {
  const _LayerWidget({
    required this.layer,
    required this.canvasSize,
    required this.interactive,
    required this.selected,
    required this.editingText,
    required this.selectedIconSectionIndex,
    required this.selectedTextPart,
    required this.gifFrames,
    required this.onSelect,
    required this.onSelectIconSection,
    required this.onSelectTextPart,
    required this.onMoved,
    required this.onScaled,
    this.onBeginTextEdit,
    this.textEditingController,
    this.textFocusNode,
    this.onTextEdited,
    this.onIconSectionScaled,
  });

  final PreviewLayer layer;
  final Size canvasSize;
  final bool interactive;
  final bool selected;
  final bool editingText;
  final int? selectedIconSectionIndex;
  final PreviewTextPartSelection? selectedTextPart;
  final Map<String, ui.Image> gifFrames;
  final VoidCallback onSelect;
  final VoidCallback? onBeginTextEdit;
  final ValueChanged<int> onSelectIconSection;
  final ValueChanged<PreviewTextPartSelection>? onSelectTextPart;
  final ValueChanged<Rect> onMoved;
  final ValueChanged<double> onScaled;
  final void Function(int sectionIndex, double iconSize)? onIconSectionScaled;
  final TextEditingController? textEditingController;
  final FocusNode? textFocusNode;
  final ValueChanged<String>? onTextEdited;

  @override
  State<_LayerWidget> createState() => _LayerWidgetState();
}

class _LayerWidgetState extends State<_LayerWidget> {
  double _scaleAtStart = 1;
  double _iconSizeAtScaleStart = 36;
  static const _minScale = 0.25;
  static const _maxScale = 4.0;
  static const _dragSlop = 4.0;

  Offset? _pointerDownLocal;
  Offset _lastPointerLocal = Offset.zero;
  bool _dragging = false;

  PreviewLayer get layer => widget.layer;

  @override
  void initState() {
    super.initState();
    widget.textFocusNode?.addListener(_onTextFocusChanged);
  }

  @override
  void didUpdateWidget(covariant _LayerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.textFocusNode != widget.textFocusNode) {
      oldWidget.textFocusNode?.removeListener(_onTextFocusChanged);
      widget.textFocusNode?.addListener(_onTextFocusChanged);
    }
    if (widget.editingText &&
        !oldWidget.editingText &&
        widget.textFocusNode != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && widget.editingText) {
          widget.textFocusNode?.requestFocus();
        }
      });
    }
  }

  @override
  void dispose() {
    widget.textFocusNode?.removeListener(_onTextFocusChanged);
    super.dispose();
  }

  void _onTextFocusChanged() {
    if (mounted) setState(() {});
  }

  bool get _textEditingActive =>
      layer.kind == PreviewLayerKind.text &&
      widget.editingText &&
      widget.textEditingController != null;

  /// Move in canvas/parent space. [localDelta] is in the layer's local axes
  /// (GestureDetector sits under [Transform.rotate]), so rotate it forward.
  void _moveByLocalDelta(Offset localDelta) {
    final a = layer.rotation;
    final c = math.cos(a);
    final s = math.sin(a);
    final parent = Offset(
      localDelta.dx * c - localDelta.dy * s,
      localDelta.dx * s + localDelta.dy * c,
    );
    final dx = parent.dx / widget.canvasSize.width;
    final dy = parent.dy / widget.canvasSize.height;
    final nl = (layer.bounds.left + dx).clamp(0.0, 1.0 - layer.bounds.width);
    final nt = (layer.bounds.top + dy).clamp(0.0, 1.0 - layer.bounds.height);
    widget.onMoved(
      Rect.fromLTWH(nl, nt, layer.bounds.width, layer.bounds.height),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (layer.kind == PreviewLayerKind.stroke) {
      return Opacity(
        opacity: layer.opacity.clamp(0.0, 1.0),
        child: CustomPaint(
          size: widget.canvasSize,
          painter: _StrokePainter(
            points: layer.points,
            color: layer.strokeColor,
            strokeWidth:
                layer.strokeWidth * layer.scale.clamp(_minScale, _maxScale),
            selected: widget.selected,
          ),
          child: widget.interactive
              ? GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTap: widget.onSelect,
                )
              : null,
        ),
      );
    }

    final scale =
        (layer.kind == PreviewLayerKind.text ||
            layer.kind == PreviewLayerKind.image)
        ? 1.0
        : layer.scale.clamp(_minScale, _maxScale);
    final left = layer.bounds.left * widget.canvasSize.width;
    final top = layer.bounds.top * widget.canvasSize.height;
    final baseW = layer.bounds.width * widget.canvasSize.width;
    final baseH = layer.bounds.height * widget.canvasSize.height;
    final hitW = baseW * scale;
    final hitH = baseH * scale;

    Widget content;
    switch (layer.kind) {
      case PreviewLayerKind.text:
        content = _buildText(baseW, baseH);
      case PreviewLayerKind.iconGrid:
        content = _buildIconGrid(baseW, baseH);
      case PreviewLayerKind.image:
        content = _buildImage(baseW, baseH);
      case PreviewLayerKind.shape:
        content = _buildShape(baseW, baseH);
      case PreviewLayerKind.stroke:
        content = const SizedBox.shrink();
    }

    if (layer.containedTexts.isNotEmpty &&
        (layer.kind == PreviewLayerKind.iconGrid ||
            layer.kind == PreviewLayerKind.shape)) {
      content = Stack(
        fit: StackFit.expand,
        children: [
          content,
          for (final contained in layer.containedTexts)
            _buildContainedText(contained, baseW, baseH),
        ],
      );
    }

    // Lay out at design size, then scale paint — avoids double-scaling when
    // the parent SizedBox is already hitW×hitH.
    final sizedContent = SizedBox(width: baseW, height: baseH, child: content);
    final body = scale == 1.0
        ? sizedContent
        : SizedBox(
            width: hitW,
            height: hitH,
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topLeft,
              child: OverflowBox(
                alignment: Alignment.topLeft,
                minWidth: baseW,
                maxWidth: baseW,
                minHeight: baseH,
                maxHeight: baseH,
                child: sizedContent,
              ),
            ),
          );

    final allowScale =
        layer.kind != PreviewLayerKind.text &&
        layer.kind != PreviewLayerKind.image;
    final editingText = _textEditingActive;

    void beginTextEdit() {
      widget.onSelect();
      widget.onBeginTextEdit?.call();
    }

    final child = !widget.interactive
        ? body
        : editingText
        // No competing GestureDetector while editing — TextField must get taps.
        ? body
        : layer.kind == PreviewLayerKind.text
        // Tap / double-tap to edit; drag only after slop so taps still work.
        ? Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (event) {
              _pointerDownLocal = event.localPosition;
              _lastPointerLocal = event.localPosition;
              _dragging = false;
            },
            onPointerMove: (event) {
              final start = _pointerDownLocal;
              if (start == null) return;
              if (!_dragging) {
                if ((event.localPosition - start).distance >= _dragSlop) {
                  _dragging = true;
                  widget.onSelect();
                } else {
                  return;
                }
              }
              final delta = event.localPosition - _lastPointerLocal;
              _lastPointerLocal = event.localPosition;
              _moveByLocalDelta(delta);
            },
            onPointerUp: (event) {
              final wasDragging = _dragging;
              _pointerDownLocal = null;
              _dragging = false;
              if (wasDragging) return;
              if (widget.selected && widget.textEditingController != null) {
                beginTextEdit();
              } else {
                widget.onSelect();
              }
            },
            onPointerCancel: (_) {
              _pointerDownLocal = null;
              _dragging = false;
            },
            child: GestureDetector(
              behavior: HitTestBehavior.translucent,
              onDoubleTap: widget.textEditingController != null
                  ? beginTextEdit
                  : null,
              child: body,
            ),
          )
        : GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: widget.onSelect,
            onScaleStart: (_) {
              widget.onSelect();
              _scaleAtStart = layer.scale;
            },
            onScaleUpdate: (details) {
              if (allowScale && details.pointerCount >= 2) {
                widget.onScaled(
                  (_scaleAtStart * details.scale).clamp(_minScale, _maxScale),
                );
                return;
              }
              _moveByLocalDelta(details.focalPointDelta);
            },
            child: body,
          );

    return Positioned(
      left: left,
      top: top,
      width: hitW,
      height: hitH,
      child: Opacity(
        opacity: layer.opacity.clamp(0.0, 1.0),
        child: Transform.rotate(
          angle: layer.rotation,
          alignment: Alignment.center,
          child: child,
        ),
      ),
    );
  }

  Widget _buildText(double width, double height) {
    final runs = layer.effectiveTextRuns();
    final align = layer.textAlign;
    final editing = _textEditingActive;

    Widget richVisual() {
      if (runs.isEmpty && !editing) {
        return SizedBox(width: width, height: height);
      }
      final hasOutline = runs.any((r) => r.style.outline);
      final base = Text.rich(
        TextSpan(
          children: [
            for (final run in runs)
              TextSpan(
                text: run.text,
                style: PreviewFonts.resolve(
                  run.style,
                  fill: !run.style.outline,
                ),
              ),
          ],
        ),
        textAlign: align,
        softWrap: true,
      );
      if (!hasOutline) return base;
      return Stack(
        children: [
          Text.rich(
            TextSpan(
              children: [
                for (final run in runs)
                  TextSpan(
                    text: run.text,
                    style: PreviewFonts.resolve(run.style, fill: false),
                  ),
              ],
            ),
            textAlign: align,
            softWrap: true,
          ),
          Text.rich(
            TextSpan(
              children: [
                for (final run in runs)
                  TextSpan(
                    text: run.text,
                    style: run.style.outline
                        ? PreviewFonts.resolve(run.style, fill: true)
                        : PreviewFonts.resolve(
                            run.style,
                            fill: true,
                          ).copyWith(color: Colors.transparent),
                  ),
              ],
            ),
            textAlign: align,
            softWrap: true,
          ),
        ],
      );
    }

    final fittedAlign = switch (align) {
      TextAlign.center || TextAlign.justify => Alignment.center,
      TextAlign.right || TextAlign.end => Alignment.centerRight,
      _ => Alignment.centerLeft,
    };

    final pad = layer.textBackgroundColor != null
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
        : EdgeInsets.zero;
    final decoration = layer.textBackgroundColor != null
        ? BoxDecoration(
            color: layer.textBackgroundColor,
            borderRadius: BorderRadius.circular(6),
          )
        : null;

    // Single TextField paints styled runs via PreviewRichTextController —
    // no transparent overlay (that caused selected vs idle style mismatch).
    if (editing && widget.textEditingController != null) {
      final caretStyle =
          widget.textEditingController is PreviewRichTextController
          ? (widget.textEditingController as PreviewRichTextController)
                .styleAtCaret()
          : (layer.textStyle ??
                (runs.isNotEmpty ? runs.first.style : PreviewTextStyleData()));
      final fieldStyle = PreviewFonts.resolveFieldBase(caretStyle);
      return SizedBox(
        width: width,
        height: height,
        child: Container(
          padding: pad,
          decoration: decoration,
          child: TextField(
            controller: widget.textEditingController,
            focusNode: widget.textFocusNode,
            maxLines: null,
            expands: true,
            style: fieldStyle,
            cursorColor: Colors.white,
            showCursor: true,
            textAlign: align,
            decoration: const InputDecoration(
              isCollapsed: true,
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
            onChanged: widget.onTextEdited,
          ),
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: fittedAlign,
        child: Container(
          width: width,
          padding: pad,
          decoration: decoration,
          child: richVisual(),
        ),
      ),
    );
  }

  Widget _buildIconGrid(double width, double height) {
    final sections = previewEffectiveSections(layer);
    // Chrome padding is 8 all around; row content must fill that inner width so
    // justify/spaceBetween can stretch icon gaps when the layer is widened.
    final rowWidth = math.max(0.0, width - (layer.showChrome ? 16 : 0));
    final cross = switch (layer.iconAlign) {
      TextAlign.justify => CrossAxisAlignment.stretch,
      TextAlign.center => CrossAxisAlignment.center,
      TextAlign.right || TextAlign.end => CrossAxisAlignment.end,
      _ => CrossAxisAlignment.start,
    };
    final wrapAlign = switch (layer.iconAlign) {
      TextAlign.center => WrapAlignment.center,
      TextAlign.right || TextAlign.end => WrapAlignment.end,
      TextAlign.justify => WrapAlignment.spaceBetween,
      _ => WrapAlignment.start,
    };
    final titleAlign = layer.iconAlign;
    final useLawn =
        layer.lawnRows != null &&
        layer.lawnCols != null &&
        layer.lawnRows! > 0 &&
        layer.lawnCols! > 0 &&
        sections.any((s) => s.items.any((i) => i.hasCell));

    Widget sectionBody(PreviewIconSection section) {
      if (useLawn) {
        return _buildMiniLawn(
          width: rowWidth,
          rows: layer.lawnRows!,
          cols: layer.lawnCols!,
          items: section.items,
        );
      }
      return SizedBox(
        width: rowWidth,
        child: Wrap(
          spacing: layer.iconAlign == TextAlign.justify ? 0 : 4,
          runSpacing: 4,
          alignment: wrapAlign,
          children: [
            for (final item in section.items.take(48))
              _ItemIcon(
                item: item,
                gifFrames: widget.gifFrames,
                size: section.iconSize,
              ),
          ],
        ),
      );
    }

    final body = Column(
      crossAxisAlignment: cross,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          if (sections[i].title != null && sections[i].title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _selectableTextPart(
                selection: PreviewTextPartSelection(
                  layerId: layer.id,
                  kind: PreviewTextPartKind.sectionTitle,
                  sectionIndex: i,
                ),
                child: SizedBox(
                  width: rowWidth,
                  child: Text(
                    sections[i].title!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    textAlign: titleAlign,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.95),
                      fontSize: sections[i].iconSize >= 64 ? 15 : 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          _selectableIconSection(index: i, child: sectionBody(sections[i])),
        ],
      ],
    );

    // Stack + Positioned (no bottom) gives the column unbounded height so
    // RenderFlex never overflows; ClipRect hides anything past [height].
    Widget clipFill({required Widget child}) {
      return SizedBox(
        width: width,
        height: height,
        child: ClipRect(
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [Positioned(left: 0, top: 0, width: width, child: child)],
          ),
        ),
      );
    }

    if (!layer.showChrome) {
      return clipFill(child: body);
    }

    return clipFill(
      child: Container(
        width: width,
        constraints: BoxConstraints(minHeight: height),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.white24),
        ),
        child: Column(
          crossAxisAlignment: cross,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (layer.gridTitle != null && layer.gridTitle!.isNotEmpty)
              _selectableTextPart(
                selection: PreviewTextPartSelection(
                  layerId: layer.id,
                  kind: PreviewTextPartKind.gridTitle,
                ),
                child: SizedBox(
                  width: rowWidth,
                  child: Text(
                    layer.gridTitle!,
                    textAlign: titleAlign,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            if (layer.sourceLabel != null && layer.sourceLabel!.isNotEmpty)
              _selectableTextPart(
                selection: PreviewTextPartSelection(
                  layerId: layer.id,
                  kind: PreviewTextPartKind.sourceLabel,
                ),
                child: SizedBox(
                  width: rowWidth,
                  child: Text(
                    layer.sourceLabel!,
                    maxLines: 6,
                    overflow: TextOverflow.ellipsis,
                    textAlign: titleAlign,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 11,
                      height: 1.25,
                    ),
                  ),
                ),
              ),
            if ((layer.gridTitle != null && layer.gridTitle!.isNotEmpty) ||
                (layer.sourceLabel != null && layer.sourceLabel!.isNotEmpty))
              const SizedBox(height: 4),
            body,
          ],
        ),
      ),
    );
  }

  Widget _buildMiniLawn({
    required double width,
    required int rows,
    required int cols,
    required List<PreviewItem> items,
  }) {
    final byCell = <String, List<PreviewItem>>{};
    for (final item in items.take(96)) {
      if (!item.hasCell) continue;
      final key = '${item.gridX},${item.gridY}';
      (byCell[key] ??= []).add(item);
    }
    return LawnGrid(
      rows: rows,
      cols: cols,
      maxWidth: width,
      style: LevelPreviewGridStyle(
        gridBg: const Color(0xFF1A1A1A).withValues(alpha: 0.55),
        borderColor: Colors.white24,
        cellBorderColor: Colors.white24,
        cellAspectRatio: 1.0,
        maxWidth: width,
      ),
      cellBuilder: (context, col, row) {
        final list = byCell['$col,$row'];
        if (list == null || list.isEmpty) return null;
        Widget iconFor(PreviewItem item) {
          final gif = widget.gifFrames[item.assetPath];
          if (gif != null) {
            return RawImage(image: gif, fit: BoxFit.contain);
          }
          return AssetImageWidget(
            assetPath: item.assetPath,
            altCandidates: imageAltCandidates(item.assetPath),
            fit: BoxFit.contain,
          );
        }

        if (list.length == 1) {
          return Padding(
            padding: const EdgeInsets.all(1),
            child: iconFor(list.first),
          );
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            for (var i = 0; i < list.length && i < 4; i++)
              Padding(
                padding: EdgeInsets.only(
                  left: i * 2.0,
                  top: i * 2.0,
                  right: 1,
                  bottom: 1,
                ),
                child: iconFor(list[i]),
              ),
          ],
        );
      },
    );
  }

  Widget _selectableIconSection({required int index, required Widget child}) {
    if (!widget.interactive) return child;
    final selected =
        widget.selected && widget.selectedIconSectionIndex == index;
    return GestureDetector(
      key: ValueKey('preview-icon-section-${layer.id}-$index'),
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onSelectIconSection(index),
      onScaleStart: widget.onIconSectionScaled == null
          ? null
          : (_) {
              widget.onSelectIconSection(index);
              _iconSizeAtScaleStart = previewEffectiveSections(
                layer,
              )[index].iconSize;
            },
      onScaleUpdate: widget.onIconSectionScaled == null
          ? null
          : (details) {
              if (details.pointerCount >= 2) {
                widget.onIconSectionScaled?.call(
                  index,
                  (_iconSizeAtScaleStart * details.scale).clamp(20.0, 152.0),
                );
              } else {
                _moveByLocalDelta(details.focalPointDelta);
              }
            },
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: selected
              ? Border.all(color: Colors.lightBlueAccent, width: 2)
              : null,
          borderRadius: BorderRadius.circular(4),
        ),
        child: child,
      ),
    );
  }

  Widget _selectableTextPart({
    required PreviewTextPartSelection selection,
    required Widget child,
  }) {
    if (!widget.interactive) return child;
    final selected = widget.selected && widget.selectedTextPart == selection;
    final keySuffix = switch (selection.kind) {
      PreviewTextPartKind.gridTitle => 'grid-title',
      PreviewTextPartKind.sourceLabel => 'source-label',
      PreviewTextPartKind.sectionTitle =>
        'section-title-${selection.sectionIndex}',
      PreviewTextPartKind.contained => 'contained-${selection.containedTextId}',
    };
    return GestureDetector(
      key: ValueKey('preview-text-part-${layer.id}-$keySuffix'),
      behavior: HitTestBehavior.opaque,
      onTap: () => widget.onSelectTextPart?.call(selection),
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: selected
              ? Border.all(color: Colors.amberAccent, width: 2)
              : null,
          borderRadius: BorderRadius.circular(3),
        ),
        child: child,
      ),
    );
  }

  Widget _buildContainedText(
    PreviewContainedText contained,
    double width,
    double height,
  ) {
    final bounds = contained.bounds;
    final selection = PreviewTextPartSelection(
      layerId: layer.id,
      kind: PreviewTextPartKind.contained,
      containedTextId: contained.id,
    );
    final style = contained.style;
    final fillText = Text(
      contained.text,
      textAlign: contained.textAlign,
      style: PreviewFonts.resolve(style, fill: true),
    );
    final text = style.outline
        ? Stack(
            children: [
              Text(
                contained.text,
                textAlign: contained.textAlign,
                style: PreviewFonts.resolve(style, fill: false),
              ),
              fillText,
            ],
          )
        : fillText;
    return Positioned(
      left: bounds.left * width,
      top: bounds.top * height,
      width: bounds.width * width,
      height: bounds.height * height,
      child: _selectableTextPart(
        selection: selection,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.center,
          child: SizedBox(width: bounds.width * width, child: text),
        ),
      ),
    );
  }

  Widget _buildImage(double width, double height) {
    Widget img;
    if (layer.imagePath != null) {
      img =
          fileBannerImage(
            layer.imagePath!,
            fit: BoxFit.contain,
            width: width,
            height: height,
          ) ??
          const ColoredBox(color: Colors.black26);
    } else if (layer.imageAsset != null) {
      final gif = widget.gifFrames[layer.imageAsset!];
      if (gif != null) {
        img = RawImage(
          image: gif,
          fit: BoxFit.contain,
          width: width,
          height: height,
        );
      } else {
        img = Image.asset(
          layer.imageAsset!,
          fit: BoxFit.contain,
          width: width,
          height: height,
          errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black26),
        );
      }
    } else {
      img = const ColoredBox(color: Colors.black26);
    }
    return SizedBox(width: width, height: height, child: img);
  }

  Widget _buildShape(double width, double height) {
    final fill = layer.shapeFilled
        ? (layer.fillColor ?? layer.strokeColor.withValues(alpha: 0.35))
        : layer.fillColor;
    return CustomPaint(
      size: Size(width, height),
      painter: _ShapePainter(
        kind: layer.shapeKind ?? PreviewShapeKind.rect,
        fill: layer.shapeFilled ? fill : null,
        stroke: layer.strokeColor,
        strokeWidth: layer.strokeWidth,
        cornerRadius: layer.cornerRadius,
      ),
    );
  }
}

/// Drawn above all layers so handles always receive pointer events first.
/// Positions are computed in the padded outer frame (including rotation) so
/// handles remain hittable when they sit outside the design banner.
class _SelectionHandlesOverlay extends StatefulWidget {
  const _SelectionHandlesOverlay({
    required this.layer,
    required this.canvasSize,
    required this.canvasKey,
    this.originOffset = Offset.zero,
    this.stripedBorder = false,
    required this.onMoved,
    required this.onRotated,
    required this.onSelect,
  });

  final PreviewLayer layer;
  final Size canvasSize;
  final GlobalKey canvasKey;

  /// Top-left of the design banner inside the padded interactive frame.
  final Offset originOffset;

  /// Striped frame while in-place text editing (vs solid when only selected).
  final bool stripedBorder;
  final ValueChanged<Rect> onMoved;
  final ValueChanged<double> onRotated;
  final VoidCallback onSelect;

  @override
  State<_SelectionHandlesOverlay> createState() =>
      _SelectionHandlesOverlayState();
}

class _SelectionHandlesOverlayState extends State<_SelectionHandlesOverlay> {
  Rect? _boundsAtResizeStart;
  Offset _resizeAccum = Offset.zero;
  Offset? _rotateCenterGlobal;
  static const _minNorm = 0.04;
  static const _handleVisual = 12.0;
  static const _handleHit = 32.0;
  static const _rotateGap = 28.0;

  PreviewLayer get layer => widget.layer;

  Offset _toLocalDelta(Offset globalDelta) {
    final a = -layer.rotation;
    final c = math.cos(a);
    final s = math.sin(a);
    return Offset(
      globalDelta.dx * c - globalDelta.dy * s,
      globalDelta.dx * s + globalDelta.dy * c,
    );
  }

  void _resizeWithHandle(_BoxHandle handle, Offset localDelta) {
    final start = _boundsAtResizeStart ?? layer.bounds;
    _resizeAccum += localDelta;
    final dx = _resizeAccum.dx / widget.canvasSize.width;
    final dy = _resizeAccum.dy / widget.canvasSize.height;
    var l = start.left;
    var t = start.top;
    var r = start.right;
    var b = start.bottom;

    switch (handle) {
      case _BoxHandle.e:
        r += dx;
      case _BoxHandle.w:
        l += dx;
      case _BoxHandle.s:
        b += dy;
      case _BoxHandle.n:
        t += dy;
      case _BoxHandle.se:
        r += dx;
        b += dy;
      case _BoxHandle.sw:
        l += dx;
        b += dy;
      case _BoxHandle.ne:
        r += dx;
        t += dy;
      case _BoxHandle.nw:
        l += dx;
        t += dy;
      case _BoxHandle.rotate:
        return;
    }

    if (r - l < _minNorm) {
      if (handle == _BoxHandle.w ||
          handle == _BoxHandle.nw ||
          handle == _BoxHandle.sw) {
        l = r - _minNorm;
      } else {
        r = l + _minNorm;
      }
    }
    if (b - t < _minNorm) {
      if (handle == _BoxHandle.n ||
          handle == _BoxHandle.nw ||
          handle == _BoxHandle.ne) {
        t = b - _minNorm;
      } else {
        b = t + _minNorm;
      }
    }

    l = l.clamp(0.0, 1.0 - _minNorm);
    t = t.clamp(0.0, 1.0 - _minNorm);
    r = r.clamp(l + _minNorm, 1.0);
    b = b.clamp(t + _minNorm, 1.0);

    var next = Rect.fromLTRB(l, t, r, b);
    if (handle == _BoxHandle.e ||
        handle == _BoxHandle.w ||
        handle == _BoxHandle.ne ||
        handle == _BoxHandle.nw ||
        handle == _BoxHandle.se ||
        handle == _BoxHandle.sw) {
      next = _growIconGridBoundsIfNeeded(layer, next, widget.canvasSize);
    }
    widget.onMoved(next);
  }

  double get _displayScale =>
      (layer.kind == PreviewLayerKind.text ||
          layer.kind == PreviewLayerKind.image)
      ? 1.0
      : layer.scale.clamp(0.25, 4.0);

  /// Unrotated box in outer-frame coordinates (origin = padded stack top-left).
  Rect get _boxInFrame {
    final scale = _displayScale;
    final ox = widget.originOffset.dx;
    final oy = widget.originOffset.dy;
    final left = ox + layer.bounds.left * widget.canvasSize.width;
    final top = oy + layer.bounds.top * widget.canvasSize.height;
    final w = layer.bounds.width * widget.canvasSize.width * scale;
    final h = layer.bounds.height * widget.canvasSize.height * scale;
    return Rect.fromLTWH(left, top, w, h);
  }

  Offset _rotateAround(Offset point, Offset center, double angle) {
    final c = math.cos(angle);
    final s = math.sin(angle);
    final d = point - center;
    return Offset(
      center.dx + d.dx * c - d.dy * s,
      center.dy + d.dx * s + d.dy * c,
    );
  }

  Offset? _layerCenterGlobal() {
    final box =
        widget.canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final frame = _boxInFrame;
    final localInDesign = Offset(
      frame.center.dx - widget.originOffset.dx,
      frame.center.dy - widget.originOffset.dy,
    );
    return box.localToGlobal(localInDesign);
  }

  Map<_BoxHandle, Offset> _handleCenters(Rect box) {
    final center = box.center;
    final angle = layer.rotation;
    Offset map(Offset p) => _rotateAround(p, center, angle);
    return {
      _BoxHandle.nw: map(box.topLeft),
      _BoxHandle.n: map(Offset(box.center.dx, box.top)),
      _BoxHandle.ne: map(box.topRight),
      _BoxHandle.e: map(Offset(box.right, box.center.dy)),
      _BoxHandle.se: map(box.bottomRight),
      _BoxHandle.s: map(Offset(box.center.dx, box.bottom)),
      _BoxHandle.sw: map(box.bottomLeft),
      _BoxHandle.w: map(Offset(box.left, box.center.dy)),
      _BoxHandle.rotate: map(Offset(box.center.dx, box.top - _rotateGap)),
    };
  }

  Widget _handle(_BoxHandle kind, Offset center) {
    final isRotate = kind == _BoxHandle.rotate;
    return Positioned(
      left: center.dx - _handleHit / 2,
      top: center.dy - _handleHit / 2,
      width: _handleHit,
      height: _handleHit,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => widget.onSelect(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (_) {
            widget.onSelect();
            _boundsAtResizeStart = layer.bounds;
            _resizeAccum = Offset.zero;
            _rotateCenterGlobal = _layerCenterGlobal();
          },
          onPanUpdate: (details) {
            if (isRotate) {
              final center = _rotateCenterGlobal ?? _layerCenterGlobal();
              if (center == null) return;
              final v = details.globalPosition - center;
              widget.onRotated(math.atan2(v.dx, -v.dy));
              return;
            }
            _resizeWithHandle(kind, _toLocalDelta(details.delta));
          },
          onPanEnd: (_) {
            _boundsAtResizeStart = null;
            _resizeAccum = Offset.zero;
            _rotateCenterGlobal = null;
          },
          child: Center(
            child: isRotate
                ? Container(
                    width: _handleVisual,
                    height: _handleVisual,
                    decoration: BoxDecoration(
                      color: const Color(0xFF555555),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                      boxShadow: const [
                        BoxShadow(blurRadius: 3, color: Colors.black38),
                      ],
                    ),
                    child: const Icon(
                      Icons.rotate_right,
                      size: 10,
                      color: Colors.white,
                    ),
                  )
                : Container(
                    width: _handleVisual,
                    height: _handleVisual,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.blueGrey.shade700,
                        width: 1.2,
                      ),
                      boxShadow: const [
                        BoxShadow(blurRadius: 2, color: Colors.black26),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final box = _boxInFrame;
    final centers = _handleCenters(box);
    final n = centers[_BoxHandle.n]!;
    final rotate = centers[_BoxHandle.rotate]!;

    return Positioned.fill(
      child: IgnorePointer(
        ignoring: false,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(
                  painter: _SelectionBorderPainter(
                    box: box,
                    rotation: layer.rotation,
                    rotateHandle: rotate,
                    northHandle: n,
                    striped: widget.stripedBorder,
                  ),
                ),
              ),
            ),
            for (final entry in centers.entries)
              _handle(entry.key, entry.value),
          ],
        ),
      ),
    );
  }
}

class _SelectionBorderPainter extends CustomPainter {
  _SelectionBorderPainter({
    required this.box,
    required this.rotation,
    required this.rotateHandle,
    required this.northHandle,
    this.striped = false,
  });

  final Rect box;
  final double rotation;
  final Offset rotateHandle;
  final Offset northHandle;
  final bool striped;

  @override
  void paint(Canvas canvas, Size size) {
    final center = box.center;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotation);
    canvas.translate(-center.dx, -center.dy);
    if (striped) {
      _paintStripedRect(canvas, box);
    } else {
      final paint = Paint()
        ..color = Colors.blueGrey.shade400
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.25;
      canvas.drawRect(box, paint);
    }
    canvas.restore();

    canvas.drawLine(
      northHandle,
      rotateHandle,
      Paint()
        ..color = Colors.blueGrey
        ..strokeWidth = 1.5,
    );
  }

  /// Alternating dark/light dashes — distinct from PowerPoint-style dots.
  void _paintStripedRect(Canvas canvas, Rect rect) {
    const stripe = 7.0;
    const gap = 5.0;
    final dark = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.butt;
    final light = Paint()
      ..color = const Color(0xFFECEFF1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.butt;

    void paintEdge(Offset a, Offset b) {
      final delta = b - a;
      final length = delta.distance;
      if (length <= 0) return;
      final dir = delta / length;
      var t = 0.0;
      var useDark = true;
      while (t < length) {
        final seg = math.min(stripe, length - t);
        final p0 = a + dir * t;
        final p1 = a + dir * (t + seg);
        canvas.drawLine(p0, p1, useDark ? dark : light);
        t += seg + gap;
        useDark = !useDark;
      }
    }

    paintEdge(rect.topLeft, rect.topRight);
    paintEdge(rect.topRight, rect.bottomRight);
    paintEdge(rect.bottomRight, rect.bottomLeft);
    paintEdge(rect.bottomLeft, rect.topLeft);
  }

  @override
  bool shouldRepaint(covariant _SelectionBorderPainter oldDelegate) =>
      oldDelegate.box != box ||
      oldDelegate.rotation != rotation ||
      oldDelegate.striped != striped ||
      oldDelegate.rotateHandle != rotateHandle ||
      oldDelegate.northHandle != northHandle;
}

class _StrokePainter extends CustomPainter {
  _StrokePainter({
    required this.points,
    required this.color,
    required this.strokeWidth,
    required this.selected,
  });

  final List<Offset> points;
  final Color color;
  final double strokeWidth;
  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final path = Path()
      ..moveTo(points.first.dx * size.width, points.first.dy * size.height);
    for (var i = 1; i < points.length; i++) {
      path.lineTo(points[i].dx * size.width, points[i].dy * size.height);
    }
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, paint);
    if (selected) {
      canvas.drawPath(
        path,
        Paint()
          ..color = Colors.amber.withValues(alpha: 0.5)
          ..strokeWidth = strokeWidth + 4
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _StrokePainter oldDelegate) => true;
}

class _ShapePainter extends CustomPainter {
  _ShapePainter({
    required this.kind,
    required this.fill,
    required this.stroke,
    required this.strokeWidth,
    required this.cornerRadius,
  });

  final PreviewShapeKind kind;
  final Color? fill;
  final Color stroke;
  final double strokeWidth;
  final double cornerRadius;

  Path _starPath(Rect rect) {
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final outer = math.min(rect.width, rect.height) / 2;
    final inner = outer * 0.4;
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? outer : inner;
      final a = -math.pi / 2 + i * math.pi / 5;
      final x = cx + r * math.cos(a);
      final y = cy + r * math.sin(a);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final shape = RRect.fromRectAndRadius(
      rect,
      Radius.circular(cornerRadius.clamp(0, size.shortestSide / 2)),
    );
    final hasStroke = strokeWidth > 0 && stroke.a > 0;
    final sp = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final fp = fill == null ? null : (Paint()..color = fill!);

    switch (kind) {
      case PreviewShapeKind.rect:
        if (fp != null) canvas.drawRRect(shape, fp);
        if (hasStroke) canvas.drawRRect(shape, sp);
      case PreviewShapeKind.oval:
        if (fp != null) canvas.drawOval(rect, fp);
        if (hasStroke) canvas.drawOval(rect, sp);
      case PreviewShapeKind.line:
        if (hasStroke) canvas.drawLine(rect.topLeft, rect.bottomRight, sp);
      case PreviewShapeKind.star:
        final path = _starPath(rect);
        if (fp != null) canvas.drawPath(path, fp);
        if (hasStroke) canvas.drawPath(path, sp);
    }
  }

  @override
  bool shouldRepaint(covariant _ShapePainter oldDelegate) => true;
}

class _ItemIcon extends StatelessWidget {
  const _ItemIcon({
    required this.item,
    required this.gifFrames,
    required this.size,
  });

  final PreviewItem item;
  final Map<String, ui.Image> gifFrames;
  final double size;

  @override
  Widget build(BuildContext context) {
    final gif = gifFrames[item.assetPath];
    final child = gif != null
        ? RawImage(image: gif, fit: BoxFit.contain)
        : AssetImageWidget(assetPath: item.assetPath, fit: BoxFit.contain);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.35),
        border: Border.all(color: Colors.black87, width: 1),
      ),
      padding: const EdgeInsets.all(2),
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (item.label != null && item.label!.isNotEmpty)
            Align(
              alignment: Alignment.bottomRight,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 1),
                color: Colors.black54,
                child: Text(
                  item.label!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (size * 0.22).clamp(8.0, 12.0),
                    fontWeight: FontWeight.w700,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
