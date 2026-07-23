import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';

/// In-memory asset accessor for a loaded plugin.
class MemoryCPluginAssets implements CPluginAssets {
  MemoryCPluginAssets(this._assets);

  final Map<String, Uint8List> _assets;

  Uint8List _require(String relativePath) {
    final normalized = relativePath.replaceAll('\\', '/');
    final bytes = _assets[normalized];
    if (bytes == null) {
      throw StateError('Plugin asset not found: $normalized');
    }
    return bytes;
  }

  @override
  ImageProvider image(String relativePath) {
    return MemoryImage(_require(relativePath));
  }

  @override
  Future<List<int>> readBytes(String relativePath) async {
    return _require(relativePath);
  }

  @override
  Future<String> readString(String relativePath) async {
    return utf8.decode(_require(relativePath));
  }
}

/// Host instance passed into a plugin's `initialize` entrypoint.
class PluginHostImpl implements CPluginHost {
  PluginHostImpl({
    required this.pluginId,
    required CPluginAssets assets,
    required PluginScreenRegistry registry,
  }) : _assets = assets,
       _registry = registry;

  @override
  final String pluginId;

  final CPluginAssets _assets;
  final PluginScreenRegistry _registry;

  @override
  CPluginAssets get assets => _assets;

  @override
  void registerScreen(
    String id,
    String title,
    CPluginScreenBuilder builder,
  ) {
    if (id.isEmpty) {
      throw ArgumentError('Screen id must not be empty');
    }
    _registry.register(
      PluginRegisteredScreen(
        pluginId: pluginId,
        screenId: id,
        title: title.isEmpty ? id : title,
        builder: builder,
      ),
    );
  }
}
