import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Top-centered banner (below [AppBar], content width, theme-neutral) with FAB-style motion.
class AppMessage {
  AppMessage._();

  static final AppMessageController controller = AppMessageController();

  static const displayDuration = Duration(seconds: 3);
  static const animDuration = Duration(milliseconds: 320);

  static Color backgroundColor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return isDark ? const Color(0xFF383838) : const Color(0xFFEEEEEE);
  }

  static Color foregroundColor(Brightness brightness) {
    final isDark = brightness == Brightness.dark;
    return isDark ? Colors.white : const Color(0xFF212121);
  }

  static void show(
    BuildContext context,
    String message, {
    IconData? icon,
    Duration? duration,
  }) {
    if (!context.mounted) return;
    controller.show(
      message,
      brightness: Theme.of(context).brightness,
      icon: icon,
      duration: duration ?? displayDuration,
    );
  }

  static void hide() {
    controller.hide();
  }
}

class AppMessageController extends ChangeNotifier {
  String? message;
  IconData? icon;
  Brightness brightness = Brightness.dark;
  Timer? _hideTimer;

  void show(
    String text, {
    required Brightness brightness,
    IconData? icon,
    required Duration duration,
  }) {
    _hideTimer?.cancel();
    message = text;
    this.icon = icon;
    this.brightness = brightness;
    notifyListeners();
    _hideTimer = Timer(duration, hide);
  }

  void hide() {
    _hideTimer?.cancel();
    _hideTimer = null;
    if (message == null) return;
    message = null;
    icon = null;
    notifyListeners();
  }
}

/// Hosts the navigator and animated message banner inside the scaled layout.
class AppMessageMessenger extends StatelessWidget {
  const AppMessageMessenger({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        const AppMessageBanner(),
      ],
    );
  }
}

class AppMessageBanner extends StatefulWidget {
  const AppMessageBanner({super.key});

  @override
  State<AppMessageBanner> createState() => _AppMessageBannerState();
}

class _AppMessageBannerState extends State<AppMessageBanner>
    with SingleTickerProviderStateMixin {
  static const _animDuration = AppMessage.animDuration;
  static const _maxWidth = 360.0;
  static const _horizontalMargin = 16.0;

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _animDuration,
  );

  late final Animation<double> _reveal = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  String? _displayText;
  IconData? _displayIcon;
  Brightness _displayBrightness = Brightness.dark;

  @override
  void initState() {
    super.initState();
    AppMessage.controller.addListener(_onControllerChanged);
    _syncFromController(animate: false);
  }

  @override
  void dispose() {
    AppMessage.controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _syncFromController({required bool animate}) {
    final text = AppMessage.controller.message;
    if (text != null) {
      _displayText = text;
      _displayIcon = AppMessage.controller.icon;
      _displayBrightness = AppMessage.controller.brightness;
      if (animate) {
        _playShowAnimation();
      } else if (text.isNotEmpty) {
        _controller.value = 1;
      }
    }
  }

  void _onControllerChanged() {
    if (!mounted) return;
    final text = AppMessage.controller.message;
    if (text != null) {
      setState(() {
        _displayText = text;
        _displayIcon = AppMessage.controller.icon;
        _displayBrightness = AppMessage.controller.brightness;
      });
      _playShowAnimation();
    } else {
      _playHideAnimation();
    }
  }

  void _playShowAnimation() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (!mounted || AppMessage.controller.message == null) return;
      _controller.forward(from: 0);
    });
  }

  void _playHideAnimation() {
    _controller.reverse().whenComplete(() {
      if (!mounted || AppMessage.controller.message != null) return;
      setState(() {
        _displayText = null;
        _displayIcon = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_displayText == null && _controller.isDismissed) {
      return const SizedBox.shrink();
    }

    final text = _displayText ?? '';
    final fg = AppMessage.foregroundColor(_displayBrightness);
    final bg = AppMessage.backgroundColor(_displayBrightness);
    final icon = _displayIcon;
    final top = MediaQuery.paddingOf(context).top + kToolbarHeight + 8;

    return Positioned(
      top: top,
      left: 0,
      right: 0,
      child: IgnorePointer(
        child: AnimatedBuilder(
          animation: _reveal,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                alignment: Alignment.topCenter,
                heightFactor: _reveal.value.clamp(0.001, 1.0),
                child: Opacity(
                  opacity: _reveal.value,
                  child: Transform.translate(
                    offset: Offset(0, -10 * (1 - _reveal.value)),
                    child: child,
                  ),
                ),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: _horizontalMargin),
            child: Material(
              color: bg,
              elevation: 4,
              borderRadius: BorderRadius.circular(6),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, size: 20, color: fg),
                      const SizedBox(width: 8),
                    ],
                    ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: _maxWidth - 56,
                      ),
                      child: Text(
                        text,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: fg,
                          fontWeight: FontWeight.w500,
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
  }
}
