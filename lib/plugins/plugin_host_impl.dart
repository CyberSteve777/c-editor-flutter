import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/active_editor_session.dart';
import 'package:c_editor/plugins/plugin_level_io.dart';
import 'package:c_editor/plugins/plugin_l10n.dart';
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

  /// Sync read for localization lookup (returns null if missing).
  String? tryReadString(String relativePath) {
    final normalized = relativePath.replaceAll('\\', '/');
    final bytes = _assets[normalized];
    if (bytes == null) return null;
    return utf8.decode(bytes);
  }
}

/// Host instance passed into a plugin's `initialize` entrypoint.
class PluginHostImpl implements CPluginHost {
  PluginHostImpl({
    required this.pluginId,
    required CPluginAssets assets,
    required this.registry,
    ActiveEditorSession? session,
  }) : _assets = assets,
       _session = session ?? ActiveEditorSession.instance;

  @override
  final String pluginId;

  final CPluginAssets _assets;
  final ActiveEditorSession _session;

  /// Registry that receives screens / UI elements from this host.
  final PluginScreenRegistry registry;

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
    registry.register(
      PluginRegisteredScreen(
        pluginId: pluginId,
        screenId: id,
        title: title.isEmpty ? id : title,
        builder: builder,
      ),
    );
  }

  @override
  void registerUiElement(
    String id,
    String title,
    String slot,
    CPluginScreenBuilder builder, [
    int? iconCodePoint,
  ]) {
    if (id.isEmpty) {
      throw ArgumentError('UI element id must not be empty');
    }
    if (!CPluginUiSlots.isValid(slot)) {
      throw ArgumentError(
        'Unknown UI slot "$slot". '
        'Use CPluginUiSlots.editorAppBar, editorOverflow, or levelListOverflow.',
      );
    }
    registry.registerUiElement(
      PluginUiElement(
        pluginId: pluginId,
        id: id,
        title: title.isEmpty ? id : title,
        slot: slot,
        builder: builder,
        iconCodePoint: iconCodePoint,
      ),
    );
  }

  @override
  bool get hasOpenLevel => _session.hasOpenLevel;

  @override
  String? get openLevelPath => _session.openLevelPath;

  @override
  String? get openLevelFileName => _session.openLevelFileName;

  @override
  String? getOpenLevelJson() {
    final level = _session.cubit?.state.levelFile;
    if (level == null) return null;
    return encodeLevelJson(level);
  }

  @override
  void applyOpenLevelJson(String json) {
    final cubit = _session.cubit;
    if (cubit == null) {
      throw StateError('No level is open in the editor');
    }
    if (cubit.state.levelFile == null && cubit.state.isLoading) {
      throw StateError('Open level is still loading');
    }
    cubit.applyLevelFile(decodeLevelJson(json));
  }

  @override
  Future<void> saveOpenLevel() async {
    final cubit = _session.cubit;
    if (cubit == null || cubit.state.levelFile == null) {
      throw StateError('No level is open in the editor');
    }
    await cubit.save();
  }

  @override
  Future<String?> loadLevelJson(String filePath) async {
    if (filePath.isEmpty) return null;
    final level = await LevelRepository.loadLevelFromPath(filePath);
    if (level == null) return null;
    return encodeLevelJson(level);
  }

  @override
  Future<void> saveLevelJson(String filePath, String json) async {
    if (filePath.isEmpty) {
      throw ArgumentError('filePath must not be empty');
    }
    final level = decodeLevelJson(json);
    await LevelRepository.saveAndExport(filePath, level);

    final cubit = _session.cubit;
    if (cubit != null && cubit.filePath == filePath) {
      cubit.applyLevelFile(level, markDirty: false);
    }
  }

  @override
  String localize(BuildContext context, String key, [String? fallback]) {
    final locale = Localizations.localeOf(context).languageCode;
    final assets = _assets;
    if (assets is MemoryCPluginAssets) {
      for (final code in [locale, 'en']) {
        final raw = assets.tryReadString('l10n/$code.json');
        if (raw == null) continue;
        try {
          final decoded = jsonDecode(raw);
          if (decoded is Map && decoded[key] is String) {
            return decoded[key] as String;
          }
        } catch (_) {}
      }
    }
    return lookupHostL10n(context, key) ?? fallback ?? key;
  }
}
