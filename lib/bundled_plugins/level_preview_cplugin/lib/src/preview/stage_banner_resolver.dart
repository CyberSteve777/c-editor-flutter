import 'dart:convert';

import 'package:flutter/services.dart';

/// Resolves stage / custom-stage aliases to banner asset paths.
class StageBannerResolver {
  StageBannerResolver._(this._defaultStem, this._extension, this._directory, this._stages);

  static const flutterAssetsRoot =
      'lib/bundled_plugins/level_preview_cplugin/assets';

  final String _defaultStem;
  final String _extension;
  final String _directory;
  final Map<String, String> _stages;

  static StageBannerResolver? _instance;

  static Future<StageBannerResolver> load() async {
    if (_instance != null) return _instance!;
    final raw = await rootBundle.loadString(
      '$flutterAssetsRoot/stage_banners.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final stagesRaw = json['stages'];
    final stages = <String, String>{};
    if (stagesRaw is Map) {
      for (final e in stagesRaw.entries) {
        stages[e.key.toString()] = e.value.toString();
      }
    }
    _instance = StageBannerResolver._(
      (json['default'] as String?) ?? 'Unknown',
      (json['extension'] as String?) ?? '.png',
      (json['directory'] as String?) ?? 'banners',
      stages,
    );
    return _instance!;
  }

  /// For tests.
  static void resetForTest() => _instance = null;

  static StageBannerResolver forTest({
    String defaultStem = 'Unknown',
    String extension = '.png',
    String directory = 'banners',
    Map<String, String> stages = const {},
  }) {
    return StageBannerResolver._(defaultStem, extension, directory, stages);
  }

  String get defaultStem => _defaultStem;

  String assetPathForStem(String stem) =>
      '$flutterAssetsRoot/$_directory/$stem$_extension';

  String resolveStem(String? stageAlias) {
    if (stageAlias == null || stageAlias.isEmpty) return _defaultStem;
    final direct = _stages[stageAlias];
    if (direct != null && direct.isNotEmpty) return direct;
    // Alias without trailing "Stage" / custom suffix already in map.
    if (_stages.containsKey(stageAlias)) return _stages[stageAlias]!;
    return _defaultStem;
  }

  String resolveAssetPath(String? stageAlias) =>
      assetPathForStem(resolveStem(stageAlias));

  List<String> get allStems {
    final stems = <String>{_defaultStem, ..._stages.values};
    return stems.toList()..sort();
  }
}
