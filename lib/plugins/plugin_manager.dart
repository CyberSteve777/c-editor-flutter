import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dart_eval/dart_eval.dart';
import 'package:c_editor/plugins/c_plugin_validator.dart';
import 'package:c_editor/plugins/plugin_downloader.dart';
import 'package:c_editor/plugins/plugin_runtime.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';
import 'package:c_editor/plugins/plugin_storage.dart';
import 'package:c_editor/plugins/plugin_storage_factory.dart';

/// Coordinates install, enable/disable, and runtime loading of plugins.
class PluginManager extends ChangeNotifier {
  PluginManager._({
    required PluginStorage storage,
    required this.screenRegistry,
  }) : _storage = storage;

  static PluginManager? _instance;

  static PluginManager get instance {
    final current = _instance;
    if (current == null) {
      throw StateError('PluginManager.init() has not been called');
    }
    return current;
  }

  static bool get isInitialized => _instance != null;

  static Future<PluginManager> init(SharedPreferences prefs) async {
    if (_instance != null) return _instance!;
    final manager = PluginManager._(
      storage: createPluginStorage(prefs),
      screenRegistry: PluginScreenRegistry(),
    );
    _instance = manager;
    await manager.reload();
    return manager;
  }

  final PluginStorage _storage;
  final PluginScreenRegistry screenRegistry;
  final PluginDownloader _downloader = PluginDownloader();
  final CPluginValidator _validator = const CPluginValidator();

  List<InstalledPluginRecord> _installed = [];
  final Map<String, Runtime> _runtimes = {};

  List<InstalledPluginRecord> get installed =>
      List.unmodifiable(_installed);

  Future<void> reload() async {
    for (final id in _runtimes.keys.toList()) {
      screenRegistry.clearForPlugin(id);
    }
    _runtimes.clear();

    _installed = await _storage.listInstalled();
    for (final plugin in _installed.where((p) => p.enabled)) {
      await _loadPlugin(plugin);
    }
    notifyListeners();
  }

  Future<InstalledPluginRecord> installBytes(
    Uint8List bytes, {
    bool enable = true,
  }) async {
    final package = _validator.validate(bytes);
    await _checkMinEditorVersion(package.manifest.minEditorVersion);

    // Verify the entrypoint actually runs before persisting (catches EVC that
    // was compiled without the library marked as an entrypoint).
    try {
      executePluginEntrypoint(
        evcBytes: package.evcBytes,
        manifest: package.manifest,
        pluginId: package.manifest.id,
        assets: package.assets,
      );
    } catch (e) {
      throw CPluginValidationException(
        'Plugin bytecode failed to execute initialize(): $e',
      );
    }

    await _storage.savePackage(package, enabled: enable);
    await reload();
    return _installed.firstWhere((p) => p.id == package.manifest.id);
  }

  Future<InstalledPluginRecord> installFromUrl(
    Uri uri, {
    PluginDownloadProgress? onProgress,
    bool enable = true,
  }) async {
    final bytes = await _downloader.download(uri, onProgress: onProgress);
    return installBytes(bytes, enable: enable);
  }

  Future<void> setEnabled(String pluginId, bool enabled) async {
    await _storage.setEnabled(pluginId, enabled);
    await reload();
  }

  Future<void> uninstall(String pluginId) async {
    screenRegistry.clearForPlugin(pluginId);
    _runtimes.remove(pluginId);
    await _storage.uninstall(pluginId);
    await reload();
  }

  Future<void> _loadPlugin(InstalledPluginRecord record) async {
    screenRegistry.clearForPlugin(record.id);
    try {
      final runtime = executePluginEntrypoint(
        evcBytes: record.evcBytes,
        manifest: record.manifest,
        pluginId: record.id,
        assets: record.assets,
        registry: screenRegistry,
      );
      _runtimes[record.id] = runtime;

      final index = _installed.indexWhere((p) => p.id == record.id);
      if (index >= 0) {
        _installed[index] = record.copyWith(clearLoadError: true);
      }
    } catch (e, st) {
      debugPrint('Failed to load plugin ${record.id}: $e\n$st');
      final index = _installed.indexWhere((p) => p.id == record.id);
      if (index >= 0) {
        _installed[index] = record.copyWith(loadError: e.toString());
      }
    }
  }

  Future<void> _checkMinEditorVersion(String? minVersion) async {
    if (minVersion == null || minVersion.isEmpty) return;
    final info = await PackageInfo.fromPlatform();
    if (!_isVersionAtLeast(info.version, minVersion)) {
      throw CPluginValidationException(
        'Plugin requires C-Editor $minVersion or newer '
        '(current: ${info.version})',
      );
    }
  }

  /// Simple dotted numeric compare (ignores pre-release suffixes).
  static bool _isVersionAtLeast(String current, String minimum) {
    List<int> parts(String v) {
      final core = v.split(RegExp(r'[-+]')).first;
      return core
          .split('.')
          .map((p) => int.tryParse(p) ?? 0)
          .toList();
    }

    final a = parts(current);
    final b = parts(minimum);
    final len = a.length > b.length ? a.length : b.length;
    for (var i = 0; i < len; i++) {
      final ai = i < a.length ? a[i] : 0;
      final bi = i < b.length ? b[i] : 0;
      if (ai > bi) return true;
      if (ai < bi) return false;
    }
    return true;
  }
}
