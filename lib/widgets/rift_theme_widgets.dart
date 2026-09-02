import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/rift_theme_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart';

const _unknownIconPath = 'assets/images/others/unknown.webp';
const _pursuitThemeIconPath = 'assets/images/rift_themes/pursuit.webp';

class RiftThemeIcon extends StatelessWidget {
  const RiftThemeIcon({
    super.key,
    required this.themeId,
    this.size = 44,
    this.borderRadius = 10,
  });

  final String themeId;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: AssetImageWidget(
        assetPath: RiftThemeRepository.iconAssetPath(themeId),
        altCandidates: const [_pursuitThemeIconPath],
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorWidget: Icon(
          Icons.auto_awesome,
          size: size * 0.7,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}

Future<void> showRiftThemeDetailsDialog(
  BuildContext context,
  String themeId,
) async {
  await Future.wait([
    ResourceNames.ensureLoaded(),
    PlantRepository().init(),
    ZombieRepository().init(),
    ZombiePropertiesRepository.init(),
    RiftThemeRepository.ensureTargetListsLoaded(),
  ]);
  if (!context.mounted) return;

  final nameKey = RiftThemeRepository.nameKey(themeId);
  final name = ResourceNames.lookup(context, nameKey);
  final descriptionKey = RiftThemeRepository.descriptionKey(themeId);
  final description = ResourceNames.lookup(context, descriptionKey);
  final detailsKey = RiftThemeRepository.descriptionDetailsKey(themeId);
  final details = ResourceNames.lookup(context, detailsKey);
  final targetList = RiftThemeRepository.detailsTargetList(themeId);

  await showDialog<void>(
    context: context,
    builder: (dialogContext) {
      final l10n = AppLocalizations.of(dialogContext);
      final colorScheme = Theme.of(dialogContext).colorScheme;
      const compactCardWidth = 154.0;
      const cardSpacing = 8.0;
      final availableContentWidth =
          (MediaQuery.sizeOf(dialogContext).width - 128).clamp(0.0, 720.0);
      final useSingleColumn =
          availableContentWidth < compactCardWidth * 2 + cardSpacing;
      final targetCardWidth = useSingleColumn
          ? availableContentWidth
          : compactCardWidth;
      final targetColumnCount = useSingleColumn
          ? 1
          : ((availableContentWidth + cardSpacing) /
                    (compactCardWidth + cardSpacing))
                .floor();
      return AlertDialog(
        title: Row(
          children: [
            RiftThemeIcon(themeId: themeId, size: 48),
            const SizedBox(width: 12),
            Expanded(child: Text(name == nameKey ? themeId : name)),
          ],
        ),
        content: ConstrainedBox(
          constraints: BoxConstraints(
            minWidth: useSingleColumn ? availableContentWidth : 0,
            maxWidth: 720,
            maxHeight: 620,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _SectionTitle(
                  text: _resourceLabel(
                    dialogContext,
                    'rift_theme_effect_label',
                    'Theme effect',
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  description == descriptionKey ? themeId : description,
                  style: Theme.of(dialogContext).textTheme.bodyLarge,
                ),
                if (details != detailsKey) ...[
                  const SizedBox(height: 18),
                  _SectionTitle(
                    text: _resourceLabel(
                      dialogContext,
                      'rift_theme_details_label',
                      'Details',
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(details),
                ],
                if (targetList != null) ...[
                  const SizedBox(height: 20),
                  _SectionTitle(
                    text: _resourceLabel(
                      dialogContext,
                      targetList.type == RiftThemeTargetType.plants
                          ? 'rift_theme_related_plants'
                          : 'rift_theme_related_zombies',
                      targetList.type == RiftThemeTargetType.plants
                          ? 'Plant list'
                          : 'Zombie list',
                    ),
                  ),
                  const SizedBox(height: 10),
                  if (targetList.ids.isEmpty)
                    Text(
                      _resourceLabel(
                        dialogContext,
                        'rift_theme_no_related_zombies',
                        'There are currently no matching zombies available '
                            'in the editor.',
                      ),
                    )
                  else
                    _TargetCardRows(
                      ids: targetList.ids,
                      type: targetList.type,
                      colorScheme: colorScheme,
                      cardWidth: targetCardWidth,
                      columnCount: targetColumnCount,
                      spacing: cardSpacing,
                    ),
                ],
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      );
    },
  );
}

class _TargetCardRows extends StatelessWidget {
  const _TargetCardRows({
    required this.ids,
    required this.type,
    required this.colorScheme,
    required this.cardWidth,
    required this.columnCount,
    required this.spacing,
  });

  final List<String> ids;
  final RiftThemeTargetType type;
  final ColorScheme colorScheme;
  final double cardWidth;
  final int columnCount;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    final rows = <List<String>>[];
    for (var start = 0; start < ids.length; start += columnCount) {
      final next = start + columnCount;
      final end = next < ids.length ? next : ids.length;
      rows.add(ids.sublist(start, end));
    }

    return Column(
      children: [
        for (var rowIndex = 0; rowIndex < rows.length; rowIndex++) ...[
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var column = 0; column < columnCount; column++) ...[
                  if (column > 0) SizedBox(width: spacing),
                  SizedBox(
                    width: cardWidth,
                    child: column < rows[rowIndex].length
                        ? _TargetCard(
                            id: rows[rowIndex][column].trim(),
                            type: type,
                            colorScheme: colorScheme,
                            width: double.infinity,
                          )
                        : const SizedBox.shrink(),
                  ),
                ],
              ],
            ),
          ),
          if (rowIndex < rows.length - 1) SizedBox(height: spacing),
        ],
      ],
    );
  }
}

String _resourceLabel(BuildContext context, String key, String fallback) {
  final value = ResourceNames.lookup(context, key);
  return value == key ? fallback : value;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
        color: Theme.of(context).colorScheme.primary,
      ),
    );
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({
    required this.id,
    required this.type,
    required this.colorScheme,
    required this.width,
  });

  final String id;
  final RiftThemeTargetType type;
  final ColorScheme colorScheme;
  final double width;

  @override
  Widget build(BuildContext context) {
    final (nameKey, iconPath) = switch (type) {
      RiftThemeTargetType.plants => (
        PlantRepository().getName(id),
        PlantRepository().getPlantInfoById(id)?.iconAssetPath,
      ),
      RiftThemeTargetType.zombies => (
        ZombieRepository().getName(id),
        ZombieRepository().getZombieById(id)?.iconAssetPath,
      ),
    };
    final localizedName = ResourceNames.lookup(context, nameKey);
    final displayName = localizedName == nameKey ? id : localizedName;

    return Tooltip(
      message: '$displayName\n$id',
      child: Container(
        key: ValueKey('riftThemeTarget-$id'),
        width: width,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: colorScheme.outlineVariant.withValues(alpha: 0.65),
          ),
        ),
        child: Row(
          children: [
            AssetImageWidget(
              assetPath: iconPath ?? _unknownIconPath,
              width: 38,
              height: 38,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    id,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
