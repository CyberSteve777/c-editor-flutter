import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/gif_first_frame.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_file_image.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_fonts.dart';
import 'package:c_editor/widgets/asset_image.dart';

enum _BoxHandle { nw, n, ne, e, se, s, sw, w, rotate }

/// Extra space around the design banner so edge/rotate handles stay hittable.
const double kPreviewInteractPad = 56.0;

/// Renders a [PreviewDocument] at design size inside a [RepaintBoundary].
class PreviewCanvas extends StatefulWidget {
  const PreviewCanvas({
    super.key,
    required this.document,
    this.interactive = false,
    this.tool = PreviewEditTool.select,
    this.selectedLayerId,
    this.drawColor = Colors.white,
    this.drawStrokeWidth = 4,
    this.onSelectLayer,
    this.onLayerMoved,
    this.onLayerScaled,
    this.onLayerRotated,
    this.onStrokeStarted,
    this.onStrokeUpdated,
    this.onStrokeEnded,
    this.onShapeDraft,
    this.boundaryKey,
  });

  final PreviewDocument document;
  final bool interactive;
  final PreviewEditTool tool;
  final String? selectedLayerId;
  final Color drawColor;
  final double drawStrokeWidth;
  final ValueChanged<String?>? onSelectLayer;
  final void Function(String id, Rect newBounds)? onLayerMoved;
  final void Function(String id, double newScale)? onLayerScaled;
  final void Function(String id, double rotation)? onLayerRotated;
  final void Function(Offset normalized)? onStrokeStarted;
  final void Function(Offset normalized)? onStrokeUpdated;
  final VoidCallback? onStrokeEnded;
  final void Function(Rect normalizedBounds)? onShapeDraft;
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
      if (layer.kind != PreviewLayerKind.iconGrid) continue;
      final paths = <String>{
        for (final item in layer.items) item.assetPath,
        for (final section in layer.sections)
          for (final item in section.items) item.assetPath,
      };
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
    final pad = widget.interactive ? kPreviewInteractPad : 0.0;
    final drawing =
        widget.interactive &&
        (widget.tool == PreviewEditTool.pen ||
            widget.tool == PreviewEditTool.rect ||
            widget.tool == PreviewEditTool.oval);
    final selected = _selectedLayer;

