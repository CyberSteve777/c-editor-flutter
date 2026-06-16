import 'package:flutter/material.dart';
import 'package:c_editor/data/armrack_type_catalog.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/drop_ship_area_preview_grid.dart';
import 'package:c_editor/widgets/grid_override_preview_grid.dart';

const _energyGridTileAsset = 'assets/images/griditems/energyGrid.webp';

Future<void> showArmrackGridPreviewDialog(
  BuildContext context, {
  required PvzLevelFile levelFile,
  required List<ArmrackOverrideItemData> items,
  String? title,
  VoidCallback? onOpenModuleSettings,
}) {
  final l10n = AppLocalizations.of(context);
  final (rows, cols) = LevelParser.getGridDimensionsFromFile(levelFile);
  ArmrackOverrideItemData? itemAt(int col, int row) {
    for (final item in items) {
      if (item.mX == col && item.mY == row) return item;
    }
    return null;
  }

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        title ??
            l10n?.gridOverridePreviewArmrackTitle ??
            'Weapon stand placement',
      ),
      content: SingleChildScrollView(
        child: GridOverridePreviewGrid(
          gridRows: rows,
          gridCols: cols,
          cellImageAt: (col, row) {
            final item = itemAt(col, row);
            if (item == null) return null;
            return armrackIconAsset(item.type);
          },
          cellImageScaleAt: (col, row) {
            final item = itemAt(col, row);
            if (item == null) return 1.0;
            return armrackGridScale(item.type);
          },
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

Future<void> showEnergyGridPreviewDialog(
  BuildContext context, {
  required PvzLevelFile levelFile,
  required List<EnergyGridOverrideItemData> items,
  String? title,
  VoidCallback? onOpenModuleSettings,
}) {
  final l10n = AppLocalizations.of(context);
  final (rows, cols) = LevelParser.getGridDimensionsFromFile(levelFile);

  bool hasTileAt(int col, int row) {
    return items.any((item) => item.mX == col && item.mY == row);
  }

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        title ??
            l10n?.gridOverridePreviewEnergyGridTitle ??
            'Taiji tile placement',
      ),
      content: SingleChildScrollView(
        child: GridOverridePreviewGrid(
          gridRows: rows,
          gridCols: cols,
          cellImageAt: (col, row) =>
              hasTileAt(col, row) ? _energyGridTileAsset : null,
          cellImageScaleAt: (col, row) => 0.92,
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

Future<void> showDropShipGridPreviewDialog(
  BuildContext context, {
  required PvzLevelFile levelFile,
  required DropShipAppearWaveData wave,
  String? title,
  VoidCallback? onOpenModuleSettings,
}) {
  final l10n = AppLocalizations.of(context);
  final (rows, cols) = LevelParser.getGridDimensionsFromFile(levelFile);

  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(
        title ??
            l10n?.airDropShipModuleDropAreaPreview ??
            'Drop area preview',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${l10n?.airDropShipModuleExtraImpCount ?? 'Extra imp count (Imp)'}: ${wave.imp}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              l10n?.airDropShipModuleAreaDropPreviewLabel ??
                  'Area drop preview:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropShipAreaPreviewGrid(
              gridRows: rows,
              gridCols: cols,
              rowRange: wave.rowRange,
              colRange: wave.colRange,
            ),
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

String armrackTypeLabel(BuildContext context, String type) {
  final key = 'armrack_$type';
  final localized = ResourceNames.lookup(context, key);
  return localized == key ? type : localized;
}
