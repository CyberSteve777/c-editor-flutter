import 'package:flutter/material.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/asset_image.dart';

/// One entry in a reorderable preset plant / zombie / grid-item list.
class PresetResourceListTile extends StatelessWidget {
  const PresetResourceListTile({
    super.key,
    required this.label,
    required this.iconAssetPath,
    required this.iconAltCandidates,
    required this.reorderIndex,
    required this.onRemove,
  });

  final String label;
  final String iconAssetPath;
  final List<String> iconAltCandidates;
  final int reorderIndex;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: PresetResourceListRow(
        label: label,
        iconAssetPath: iconAssetPath,
        iconAltCandidates: iconAltCandidates,
        reorderIndex: reorderIndex,
        onRemove: onRemove,
      ),
    );
  }
}

/// Shared layout: drag handle, rounded icon, localized name, remove.
class PresetResourceListRow extends StatelessWidget {
  const PresetResourceListRow({
    super.key,
    required this.label,
    required this.iconAssetPath,
    required this.iconAltCandidates,
    required this.onRemove,
    this.reorderIndex,
  });

  final String label;
  final String iconAssetPath;
  final List<String> iconAltCandidates;
  final VoidCallback onRemove;
  final int? reorderIndex;

  static const _controlHeight = 52.0;
  static const _iconBoxSize = 44.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final handleColor = theme.colorScheme.onSurfaceVariant.withValues(
      alpha: 0.85,
    );

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (reorderIndex != null) _buildReorderHandle(handleColor),
            Padding(
              padding: const EdgeInsets.only(left: 8, right: 4),
              child: _buildIcon(theme),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 12,
                ),
                child: Text(
                  label,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    height: 1.25,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: _controlHeight,
              child: IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close, size: 22),
                tooltip: l10n?.remove ?? 'Remove',
                onPressed: onRemove,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon(ThemeData theme) {
    return SizedBox(
      width: _iconBoxSize,
      height: _iconBoxSize,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(7),
          child: AssetImageWidget(
            assetPath: iconAssetPath,
            width: _iconBoxSize,
            height: _iconBoxSize,
            fit: BoxFit.contain,
            altCandidates: iconAltCandidates,
          ),
        ),
      ),
    );
  }

  Widget _buildReorderHandle(Color handleColor) {
    return SizedBox(
      width: 48,
      height: _controlHeight,
      child: Center(
        child: ReorderableDragStartListener(
          index: reorderIndex!,
          child: Icon(Icons.drag_indicator, color: handleColor, size: 28),
        ),
      ),
    );
  }
}
