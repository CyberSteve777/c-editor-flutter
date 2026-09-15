import 'package:flutter/material.dart';
import 'package:c_editor/widgets/app_message.dart';
import 'package:c_editor/widgets/app_ui_scale.dart';

/// Root UI zoom used by [MaterialApp.builder].
///
/// Inflates [MediaQuery] to a larger logical size, lays the navigator out at
/// that size with an [OverflowBox] (bounded constraints), then paints with
/// [Transform.scale].
///
/// Do **not** use [FittedBox] here: it lays out its child with unbounded
/// constraints, which leaves Material dialog `ConstrainedBox(minWidth: 280)`
/// with `size: MISSING` and crashes hit-testing on pointer moves.
class AppUiScaler extends StatelessWidget {
  const AppUiScaler({
    super.key,
    required this.scale,
    required this.child,
    this.wrapMessenger = true,
  });

  final double scale;
  final Widget child;

  /// When false, skips [AppMessageMessenger] (useful in widget tests).
  final bool wrapMessenger;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final safeScale = (scale.isFinite && scale > 0) ? scale : 1.0;
    final viewport = mediaQuery.size;
    final scaledSize = Size(
      viewport.width / safeScale,
      viewport.height / safeScale,
    );

    EdgeInsets scaleInsets(EdgeInsets e) => EdgeInsets.fromLTRB(
      e.left / safeScale,
      e.top / safeScale,
      e.right / safeScale,
      e.bottom / safeScale,
    );

    final content = SizedBox(
      width: scaledSize.width,
      height: scaledSize.height,
      child: AppUiScale(
        scale: safeScale,
        child: wrapMessenger ? AppMessageMessenger(child: child) : child,
      ),
    );

    final media = MediaQuery(
      data: mediaQuery.copyWith(
        size: scaledSize,
        padding: scaleInsets(mediaQuery.padding),
        viewPadding: scaleInsets(mediaQuery.viewPadding),
        viewInsets: scaleInsets(mediaQuery.viewInsets),
        textScaler: TextScaler.linear(1.0),
      ),
      child: content,
    );

    // Identity scale: still wrap in the same structure so dialogs always see
    // tight logical constraints (no special-case path that can drift).
    return Transform.scale(
      scale: safeScale,
      alignment: Alignment.topLeft,
      filterQuality: FilterQuality.medium,
      child: OverflowBox(
        alignment: Alignment.topLeft,
        minWidth: scaledSize.width,
        maxWidth: scaledSize.width,
        minHeight: scaledSize.height,
        maxHeight: scaledSize.height,
        child: media,
      ),
    );
  }
}
