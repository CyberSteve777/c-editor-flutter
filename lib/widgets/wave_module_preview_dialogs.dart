import 'package:flutter/material.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/module_open_hint.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/renai_wave_preview_utils.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/drop_ship_area_preview_grid.dart';
import 'package:c_editor/widgets/grid_override_preview_grid.dart';
import 'package:c_editor/widgets/heian_wind_preview_text.dart';
import 'package:c_editor/widgets/renai_statue_preview_grid.dart';

Future<void> showDropShipWavePreviewDialog(
  BuildContext context, {
  required PvzLevelFile levelFile,
  required int waveIndex,
  required List<DropShipAppearWaveData> waves,
  VoidCallback? onOpenModuleSettings,
}) {
  if (waves.isEmpty) return Future.value();
  final l10n = AppLocalizations.of(context);
  final title =
      '${l10n?.waveLabel ?? 'Wave'} $waveIndex - ${l10n?.airDropShipModuleExpectationLabel ?? 'Airdropped Imps'}';
  final (gridRows, gridCols) = LevelParser.getGridDimensionsFromFile(levelFile);

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (final w in waves) ...[
              Text(
                '${l10n?.airDropShipModuleExtraImpCount ?? 'Extra imp count (Imp)'}: ${w.imp}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.airDropShipModuleAreaDropPreviewLabel ??
                    'Area drop preview:',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropShipAreaPreviewGrid(
                gridRows: gridRows,
                gridCols: gridCols,
                rowRange: w.rowRange,
                colRange: w.colRange,
              ),
              const SizedBox(height: 16),
            ],
          ],
        ),
      ),
      actions: [
        if (onOpenModuleSettings != null)
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(ctx);
              onOpenModuleSettings();
            },
            child: Text(l10n?.openModuleSettings ?? 'Open module settings'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n?.close ?? 'Close'),
        ),
      ],
    ),
  );
}

Future<void> showHeianWindWavePreviewDialog(
  BuildContext context, {
  required int waveIndex,
  required List<HeianWindWaveWindInfoData> waves,
  VoidCallback? onOpenModuleSettings,
}) {
  if (waves.isEmpty) return Future.value();
  final l10n = AppLocalizations.of(context);

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        '${l10n?.waveLabel ?? 'Wave'} $waveIndex - ${l10n?.heianWindModuleExpectationLabel ?? 'Divine Wind'}',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (final w in waves) ...[
              Text(
                '${l10n?.heianWindModuleWindDelay ?? 'Time between wind spawns (WindDelay)'}: ${w.windDelay}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              for (final wind in w.windInfos)
                Padding(
                  padding: const EdgeInsets.only(left: 8, top: 4),
                  child: Text(heianWindEntryPreviewLine(context, wind)),
                ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
      actions: [
        if (onOpenModuleSettings != null)
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(ctx);
              onOpenModuleSettings();
            },
            child: Text(l10n?.openModuleSettings ?? 'Open module settings'),
          ),
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n?.close ?? 'Close'),
        ),
      ],
    ),
  );
}

void openModuleWithHint(
  OpenModuleCallback? onOpenModule,
  PvzLevelFile levelFile,
  String objClass, {
  ModuleOpenHint? hint,
}) {
  if (onOpenModule == null) return;
  final rtid = moduleRtidForClass(levelFile, objClass);
  if (rtid == null) return;
  onOpenModule(rtid, hint: hint);
}

Future<void> showRenaiWavePreviewDialog(
  BuildContext context, {
  required PvzLevelFile levelFile,
  required int waveIndex,
  required RenaiModulePropertiesData renai,
  VoidCallback? onOpenModuleSettings,
}) {
  final l10n = AppLocalizations.of(context);
  final nightStarts = renaiNightStartsOnWave(renai, waveIndex);
  final nightSpawnStatues = renaiNightSpawnStatuesForWave(renai, waveIndex);
  final revivingStatues = renaiRevivingStatuesForWave(renai, waveIndex);
  final isEmpty = !renai.nightEnabled &&
      renai.statueInfos.isEmpty &&
      renai.statueNightInfos.isEmpty;
  final hasWaveEvents = nightStarts ||
      nightSpawnStatues.isNotEmpty ||
      revivingStatues.isNotEmpty;

  return showDialog<void>(
    context: context,
    builder: (ctx) {
      final previewGridWidth = renaiStatuePreviewMaxWidth(ctx);
      final children = <Widget>[];

      if (isEmpty) {
        children.add(
          Text(
            'Empty (roller/tiles only)',
            style: Theme.of(ctx).textTheme.bodyMedium,
          ),
        );
      } else {
        if (nightStarts) {
          children.add(
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.nightlight_round,
                  size: 16,
                  color: Theme.of(ctx).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(l10n?.renaiModuleNightStarts ?? 'Night begins'),
              ],
            ),
          );
          children.add(const SizedBox(height: 12));
        }
        if (nightSpawnStatues.isNotEmpty) {
          children.add(
            Text(
              l10n?.renaiModulePreviewNightStatues ?? 'Night statues:',
              style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
          children.add(const SizedBox(height: 8));
          children.add(
            RenaiStatuePreviewGrid(
              levelFile: levelFile,
              statues: nightSpawnStatues,
              maxWidth: previewGridWidth,
              shrinkOnDesktop: false,
            ),
          );
          children.add(const SizedBox(height: 12));
        }
        if (revivingStatues.isNotEmpty) {
          children.add(
            Text(
              l10n?.renaiModulePreviewRevivingStatues ?? 'Reviving statues:',
              style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          );
          children.add(const SizedBox(height: 8));
          children.add(
            RenaiStatuePreviewGrid(
              levelFile: levelFile,
              statues: revivingStatues,
              maxWidth: previewGridWidth,
              shrinkOnDesktop: false,
            ),
          );
        }
      }

      return AlertDialog(
        title: Text(
          '${l10n?.waveLabel ?? 'Wave'} $waveIndex - ${l10n?.renaiModuleExpectationLabel ?? 'Renaissance event preview'}',
        ),
        content: SingleChildScrollView(
          child: !hasWaveEvents && !isEmpty
              ? Text(
                  l10n?.noDynamicZombies ?? 'No events',
                  style: Theme.of(ctx).textTheme.bodySmall,
                )
              : children.isEmpty
                  ? Text(
                      l10n?.noDynamicZombies ?? 'No events',
                      style: Theme.of(ctx).textTheme.bodySmall,
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: children,
                    ),
        ),
        actions: [
          if (onOpenModuleSettings != null)
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () {
                Navigator.pop(ctx);
                onOpenModuleSettings();
              },
              child: Text(l10n?.openModuleSettings ?? 'Open module settings'),
            ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.close ?? 'Close'),
          ),
        ],
      );
    },
  );
}
