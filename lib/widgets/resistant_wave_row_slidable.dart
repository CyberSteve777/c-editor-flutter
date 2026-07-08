import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

/// Max swipe reveal as a fraction of row width.
const double kWaveRowMaxRevealRatio = 0.18;

/// Row-width fraction the user must reach to trigger a swipe action.
const double kWaveRowTriggerRatio = 0.12;

/// Drawer slide-in that lands centered in the pane at max reveal.
///
/// [DrawerMotion] animates to `+extent`, which pushes icons past the visible
/// clip when [extentRatio] is small. This variant ends at offset zero instead.
class CenteredDrawerMotion extends StatelessWidget {
  const CenteredDrawerMotion({super.key});

  @override
  Widget build(BuildContext context) {
    final paneData = ActionPane.of(context)!;
    final controller = Slidable.of(context)!;
    final progress = controller.animation.drive(
      CurveTween(curve: Interval(0, paneData.extentRatio)),
    );

    return AnimatedBuilder(
      animation: progress,
      builder: (context, child) {
        final t = progress.value;
        return LayoutBuilder(
          builder: (context, constraints) {
            final extent = paneData.direction == Axis.horizontal
                ? constraints.maxWidth
                : constraints.maxHeight;
            final begin = paneData.fromStart ? -extent : extent;
            final offset = begin * (1 - t);
            return Transform.translate(
              offset: paneData.direction == Axis.horizontal
                  ? Offset(offset, 0)
                  : Offset(0, offset),
              child: child,
            );
          },
        );
      },
      child: Flex(
        direction: paneData.direction,
        children: paneData.children,
      ),
    );
  }
}

/// Horizontal swipe with heavy resistance: finger travel slows as the row opens,
/// clamped to [kWaveRowMaxRevealRatio]. Uses [Slidable] visuals only.
class ResistantWaveRowSlidable extends StatefulWidget {
  const ResistantWaveRowSlidable({
    super.key,
    required this.rowKey,
    required this.child,
    required this.onManage,
    required this.onDeleteConfirm,
    required this.onDeleteConfirmed,
    this.startBackgroundColor,
    this.endBackgroundColor,
  });

  final Key rowKey;
  final Widget child;
  final VoidCallback onManage;
  final Future<bool> Function() onDeleteConfirm;
  final VoidCallback onDeleteConfirmed;
  final Color? startBackgroundColor;
  final Color? endBackgroundColor;

  @override
  State<ResistantWaveRowSlidable> createState() =>
      _ResistantWaveRowSlidableState();
}

class _ResistantWaveRowSlidableState extends State<ResistantWaveRowSlidable>
    with SingleTickerProviderStateMixin {
  late final SlidableController _controller;
  final GlobalKey _rowKey = GlobalKey();
  double _peakAbsRatio = 0;
  int _peakDirection = 0;

  @override
  void initState() {
    super.initState();
    _controller = SlidableController(this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double _rowWidth() {
    final box = _rowKey.currentContext?.findRenderObject() as RenderBox?;
    return box?.size.width ?? 0;
  }

  double _resistanceFactor(double absRatio) {
    final progress = (absRatio / kWaveRowMaxRevealRatio).clamp(0.0, 1.0);
    // Quadratic falloff: stiff near the limit, but still reachable.
    return math.pow(1 - progress, 2).toDouble().clamp(0.06, 1.0);
  }

  void _onHorizontalDragStart(DragStartDetails details) {
    _peakAbsRatio = _controller.ratio.abs();
    _peakDirection = _controller.ratio.sign.toInt();
  }

  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final width = _rowWidth();
    if (width <= 0) return;

    final deltaRatio = details.primaryDelta! / width;
    final current = _controller.ratio;
    final resistedDelta = deltaRatio * _resistanceFactor(current.abs());
    var next = current + resistedDelta;
    next = next.clamp(-kWaveRowMaxRevealRatio, kWaveRowMaxRevealRatio);
    _controller.ratio = next;

    final absNext = next.abs();
    if (absNext >= _peakAbsRatio) {
      _peakAbsRatio = absNext;
      _peakDirection = next.sign.toInt();
    }
  }

  Future<void> _onHorizontalDragEnd(DragEndDetails details) async {
    final signedPeak =
        _peakDirection == 0 ? _controller.ratio : _peakAbsRatio * _peakDirection;

    _peakAbsRatio = 0;
    _peakDirection = 0;

    if (signedPeak >= kWaveRowTriggerRatio) {
      widget.onManage();
      await _controller.close();
      return;
    }
    if (signedPeak <= -kWaveRowTriggerRatio) {
      final confirmed = await widget.onDeleteConfirm();
      await _controller.close();
      if (confirmed) widget.onDeleteConfirmed();
      return;
    }
    await _controller.close();
  }

  void _onHorizontalDragCancel() {
    _peakAbsRatio = 0;
    _peakDirection = 0;
    _controller.close();
  }

  Widget _buildActionIcon({
    required Color backgroundColor,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return CustomSlidableAction(
      flex: 1,
      onPressed: (_) => onTap(),
      autoClose: false,
      backgroundColor: backgroundColor,
      foregroundColor: Colors.white,
      padding: EdgeInsets.zero,
      alignment: Alignment.center,
      child: Icon(icon, size: 26),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final startColor = widget.startBackgroundColor ?? theme.colorScheme.primary;
    final endColor = widget.endBackgroundColor ?? theme.colorScheme.error;

    return KeyedSubtree(
      key: _rowKey,
      child: Slidable(
        key: widget.rowKey,
        controller: _controller,
        enabled: false,
        closeOnScroll: false,
        groupTag: 'wave_timeline_rows',
        startActionPane: ActionPane(
          motion: const CenteredDrawerMotion(),
          extentRatio: kWaveRowMaxRevealRatio,
          dragDismissible: false,
          children: [
            _buildActionIcon(
              backgroundColor: startColor,
              icon: Icons.settings,
              onTap: () async {
                await _controller.close();
                widget.onManage();
              },
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const CenteredDrawerMotion(),
          extentRatio: kWaveRowMaxRevealRatio,
          dragDismissible: false,
          children: [
            _buildActionIcon(
              backgroundColor: endColor,
              icon: Icons.delete,
              onTap: () async {
                await _controller.close();
                final confirmed = await widget.onDeleteConfirm();
                if (confirmed) widget.onDeleteConfirmed();
              },
            ),
          ],
        ),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          dragStartBehavior: DragStartBehavior.down,
          onHorizontalDragStart: _onHorizontalDragStart,
          onHorizontalDragUpdate: _onHorizontalDragUpdate,
          onHorizontalDragEnd: _onHorizontalDragEnd,
          onHorizontalDragCancel: _onHorizontalDragCancel,
          child: widget.child,
        ),
      ),
    );
  }
}
