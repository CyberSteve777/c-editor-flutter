import 'package:flutter/material.dart';
import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/data/zomboss_mech_l10n.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/asset_image.dart';

/// Accent for custom zomboss mech editor (matches boss / custom tooling).
Color zombossMechAccent(BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return isDark ? pvzPurpleDark : pvzPurpleLight;
}

Color zombossMechActionTagColor(String tag, BuildContext context) {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return switch (tag) {
    'movement' => isDark ? const Color(0xFF64B5F6) : const Color(0xFF1565C0),
    'attack' => isDark ? const Color(0xFFEF9A9A) : const Color(0xFFC62828),
    'spawn' => isDark ? const Color(0xFFA5D6A7) : const Color(0xFF2E7D32),
    'special' => isDark ? const Color(0xFFCE93D8) : const Color(0xFF6A1B9A),
    'retreat' => isDark ? const Color(0xFFB0BEC5) : const Color(0xFF546E7A),
    _ => isDark ? const Color(0xFF90A4AE) : const Color(0xFF455A64),
  };
}

TextStyle zombossMechActionTitleStyle(BuildContext context) {
  return Theme.of(context).textTheme.titleSmall!.copyWith(
    fontWeight: FontWeight.bold,
    fontSize: 15,
    height: 1.25,
  );
}

/// Shared zomboss mech base card: icon + localized name in one row.
class ZombossMechBaseCard extends StatelessWidget {
  const ZombossMechBaseCard({
    super.key,
    required this.baseId,
    this.icon,
    this.compact = false,
    this.hideBorder = false,
    this.selected = false,
    this.trailing,
    this.onTap,
  });

  final String baseId;
  final String? icon;

  /// Tighter padding for the battle-tab summary row.
  final bool compact;

  /// Hides the outline (e.g. summary row on battle tabs).
  final bool hideBorder;
  final bool selected;
  final Widget? trailing;
  final VoidCallback? onTap;

  String _displayName(BuildContext context) {
    final name = ResourceNames.lookup(context, baseId);
    return name == baseId ? baseId : name;
  }

  String? _resolveIcon() {
    if (icon != null && icon!.isNotEmpty) return icon;
    return ZombossMechRepository.getBase(baseId)?.icon;
  }

  double _iconSize(double maxWidth) {
    final base = maxWidth * 0.11;
    if (compact) return base.clamp(36, 48);
    return base.clamp(40, 52);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconPath = _resolveIcon();
    final borderColor = selected
        ? theme.colorScheme.primary
        : theme.colorScheme.outlineVariant.withValues(alpha: 0.6);

    return Material(
      color: hideBorder
          ? Colors.transparent
          : selected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final iconSize = _iconSize(constraints.maxWidth);
            final gap = iconSize * 0.2;
            final hPad = compact ? 10.0 : 12.0;
            final vPad = compact ? 10.0 : 8.0;

            return Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: hideBorder
                    ? theme.colorScheme.surfaceContainerHighest.withValues(
                        alpha: 0.45,
                      )
                    : null,
                border: hideBorder
                    ? null
                    : Border.all(color: borderColor, width: selected ? 2 : 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildIcon(context, iconPath, iconSize),
                  SizedBox(width: gap),
                  Expanded(
                    child: Text(
                      _displayName(context),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                  ),
                  if (trailing != null) ...[SizedBox(width: gap), trailing!],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildIcon(BuildContext context, String? iconPath, double size) {
    return SizedBox(
      width: size,
      height: size,
      child: iconPath == null
          ? Icon(Icons.smart_toy_outlined, size: size * 0.6)
          : ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: AssetImageWidget(
                assetPath: 'assets/images/zombies/$iconPath',
                width: size,
                height: size,
                fit: BoxFit.contain,
              ),
            ),
    );
  }
}

/// Estimated row height for [ReorderableListView] in a bounded [SizedBox].
const double kZombossMechActionRowHeight = 62;

/// Action row for phase lists (drag handle + title + action buttons).
class ZombossMechActionListTile extends StatelessWidget {
  const ZombossMechActionListTile({
    super.key,
    required this.mechId,
    required this.catalog,
    required this.levelFile,
    required this.rtid,
    required this.tag,
    this.reorderIndex,
    this.onRemove,
    this.onEdit,
    this.onInspect,
  });

  final String mechId;
  final ZombossMechCatalogEntry catalog;
  final PvzLevelFile levelFile;
  final String rtid;
  final String tag;
  final int? reorderIndex;
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;
  final VoidCallback? onInspect;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ZombossMechActionRow(
        label: ZombossMechL10n.labelForStageRtid(
          context: context,
          mechId: mechId,
          catalog: catalog,
          levelFile: levelFile,
          rtid: rtid,
        ),
        tag: tag,
        onRemove: onRemove,
        onEdit: onEdit,
        onInspect: onInspect,
        reorderIndex: reorderIndex,
      ),
    );
  }
}

/// Retreat action row: always shows the action + swap button (no delete).
class ZombossMechRetreatActionTile extends StatelessWidget {
  const ZombossMechRetreatActionTile({
    super.key,
    required this.mechId,
    required this.catalog,
    required this.levelFile,
    required this.rtid,
    required this.tag,
    this.onSwap,
    this.onEdit,
    this.onInspect,
  });

