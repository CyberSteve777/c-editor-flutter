import 'package:flutter/material.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';

const _armrackGridItemType = 'armrack';
const _energyGridGridItemType = 'energyGrid';
const _renaiGridItemTypes = {
  'renai_roller',
  'renai_tile_left',
  'renai_tile_right',
};

/// Returns true when the grid item selection should proceed.
Future<bool> confirmGridItemModuleRequirements(
  BuildContext context, {
  required String typeName,
  required PvzLevelFile levelFile,
  void Function(String objClass)? onAddModule,
}) async {
  if (typeName == _armrackGridItemType) {
    if (levelHasModule(levelFile, 'ArmrackProperties')) return true;
    if (onAddModule == null) return false;
    final l10n = AppLocalizations.of(context)!;
    final moduleName = ModuleRegistry.getMetadata(
      'ArmrackProperties',
    ).getTitle(context);
    final added = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.armrackModuleRequiredMessage(moduleName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.add),
          ),
        ],
      ),
    );
    if (added == true) {
      onAddModule('ArmrackProperties');
      return true;
    }
    return false;
  }

  if (typeName == _energyGridGridItemType) {
    if (levelHasModule(levelFile, 'EnergyGridProperties')) return true;
    final l10n = AppLocalizations.of(context)!;
    final proceed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.energyGridModuleWarningMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.continueAnyway),
          ),
        ],
      ),
    );
    if (proceed != true) return false;
    return true;
  }

  if (_renaiGridItemTypes.contains(typeName)) {
    if (levelHasModule(levelFile, 'RenaiModuleProperties')) return true;
    if (onAddModule == null) return false;
    final l10n = AppLocalizations.of(context)!;
    final moduleName = ModuleRegistry.getMetadata(
      'RenaiModuleProperties',
    ).getTitle(context);
    final added = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        content: Text(l10n.renaiGridItemModuleRequiredMessage(moduleName)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              l10n.cancel,
              style: TextStyle(color: Theme.of(ctx).colorScheme.error),
            ),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text(l10n.add),
          ),
        ],
      ),
    );
    if (added == true) {
      onAddModule('RenaiModuleProperties');
      return true;
    }
    return false;
  }

  return true;
}
