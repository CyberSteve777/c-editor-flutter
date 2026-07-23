import 'package:flutter/material.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';

/// A screen registered by a loaded plugin (Plugins management UI).
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

/// A button / menu item a plugin injects into the host chrome.
class PluginUiElement {
  const PluginUiElement({
    required this.pluginId,
    required this.id,
    required this.title,
    required this.slot,
    required this.builder,
    this.iconCodePoint,
  });

  final String pluginId;
  final String id;
  final String title;
  final String slot;
  final CPluginScreenBuilder builder;
  final int? iconCodePoint;

  String get key => '$pluginId::$slot::$id';

  IconData get icon {
    if (iconCodePoint == null) return Icons.extension;
    // Plugin authors pass a runtime Material icon code point from EVC.
    // ignore: non_const_argument_for_const_parameter
    return IconData(iconCodePoint!, fontFamily: 'MaterialIcons');
  }
}

/// Holds screens and UI elements contributed by currently loaded plugins.
class PluginScreenRegistry extends ChangeNotifier {
  final List<PluginRegisteredScreen> _screens = [];
  final List<PluginUiElement> _uiElements = [];

  List<PluginRegisteredScreen> get screens => List.unmodifiable(_screens);

  List<PluginUiElement> get uiElements => List.unmodifiable(_uiElements);

  List<PluginUiElement> elementsForSlot(String slot) =>
      _uiElements.where((e) => e.slot == slot).toList(growable: false);

  void clearForPlugin(String pluginId) {
    _screens.removeWhere((s) => s.pluginId == pluginId);
    _uiElements.removeWhere((e) => e.pluginId == pluginId);
    notifyListeners();
  }

  void clearAll() {
    _screens.clear();
    _uiElements.clear();
    notifyListeners();
  }

  void register(PluginRegisteredScreen screen) {
    _screens.removeWhere((s) => s.key == screen.key);
    _screens.add(screen);
    notifyListeners();
  }

  void registerUiElement(PluginUiElement element) {
    _uiElements.removeWhere((e) => e.key == element.key);
    _uiElements.add(element);
    notifyListeners();
  }
}
