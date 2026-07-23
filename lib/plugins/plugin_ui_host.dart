import 'package:flutter/material.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/plugin_manager.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';

/// Opens a plugin-contributed UI element as a full-screen route.
void openPluginUiElement(BuildContext context, PluginUiElement element) {
  Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (context) => element.builder(context),
    ),
  );
}

/// AppBar icon buttons for [CPluginUiSlots.editorAppBar] elements.
List<Widget> pluginEditorAppBarActions(BuildContext context) {
  if (!PluginManager.isInitialized) return const [];
  final elements = PluginManager.instance.screenRegistry
      .elementsForSlot(CPluginUiSlots.editorAppBar);
  if (elements.isEmpty) return const [];

  return [
    for (final element in elements)
      IconButton(
        icon: Icon(element.icon),
        tooltip: element.title,
        onPressed: () => openPluginUiElement(context, element),
      ),
  ];
}

/// Overflow [PopupMenuItem]s for a given plugin UI [slot].
List<PopupMenuEntry<String>> pluginOverflowMenuItems({
  required String slot,
  required String valuePrefix,
}) {
  if (!PluginManager.isInitialized) return const [];
  final elements =
      PluginManager.instance.screenRegistry.elementsForSlot(slot);
  if (elements.isEmpty) return const [];

  return [
    for (final element in elements)
      PopupMenuItem<String>(
        value: '$valuePrefix${element.key}',
        child: ListTile(
          leading: Icon(element.icon),
          title: Text(element.title),
          contentPadding: EdgeInsets.zero,
        ),
      ),
  ];
}

/// Resolves an overflow menu selection that uses [valuePrefix].
bool handlePluginOverflowSelection(
  BuildContext context, {
  required String value,
  required String valuePrefix,
  required String slot,
}) {
  if (!value.startsWith(valuePrefix)) return false;
  if (!PluginManager.isInitialized) return false;
  final key = value.substring(valuePrefix.length);
  final match = PluginManager.instance.screenRegistry
      .elementsForSlot(slot)
      .where((e) => e.key == key);
  if (match.isEmpty) return false;
  openPluginUiElement(context, match.first);
  return true;
}
