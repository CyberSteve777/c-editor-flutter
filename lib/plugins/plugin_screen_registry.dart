import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';

/// A screen registered by a loaded plugin.
class PluginRegisteredScreen {
  const PluginRegisteredScreen({
    required this.pluginId,
    required this.screenId,
    required this.title,
    required this.builder,
  });

  final String pluginId;
  final String screenId;
  final String title;
  final CPluginScreenBuilder builder;

  String get key => '$pluginId::$screenId';
}

/// Holds screens contributed by currently loaded plugins.
class PluginScreenRegistry extends ChangeNotifier {
  final List<PluginRegisteredScreen> _screens = [];

  List<PluginRegisteredScreen> get screens =>
      List.unmodifiable(_screens);

  void clearForPlugin(String pluginId) {
    _screens.removeWhere((s) => s.pluginId == pluginId);
    notifyListeners();
  }

  void clearAll() {
    _screens.clear();
    notifyListeners();
  }

  void register(PluginRegisteredScreen screen) {
    _screens.removeWhere((s) => s.key == screen.key);
    _screens.add(screen);
    notifyListeners();
  }
}
