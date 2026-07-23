import 'dart:typed_data';

import 'package:c_editor/plugins/c_plugin_manifest.dart';
import 'package:c_editor/plugins/plugin_host_impl.dart';
import 'package:c_editor/plugins/plugin_kind.dart';
import 'package:c_editor/plugins/plugin_storage.dart';

/// First-party plugin registered as in-process Dart (not EVC).
abstract class BundledPlugin {
  String get id;

  String get name;

  String get version;

  String get description;

  String get author;

  /// Registers screens / UI / file actions on [host].
  void register(PluginHostImpl host);
}

/// Builds a synthetic [InstalledPluginRecord] for a bundled plugin.
InstalledPluginRecord bundledPluginRecord(
  BundledPlugin plugin, {
  required bool enabled,
}) {
  return InstalledPluginRecord(
    manifest: CPluginManifest(
      format: CPluginManifest.expectedFormat,
      formatVersion: CPluginManifest.supportedFormatVersion,
      id: plugin.id,
      name: plugin.name,
      version: plugin.version,
      author: plugin.author,
      description: plugin.description,
      entryLibrary: 'package:c_editor/bundled/${plugin.id}',
      entryFunction: 'register',
    ),
    evcBytes: Uint8List(0),
    assets: const {},
    enabled: enabled,
    kind: PluginKind.bundled,
  );
}