    final design = SizedBox(
      key: _canvasKey,
      width: w,
      height: h,
      child: RepaintBoundary(
        key: widget.boundaryKey,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapUp: widget.interactive && widget.tool == PreviewEditTool.select
              ? (_) => widget.onSelectLayer?.call(null)
              : null,
          onPanStart: drawing
              ? (d) {
                  final n = _toNorm(d.localPosition);
                  if (widget.tool == PreviewEditTool.pen) {
                    widget.onStrokeStarted?.call(n);
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
              for (final layer in doc.sortedLayers)
                if (layer.visible)
                  _LayerWidget(
                    layer: layer,
                    canvasSize: kPreviewCanvasSize,
                    interactive:
                        widget.interactive &&
                        widget.tool == PreviewEditTool.select,
                    selected: widget.selectedLayerId == layer.id,
                    gifFrames: _gifFrames,
                    onSelect: () => widget.onSelectLayer?.call(layer.id),
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
        selected.kind != PreviewLayerKind.stroke;

    // Outer size includes pad so handles past the banner still receive hits.
    // Export [RepaintBoundary] stays at design size only.
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: w + pad * 2,
        height: h + pad * 2,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(left: pad, top: pad, width: w, height: h, child: design),
            if (showHandles)
              _SelectionHandlesOverlay(
                layer: selected,
                canvasSize: kPreviewCanvasSize,
                canvasKey: _canvasKey,
                originOffset: Offset(pad, pad),
                onMoved: (bounds) =>
                    widget.onLayerMoved?.call(selected.id, bounds),
                onRotated: (rotation) =>
                    widget.onLayerRotated?.call(selected.id, rotation),
                onSelect: () => widget.onSelectLayer?.call(selected.id),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBanner(PreviewDocument doc) {
    final ref = doc.banner;
    if (ref.kind == PreviewBannerSourceKind.userFile &&
        ref.userFilePath != null) {
      final fileImg = fileBannerImage(
        ref.userFilePath!,
        fit: BoxFit.cover,
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

Rect _growIconGridBoundsIfNeeded(PreviewLayer layer, Rect proposed, Size canvas) {
  if (layer.kind != PreviewLayerKind.iconGrid) return proposed;
  final maxW = proposed.width * canvas.width;
  final intrinsic = previewIconGridIntrinsicSize(
    maxWidth: maxW,
    sections: previewEffectiveSections(layer),
    showChrome: layer.showChrome,
    gridTitle: layer.gridTitle,
    sourceLabel: layer.sourceLabel,
  );
  final needH = (intrinsic.height / canvas.height).clamp(0.04, 1.0 - proposed.top);
  final h = math.max(proposed.height, needH);
  return Rect.fromLTWH(proposed.left, proposed.top, proposed.width, h);
}

class _LayerWidget extends StatefulWidget {
  const _LayerWidget({
    required this.layer,
    required this.canvasSize,
    required this.interactive,
    required this.selected,
    required this.gifFrames,
    required this.onSelect,
    required this.onMoved,
    required this.onScaled,
  });

  final PreviewLayer layer;
  final Size canvasSize;
  final bool interactive;
  final bool selected;
  final Map<String, ui.Image> gifFrames;
  final VoidCallback onSelect;
  final ValueChanged<Rect> onMoved;
  final ValueChanged<double> onScaled;

  @override
  State<_LayerWidget> createState() => _LayerWidgetState();
}

class _LayerWidgetState extends State<_LayerWidget> {
  double _scaleAtStart = 1;
  static const _minScale = 0.25;
  static const _maxScale = 4.0;

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

  @override
  Widget build(BuildContext context) {
    if (layer.kind == PreviewLayerKind.stroke) {
      return CustomPaint(
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
      );
    }

    final scale = layer.kind == PreviewLayerKind.text
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

    final allowScale = layer.kind != PreviewLayerKind.text;
    final child = widget.interactive
        ? GestureDetector(
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
              final local = _toLocalDelta(details.focalPointDelta);
              final dx = local.dx / widget.canvasSize.width;
              final dy = local.dy / widget.canvasSize.height;
              final nl = (layer.bounds.left + dx).clamp(
                0.0,
                1.0 - layer.bounds.width,
              );
              final nt = (layer.bounds.top + dy).clamp(
                0.0,
                1.0 - layer.bounds.height,
              );
              widget.onMoved(
                Rect.fromLTWH(
                  nl,
                  nt,
                  layer.bounds.width,
                  layer.bounds.height,
                ),
              );
            },
            child: Listener(
              onPointerSignal: (event) {
                if (!allowScale) return;
                if (event is! PointerScrollEvent) return;
                if (!widget.selected) return;
                final delta = event.scrollDelta.dy;
                if (delta == 0) return;
                final next = (layer.scale * (delta > 0 ? 0.92 : 1.08))
                    .clamp(_minScale, _maxScale);
                widget.onScaled(next.toDouble());
              },
              child: body,
            ),
          )
        : body;

    return Positioned(
      left: left,
      top: top,
      width: hitW,
      height: hitH,
      child: Transform.rotate(
        angle: layer.rotation,
        alignment: Alignment.center,
        child: child,
      ),
    );
  }

  Widget _buildText(double width, double height) {
    final runs = layer.effectiveTextRuns();
    if (runs.isEmpty) {
      return SizedBox(width: width, height: height);
    }
    final align = layer.textAlign;
    final hasOutline = runs.any((r) => r.style.outline);
    final base = Text.rich(
      TextSpan(
        children: [
          for (final run in runs)
            TextSpan(
              text: run.text,
              style: PreviewFonts.resolve(run.style, fill: !run.style.outline),
            ),
        ],
      ),
      textAlign: align,
      softWrap: true,
    );
    final child = hasOutline
        ? Stack(
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
                            : PreviewFonts.resolve(run.style, fill: true)
                                  .copyWith(color: Colors.transparent),
                      ),
                  ],
                ),
                textAlign: align,
                softWrap: true,
              ),
            ],
          )
        : base;
    final fittedAlign = switch (align) {
      TextAlign.center || TextAlign.justify => Alignment.center,
      TextAlign.right || TextAlign.end => Alignment.centerRight,
      _ => Alignment.centerLeft,
    };
    return SizedBox(
      width: width,
      height: height,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: fittedAlign,
        child: SizedBox(
          width: width,
          child: child,
        ),
      ),
    );
  }

  Widget _buildIconGrid(double width, double height) {
    final sections = previewEffectiveSections(layer);
    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          if (sections[i].title != null && sections[i].title!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                sections[i].title!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontSize: sections[i].iconSize >= 64 ? 15 : 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          Wrap(
            spacing: 4,
            runSpacing: 4,
            children: [
              for (final item in sections[i].items.take(48))
                _ItemIcon(
                  item: item,
                  gifFrames: widget.gifFrames,
                  size: sections[i].iconSize,
                ),
            ],
          ),
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
            children: [
              Positioned(
                left: 0,
                top: 0,
                width: width,
                child: child,
              ),
            ],
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
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (layer.gridTitle != null && layer.gridTitle!.isNotEmpty)
              Text(
                layer.gridTitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            if (layer.sourceLabel != null && layer.sourceLabel!.isNotEmpty)
              Text(
                layer.sourceLabel!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
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
      img = Image.asset(
        layer.imageAsset!,
        fit: BoxFit.contain,
        width: width,
        height: height,
        errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black26),
      );
    } else {
      img = const ColoredBox(color: Colors.black26);
    }
    return SizedBox(width: width, height: height, child: img);
  }

  Widget _buildShape(double width, double height) {
    final fill = layer.fillColor;
    final stroke = layer.strokeColor;
    final sw = layer.strokeWidth;
    return CustomPaint(
      size: Size(width, height),
      painter: _ShapePainter(
        oval: layer.shapeKind == PreviewShapeKind.oval,
        fill: fill,
        stroke: stroke,
        strokeWidth: sw,
      ),
    );
  }
}

/// Drawn above all layers so handles always receive pointer events first.
class _SelectionHandlesOverlay extends StatefulWidget {
  const _SelectionHandlesOverlay({
    required this.layer,
    required this.canvasSize,
    required this.canvasKey,
    this.originOffset = Offset.zero,
    required this.onMoved,
    required this.onRotated,
    required this.onSelect,
  });

  final PreviewLayer layer;
  final Size canvasSize;
  final GlobalKey canvasKey;
  /// Top-left of the design banner inside the padded interactive frame.
  final Offset originOffset;
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
  static const _handleHit = 28.0;

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
    // Width changes that wrap icons should grow height so content isn't hidden.
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

  double get _displayScale => layer.kind == PreviewLayerKind.text
      ? 1.0
      : layer.scale.clamp(0.25, 4.0);

  Offset? _layerCenterGlobal() {
    final box = widget.canvasKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return null;
    final scale = _displayScale;
    final left = layer.bounds.left * widget.canvasSize.width;
    final top = layer.bounds.top * widget.canvasSize.height;
    final hitW = layer.bounds.width * widget.canvasSize.width * scale;
    final hitH = layer.bounds.height * widget.canvasSize.height * scale;
    return box.localToGlobal(Offset(left + hitW / 2, top + hitH / 2));
  }

  Widget _handle(_BoxHandle kind, {required double left, required double top}) {
    final isRotate = kind == _BoxHandle.rotate;
    final inset = (_handleHit - _handleVisual) / 2;
    return Positioned(
      left: left - inset,
      top: top - inset,
      width: _handleHit,
      height: _handleHit,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: (_) => widget.onSelect(),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onPanStart: (details) {
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
              // 0 rad = handle pointing up; drag direction rotates the layer.
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
    final scale = _displayScale;
    final left = layer.bounds.left * widget.canvasSize.width;
    final top = layer.bounds.top * widget.canvasSize.height;
    final hitW = layer.bounds.width * widget.canvasSize.width * scale;
    final hitH = layer.bounds.height * widget.canvasSize.height * scale;
    final hs = _handleVisual;
    // Expand hit-test bounds so corner + rotation handles outside the box
    // still receive pointer events (parent Positioned otherwise rejects them).
    const pad = 40.0;
    final midX = (hitW - hs) / 2;
    final midY = (hitH - hs) / 2;
    const rotateGap = 28.0;
    final totalW = hitW + pad * 2;
    final totalH = hitH + pad * 2;
    final alignX = ((pad + hitW / 2) / totalW) * 2 - 1;
    final alignY = ((pad + hitH / 2) / totalH) * 2 - 1;

    return Positioned(
      left: widget.originOffset.dx + left - pad,
      top: widget.originOffset.dy + top - pad,
      width: totalW,
      height: totalH,
      child: Transform.rotate(
        angle: layer.rotation,
        alignment: Alignment(alignX, alignY),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: pad,
              top: pad,
              width: hitW,
              height: hitH,
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Colors.blueGrey.shade400,
                      width: 1.25,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              left: pad + hitW / 2 - 0.75,
              top: pad - rotateGap,
              child: IgnorePointer(
                child: Container(
                  width: 1.5,
                  height: rotateGap,
                  color: Colors.blueGrey,
                ),
              ),
            ),
            _handle(
              _BoxHandle.rotate,
              left: pad + midX,
              top: pad - rotateGap - hs / 2,
            ),
            _handle(_BoxHandle.nw, left: pad - hs / 2, top: pad - hs / 2),
            _handle(_BoxHandle.n, left: pad + midX, top: pad - hs / 2),
            _handle(_BoxHandle.ne, left: pad + hitW - hs / 2, top: pad - hs / 2),
            _handle(_BoxHandle.e, left: pad + hitW - hs / 2, top: pad + midY),
            _handle(
              _BoxHandle.se,
              left: pad + hitW - hs / 2,
              top: pad + hitH - hs / 2,
            ),
            _handle(_BoxHandle.s, left: pad + midX, top: pad + hitH - hs / 2),
            _handle(_BoxHandle.sw, left: pad - hs / 2, top: pad + hitH - hs / 2),
            _handle(_BoxHandle.w, left: pad - hs / 2, top: pad + midY),
          ],
        ),
      ),
    );
  }
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
    required this.oval,
    required this.fill,
    required this.stroke,
    required this.strokeWidth,
  });

  final bool oval;
  final Color? fill;
  final Color stroke;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    if (fill != null) {
      final fp = Paint()..color = fill!;
      if (oval) {
        canvas.drawOval(rect, fp);
      } else {
        canvas.drawRect(rect, fp);
      }
    }
    final sp = Paint()
      ..color = stroke
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    if (oval) {
      canvas.drawOval(rect, sp);
    } else {
      canvas.drawRect(rect, sp);
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
      child: child,
    );
  }
}
