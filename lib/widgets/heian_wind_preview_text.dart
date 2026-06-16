import 'package:flutter/widgets.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';

String heianWindEntryPreviewLine(
  BuildContext context,
  HeianWindInfoData wind,
) {
  final l10n = AppLocalizations.of(context);
  final row = wind.row == -1
      ? (l10n?.heianWindModuleAllRows ?? 'All rows (-1)')
      : '${l10n?.heianWindModuleRow ?? 'Affected row (Row)'} ${wind.row + 1}';
  final affect =
      '${l10n?.heianWindModuleAffectZombies ?? 'Affect zombies'}: ${wind.affectZombies}';
  final distance =
      '${l10n?.heianWindModuleDistance ?? 'Push distance (Distance)'}: ${wind.distance}';
  return '$row · $affect · $distance';
}
