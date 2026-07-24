import 'dart:typed_data';

import 'package:flutter/painting.dart';
import 'package:c_editor/plugins/c_plugin_manifest.dart';
import 'package:c_editor/plugins/c_plugin_validator.dart';
import 'package:c_editor/plugins/plugin_kind.dart';

/// On-disk / IndexedDB / in-process record for a plugin.
class InstalledPluginRecord {
  const InstalledPluginRecord({
    required this.manifest,
    required this.evcBytes,
    required this.assets,
    required this.enabled,
    this.kind = PluginKind.imported,
    this.loadError,
  });

  final CPluginManifest manifest;
  final Uint8List evcBytes;
  final Map<String, Uint8List> assets;
  final bool enabled;
  final PluginKind kind;
  final String? loadError;

  String get id => manifest.id;

  bool get canUninstall => kind == PluginKind.imported;

  bool get isBundled => kind == PluginKind.bundled;

  ImageProvider? iconImageProvider() {
    final path = manifest.icon;
    if (path == null || path.isEmpty) return null;
    final normalized = path.replaceAll('\\', '/');
    final bytes = assets[normalized];
    if (bytes == null || bytes.isEmpty) return null;
    return MemoryImage(bytes);
  }

  InstalledPluginRecord copyWith({
    bool? enabled,
    String? loadError,
    bool clearLoadError = false,
    PluginKind? kind,
  }) {
    return InstalledPluginRecord(
      manifest: manifest,
      evcBytes: evcBytes,
      assets: assets,
      enabled: enabled ?? this.enabled,
      kind: kind ?? this.kind,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
    );
  }
}

/// Persistence for installed `.cplugin` packages (imported plugins only).
abstract class PluginStorage {
  Future<List<InstalledPluginRecord>> listInstalled();

  Future<void> savePackage(CPluginPackage package, {required bool enabled});

  Future<void> setEnabled(String pluginId, bool enabled);

  Future<void> uninstall(String pluginId);

  Future<Set<String>> enabledIds();
}
