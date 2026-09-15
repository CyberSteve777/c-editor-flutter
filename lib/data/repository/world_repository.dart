import 'dart:convert';

import 'package:c_editor/data/asset_loader.dart';
import 'package:c_editor/data/models/world_info.dart';
import 'package:c_editor/l10n/app_localizations.dart';

/// Worlds available for dynamic RSB export level assignment.
///
/// Softcoded from [referenceAssetPath]. Call [init] during app bootstrap
/// (or before export) so [allWorlds] / [findByCodename] are populated.
class WorldRepository {
  WorldRepository._();

  static const referenceAssetPath = 'assets/reference/WorldCodenames.json';

  static final List<WorldInfo> _worlds = [];
  static bool _isInitialized = false;

  static bool get isInitialized => _isInitialized;

  static Future<void> init() async {
    if (_isInitialized) return;
    try {
      final jsonStr = await loadJsonString(referenceAssetPath);
      final list = jsonDecode(jsonStr) as List<dynamic>;
      _worlds
        ..clear()
        ..addAll(
          list
              .whereType<Map>()
              .map((raw) => Map<String, dynamic>.from(raw))
              .map(_parseWorld)
              .whereType<WorldInfo>(),
        );
    } catch (_) {
      // Leave empty when the reference file is missing or malformed.
    } finally {
      _isInitialized = true;
    }
  }

  /// Test / tooling helper to force a reload after [init] already ran.
  static Future<void> reloadForTest() async {
    _isInitialized = false;
    _worlds.clear();
    await init();
  }

  static WorldInfo? _parseWorld(Map<String, dynamic> raw) {
    final codename = raw['codename'] as String?;
    final levelCount = raw['level_count'];
    final iconAsset = raw['icon_asset'] as String?;
    if (codename == null ||
        codename.isEmpty ||
        levelCount is! num ||
        iconAsset == null ||
        iconAsset.isEmpty) {
      return null;
    }
    final nameGetter = _nameGetterForCodename(codename);
    if (nameGetter == null) return null;
    return WorldInfo(
      codename: codename,
      levelCount: levelCount.toInt(),
      iconAsset: iconAsset,
      nameGetter: nameGetter,
    );
  }

  /// Maps world [codename] to the matching [AppLocalizations] world label.
  /// Unknown codenames are skipped so a typo does not crash export.
  static String Function(AppLocalizations l10n)? _nameGetterForCodename(
    String codename,
  ) {
    return switch (codename) {
      'egypt' => (l10n) => l10n.plantTagWorldEgypt,
      'pirate' => (l10n) => l10n.plantTagWorldPirate,
      'cowboy' => (l10n) => l10n.plantTagWorldWildWest,
      'kongfu' => (l10n) => l10n.plantTagWorldKongfu,
      'future' => (l10n) => l10n.plantTagWorldFuture,
      'dark' => (l10n) => l10n.plantTagWorldDarkAges,
      'iceage' => (l10n) => l10n.plantTagWorldIceage,
      'beach' => (l10n) => l10n.plantTagWorldBeach,
      'skycity' => (l10n) => l10n.plantTagWorldSkycity,
      'lostcity' => (l10n) => l10n.plantTagWorldLostCity,
      'eighties' => (l10n) => l10n.plantTagWorldEighties,
      'dino' => (l10n) => l10n.plantTagWorldDino,
      'modern' => (l10n) => l10n.plantTagWorldModern,
      'steam' => (l10n) => l10n.plantTagWorldSteam,
      'renai' => (l10n) => l10n.plantTagWorldRenai,
      'heian' => (l10n) => l10n.plantTagWorldHeian,
      'atlantis' => (l10n) => l10n.plantTagWorldAtlantis,
      'moon' => (l10n) => l10n.plantTagWorldMoon,
      'tutorial' => (l10n) => l10n.plantTagWorldTutorial,
      'fairytale' => (l10n) => l10n.plantTagWorldFairytale,
      'zcorp' => (l10n) => l10n.plantTagWorldZcorp,
      'mausoleum' => (l10n) => l10n.plantTagWorldMausoleum,
      _ => null,
    };
  }

  static List<WorldInfo> get allWorlds => List.unmodifiable(_worlds);

  static WorldInfo? findByCodename(String codename) {
    for (final world in _worlds) {
      if (world.codename == codename) return world;
    }
    return null;
  }
}
