import 'package:flutter/widgets.dart';
import 'package:z_editor/data/models/zomboss_mech_catalog.dart';
import 'package:z_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:z_editor/data/rtid_parser.dart';
import 'package:z_editor/data/zomboss_mech_action_utils.dart';
import 'package:z_editor/l10n/app_localizations.dart';
import 'package:z_editor/l10n/resource_names.dart';

/// Localization keys for [assets/l10n/resource_*.json] zomboss mech editor strings.
abstract class ZombossMechL10n {
  ZombossMechL10n._();

  static String variationKey(String mechId, String variation) =>
      '${mechId}_variation_$variation';

  static String actionKey(String mechId, String objclass) =>
      '${mechId}_action_$objclass';

  static String fieldKey(String mechId, String objclass, String fieldName) =>
      '${mechId}_action_${objclass}_field_$fieldName';

  static String? _lookup(BuildContext context, String key, String fallback) {
    final localized = ResourceNames.lookup(context, key);
    return localized != key ? localized : fallback;
  }

  static String variationLabel(
    BuildContext context,
    String mechId,
    String variation, {
    String? fallback,
  }) {
    final fb = fallback ?? variation;
    return _lookup(context, variationKey(mechId, variation), fb) ?? fb;
  }

  static String actionLabel(
    BuildContext context,
    String mechId,
    String objclass, {
    String? fallback,
  }) {
    final fb = fallback ?? objclass;
    return _lookup(context, actionKey(mechId, objclass), fb) ?? fb;
  }

  static String fieldLabel(
    BuildContext context,
    String mechId,
    String objclass,
    String fieldName, {
    String? fallback,
  }) {
    final fb = fallback ?? fieldName;
    return _lookup(context, fieldKey(mechId, objclass, fieldName), fb) ?? fb;
  }

  /// Category chip / tag label from ARB (movement, attack, spawn, …).
  static String tagLabel(BuildContext context, String tag) {
    final l10n = AppLocalizations.of(context);
    return switch (tag) {
      'movement' => l10n?.zombossMechActionCategoryMovement ?? 'Movement',
      'attack' => l10n?.zombossMechActionCategoryAttack ?? 'Attack',
      'spawn' => l10n?.zombossMechActionCategorySpawn ?? 'Spawn',
      'special' => l10n?.zombossMechActionCategorySpecial ?? 'Special',
      'retreat' => l10n?.zombossMechActionCategoryRetreat ?? 'Retreat',
      _ => tag,
    };
  }

  /// RTID label for phase lists and action picker.
  /// [CurrentLevel] actions stay ``alias@CurrentLevel``; catalog uses resource JSON.
  static String actionRtidLabel(
    BuildContext context,
    String mechId,
    String rtid, {
    String? objclass,
    String? implementationAlias,
  }) {
    final info = RtidParser.parse(rtid);
    if (info == null) return rtid;
    if (info.source == 'CurrentLevel') {
      return '${info.alias}@${info.source}';
    }
    if (objclass != null && objclass.isNotEmpty) {
      return actionLabel(
        context,
        mechId,
        objclass,
        fallback: implementationAlias ?? info.alias,
      );
    }
    return '${info.alias}@${info.source}';
  }

  /// Phase / retreat list label: always ``alias@source`` (catalog and custom).
  static String labelForStageRtid({
    required BuildContext context,
    required String mechId,
    required ZombossMechCatalogEntry catalog,
    required PvzLevelFile levelFile,
    required String rtid,
  }) {
    return ZombossMechActionUtils.displayLabel(rtid);
  }
}
