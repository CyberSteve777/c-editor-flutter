import 'dart:convert';

/// Parsed `.cplugin` manifest (`manifest.json`).
class CPluginManifest {
  const CPluginManifest({
    required this.format,
    required this.formatVersion,
    required this.id,
    required this.name,
    required this.version,
    required this.entryLibrary,
    required this.entryFunction,
    this.author = '',
    this.description = '',
    this.minEditorVersion,
  });

  final String format;
  final int formatVersion;
  final String id;
  final String name;
  final String version;
  final String author;
  final String description;
  final String? minEditorVersion;
  final String entryLibrary;
  final String entryFunction;

  static const expectedFormat = 'cplugin';
  static const supportedFormatVersion = 1;

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
    if (name is! String || name.isEmpty) {
      throw const FormatException('manifest name is required');
    }
    if (version is! String || version.isEmpty) {
      throw const FormatException('manifest version is required');
    }

    return CPluginManifest(
      format: format,
      formatVersion: formatVersion,
      id: id,
      name: name,
      version: version,
      author: json['author'] is String ? json['author'] as String : '',
      description:
          json['description'] is String ? json['description'] as String : '',
      minEditorVersion: json['minEditorVersion'] is String
          ? json['minEditorVersion'] as String
          : null,
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
        'name': name,
        'version': version,
        if (author.isNotEmpty) 'author': author,
        if (description.isNotEmpty) 'description': description,
        if (minEditorVersion != null) 'minEditorVersion': minEditorVersion,
        'entry': {
          'library': entryLibrary,
          'function': entryFunction,
        },
      };

  String toJsonString() => const JsonEncoder.withIndent('  ').convert(toJson());
}
