import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Tracks host-owned modal routes (dialogs / sheets) so editor leave / Escape
/// can close them instead of exiting to the level list.
///
/// Remembers the frame a modal closed on so a second Escape handler in the
/// same frame does not leave the editor right after closing Overview.
class ModalGate {
  ModalGate._();

  static int _depth = 0;
  static Duration? _closedOnFrameTime;

  static bool get isOpen => _depth > 0;

  static Duration get _now =>
      SchedulerBinding.instance.currentSystemFrameTimeStamp;

  /// True while a modal is open, or if one closed earlier in this frame.
  static bool get shouldAbsorbBack =>
      _depth > 0 || _closedOnFrameTime == _now;

  static void enter() => _depth++;

  static void leave() {
    if (_depth > 0) _depth--;
    _closedOnFrameTime = _now;
  }

  /// Whether back/Escape should stay on the current screen (modal open or
  /// just closed this frame). Does not touch the [Navigator].
  static bool tryAbsorb() => shouldAbsorbBack;
}

/// Allows a pushed route (e.g. JsonViewerScreen in edit mode) or modal to handle
/// Escape before the global handler pops. When set, the global handler calls
/// this first; if it returns true, the pop is skipped.
class EscapeOverride {
  EscapeOverride._();

  static final List<bool Function()> _stack = [];

  static void push(bool Function() handler) => _stack.add(handler);
  static void pop(bool Function() handler) => _stack.remove(handler);

  /// The topmost registered handler, or null if none.
  static bool Function()? get tryHandle => _stack.isEmpty ? null : _stack.last;
}

/// True when [context]'s [ModalRoute] is covered by another route (dialog,
/// bottom sheet, pushed page, …) on the same navigator.
bool navigatorHasRouteAbove(BuildContext context) {
  final route = ModalRoute.of(context);
  return route != null && !route.isCurrent;
}

/// Pops the top-most route when one covers [context]'s route.
/// Returns true if a route was popped.
bool popRouteAbove(BuildContext context) {
  if (!navigatorHasRouteAbove(context)) return false;
  final nav = Navigator.of(context, rootNavigator: true);
  if (!nav.canPop()) return false;
  nav.pop();
  return true;
}

/// Pops [context]'s navigator only when [Navigator.canPop] is true.
/// Never uses [Navigator.removeRoute] (that can wipe the home route).
bool safeNavPop(BuildContext context) {
  final nav = Navigator.of(context, rootNavigator: true);
  if (!nav.canPop()) return false;
  nav.pop();
  return true;
}

/// Wraps modal bottom sheet / dialog content so Escape closes only the modal,
/// not the screen below. Place as the root child of the modal's builder.
class EscapeClosesModal extends StatefulWidget {
  const EscapeClosesModal({super.key, required this.child});

  final Widget child;

  @override
  State<EscapeClosesModal> createState() => _EscapeClosesModalState();
}

class _EscapeClosesModalState extends State<EscapeClosesModal> {
  late final bool Function() _handler;
  bool _dismissed = false;

  @override
  void initState() {
    super.initState();
    ModalGate.enter();
    _handler = () {
      if (!context.mounted) return false;
      if (_dismissed) return true; // closing — absorb duplicate Escape
      // Nested dialogs/sheets sit above this modal — pop those first
      // without marking this EscapeClosesModal as dismissed.
      if (popRouteAbove(context)) return true;
      if (safeNavPop(context)) {
        _dismissed = true;
        return true;
      }
      // Still absorb so the editor leave path does not run while we are open.
      return ModalGate.isOpen;
    };
    EscapeOverride.push(_handler);
  }

  @override
  void dispose() {
    EscapeOverride.pop(_handler);
    ModalGate.leave();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
