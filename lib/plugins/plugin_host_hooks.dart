import 'package:flutter/material.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';

/// Optional host capabilities implemented by first-party plugin packages.
///
/// Keeps `lib/plugins` free of direct imports of bundled plugin UI while still
/// exposing the same [CPluginHost] surface to in-process and EVC plugins.
abstract final class PluginHostHooks {
  /// Opens the level preview UI. Set by the level-preview package on load.
  static Future<void> Function(
    BuildContext context, {
    required CPluginHost host,
    String? filePath,
    String? fileName,
  })? openLevelPreview;
}
