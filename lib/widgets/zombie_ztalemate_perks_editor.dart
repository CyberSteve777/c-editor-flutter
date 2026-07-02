import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/zombie_title_catalog_repository.dart';
import 'package:c_editor/data/zombie_title_descriptions.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/anchored_floating_panel.dart';
import 'package:c_editor/widgets/asset_image.dart';

class ZombieZtalematePerksEditor extends StatelessWidget {
  const ZombieZtalematePerksEditor({
    super.key,
    required this.titles,
    required this.onChanged,
  });

  final List<String> titles;
  final ValueChanged<List<String>> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final selected = List<String>.from(titles);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n?.ztPerksSectionTitle ?? 'Ztalemate perks',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n?.ztPerksSectionHint ??
                        'Each perk type can only be applied once per zombie.',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              onPressed: () => _showAddPerkDialog(
                context,
                selectedTitles: selected,
                onSelected: onChanged,
              ),
              icon: const Icon(Icons.add, size: 18),
              label: Text(l10n?.ztPerksAdd ?? 'Add perk'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (selected.isEmpty)
          Text(
            l10n?.ztPerksNone ?? 'No perks assigned.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final alias in selected)
                _SelectedPerkChip(
                  alias: alias,
                  onRemove: () {
                    final next = List<String>.from(selected)..remove(alias);
                    onChanged(next);
                  },
                ),
            ],
          ),
      ],
    );
  }

  Future<void> _showAddPerkDialog(
    BuildContext context, {
    required List<String> selectedTitles,
    required ValueChanged<List<String>> onSelected,
  }) async {
    final l10n = AppLocalizations.of(context);
    final selectedTypes = <String>{
      for (final alias in selectedTitles)
        if (ZombieTitleCatalogRepository.getByAlias(alias)?.type != null)
          ZombieTitleCatalogRepository.getByAlias(alias)!.type,
    };
    final grouped = <String, List<ZombieTitleEntry>>{};
    for (final entry in ZombieTitleCatalogRepository.getAll()) {
      grouped.putIfAbsent(entry.type, () => []).add(entry);
    }
    final typeOrder = grouped.keys.toList()..sort();

    final picked = await showDialog<String>(
      context: context,
      builder: (ctx) {
        final dialogWidth = (MediaQuery.sizeOf(ctx).width - 32).clamp(
          360.0,
          560.0,
        );
        return AlertDialog(
          title: Text(l10n?.ztPerksAdd ?? 'Add perk'),
          content: SizedBox(
            width: dialogWidth,
            child: ListView(
            shrinkWrap: true,
            children: [
              for (final type in typeOrder) ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(0, 8, 0, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          _categoryLabel(ctx, type),
                          style: Theme.of(ctx).textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Builder(
                        builder: (infoContext) => IconButton(
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                          tooltip: l10n?.ztPerksCategoryInfoTitle ??
                              'Perk descriptions',
                          onPressed: () => _showCategoryDescriptions(
                            infoContext,
                            type,
                          ),
                          icon: Icon(
                            Icons.info_outline,
                            size: 18,
                            color: Theme.of(ctx).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                for (final entry in grouped[type]!)
                  _PerkPickerTile(
                    entry: entry,
                    isSelected: selectedTitles.contains(entry.alias),
                    isTypeBlocked:
                        selectedTypes.contains(entry.type) &&
                        !selectedTitles.contains(entry.alias),
                    onTap: () => Navigator.pop(ctx, entry.alias),
                  ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
        ],
        );
      },
    );
    if (picked == null) return;

    final entry = ZombieTitleCatalogRepository.getByAlias(picked);
    if (entry == null) return;

    final next = List<String>.from(selectedTitles)
      ..removeWhere((alias) {
        final existing = ZombieTitleCatalogRepository.getByAlias(alias);
        return existing?.type == entry.type;
      })
      ..add(picked);
    onSelected(next);
  }

  void _showCategoryDescriptions(
    BuildContext anchorContext,
    String type,
  ) {
    final l10n = AppLocalizations.of(anchorContext);
    final theme = Theme.of(anchorContext);
    final description = ZombieTitleDescriptions.resolveCategoryTemplate(
      anchorContext,
      type,
    );
    if (description.isEmpty) return;

    showAnchoredFloatingPanel(
      anchorContext,
      anchorContext: anchorContext,
      maxWidth: 320,
      maxHeight: 200,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _categoryLabel(anchorContext, type),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.ztPerkCategoryDescNumericHint ??
                  'Letters such as A, B, X, N, and P stand for numeric values that vary by tier.',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(
                  alpha: 0.75,
                ),
                fontStyle: FontStyle.italic,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _categoryLabel(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context);
    return switch (type) {
      'zombie_title_crystal' => l10n?.ztPerkCategoryCrystal ?? 'Crystal',
      'zombie_title_attack' => l10n?.ztPerkCategoryAttack ?? 'Attack',
      'zombie_title_speed' => l10n?.ztPerkCategorySpeed ?? 'Speed',
      'zombie_title_shield' => l10n?.ztPerkCategoryShield ?? 'Shield',
      'zombie_title_gravity' => l10n?.ztPerkCategoryGravity ?? 'Gravity',
      'zombie_title_immunecontrol' =>
        l10n?.ztPerkCategoryImmuneControl ?? 'Control immunity',
      'zombie_title_anticontrol' =>
        l10n?.ztPerkCategoryAntiControl ?? 'Control resistance',
      _ => type,
    };
  }
}

class _SelectedPerkChip extends StatelessWidget {
  const _SelectedPerkChip({required this.alias, required this.onRemove});

  final String alias;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final entry = ZombieTitleCatalogRepository.getByAlias(alias);
    final label = entry == null
        ? alias
        : ResourceNames.lookup(context, entry.nameKey);
    final iconPath = entry == null
        ? 'assets/images/others/unknown.webp'
        : ZombieTitleCatalogRepository.iconAssetForType(entry.type);

    return InputChip(
      avatar: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: AssetImageWidget(
          assetPath: iconPath,
          width: 20,
          height: 20,
          fit: BoxFit.cover,
        ),
      ),
      label: Text(label),
      onDeleted: onRemove,
    );
  }
}

class _PerkPickerTile extends StatelessWidget {
  const _PerkPickerTile({
    required this.entry,
    required this.isSelected,
    required this.isTypeBlocked,
    required this.onTap,
  });

  final ZombieTitleEntry entry;
  final bool isSelected;
  final bool isTypeBlocked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final name = ResourceNames.lookup(context, entry.nameKey);
    final iconPath = ZombieTitleCatalogRepository.iconAssetForType(entry.type);
    final hasStats = entry.numericProperties.isNotEmpty;
    final nameColor = isTypeBlocked
        ? theme.colorScheme.onSurface.withValues(alpha: 0.45)
        : null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isTypeBlocked ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AssetImageWidget(
                  assetPath: iconPath,
                  width: 36,
                  height: 36,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: nameColor,
                        ),
                      ),
                    ),
                    Builder(
                      builder: (infoContext) => IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 32,
                          minHeight: 32,
                        ),
                        tooltip: l10n?.ztPerksViewStats ?? 'View stats',
                        onPressed: hasStats
                            ? () => _showPerkNumericProperties(
                                  infoContext,
                                  entry,
                                )
                            : null,
                        icon: Icon(
                          Icons.info_outline,
                          size: 18,
                          color: hasStats
                              ? theme.colorScheme.primary
                              : theme.colorScheme.onSurfaceVariant.withValues(
                                  alpha: 0.4,
                                ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: isSelected
                      ? Icon(
                          Icons.check_circle,
                          color: theme.colorScheme.primary,
                          size: 22,
                        )
                      : const SizedBox.shrink(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPerkNumericProperties(
    BuildContext anchorContext,
    ZombieTitleEntry entry,
  ) {
    final theme = Theme.of(anchorContext);
    final lines = entry.numericProperties.entries
        .map(
          (property) =>
              '${_propertyLabel(anchorContext, property.key)}: ${_formatPropertyValue(property.value)}',
        )
        .toList();
    if (lines.isEmpty) return;

    showAnchoredFloatingPanel(
      anchorContext,
      anchorContext: anchorContext,
      maxWidth: 260,
      maxHeight: 220,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ResourceNames.lookup(anchorContext, entry.nameKey),
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            for (final line in lines)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(line, style: theme.textTheme.bodySmall),
              ),
          ],
        ),
      ),
    );
  }

  String _propertyLabel(BuildContext context, String key) {
    final l10n = AppLocalizations.of(context);
    return switch (key) {
      'DamageTakenInterval' =>
        l10n?.ztPerkPropDamageTakenInterval ?? 'Damage taken interval',
      'DamageTotalTaken' =>
        l10n?.ztPerkPropDamageTotalTaken ?? 'Damage total taken',
      'DamageTakenPerTime' =>
        l10n?.ztPerkPropDamageTakenPerTime ?? 'Damage taken per time',
      'HPReduced' => l10n?.ztPerkPropHpReduced ?? 'HP reduced',
      'ShieldNum' => l10n?.ztPerkPropShieldNum ?? 'Shield layers',
      'ReducedControlPercent' =>
        l10n?.ztPerkPropReducedControlPercent ?? 'Control reduction',
      'ReducedDamagePercent' =>
        l10n?.ztPerkPropReducedDamagePercent ?? 'Damage reduction',
      'ImprovedDamagePercent' =>
        l10n?.ztPerkPropImprovedDamagePercent ?? 'Damage boost',
      'ImprovedSpeedPercent' =>
        l10n?.ztPerkPropImprovedSpeedPercent ?? 'Speed boost',
      _ => key,
    };
  }

  String _formatPropertyValue(num value) {
    if (value is int) return value.toString();
    if (value == value.roundToDouble()) return value.round().toString();
    final text = value.toStringAsFixed(2);
    return text.replaceFirst(RegExp(r'\.?0+$'), '');
  }
}
