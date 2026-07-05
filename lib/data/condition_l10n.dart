import 'package:flutter/widgets.dart';
import 'package:c_editor/data/plant_conditions.dart';
import 'package:c_editor/data/zombie_conditions.dart';
import 'package:c_editor/l10n/resource_names.dart';

/// Localization keys for plant/zombie special-state ids in [assets/l10n/resource_*.json].
abstract class ConditionL10n {
  ConditionL10n._();

  static String zombieKey(String id) => ZombieConditions.resourceKey(id);

  static String plantKey(String id) => PlantConditions.resourceKey(id);

  static String _lookup(BuildContext context, String key, String fallback) {
    final localized = ResourceNames.lookup(context, key);
    return localized != key ? localized : fallback;
  }

  static String zombieLabel(BuildContext context, String conditionId) =>
      _lookup(context, zombieKey(conditionId), conditionId);

  static String plantLabel(BuildContext context, String conditionId) {
    final key = plantKey(conditionId);
    final localized = ResourceNames.lookup(context, key);
    if (localized != key) return localized;
    // Shared state (e.g. icecubed) also exists on zombies.
    return zombieLabel(context, conditionId);
  }
}
