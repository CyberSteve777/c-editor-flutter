import 'dart:typed_data';

import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/plugin_host_impl.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';

/// In-memory host used when debugging a plugin as a normal Flutter project.
///
/// Call your plugin's `initialize(host)` once, then read [registry] for
/// registered screens and UI elements.
class DebugPluginHost implements CPluginHost {
  DebugPluginHost({
    this.pluginId = 'debug.plugin',
    Map<String, Uint8List>? assets,
    PluginScreenRegistry? registry,
  }) : registry = registry ?? PluginScreenRegistry() {
    _impl = PluginHostImpl(
      pluginId: pluginId,
      assets: MemoryCPluginAssets(assets ?? const {}),
      registry: this.registry,
    );
  }

  @override
  final String pluginId;

  /// Collects screens / UI elements registered during [initialize].
  final PluginScreenRegistry registry;

  late final PluginHostImpl _impl;

  @override
  CPluginAssets get assets => _impl.assets;

  @override
  void registerScreen(
    String id,
    String title,
    CPluginScreenBuilder builder,
  ) =>
      _impl.registerScreen(id, title, builder);

  @override
  void registerUiElement(
    String id,
    String title,
    String slot,
    CPluginScreenBuilder builder, [
    int? iconCodePoint,
  ]) =>
      _impl.registerUiElement(id, title, slot, builder, iconCodePoint);
}
