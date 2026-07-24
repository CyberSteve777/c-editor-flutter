import 'dart:convert';

/// Parses a Flutter-style `.arb` document into message key → string value.
///
/// Skips metadata keys (`@@locale`, `@someKey`, …). Non-string message values
/// are ignored. Invalid JSON returns an empty map.
Map<String, String> parsePluginArb(String source) {
  Object? decoded;
  try {
    decoded = jsonDecode(source);
  } catch (_) {
    return const {};
  }
  if (decoded is! Map) return const {};

  final out = <String, String>{};
  for (final entry in decoded.entries) {
    final key = entry.key;
    if (key is! String || key.isEmpty) continue;
    if (key.startsWith('@')) continue;
    final value = entry.value;
    if (value is String) {
      out[key] = value;
    }
  }
  return out;
}

/// Candidate asset paths for plugin locale messages (ARB only).
///
/// Preferred layout: `assets/l10n/{locale}.arb`.
/// Also accepts Flutter-style `*_ {locale}.arb` names.
List<String> pluginArbAssetCandidates(String languageCode) {
  final code = languageCode.trim().toLowerCase();
  if (code.isEmpty) return const [];
  return [
    'l10n/$code.arb',
    'l10n/app_$code.arb',
    'l10n/messages_$code.arb',
    'l10n/plugin_$code.arb',
  ];
}

/// Looks up [key] in plugin ARB assets for [languageCode], then `en`.
String? lookupPluginArbMessage(
  String? Function(String relativePath) readString,
  String languageCode,
  String key,
) {
  for (final code in [languageCode, 'en']) {
    if (code.isEmpty) continue;
    for (final path in pluginArbAssetCandidates(code)) {
      final raw = readString(path);
      if (raw == null) continue;
      final messages = parsePluginArb(raw);
      final value = messages[key];
      if (value != null) return value;
    }
  }
  return null;
}
