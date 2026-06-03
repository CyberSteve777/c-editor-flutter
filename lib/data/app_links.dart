import 'dart:convert';

import 'package:c_editor/data/asset_loader.dart';

/// External URLs loaded from [assetPath] (editable without recompiling).
class AppLinks {
  AppLinks({
    required this.source,
    required this.issues,
    required this.discordInvite,
    required this.levelPlaza,
  });

  static const assetPath = 'assets/meta/links.json';

  final String source;
  final String issues;
  final String discordInvite;
  final String levelPlaza;

  static AppLinks? _cached;

  static Future<AppLinks> load() async {
    if (_cached != null) return _cached!;
    final raw = json.decode(await loadJsonString(assetPath)) as Map<String, dynamic>;
    _cached = AppLinks(
      source: raw['source'] as String,
      issues: raw['issues'] as String,
      discordInvite: raw['discordInvite'] as String,
      levelPlaza: raw['levelPlaza'] as String,
    );
    return _cached!;
  }
}
