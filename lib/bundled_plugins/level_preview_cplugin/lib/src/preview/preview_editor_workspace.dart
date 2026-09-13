import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
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
  final _canvasHorizontalScroll = ScrollController();
  final _canvasVerticalScroll = ScrollController();
  double _toolbarFraction = 0.28;
  double _zoom = 1;
  Size _canvasViewport = Size.zero;
  Offset? _pendingZoomCenter;
  int _zoomRevision = 0;

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
    final center =
        _pendingZoomCenter ??
        Offset(
          ((_canvasHorizontalScroll.hasClients
                      ? _canvasHorizontalScroll.offset
                      : 0) +
                  _canvasViewport.width / 2 -
                  origin.dx) /
              _zoom,
          ((_canvasVerticalScroll.hasClients
                      ? _canvasVerticalScroll.offset
                      : 0) +
                  _canvasViewport.height / 2 -
                  origin.dy) /
              _zoom,
        );
    _pendingZoomCenter = center;
    final revision = ++_zoomRevision;
    setState(() => _zoom = zoom);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || revision != _zoomRevision) return;
      final newOrigin = _zoomOrigin(_zoom);
      void reposition(ScrollController controller, double position) {
        if (!controller.hasClients) return;
        controller.jumpTo(
          position.clamp(0.0, controller.position.maxScrollExtent),
        );
      }

      reposition(
        _canvasHorizontalScroll,
        fit ? 0 : center.dx * _zoom + newOrigin.dx - _canvasViewport.width / 2,
      );
      reposition(
        _canvasVerticalScroll,
        fit ? 0 : center.dy * _zoom + newOrigin.dy - _canvasViewport.height / 2,
      );
      _pendingZoomCenter = null;
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
                                  GestureBinding.instance.pointerSignalResolver
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
        );
      },
    );
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
