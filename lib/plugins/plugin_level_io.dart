import 'dart:convert';

import 'package:c_editor/data/pvz_models.dart';

/// Parses plugin-supplied level JSON into a [PvzLevelFile].
PvzLevelFile decodeLevelJson(String json) {
  late final Object? decoded;
  try {
    decoded = jsonDecode(json);
  } on FormatException catch (e) {
    throw FormatException('Invalid level JSON: ${e.message}');
  }
  if (decoded is! Map) {
    throw ArgumentError('Level JSON must be a JSON object');
  }
  try {
    return PvzLevelFile.fromJson(Map<String, dynamic>.from(decoded));
  } catch (e) {
    throw ArgumentError('Level JSON could not be parsed as PvzLevelFile: $e');
  }
}

/// Encodes a [PvzLevelFile] for the plugin host API.
String encodeLevelJson(PvzLevelFile level) => jsonEncode(level.toJson());
