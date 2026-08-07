import 'package:flutter/material.dart';

import 'package:c_editor/data/resilience_weak_type.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/asset_image.dart';

String resilienceWeakTypeLabel(AppLocalizations? l10n, int weakType) =>
    resilienceWeakTypeLabelForValue(l10n, weakType);

String? resilienceWeakTypeIconPath(int weakType) =>
    resilienceWeakTypeIconForValue(weakType);

class ResilienceWeakTypeIcon extends StatelessWidget {
  const ResilienceWeakTypeIcon({
    super.key,
    required this.weakType,
    this.size = 20,
  });

  final int weakType;
  final double size;

  @override
  Widget build(BuildContext context) {
    final iconPath = resilienceWeakTypeIconPath(weakType);
    if (iconPath == null) return SizedBox(width: size, height: size);
    return AssetImageWidget(
      assetPath: iconPath,
      width: size,
      height: size,
      fit: BoxFit.contain,
      altCandidates: imageAltCandidates(iconPath),
    );
  }
}

class ResilienceWeakTypeLabelRow extends StatelessWidget {
  const ResilienceWeakTypeLabelRow({
    super.key,
    required this.weakType,
    required this.label,
    this.iconSize = 20,

    /// Use in horizontally scrolling chips where width is unbounded.
    this.compact = false,
    this.valueBold = false,
  });

  final int weakType;
  final String label;
  final double iconSize;
  final bool compact;
  final bool valueBold;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final text = Text(
      label,
      overflow: TextOverflow.ellipsis,
      style: valueBold
          ? theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500)
          : null,
    );
    return Row(
      mainAxisSize: compact ? MainAxisSize.min : MainAxisSize.max,
      children: [
        ResilienceWeakTypeIcon(weakType: weakType, size: iconSize),
        const SizedBox(width: 8),
        if (compact) text else Flexible(child: text),
      ],
    );
  }
}

class ResilienceShieldSelectionCard extends StatelessWidget {
  const ResilienceShieldSelectionCard({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ResilienceShieldParameterRow extends StatelessWidget {
  const ResilienceShieldParameterRow({
    super.key,
    required this.label,
    required this.value,
    this.weakType,
  });

  final String label;
  final String value;
  final int? weakType;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelWidget = Text(
      label,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
    final valueWidget = weakType != null
        ? ResilienceWeakTypeLabelRow(
            weakType: weakType!,
            label: value,
            iconSize: 18,
            valueBold: true,
          )
        : Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          );
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 600) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                labelWidget,
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: valueWidget,
                ),
              ],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 3, child: labelWidget),
              const SizedBox(width: 24),
              Expanded(flex: 2, child: valueWidget),
            ],
          );
        },
      ),
    );
  }
}
