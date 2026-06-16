import 'package:flutter/material.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/module_open_hint.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/grid_override_preview_dialog.dart';
import 'package:c_editor/widgets/wave_module_preview_dialogs.dart';

/// Card for previewing initial armrack / energy-grid placements (wave 1 preset).
class InitialKongfuGridItemsCard extends StatelessWidget {
  const InitialKongfuGridItemsCard({
    super.key,
    required this.levelFile,
    this.onOpenModule,
    this.margin = const EdgeInsets.only(bottom: 16),
  });

  final PvzLevelFile levelFile;
  final OpenModuleCallback? onOpenModule;
  final EdgeInsetsGeometry margin;

  void _showInitialArmrackPreview(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = initialArmrackItems(readArmrackModuleData(levelFile));
    if (items.isEmpty) return;
    showArmrackGridPreviewDialog(
      context,
      levelFile: levelFile,
      items: items,
      title: l10n?.waveGeneratorPreviewInitialArmrack ??
          'Preview initial weapon stands placement',
      onOpenModuleSettings: onOpenModule == null
          ? null
          : () => openModuleWithHint(
                onOpenModule,
                levelFile,
                'ArmrackProperties',
                hint: const ModuleOpenHint(
                  gridOverrideModuleWave: gridOverrideInitialWave,
                ),
              ),
    );
  }

  void _showInitialEnergyGridPreview(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final items = initialEnergyGridItems(readEnergyGridModuleData(levelFile));
    if (items.isEmpty) return;
    showEnergyGridPreviewDialog(
      context,
      levelFile: levelFile,
      items: items,
      title: l10n?.waveGeneratorPreviewInitialEnergyGrid ??
          'Preview initial Taiji tiles placement',
      onOpenModuleSettings: onOpenModule == null
          ? null
          : () => openModuleWithHint(
                onOpenModule,
                levelFile,
                'EnergyGridProperties',
                hint: const ModuleOpenHint(
                  gridOverrideModuleWave: gridOverrideInitialWave,
                ),
              ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!levelHasKongfuGridOverrideModules(levelFile)) {
      return const SizedBox.shrink();
    }

    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final showArmrack =
        hasInitialArmrackItems(readArmrackModuleData(levelFile));
    final showEnergyGrid =
        hasInitialEnergyGridItems(readEnergyGridModuleData(levelFile));
    final itemBg = theme.colorScheme.surfaceContainerHighest;
    final onCard = theme.colorScheme.onSurface;

    return Card(
      margin: margin,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.grid_view, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.waveGeneratorInitialGridOverridesTitle ??
                        'Initial kongfu grid items',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (showArmrack || showEnergyGrid) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  if (showArmrack)
                    Material(
                      color: itemBg,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => _showInitialArmrackPreview(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Text(
                            l10n?.waveGeneratorPreviewInitialArmrack ??
                                'Preview initial weapon stands placement',
                            style: TextStyle(
                              color: onCard,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  if (showEnergyGrid)
                    Material(
                      color: itemBg,
                      borderRadius: BorderRadius.circular(8),
                      child: InkWell(
                        onTap: () => _showInitialEnergyGridPreview(context),
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          child: Text(
                            l10n?.waveGeneratorPreviewInitialEnergyGrid ??
                                'Preview initial Taiji tiles placement',
                            style: TextStyle(
                              color: onCard,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
