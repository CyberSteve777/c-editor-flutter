import 'dart:typed_data';

import 'package:c_editor/plugins/c_plugin_manifest.dart';
import 'package:c_editor/plugins/c_plugin_validator.dart';

/// On-disk / IndexedDB record for an installed plugin.
class InstalledPluginRecord {
  const InstalledPluginRecord({
    required this.manifest,
    required this.evcBytes,
    required this.assets,
    required this.enabled,
    this.loadError,
  });

  final CPluginManifest manifest;
  final Uint8List evcBytes;
  final Map<String, Uint8List> assets;
  final bool enabled;
  final String? loadError;

  String get id => manifest.id;

  InstalledPluginRecord copyWith({
    bool? enabled,
    String? loadError,
    bool clearLoadError = false,
  }) {
    return InstalledPluginRecord(
      manifest: manifest,
      evcBytes: evcBytes,
      assets: assets,
      enabled: enabled ?? this.enabled,
      loadError: clearLoadError ? null : (loadError ?? this.loadError),
    );
  }
}

/// Persistence for installed `.cplugin` packages.
abstract class PluginStorage {
  Future<List<InstalledPluginRecord>> listInstalled();

  Future<void> savePackage(CPluginPackage package, {required bool enabled});

  Future<void> setEnabled(String pluginId, bool enabled);

  Future<void> uninstall(String pluginId);

  Future<Set<String>> enabledIds();
}
