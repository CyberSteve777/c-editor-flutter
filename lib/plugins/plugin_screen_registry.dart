import 'package:flutter/material.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/plugin_material_icon.dart';

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

  IconData get icon => pluginMaterialIcon(iconCodePoint);
}

/// Localized title for bundled plugin actions.
typedef PluginTitleBuilder = String Function(BuildContext context);

/// Immediate action in the editor AppBar / overflow (no full-screen route).
class PluginEditorAction {
  const PluginEditorAction({
    required this.pluginId,
    required this.id,
    required this.titleBuilder,
    required this.icon,
    required this.slot,
    required this.onActivate,
  });

  final String pluginId;
  final String id;
  final PluginTitleBuilder titleBuilder;
  final IconData icon;
  final String slot;
  final Future<void> Function(BuildContext context) onActivate;

  String get key => '$pluginId::editorAction::$slot::$id';
}

/// Action shown on each level-file overflow menu in the level list.
class PluginLevelFileAction {
  const PluginLevelFileAction({
    required this.pluginId,
    required this.id,
    required this.titleBuilder,
    required this.icon,
    required this.onActivate,
    this.matchesFileName,
  });

  final String pluginId;
  final String id;
  final PluginTitleBuilder titleBuilder;
  final IconData icon;
  final Future<void> Function(
    BuildContext context,
    String fileName,
    String filePath,
  ) onActivate;
  final bool Function(String fileName)? matchesFileName;

  String get key => '$pluginId::fileAction::$id';

  bool matches(String fileName) =>
      matchesFileName == null || matchesFileName!(fileName);
}

/// Holds screens and UI elements contributed by currently loaded plugins.
class PluginScreenRegistry extends ChangeNotifier {
  final List<PluginRegisteredScreen> _screens = [];
  final List<PluginUiElement> _uiElements = [];
  final List<PluginEditorAction> _editorActions = [];
  final List<PluginLevelFileAction> _levelFileActions = [];

  List<PluginRegisteredScreen> get screens => List.unmodifiable(_screens);

  List<PluginUiElement> get uiElements => List.unmodifiable(_uiElements);

  List<PluginEditorAction> get editorActions =>
      List.unmodifiable(_editorActions);

  List<PluginLevelFileAction> get levelFileActions =>
      List.unmodifiable(_levelFileActions);

  List<PluginUiElement> elementsForSlot(String slot) =>
      _uiElements.where((e) => e.slot == slot).toList(growable: false);

  List<PluginEditorAction> editorActionsForSlot(String slot) => _editorActions
      .where((e) => e.slot == slot)
      .toList(growable: false);

  List<PluginLevelFileAction> levelFileActionsFor(String fileName) =>
      _levelFileActions
          .where((e) => e.matches(fileName))
          .toList(growable: false);

  void clearForPlugin(String pluginId) {
    _screens.removeWhere((s) => s.pluginId == pluginId);
    _uiElements.removeWhere((e) => e.pluginId == pluginId);
    _editorActions.removeWhere((e) => e.pluginId == pluginId);
    _levelFileActions.removeWhere((e) => e.pluginId == pluginId);
    notifyListeners();
  }

  void clearAll() {
    _screens.clear();
    _uiElements.clear();
    _editorActions.clear();
    _levelFileActions.clear();
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

  void registerEditorAction(PluginEditorAction action) {
    _editorActions.removeWhere((e) => e.key == action.key);
    _editorActions.add(action);
    notifyListeners();
  }

  void registerLevelFileAction(PluginLevelFileAction action) {
    _levelFileActions.removeWhere((e) => e.key == action.key);
    _levelFileActions.add(action);
    notifyListeners();
  }
}
