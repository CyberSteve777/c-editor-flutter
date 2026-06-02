import 'package:flutter/material.dart';
import 'package:z_editor/data/zomboss_mech_action_utils.dart';
import 'package:z_editor/l10n/app_localizations.dart';
import 'package:z_editor/theme/app_theme.dart';

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

/// Estimated row height for [ReorderableListView] in a bounded [SizedBox].
const double kZombossMechActionRowHeight = 62;

/// Action row for phase lists (drag handle + title + action buttons).
class ZombossMechActionListTile extends StatelessWidget {
  const ZombossMechActionListTile({
    super.key,
    required this.rtid,
    required this.tag,
    required this.reorderIndex,
    required this.onRemove,
    this.onEdit,
  });

  final String rtid;
  final String tag;
  final int reorderIndex;
  final VoidCallback onRemove;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: ZombossMechActionRow(
        rtid: rtid,
        tag: tag,
        onRemove: onRemove,
        onEdit: onEdit,
        reorderIndex: reorderIndex,
      ),
    );
  }
}

/// Retreat action row: always shows the action + swap button (no delete).
class ZombossMechRetreatActionTile extends StatelessWidget {
  const ZombossMechRetreatActionTile({
    super.key,
    required this.rtid,
    required this.tag,
    required this.onSwap,
    this.onEdit,
  });

  final String rtid;
  final String tag;
  final VoidCallback onSwap;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ZombossMechActionRow(
      rtid: rtid,
      tag: tag,
      onRemove: () {},
      onEdit: onEdit,
      showRemoveButton: false,
      trailing: IconButton(
        visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.swap_horiz, size: 22),
        tooltip: l10n?.zombossMechEditRetreatAction ?? 'Choose retreat action',
        onPressed: onSwap,
      ),
    );
  }
}

/// Shared layout for action / retreat rows.
class ZombossMechActionRow extends StatelessWidget {
  const ZombossMechActionRow({
    super.key,
    required this.rtid,
    required this.tag,
    required this.onRemove,
    this.onEdit,
    this.reorderIndex,
    this.showRemoveButton = true,
    this.trailing,
    this.mutedLabel = false,
  });

  final String rtid;
  final String tag;
  final VoidCallback onRemove;
  final VoidCallback? onEdit;
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

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
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
            if (reorderIndex != null) _buildReorderHandle(accent),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                child: Text(
                  mutedLabel
                      ? rtid
                      : ZombossMechActionUtils.displayLabel(rtid),
                  style: mutedLabel
                      ? theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        )
                      : zombossMechActionTitleStyle(context),
                ),
              ),
            ),
            SizedBox(
              height: _controlHeight,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (onEdit != null)
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      icon: const Icon(Icons.edit_outlined, size: 22),
                      tooltip: l10n?.edit ?? 'Edit',
                      onPressed: onEdit,
                    ),
                  if (trailing != null)
                    Center(child: trailing)
                  else if (showRemoveButton)
                    IconButton(
                      visualDensity: VisualDensity.compact,
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

  Widget _buildReorderHandle(Color accent) {
    return SizedBox(
      width: 48,
      height: _controlHeight,
      child: Center(
        child: ReorderableDragStartListener(
          index: reorderIndex!,
          child: Icon(
            Icons.drag_handle,
            color: accent.withValues(alpha: 0.9),
            size: 28,
          ),
        ),
      ),
    );
  }
}
