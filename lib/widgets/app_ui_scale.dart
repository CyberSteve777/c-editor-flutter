import 'package:flutter/widgets.dart';

/// The paint scale applied by the app's root FittedBox. Descendants can recover
/// their actual window allocation without confusing UI zoom with screen size.
class AppUiScale extends InheritedWidget {
  const AppUiScale({super.key, required this.scale, required super.child});

  final double scale;

  static double of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppUiScale>()?.scale ?? 1;

  @override
  bool updateShouldNotify(AppUiScale oldWidget) => scale != oldWidget.scale;
}
