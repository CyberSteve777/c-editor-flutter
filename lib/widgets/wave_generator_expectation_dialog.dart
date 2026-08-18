import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/wave_generator_point_analysis.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart' show isDesktopPlatform;

const _kUnknownIconPath = 'assets/images/others/unknown.webp';

double _expectationDialogIconSize(BuildContext context) {
  final isDesktop = isDesktopPlatform(context);
  final compact = MediaQuery.sizeOf(context).width < 400;
  if (isDesktop) return compact ? 44 : 48;
  return compact ? 36 : 40;
}

Size _expectationDialogListSize(BuildContext context) {
  final isDesktop = isDesktopPlatform(context);
  final screenWidth = MediaQuery.sizeOf(context).width;
  if (isDesktop) {
    return Size(420, screenWidth < 500 ? 300 : 360);
  }
  return Size((screenWidth - 96).clamp(280, 360), 280);
}

void showWaveGeneratorExpectationDialog(
  BuildContext context, {
  required WaveGeneratorPropertiesData data,
  required int waveIndex,
}) {
  final l10n = AppLocalizations.of(context);
  final preview = WaveGeneratorPointAnalysis.calculatePreview(data, waveIndex);
  final items = preview.entries
      .where((entry) => entry.averageCount > 0)
      .toList();

  showDialog<void>(
    context: context,
    builder: (ctx) {
      final scrollController = ScrollController();
      final iconSize = _expectationDialogIconSize(ctx);
      final listSize = _expectationDialogListSize(ctx);
      return AlertDialog(
        title: Text(
          l10n?.waveGeneratorExpectationTitle(waveIndex) ??
              '${l10n?.waveLabel ?? 'Wave'} $waveIndex — Random spawn preview',
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.waveGeneratorEffectiveRandomPoints(preview.points) ??
                  'Effective random-spawn points: ${preview.points}',
              style: Theme.of(
                ctx,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              l10n?.waveGeneratorFixedSpawnCount(preview.fixedSpawnCount) ??
                  'Fixed spawns: ${preview.fixedSpawnCount}',
            ),
            if (preview.missingDataTypes.isNotEmpty) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(ctx).colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    l10n?.waveGeneratorExpectationMissingData(
                          preview.missingDataTypes.join(', '),
                        ) ??
                        'Preview unavailable because some zombies are missing WavePointCost or Weight data: ${preview.missingDataTypes.join(', ')}',
                    style: TextStyle(
                      color: Theme.of(ctx).colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ] else if (!preview.randomSpawnsEnabled) ...[
              const SizedBox(height: 12),
              Text(
                l10n?.waveGeneratorExpectationDisabled ??
                    'Random spawning is disabled on this wave.',
              ),
            ] else if (preview.poolIsEmpty || preview.points <= 0) ...[
              const SizedBox(height: 12),
              Text(
                l10n?.waveGeneratorExpectationEmpty ??
                    'No eligible pool zombies for random spawns on this wave.',
                style: Theme.of(ctx).textTheme.bodySmall,
              ),
            ] else ...[
              const SizedBox(height: 8),
              Text(
                l10n?.waveGeneratorExpectationEstimatedTotal(
                      preview.averageTotal.toStringAsFixed(1),
                    ) ??
                    'Estimated random spawns: about ${preview.averageTotal.toStringAsFixed(1)}',
                style: Theme.of(
                  ctx,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                l10n?.waveGeneratorExpectationCommonRange(
                      preview.commonMinimum,
                      preview.commonMaximum,
                    ) ??
                    'Common range: ${preview.commonMinimum}–${preview.commonMaximum}',
              ),
              const SizedBox(height: 6),
              Text(
                l10n?.waveGeneratorExpectationPoolNote ??
                    'This is a stable statistical preview of repeated weighted purchases from the current effective pool, not a prediction of the game RNG.',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                  color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: listSize.width,
                height: listSize.height,
                child: Scrollbar(
                  controller: scrollController,
                  thumbVisibility: true,
                  child: ListView.builder(
                    controller: scrollController,
                    padding: const EdgeInsets.only(right: 14),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final e = items[i];
                      final typeName = e.id;
                      final info = ZombieRepository().getZombieById(typeName);
                      final nameKey =
                          info?.name ?? ZombieRepository().getName(typeName);
                      final displayName = ResourceNames.lookup(ctx, nameKey);
                      final iconPath = info?.iconAssetPath ?? _kUnknownIconPath;
                      return Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: isDesktopPlatform(ctx) ? 5 : 4,
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: ColoredBox(
                                color: Theme.of(
                                  ctx,
                                ).colorScheme.surfaceContainerHighest,
                                child: SizedBox(
                                  width: iconSize,
                                  height: iconSize,
                                  child: AssetImageWidget(
                                    assetPath: iconPath,
                                    altCandidates: imageAltCandidates(iconPath),
                                    width: iconSize,
                                    height: iconSize,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    displayName.isNotEmpty
                                        ? displayName
                                        : typeName,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(ctx).textTheme.bodyMedium
                                        ?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                  Text(
                                    typeName,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(ctx).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            ctx,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                  Text(
                                    l10n?.waveGeneratorExpectationCostWeight(
                                          e.cost,
                                          e.weight.toStringAsFixed(0),
                                        ) ??
                                        'Cost ${e.cost} · Weight ${e.weight.toStringAsFixed(0)}',
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(ctx).textTheme.bodySmall
                                        ?.copyWith(
                                          color: Theme.of(
                                            ctx,
                                          ).colorScheme.onSurfaceVariant,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              l10n?.waveGeneratorExpectationAverageCount(
                                    e.averageCount.toStringAsFixed(2),
                                  ) ??
                                  'Avg. ${e.averageCount.toStringAsFixed(2)}',
                              style: Theme.of(ctx).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.close ?? 'Close'),
          ),
        ],
      );
    },
  );
}
