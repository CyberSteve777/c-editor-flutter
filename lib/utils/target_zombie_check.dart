import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';

bool isTargetZombie(String id) {
  return id.startsWith('zombie_target_arrow') ||
      id.startsWith('zombie_target_bottle') ||
      id.startsWith('zombie_target_wizard') ||
      id.startsWith('zombie_target_archmage') ||
      id.startsWith('zombie_target_gargantuar');
}

final _camelTouchPattern = RegExp(r'^camel_.*_touch$');

bool isCamelTouchZombie(String id) => _camelTouchPattern.hasMatch(id);

bool hasOakTrain(PvzLevelFile levelFile) {
  return levelFile.objects.any((o) => o.objClass == 'OakTrainProperties');
}

bool isTargetZombieBlocked(String selectedId, PvzLevelFile levelFile) {
  return isTargetZombie(selectedId) && !hasOakTrain(levelFile);
}

Future<bool> showTargetZombieNeedsOakTrainDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final meta = ModuleRegistry.getMetadata('OakTrainProperties');
  final moduleName = meta.getTitle(context);
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      content: Text(
        l10n?.targetZombieRequiresOakTrainDialog(moduleName) ??
            'This zombie requires the $moduleName module. Would you like to add it to the level?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(
            l10n?.cancel ?? 'Cancel',
            style: TextStyle(color: Theme.of(ctx).colorScheme.error),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.of(ctx).pop(true),
          child: Text(l10n?.add ?? 'Add'),
        ),
      ],
    ),
  );
  return result == true;
}
