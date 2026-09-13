import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/plugins/plugin_config_store_io.dart'
    if (dart.library.html) 'package:c_editor/plugins/plugin_config_store_web.dart'
    as config_io;

/// UTF-8 JSON config files for plugins (`config.json` per plugin id).
///
/// Native (with a level library): `{library}/.plugin_config/{pluginId}/config.json`
/// Web / no library: SharedPreferences key `cplugin_config::{pluginId}`
///
/// Values may contain any Unicode (English, Russian, Chinese, …).
class PluginConfigStore {
  PluginConfigStore._();
  static final PluginConfigStore instance = PluginConfigStore._();

  static const _prefsPrefix = 'cplugin_config::';

  /// Reads the plugin config as a JSON object string (`{}` when missing).
  Future<String> readJson(String pluginId) async {
    final id = _requireId(pluginId);
    final fromFile = await config_io.readConfigFile(id);
    if (fromFile != null) return fromFile;
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefsPrefix$id') ?? '{}';
  }

  /// Parses [readJson] into a map (empty object on missing/invalid).
  Future<Map<String, dynamic>> readMap(String pluginId) async {
    final raw = await readJson(pluginId);
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return Map<String, dynamic>.from(decoded);
      if (decoded is Map) {
        return decoded.map((k, v) => MapEntry(k.toString(), v));
      }
    } catch (_) {}
    return <String, dynamic>{};
  }

  /// Replaces the plugin config with a UTF-8 JSON object string.
  Future<void> writeJson(String pluginId, String json) async {
    final id = _requireId(pluginId);
    final normalized = _normalizeObjectJson(json);
    final wroteFile = await config_io.writeConfigFile(id, normalized);
    if (wroteFile) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_prefsPrefix$id');
      return;
    }
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString('$_prefsPrefix$id', normalized)) {
      throw StateError('Failed to save plugin config for $id');
    }
  }

  /// Writes a map as indented UTF-8 JSON.
  Future<void> writeMap(String pluginId, Map<String, dynamic> map) async {
    await writeJson(
      pluginId,
      const JsonEncoder.withIndent('  ').convert(map),
    );
  }

  Future<void> clear(String pluginId) async {
    final id = _requireId(pluginId);
    await config_io.deleteConfigFile(id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_prefsPrefix$id');
  }

  String _requireId(String pluginId) {
    final id = pluginId.trim();
    if (id.isEmpty) throw ArgumentError('pluginId must not be empty');
    if (id.contains('/') || id.contains('\\') || id.contains('..')) {
      throw ArgumentError('Invalid pluginId: $pluginId');
    }
    return id;
  }

  String _normalizeObjectJson(String json) {
    final decoded = jsonDecode(json);
    if (decoded is! Map) {
      throw const FormatException('Plugin config must be a JSON object');
    }
    final map = decoded is Map<String, dynamic>
        ? decoded
        : decoded.map((k, v) => MapEntry(k.toString(), v));
    return const JsonEncoder.withIndent('  ').convert(map);
  }
}
