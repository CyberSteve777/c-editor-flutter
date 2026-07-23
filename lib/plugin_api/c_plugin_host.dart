import 'package:flutter/material.dart';

/// Callback used by plugins to build a registered screen.
typedef CPluginScreenBuilder = Widget Function(BuildContext context);

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
}
