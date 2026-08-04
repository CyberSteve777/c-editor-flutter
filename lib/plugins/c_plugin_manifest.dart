import 'dart:convert';

import 'package:pub_semver/pub_semver.dart';

/// Declares that this plugin conflicts with another plugin id at matching versions.
class CPluginIncompatibility {
  const CPluginIncompatibility({
    required this.id,
    this.version = '*',
  });

  /// Target plugin id.
  final String id;

  /// Semver constraint for the target's version (e.g. `>=2.0.0`, `^1.2.0`, `*`).
  final String version;

  factory CPluginIncompatibility.fromJson(Map<String, dynamic> json) {
    final id = json['id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('incompatibleWith.id is required');
    }
    final version = json['version'];
    return CPluginIncompatibility(
      id: id,
      version: version is String && version.isNotEmpty ? version : '*',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        if (version != '*') 'version': version,
      };

  /// Whether [otherVersion] satisfies this constraint (i.e. conflict applies).
  bool matchesVersion(String otherVersion) {
    try {
      final constraint = VersionConstraint.parse(version);
      final parsed = Version.parse(_normalizeVersion(otherVersion));
      return constraint.allows(parsed);
    } catch (_) {
      // Invalid constraint / version → treat as non-matching (no false conflict).
      return false;
    }
  }
}

String _normalizeVersion(String raw) {
  final trimmed = raw.trim();
  if (trimmed.isEmpty) return '0.0.0';
  // Allow "1.0" → "1.0.0"
  final parts = trimmed.split(RegExp(r'[-+]')).first.split('.');
  while (parts.length < 3) {
    parts.add('0');
  }
  final core = parts.take(3).join('.');
  final rest = trimmed.substring(parts.take(3).join('.').length);
  return '$core$rest';
}

/// Parsed `.cplugin` manifest (`manifest.json`).
class CPluginManifest {
  const CPluginManifest({
    required this.format,
    required this.formatVersion,
    required this.id,
    required this.version,
    required this.entryLibrary,
    required this.entryFunction,
    this.name = '',
    this.author = '',
    this.authors = const [],
    this.contributors = const [],
    this.description = '',
    this.minEditorVersion,
    this.icon,
    this.license,
    this.website,
    this.issues,
    this.source,
    this.discord,
    this.incompatibleWith = const [],
  });

  final String format;
  final int formatVersion;
  final String id;

  /// Legacy English display name. Prefer `pluginName` in plugin ARB assets.
  final String name;
  final String version;

  /// Legacy single-author field (still accepted). Prefer [authors].
  final String author;

  /// Primary authors credited for the plugin.
  final List<String> authors;

  /// Additional contributors.
  final List<String> contributors;

  /// Legacy English description. Prefer `pluginDescription` in plugin ARB assets.
  final String description;
  final String? minEditorVersion;

  /// Path relative to plugin `assets/` (e.g. `icon.png`).
  final String? icon;

  final String? license;
  final String? website;
  final String? issues;
  final String? source;
  final String? discord;

  final List<CPluginIncompatibility> incompatibleWith;

  final String entryLibrary;
  final String entryFunction;

  static const expectedFormat = 'cplugin';
  static const supportedFormatVersion = 1;

  /// Authors for display: [authors] if non-empty, else legacy [author].
  List<String> get resolvedAuthors {
    if (authors.isNotEmpty) return authors;
    if (author.isNotEmpty) return [author];
    return const [];
  }

  String get authorsDisplay {
    final list = resolvedAuthors;
    if (list.isEmpty) return '';
    return list.join(', ');
  }

  /// Whether this manifest declares a conflict with [other]'s id+version.
  bool declaresIncompatibilityWith(CPluginManifest other) {
    for (final rule in incompatibleWith) {
      if (rule.id == other.id && rule.matchesVersion(other.version)) {
        return true;
      }
    }
    return false;
  }