  final String mechId;
  final ZombossMechCatalogEntry catalog;
  final PvzLevelFile levelFile;
  final String rtid;
  final String tag;
  final VoidCallback? onSwap;
  final VoidCallback? onEdit;
  final VoidCallback? onInspect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ZombossMechActionRow(
      label: ZombossMechL10n.labelForStageRtid(
        context: context,
        mechId: mechId,
        catalog: catalog,
        levelFile: levelFile,
        rtid: rtid,
      ),
      tag: tag,
      onRemove: null,
      onEdit: onEdit,
      onInspect: onInspect,
      showRemoveButton: false,
      trailing: onSwap == null
          ? null
          : IconButton(
              visualDensity: VisualDensity.compact,
              icon: const Icon(Icons.swap_horiz, size: 22),
              tooltip:
                  l10n?.zombossMechEditRetreatAction ?? 'Choose retreat action',
              onPressed: onSwap,
            ),
    );
  }
}

/// Shared layout for action / retreat rows.
class ZombossMechActionRow extends StatelessWidget {
  const ZombossMechActionRow({
    super.key,
    required this.label,
    required this.tag,
    this.onRemove,
    this.onEdit,
    this.onInspect,
    this.reorderIndex,
    this.showRemoveButton = true,
    this.trailing,
    this.mutedLabel = false,
  });

  final String label;
  final String tag;
  final VoidCallback? onRemove;
  final VoidCallback? onEdit;
  final VoidCallback? onInspect;
  final int? reorderIndex;
  final bool showRemoveButton;
  final Widget? trailing;
  final bool mutedLabel;

  static const _controlHeight = 52.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = zombossMechActionTagColor(tag, context);
    final l10n = AppLocalizations.of(context);
    final compact = MediaQuery.sizeOf(context).width < 400;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.55,
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: accent.withValues(alpha: 0.35)),
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(10),
                ),
              ),
            ),
            if (reorderIndex != null) _buildReorderHandle(accent, compact),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: compact ? 8 : 10,
                  vertical: compact ? 10 : 12,
                ),
                child: Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style:
                      (mutedLabel
                              ? theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                )
                              : zombossMechActionTitleStyle(context))
                          ?.copyWith(fontSize: compact ? 13 : 15),
                ),
              ),
            ),
            SizedBox(
              height: compact ? 44 : _controlHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (onEdit != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: compact ? EdgeInsets.zero : null,
                      constraints: compact
                          ? const BoxConstraints(minWidth: 36, minHeight: 36)
                          : null,
                      icon: const Icon(Icons.edit_outlined, size: 22),
                      tooltip: l10n?.edit ?? 'Edit',
                      onPressed: onEdit,
                    ),
                  if (onEdit == null && onInspect != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: compact ? EdgeInsets.zero : null,
                      constraints: compact
                          ? const BoxConstraints(minWidth: 36, minHeight: 36)
                          : null,
                      icon: const Icon(Icons.info_outline, size: 22),
                      tooltip:
                          l10n?.zombossMechActionDetails ?? 'Action Details',
                      onPressed: onInspect,
                    ),
                  if (trailing != null)
                    Center(child: trailing)
                  else if (showRemoveButton && onRemove != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: compact ? EdgeInsets.zero : null,
                      constraints: compact
                          ? const BoxConstraints(minWidth: 36, minHeight: 36)
                          : null,
                      icon: const Icon(Icons.close, size: 22),
                      tooltip: l10n?.remove ?? 'Remove',
                      onPressed: onRemove,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReorderHandle(Color accent, bool compact) {
    return SizedBox(
      width: compact ? 36 : 48,
      height: compact ? 44 : _controlHeight,
      child: Center(
        child: ReorderableDragStartListener(
          index: reorderIndex!,
          child: Icon(
            Icons.drag_indicator,
            color: accent.withValues(alpha: 0.9),
            size: compact ? 24 : 28,
          ),
        ),
      ),
    );
  }
}
