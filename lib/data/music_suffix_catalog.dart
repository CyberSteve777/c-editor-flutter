import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:z_editor/data/asset_loader.dart';

/// PVZ2 `MusicSuffix` codenames and icons for picker UI (`assets/resources/MusicSuffixes.json`).
class MusicSuffixCatalog {
  MusicSuffixCatalog._();

  static const String unknownIconAsset = 'assets/images/others/unknown.webp';
  static const String _resourcePath = 'assets/resources/MusicSuffixes.json';

  static final List<String> _orderedCodenames = [];
  static final Map<String, String> _iconFilenameByCodename = {};
  static String _iconFolder = 'assets/images/music_suffixes/';
  static bool _isLoaded = false;

  /// Display order (excluding default empty suffix in JSON list).
  static List<String> get orderedCodes => List.unmodifiable(_orderedCodenames);

  static Future<void> init() async {
    if (_isLoaded) return;
    try {
      final raw = json.decode(await loadJsonString(_resourcePath)) as Map<String, dynamic>;
      final folder = raw['iconFolder'] as String?;
      if (folder != null && folder.isNotEmpty) {
        final f = folder.endsWith('/') ? folder : '$folder/';
        _iconFolder = f;
      }
      final order = raw['orderedCodenames'] as List<dynamic>? ?? [];
      final icons = raw['iconFiles'] as Map<String, dynamic>? ?? {};
      _orderedCodenames
        ..clear()
        ..addAll(order.map((e) => '$e'));
      _iconFilenameByCodename.clear();
      icons.forEach((k, v) {
        _iconFilenameByCodename[k] = '$v';
      });
      _isLoaded = true;
    } catch (e) {
      debugPrint('MusicSuffixCatalog: failed to load $e — using empty catalog');
      _orderedCodenames.clear();
      _iconFilenameByCodename.clear();
      _isLoaded = true;
    }
  }

  static String resourceKey(String code) =>
      code.isEmpty ? 'musicSuffix_default' : 'musicSuffix_$code';

  /// Full asset path for tile icon (`unknown` uses [unknownIconAsset]).
  static String iconAsset(String codename) {
    if (codename.isEmpty) return unknownIconAsset;
    final file = _iconFilenameByCodename[codename];
    if (file == null || file.isEmpty) return unknownIconAsset;
    return '$_iconFolder$file';
  }
}