  factory CPluginManifest.fromJson(Map<String, dynamic> json) {
    final entry = json['entry'];
    if (entry is! Map) {
      throw const FormatException('manifest entry must be an object');
    }
    final library = entry['library'];
    final function = entry['function'];
    if (library is! String || library.isEmpty) {
      throw const FormatException('manifest entry.library is required');
    }
    if (function is! String || function.isEmpty) {
      throw const FormatException('manifest entry.function is required');
    }

    final id = json['id'];
    final name = json['name'];
    final version = json['version'];
    final format = json['format'];
    final formatVersion = json['formatVersion'];

    if (format is! String || format != expectedFormat) {
      throw const FormatException('manifest format must be "cplugin"');
    }
    if (formatVersion is! int || formatVersion != supportedFormatVersion) {
      throw FormatException(
        'unsupported cplugin formatVersion: $formatVersion',
      );
    }
    if (id is! String || id.isEmpty) {
      throw const FormatException('manifest id is required');
    }
    if (version is! String || version.isEmpty) {
      throw const FormatException('manifest version is required');
    }

    return CPluginManifest(
      format: format,
      formatVersion: formatVersion,
      id: id,
      name: name is String ? name : '',
      version: version,
      author: json['author'] is String ? json['author'] as String : '',
      authors: _stringList(json['authors']),
      contributors: _stringList(json['contributors']),
      description:
          json['description'] is String ? json['description'] as String : '',
      minEditorVersion: json['minEditorVersion'] is String
          ? json['minEditorVersion'] as String
          : null,
      icon: json['icon'] is String && (json['icon'] as String).isNotEmpty
          ? json['icon'] as String
          : null,
      license: _optionalString(json['license']),
      website: _optionalString(json['website']),
      issues: _optionalString(json['issues']),
      source: _optionalString(json['source']),
      discord: _optionalString(json['discord']),
      incompatibleWith: _incompatList(json['incompatibleWith']),
      entryLibrary: library,
      entryFunction: function,
    );
  }

  factory CPluginManifest.fromJsonString(String source) {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('manifest.json must be a JSON object');
    }
    return CPluginManifest.fromJson(decoded);
  }

  Map<String, dynamic> toJson() => {
        'format': format,
        'formatVersion': formatVersion,
        'id': id,
        'version': version,
        // Legacy fields kept for older packages; prefer ARB `pluginName` /
        // `pluginDescription`.
        if (name.isNotEmpty) 'name': name,
        if (author.isNotEmpty) 'author': author,
        if (authors.isNotEmpty) 'authors': authors,
        if (contributors.isNotEmpty) 'contributors': contributors,
        if (description.isNotEmpty) 'description': description,
        if (minEditorVersion != null) 'minEditorVersion': minEditorVersion,
        if (icon != null) 'icon': icon,
        if (license != null) 'license': license,
        if (website != null) 'website': website,
        if (issues != null) 'issues': issues,
        if (source != null) 'source': source,
        if (discord != null) 'discord': discord,
        if (incompatibleWith.isNotEmpty)
          'incompatibleWith':
              incompatibleWith.map((e) => e.toJson()).toList(growable: false),
        'entry': {
          'library': entryLibrary,
          'function': entryFunction,
        },
      };

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());

  static String? _optionalString(Object? value) {
    if (value is String && value.isNotEmpty) return value;
    return null;
  }

  static List<String> _stringList(Object? value) {
    if (value is! List) return const [];
    return value
        .whereType<String>()
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);
  }

  static List<CPluginIncompatibility> _incompatList(Object? value) {
    if (value is! List) return const [];
    final out = <CPluginIncompatibility>[];
    for (final item in value) {
      if (item is Map<String, dynamic>) {
        out.add(CPluginIncompatibility.fromJson(item));
      } else if (item is Map) {
        out.add(
          CPluginIncompatibility.fromJson(Map<String, dynamic>.from(item)),
        );
      }
    }
    return List.unmodifiable(out);
  }
}

/// Returns a human-readable conflict message, or `null` if none.
String? findPluginConflictMessage(
  CPluginManifest candidate,
  Iterable<CPluginManifest> installed,
) {
  for (final other in installed) {
    if (other.id == candidate.id) continue;
    if (candidate.declaresIncompatibilityWith(other)) {
      final label = other.name.isNotEmpty ? other.name : other.id;
      return 'Incompatible with $label (${other.id}) '
          'v${other.version}';
    }
    if (other.declaresIncompatibilityWith(candidate)) {
      final label = other.name.isNotEmpty ? other.name : other.id;
      return 'Conflicts with $label (${other.id}) '
          'v${other.version}';
    }
  }
  return null;
}
