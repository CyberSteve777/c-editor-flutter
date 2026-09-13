import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Keeps editing controls from changing the fitted canvas size as they grow.
/// Canvas zoom is view-only: the canvas keeps its original layout constraints
/// and export boundary, while the surrounding viewport applies the transform.
class PreviewEditorWorkspace extends StatefulWidget {
  const PreviewEditorWorkspace({
    super.key,
    required this.toolbar,
    required this.canvas,
    required this.canvasZoomLabel,
    required this.fitCanvasLabel,
    required this.resizeToolbarLabel,
    required this.zoomInLabel,
    required this.zoomOutLabel,
    this.onToolbarResizeStarted,
  });

  final Widget toolbar;
  final Widget canvas;
  final String canvasZoomLabel;
  final String fitCanvasLabel;
  final String resizeToolbarLabel;
  final String zoomInLabel;
  final String zoomOutLabel;
  final VoidCallback? onToolbarResizeStarted;

  @override
  State<PreviewEditorWorkspace> createState() => _PreviewEditorWorkspaceState();
}

class _PreviewEditorWorkspaceState extends State<PreviewEditorWorkspace> {
  final _toolbarScroll = ScrollController();
  late final _canvasHorizontalScroll = _PreviewCanvasZoomScrollController(
    pendingOffset: (metrics) => _zoomOffsetForAxis(metrics, Axis.horizontal),
  )..addListener(_discardHorizontalZoomAnchor);
  late final _canvasVerticalScroll = _PreviewCanvasZoomScrollController(
    pendingOffset: (metrics) => _zoomOffsetForAxis(metrics, Axis.vertical),
  )..addListener(_discardVerticalZoomAnchor);
  double _toolbarFraction = 0.28;
  double _zoom = 1;
  Size _canvasViewport = Size.zero;
  double? _pendingHorizontalZoomCenter;
  double? _pendingVerticalZoomCenter;
  int _zoomRevision = 0;

  // A thumb drag or wheel event can arrive after zoom was queued but before
  // its layout. That newer input takes precedence on the axis it scrolls.
  // Layout's correctPixels does not notify these listeners, so the other
  // axis still applies its pending zoom anchor before the first paint.
  void _discardHorizontalZoomAnchor() => _pendingHorizontalZoomCenter = null;

  void _discardVerticalZoomAnchor() => _pendingVerticalZoomCenter = null;

  @override
  void dispose() {
    _toolbarScroll.dispose();
    _canvasHorizontalScroll.dispose();
    _canvasVerticalScroll.dispose();
    super.dispose();
  }

  Offset _zoomOrigin(double zoom) => zoom < 1
      ? Offset(
          _canvasViewport.width * (1 - zoom) / 2,
          _canvasViewport.height * (1 - zoom) / 2,
        )
      : Offset.zero;

