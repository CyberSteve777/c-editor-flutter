import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/resilience_config_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/asset_image.dart';

String resilienceWeakTypeLabel(AppLocalizations? l10n, int weakType) {
  switch (weakType) {
    case 1:
      return l10n?.resiliencePhysics ?? 'Physics';
    case 2:
      return l10n?.resiliencePoison ?? 'Poison';
    case 3:
      return l10n?.resilienceElectric ?? 'Electric';
    case 4:
      return l10n?.resilienceMagic ?? 'Magic';
    case 5:
      return l10n?.resilienceIce ?? 'Ice';
    case 6:
      return l10n?.resilienceFire ?? 'Fire';
    default:
      return '$weakType';
  }
}

String? resilienceWeakTypeIconPath(int weakType) {
  if (weakType < 1 || weakType >= weakTypeIcons.length) return null;
  return weakTypeIcons[weakType];
}

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
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: weakType != null
                ? ResilienceWeakTypeLabelRow(
                    weakType: weakType!,
                    label: value,
                    iconSize: 18,
                    valueBold: true,
                  )
                : Text(
                    value,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
