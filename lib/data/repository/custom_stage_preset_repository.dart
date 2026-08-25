import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:c_editor/data/asset_loader.dart';
import 'package:c_editor/data/models/custom_stage_preset.dart';
import 'package:c_editor/data/pvz_models.dart';

enum CustomStageOrigin { presetTemplate, presetDerived, userCreated }

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

  /// Resource groups contributed by every bundled custom-lawn preset.
  ///
  /// This is derived from the preset data so new presets automatically become
  /// available from the custom lawn editor's global import list.
  static Set<String> get resourceGroups {
    final groups = <String>{};
    for (final preset in _presets) {
      _collectGroups(groups, preset.objdata['ResourceGroupNames']);
      _collectGroups(groups, preset.objdata['GroupsToUnloadForAds']);
    }
    return Set.unmodifiable(groups);
  }

  static void _collectGroups(Set<String> target, dynamic raw) {
    if (raw is! List) return;
    for (final item in raw) {
      if (item is String && item.isNotEmpty) target.add(item);
    }
  }

  @visibleForTesting
  static void resetForTest() {
    _isLoaded = false;
    _presets.clear();
  }

  static CustomStagePreset? presetById(String id) {
    for (final preset in _presets) {
      if (preset.id == id) return preset;
    }
    return null;
  }

  static CustomStagePreset? presetForObject(PvzObject object) {
    final alias = object.aliases?.isNotEmpty == true
        ? object.aliases!.first
        : null;
    if (alias == null) return null;
    return presetForAlias(alias);
  }

  static CustomStagePreset? presetForAlias(String alias) {
    for (final preset in _presets) {
      if (_matchesSuggestedAlias(alias, preset.alias)) return preset;
    }
    return null;
  }

  static CustomStageOrigin originForObject(PvzObject object) {
    final preset = presetForObject(object);
    if (preset == null) return CustomStageOrigin.userCreated;
    return _matchesPresetData(object, preset)
        ? CustomStageOrigin.presetTemplate
        : CustomStageOrigin.presetDerived;
  }

  static List<String> aliasesForPresetInstance({
    required String primaryAlias,
    required CustomStagePreset preset,
  }) {
    return [primaryAlias];
  }

  static List<String> preservePresetMarkerAliases({
    required String primaryAlias,
    required Iterable<String>? existingAliases,
  }) {
    return [primaryAlias];
  }

  static bool isMetadataAlias(String alias) =>
      PvzObject.isEditorMetadataAlias(alias);

  static bool isPresetCustomStageAlias(String alias) {
    return presetForAlias(alias) != null;
  }

  static bool _matchesPresetData(PvzObject object, CustomStagePreset preset) {
    if (object.objClass != preset.objclass) return false;
    final data = object.objData is Map
        ? Map<String, dynamic>.from(object.objData as Map)
        : const <String, dynamic>{};
    return const DeepCollectionEquality().equals(data, preset.objdata);
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