  void _setZoom(double value, {bool fit = false}) {
    final zoom = value.clamp(0.5, 3.0);
    final origin = _zoomOrigin(_zoom);
    final center = Offset(
      fit
          ? 0.5
          : _pendingHorizontalZoomCenter ??
                ((_canvasHorizontalScroll.hasClients
                            ? _canvasHorizontalScroll.offset
                            : 0) +
                        _canvasViewport.width / 2 -
                        origin.dx) /
                    (_zoom * math.max(1, _canvasViewport.width)),
      fit
          ? 0.5
          : _pendingVerticalZoomCenter ??
                ((_canvasVerticalScroll.hasClients
                            ? _canvasVerticalScroll.offset
                            : 0) +
                        _canvasViewport.height / 2 -
                        origin.dy) /
                    (_zoom * math.max(1, _canvasViewport.height)),
    );
    _pendingHorizontalZoomCenter = center.dx;
    _pendingVerticalZoomCenter = center.dy;
    final revision = ++_zoomRevision;
    setState(() => _zoom = zoom);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || revision != _zoomRevision) return;
      // Position correction happens during layout, before the scaled canvas
      // paints. Only clear the queued anchor here; never jump after painting.
      _pendingHorizontalZoomCenter = null;
      _pendingVerticalZoomCenter = null;
    });
  }

  Widget _buildCanvas() {
    return LayoutBuilder(
      builder: (context, constraints) {
        _canvasViewport = constraints.biggest;
        final origin = _zoomOrigin(_zoom);
        // Scrollbar thumbs pan the zoomed view. Do not compete with the canvas'
        // drawing, layer-dragging and icon-row pinch gestures for touch input.
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(
            dragDevices: const <PointerDeviceKind>{},
            scrollbars: false,
          ),
          child: Scrollbar(
            controller: _canvasVerticalScroll,
            thumbVisibility: _zoom > 1,
            trackVisibility: _zoom > 1,
            interactive: true,
            scrollbarOrientation: ScrollbarOrientation.right,
            notificationPredicate: (notification) =>
                notification.metrics.axis == Axis.vertical,
            child: Scrollbar(
              controller: _canvasHorizontalScroll,
              thumbVisibility: _zoom > 1,
              trackVisibility: _zoom > 1,
              interactive: true,
              scrollbarOrientation: ScrollbarOrientation.bottom,
              notificationPredicate: (notification) =>
                  notification.metrics.axis == Axis.horizontal,
              child: _ScrollbarThumbInputGuard(
                enabled: _zoom > 1,
                child: SingleChildScrollView(
                  controller: _canvasVerticalScroll,
                  primary: false,
                  physics: const ClampingScrollPhysics(),
                  child: SingleChildScrollView(
                    controller: _canvasHorizontalScroll,
                    primary: false,
                    scrollDirection: Axis.horizontal,
                    physics: const ClampingScrollPhysics(),
                    child: SizedBox(
                      width: _canvasViewport.width * math.max(1, _zoom),
                      height: _canvasViewport.height * math.max(1, _zoom),
                      child: Stack(
                        children: [
                          Positioned(
                            left: origin.dx,
                            top: origin.dy,
                            width: _canvasViewport.width,
                            height: _canvasViewport.height,
                            child: Transform.scale(
                              scale: _zoom,
                              alignment: Alignment.topLeft,
                              child: Listener(
                                onPointerSignal: (event) {
                                  if (event is PointerScrollEvent &&
                                      (HardwareKeyboard
                                              .instance
                                              .isControlPressed ||
                                          HardwareKeyboard
                                              .instance
                                              .isMetaPressed)) {
                                    // The editor uses Ctrl/Command-wheel to scale
                                    // selected elements. Keep that gesture from
                                    // also scrolling the surrounding canvas view.
                                    GestureBinding
                                        .instance
                                        .pointerSignalResolver
                                        .register(event, (_) {});
                                  }
                                },
                                child: widget.canvas,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  double? _zoomOffsetForAxis(ScrollMetrics metrics, Axis axis) {
    final center = axis == Axis.horizontal
        ? _pendingHorizontalZoomCenter
        : _pendingVerticalZoomCenter;
    if (center == null) return null;
    final dimension = metrics.viewportDimension;
    final origin = _zoom < 1 ? dimension * (1 - _zoom) / 2 : 0;
    return center * dimension * _zoom + origin - dimension / 2;
  }

  Widget _buildZoomBar({required bool showLabel}) {
    final percent = '${(_zoom * 100).round()}%';
    return Row(
      children: [
        IconButton(
          key: const ValueKey('previewCanvasZoomOutButton'),
          tooltip: widget.zoomOutLabel,
          onPressed: _zoom > 0.5 ? () => _setZoom(_zoom - 0.1) : null,
          icon: const Icon(Icons.zoom_out),
        ),
        if (showLabel)
          SizedBox(
            width: 120,
            child: Text(
              widget.canvasZoomLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        Expanded(
          child: Semantics(
            label: widget.canvasZoomLabel,
            child: Slider(
              key: const ValueKey('previewCanvasZoomSlider'),
              value: _zoom,
              min: 0.5,
              max: 3,
              label: percent,
              semanticFormatterCallback: (_) => percent,
              onChanged: _setZoom,
            ),
          ),
        ),
        SizedBox(
          width: 52,
          child: Text(percent, textAlign: TextAlign.center, maxLines: 1),
        ),
        IconButton(
          key: const ValueKey('previewCanvasZoomInButton'),
          tooltip: widget.zoomInLabel,
          onPressed: _zoom < 3 ? () => _setZoom(_zoom + 0.1) : null,
          icon: const Icon(Icons.zoom_in),
        ),
        IconButton(
          key: const ValueKey('previewCanvasFitButton'),
          tooltip: widget.fitCanvasLabel,
          onPressed: () => _setZoom(1, fit: true),
          icon: const Icon(Icons.fit_screen),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final footerHeight = math.min(48.0, constraints.maxHeight * 0.25);
        final bodyHeight = constraints.maxHeight - footerHeight;
        final handleHeight = math.min(20.0, bodyHeight * 0.08);
        final adjustableHeight = bodyHeight - handleHeight;
        final minToolbarHeight = math.min(56.0, adjustableHeight * 0.2);
        final maxToolbarHeight = adjustableHeight * 0.6;
        final toolbarHeight = (adjustableHeight * _toolbarFraction).clamp(
          minToolbarHeight,
          maxToolbarHeight,
        );
        void resizeToolbar(double delta) {
          if (adjustableHeight <= 0) return;
          setState(() {
            _toolbarFraction =
                ((toolbarHeight + delta).clamp(
                  minToolbarHeight,
                  maxToolbarHeight,
                ) /
                adjustableHeight);
          });
        }

        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: Column(
            children: [
              Material(
                color: theme.colorScheme.surfaceContainerHighest.withValues(
                  alpha: 0.55,
                ),
                child: SizedBox(
                  key: const ValueKey('previewToolbarViewport'),
                  height: toolbarHeight,
                  child: Scrollbar(
                    key: const ValueKey('previewToolbarScrollbar'),
                    controller: _toolbarScroll,
                    thumbVisibility: true,
                    trackVisibility: true,
                    interactive: true,
                    child: SingleChildScrollView(
                      controller: _toolbarScroll,
                      primary: false,
                      child: widget.toolbar,
                    ),
                  ),
                ),
              ),
              Semantics(
                label: widget.resizeToolbarLabel,
                onIncrease: () {
                  widget.onToolbarResizeStarted?.call();
                  resizeToolbar(24);
                },
                onDecrease: () {
                  widget.onToolbarResizeStarted?.call();
                  resizeToolbar(-24);
                },
                child: MouseRegion(
                  cursor: SystemMouseCursors.resizeUpDown,
                  child: Tooltip(
                    message: widget.resizeToolbarLabel,
                    child: GestureDetector(
                      key: const ValueKey('previewToolbarResizeHandle'),
                      behavior: HitTestBehavior.opaque,
                      onVerticalDragStart: (_) =>
                          widget.onToolbarResizeStarted?.call(),
                      onVerticalDragUpdate: (details) =>
                          resizeToolbar(details.delta.dy),
                      child: Container(
                        height: handleHeight,
                        color: theme.colorScheme.surfaceContainerHighest,
                        alignment: Alignment.center,
                        child: Container(
                          width: 44,
                          height: math.min(4, handleHeight),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.onSurfaceVariant,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SizedBox(
                  key: const ValueKey('previewCanvasViewport'),
                  child: _buildCanvas(),
                ),
              ),
              Material(
                color: theme.colorScheme.surfaceContainer,
                child: SizedBox(
                  height: footerHeight,
                  width: double.infinity,
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: SizedBox(
                      width: math.max(260, constraints.maxWidth),
                      height: 48,
                      child: _buildZoomBar(
                        showLabel: constraints.maxWidth >= 600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Keeps the canvas out of the thumb's expanded touch target. The standard
/// scrollbar only shields its painted track from child hit tests, while its
/// drag recognizer also accepts a larger area around the thumb. Without this
/// guard, a drawing gesture or raw text listener can consume that same input.
/// This stays in the tree at every zoom so fitting does not remount the canvas.
class _ScrollbarThumbInputGuard extends SingleChildRenderObjectWidget {
  const _ScrollbarThumbInputGuard({
    required this.enabled,
    required super.child,
  });

  final bool enabled;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _ScrollbarThumbInputGuardRenderBox(enabled);

  @override
  void updateRenderObject(
    BuildContext context,
    _ScrollbarThumbInputGuardRenderBox renderObject,
  ) => renderObject.enabled = enabled;
}

class _ScrollbarThumbInputGuardRenderBox extends RenderProxyBox {
  _ScrollbarThumbInputGuardRenderBox(this.enabled);

  bool enabled;

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (enabled && size.contains(position)) {
      final globalPosition = localToGlobal(position);
      RenderObject? ancestor = parent;
      while (ancestor != null) {
        if (ancestor is RenderCustomPaint) {
          final painter = ancestor.foregroundPainter;
          // RenderBox hit testing has no pointer kind. Reserve the actual
          // touch thumb target for all pointers, but leave every other canvas
          // point editable; do not approximate it with a fixed edge gutter.
          if (painter is ScrollbarPainter &&
              painter.hitTestOnlyThumbInteractive(
                ancestor.globalToLocal(globalPosition),
                PointerDeviceKind.touch,
              )) {
            // Stay an opaque child hit so the outer scrollbar's recognizer
            // receives the pointer, without delivering it to the canvas.
            result.add(BoxHitTestEntry(this, position));
            return true;
          }
        }
        ancestor = ancestor.parent;
      }
    }
    return super.hitTest(result, position: position);
  }
}

/// Applies the zoom anchor while the scroll extents are being laid out, so
/// the first painted frame already has the correct scale and pan position.
class _PreviewCanvasZoomScrollController extends ScrollController {
  _PreviewCanvasZoomScrollController({required this.pendingOffset});

  final double? Function(ScrollMetrics) pendingOffset;

  @override
  ScrollPosition createScrollPosition(
    ScrollPhysics physics,
    ScrollContext context,
    ScrollPosition? oldPosition,
  ) => _PreviewCanvasZoomScrollPosition(
    physics: physics,
    context: context,
    initialPixels: initialScrollOffset,
    keepScrollOffset: keepScrollOffset,
    oldPosition: oldPosition,
    debugLabel: debugLabel,
    pendingOffset: pendingOffset,
  );
}

class _PreviewCanvasZoomScrollPosition extends ScrollPositionWithSingleContext {
  _PreviewCanvasZoomScrollPosition({
    required super.physics,
    required super.context,
    required super.initialPixels,
    required super.keepScrollOffset,
    super.oldPosition,
    super.debugLabel,
    required this.pendingOffset,
  });

  final double? Function(ScrollMetrics) pendingOffset;

  @override
  bool correctForNewDimensions(
    ScrollMetrics oldPosition,
    ScrollMetrics newPosition,
  ) {
    final offset = pendingOffset(newPosition);
    if (offset != null) {
      correctPixels(
        offset.clamp(newPosition.minScrollExtent, newPosition.maxScrollExtent),
      );
      // SingleChildScrollView paints directly from pixels and ignores the
      // request to repeat layout. Accept these dimensions so scrollbar
      // metrics and drag gestures are updated in the same layout pass.
      return true;
    }
    return super.correctForNewDimensions(oldPosition, newPosition);
  }
}
