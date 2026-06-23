import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:c_editor/data/asset_loader.dart';
import 'package:c_editor/data/models/custom_stage_preset.dart';

abstract final class CustomStagePresetRepository {
  static const String _resourcePath =
      'assets/resources/CustomStagePresets.json';

  static final List<CustomStagePreset> _presets = [];
  static bool _isLoaded = false;

  static Future<void> init() async {
    if (_isLoaded) return;
    try {
      final jsonString = await loadJsonString(_resourcePath);
      final raw = json.decode(jsonString);
      if (raw is! List<dynamic>) {
        throw FormatException('Expected array in $_resourcePath');
      }
      _presets
        ..clear()
        ..addAll(
          raw.map(
            (entry) => CustomStagePreset.fromJson(
              Map<String, dynamic>.from(entry as Map),
            ),
          ),
        );
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading custom stage presets: $e');
    }
  }

  static List<CustomStagePreset> get presets => List.unmodifiable(_presets);

  static bool isPresetCustomStageAlias(String alias) {
    for (final preset in _presets) {
      if (_matchesSuggestedAlias(alias, preset.alias)) return true;
    }
    return false;
  }

  static bool _matchesSuggestedAlias(String alias, String suggestedAlias) {
    if (alias == suggestedAlias) return true;
    if (!alias.startsWith(suggestedAlias)) return false;
    final suffix = alias.substring(suggestedAlias.length);
    if (suffix.isEmpty) return false;
    final number = int.tryParse(suffix);
    return number != null && number >= 2;
  }
}
