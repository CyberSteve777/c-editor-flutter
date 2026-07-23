import 'package:flutter/material.dart';

/// Callback used by plugins to build a registered screen or action UI.
typedef CPluginScreenBuilder = Widget Function(BuildContext context);

/// Placement slots for plugin-contributed buttons / menu items in the host UI.
///
/// Pass these as strings to [CPluginHost.registerUiElement] for dart_eval
/// compatibility (e.g. `'editorAppBar'`).
abstract final class CPluginUiSlots {
  /// Icon button in the level editor AppBar (near Preview / JSON / Save).
  static const editorAppBar = 'editorAppBar';

  /// Item in the level editor AppBar overflow menu.
  static const editorOverflow = 'editorOverflow';

  /// Item in the level-list AppBar overflow menu.
  static const levelListOverflow = 'levelListOverflow';

  static const all = {editorAppBar, editorOverflow, levelListOverflow};

  static bool isValid(String slot) => all.contains(slot);
}

/// Access to files shipped inside a `.cplugin` under `assets/`.
abstract class CPluginAssets {
  /// Returns an [ImageProvider] for a path relative to the plugin `assets/` folder.
  ImageProvider image(String relativePath);

  /// Reads a UTF-8 text file relative to the plugin `assets/` folder.
  Future<String> readString(String relativePath);

  /// Reads raw bytes relative to the plugin `assets/` folder.
  Future<List<int>> readBytes(String relativePath);
}

/// Host API passed to a plugin's `initialize` entrypoint.
abstract class CPluginHost {
  /// Plugin package id from the manifest.
  String get pluginId;

  /// Assets bundled with this plugin.
  CPluginAssets get assets;

  /// Registers a standalone screen that users can open from the Plugins UI.
  ///
  /// Prefer positional parameters so dart_eval bridging stays simple:
  /// `host.registerScreen('id', 'Title', (context) => MyScreen());`
  void registerScreen(
    String id,
    String title,
    CPluginScreenBuilder builder,
  );

  /// Registers a button / menu item in the base editor (or level list).
  ///
  /// [slot] must be one of [CPluginUiSlots] (e.g. `'editorAppBar'`).
  /// When the user activates it, the host opens [builder] as a full screen.
  ///
  /// [iconCodePoint] is a Material Icons code point (optional); defaults to
  /// the extension icon. Example: `Icons.build.codePoint`.
  ///
  /// ```dart
  /// host.registerUiElement(
  ///   'wave_helper',
  ///   'Wave helper',
  ///   CPluginUiSlots.editorAppBar,
  ///   (context) => WaveHelperScreen(),
  ///   Icons.waves.codePoint,
  /// );
  /// ```
  void registerUiElement(
    String id,
    String title,
    String slot,
    CPluginScreenBuilder builder, [
    int? iconCodePoint,
  ]);
}
