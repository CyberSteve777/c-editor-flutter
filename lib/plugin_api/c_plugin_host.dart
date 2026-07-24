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

  /// Registers an immediate editor action (no full-screen route).
  ///
  /// [titleKey] is resolved with [localize] when the action is shown.
  /// [slot] must be [CPluginUiSlots.editorAppBar] or
  /// [CPluginUiSlots.editorOverflow].
  void registerEditorAction(
    String id,
    String titleKey,
    String slot,
    Future<void> Function(BuildContext context) onActivate, [
    int? iconCodePoint,
  ]);

  /// Registers a per-file action in the level-list overflow menu.
  ///
  /// [titleKey] is resolved with [localize] when shown.
  /// [fileExtensions] is an optional comma-separated list of extensions
  /// (e.g. `'.json,.hujson,.rton'`); omit to match all files.
  void registerLevelFileAction(
    String id,
    String titleKey,
    Future<void> Function(
      BuildContext context,
      String fileName,
      String filePath,
    ) onActivate, [
    int? iconCodePoint,
    String? fileExtensions,
  ]);

  /// Opens the host level-preview UI for the open editor level, or for
  /// [filePath] / [fileName] when provided.
  Future<void> openLevelPreview(
    BuildContext context, [
    String? filePath,
    String? fileName,
  ]);

  // --- Level data (JSON strings; cross-platform via LevelRepository) ---

  /// Whether the level editor currently has a level open.
  bool get hasOpenLevel;

  /// Library path of the open level, or `null` if none.
  String? get openLevelPath;

  /// File name of the open level, or `null` if none.
  String? get openLevelFileName;

  /// Encoded [PvzLevelFile] JSON for the open level, or `null` if none.
  String? getOpenLevelJson();

  /// Replaces the open level from encoded [PvzLevelFile] JSON and marks dirty.
  ///
  /// Throws [ArgumentError] / [FormatException] on invalid JSON.
  /// Throws [StateError] if no level is open.
  void applyOpenLevelJson(String json);

  /// Saves the open level through the host repository.
  ///
  /// Throws [StateError] if no level is open.
  Future<void> saveOpenLevel();

  /// Loads a level from a library [filePath] and returns encoded JSON.
  ///
  /// Returns `null` if the file cannot be loaded. Paths are opaque strings
  /// from the level library (native FS or web storage).
  Future<String?> loadLevelJson(String filePath);

  /// Saves encoded [PvzLevelFile] JSON to [filePath] via the level repository.
  ///
  /// If [filePath] is the currently open editor level, also applies into the
  /// open session so the editor stays consistent.
  Future<void> saveLevelJson(String filePath, String json);

  // --- Localization ---

  /// Resolves a localization key for this plugin.
  ///
  /// Order: plugin `assets/l10n/{locale}.arb`, then `en.arb`, then a curated
  /// set of host [AppLocalizations] keys. Returns [fallback] or [key] when
  /// nothing matches.
  ///
  /// [args] are ICU / ARB placeholders (same patterns as Flutter gen-l10n):
  /// simple `{name}`, `{count, plural, …}`, `{gender, select, …}`, etc.
  /// Plugin `@key` metadata (`placeholders` type / format /
  /// optionalParameters) is applied like Flutter gen-l10n.
  /// Non-l10n plugin data should use other files under `assets/`, not `l10n/`.
  ///
  /// ```dart
  /// host.localize(context, 'hello', null, {'name': 'Ada'});
  /// host.localize(
  ///   context,
  ///   'itemCount',
  ///   null,
  ///   {'count': 3},
  /// );
  /// ```
  String localize(
    BuildContext context,
    String key, [
    String? fallback,
    Map<String, Object?>? args,
  ]);
}
