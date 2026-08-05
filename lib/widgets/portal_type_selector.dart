import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/portal_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';

PortalWorldDef? portalDefinitionForType(String? typeCode) {
  if (typeCode == null || typeCode.isEmpty) return null;
  return PortalRepository.portalDefinitions.firstWhereOrNull(
    (def) => def.typeCode == typeCode,
  );
}

String portalTypeDisplayName(AppLocalizations? l10n, PortalWorldDef def) {
  return switch (def.typeCode) {
    'egypt' => l10n?.portalTypeEgypt ?? def.name,
    'egypt_2' => l10n?.portalTypeEgypt2 ?? def.name,
    'pirate' => l10n?.portalTypePirate ?? def.name,
    'west' => l10n?.portalTypeWest ?? def.name,
    'future' => l10n?.portalTypeFuture ?? def.name,
    'future_2' => l10n?.portalTypeFuture2 ?? def.name,
    'dark' => l10n?.portalTypeDark ?? def.name,
    'beach' => l10n?.portalTypeBeach ?? def.name,
    'iceage' => l10n?.portalTypeIceAge ?? def.name,
    'lostcity' => l10n?.portalTypeLostCity ?? def.name,
    'eighties' => l10n?.portalTypeEighties ?? def.name,
    'dino' => l10n?.portalTypeDino ?? def.name,
    'dangerroom_egypt' => l10n?.portalTypeEndlessEgypt ?? def.name,
    'dangerroom_pirate' => l10n?.portalTypeEndlessPirate ?? def.name,
    'dangerroom_west' => l10n?.portalTypeEndlessWest ?? def.name,
    'dangerroom_Kongfu' => l10n?.portalTypeEndlessKongfu ?? def.name,
    'dangerroom_future' => l10n?.portalTypeEndlessFuture ?? def.name,
    'dangerroom_dark' => l10n?.portalTypeEndlessDark ?? def.name,
    'dangerroom_beach' => l10n?.portalTypeEndlessBeach ?? def.name,
    'dangerroom_iceage' => l10n?.portalTypeEndlessIceAge ?? def.name,
    'dangerroom_skycity' => l10n?.portalTypeEndlessSkyCity ?? def.name,
    'dangerroom_lostcity' => l10n?.portalTypeEndlessLostCity ?? def.name,
    'dangerroom_eighties' => l10n?.portalTypeEndlessEighties ?? def.name,
    'dangerroom_dino' => l10n?.portalTypeEndlessDino ?? def.name,
    'dangerroom_modern' => l10n?.portalTypeEndlessModern ?? def.name,
    'pvz1_A' => l10n?.portalTypeMemoryLane1 ?? def.name,
    'pvz1_B' => l10n?.portalTypeMemoryLane2 ?? def.name,
    'pvz1_C' => l10n?.portalTypeMemoryLane3 ?? def.name,
    'protector' => l10n?.portalTypeShieldGenerator ?? def.name,
    'pvz1_Zombotany' => l10n?.portalTypeZombotany ?? def.name,
    'pvz1_Slime' => l10n?.portalTypeSlimeZombies ?? def.name,
    'pvz1_tutorial2' => l10n?.portalTypeGlacialNianSkill ?? def.name,
    'pvz1_Universe' => l10n?.portalTypeUniverse42 ?? def.name,
    'pvz1_Uncharted' => l10n?.portalTypeUniverse41 ?? def.name,
    'pvz1_elite_roman_healer_normal' =>
      l10n?.portalTypeEliteHealerNormal ?? def.name,
    'pvz1_elite_skycity_electric_normal' =>
      l10n?.portalTypeEliteElectricNormal ?? def.name,
    'pvz1_elite_roman_ballista_normal' =>
      l10n?.portalTypeEliteBallistaNormal ?? def.name,
    'pvz1_elite_heian_onmyoji_normal' =>
      l10n?.portalTypeEliteOnmyojiNormal ?? def.name,
    'pvz1_elite_roman_healer_hard' =>
      l10n?.portalTypeEliteHealerHard ?? def.name,
    'pvz1_elite_skycity_electric_hard' =>
      l10n?.portalTypeEliteElectricHard ?? def.name,
    'pvz1_elite_roman_ballista_hard' =>
      l10n?.portalTypeEliteBallistaHard ?? def.name,
    'pvz1_elite_heian_onmyoji_hard' =>
      l10n?.portalTypeEliteOnmyojiHard ?? def.name,
    'pvz1_renai_romeo_hard' => l10n?.portalTypeRomeoHard ?? def.name,
    'pvz1_renai_romeo2_hard' => l10n?.portalTypeRomeoHard2 ?? def.name,
    'pvz1_renai_juliet_hard' => l10n?.portalTypeJulietHard ?? def.name,
    'pvz1_renai_juliet2_hard' => l10n?.portalTypeJulietHard2 ?? def.name,
    'pvz1_renai_sherlock_hard' => l10n?.portalTypeSherlockHard ?? def.name,
    'plantwars_iceage_hunter_elite' => l10n?.portalTypeEliteHunter ?? def.name,
    'plantwars_iceage_chief_elite' => l10n?.portalTypeEliteChief ?? def.name,
    'plantwars_iceage_weaselhoarder_elite' =>
      l10n?.portalTypeEliteWeasel ?? def.name,
    'plantwars_bumpercar_elite' => l10n?.portalTypeEliteBumperCar ?? def.name,
    'plantwars_IceYearMonster' => l10n?.portalTypeGlacialNian ?? def.name,
    'dark_wizard_elite' => l10n?.portalTypeEliteWizard ?? def.name,
    'dark_king_elite' => l10n?.portalTypeEliteKing ?? def.name,
    'plantwars_mirror_queen_phase3' =>
      l10n?.portalTypeEliteMirrorQueen ?? def.name,
    _ => def.name,
  };
}

String portalTypeDisplayNameForCode(BuildContext context, String typeCode) {
  final def = portalDefinitionForType(typeCode);
  if (def == null) return typeCode;
  return portalTypeDisplayName(AppLocalizations.of(context), def);
}

Future<void> showPortalTypePreviewDialog(
  BuildContext context,
  PortalWorldDef def,
) {
  return showDialog<void>(
    context: context,
    builder: (ctx) => _PortalTypePreviewDialog(def: def),
  );
}

class PortalTypeChooserGrid extends StatelessWidget {
  const PortalTypeChooserGrid({
    super.key,
    required this.selectedPortalType,
    required this.onSelected,
  });

  final String selectedPortalType;
  final ValueChanged<PortalWorldDef> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: PortalRepository.portalDefinitions.map((def) {
        final isSelected = def.typeCode == selectedPortalType;
        return SizedBox(
          width: 130,
          child: Card(
            color: isSelected ? theme.colorScheme.primaryContainer : null,
            child: InkWell(
              onTap: () => onSelected(def),
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        portalTypeDisplayName(l10n, def),
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.info_outline),
                      iconSize: 18,
                      tooltip: l10n?.info ?? 'Info',
                      onPressed: () {
                        showPortalTypePreviewDialog(context, def);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class PortalTypeSelectionScreen extends StatelessWidget {
  const PortalTypeSelectionScreen({super.key, required this.currentPortalType});

  final String currentPortalType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.selectPortalType ?? 'Select portal type'),
      ),
      body: PortalRepository.portalDefinitions.isEmpty
          ? Center(
              child: Text(l10n?.noPortalTypesFound ?? 'No portal types found'),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: PortalTypeChooserGrid(
                selectedPortalType: currentPortalType,
                onSelected: (def) => Navigator.pop(context, def.typeCode),
              ),
            ),
    );
  }
}

class PortalTypeSingleSelectField extends StatelessWidget {
  const PortalTypeSingleSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;

  Future<void> _pick(BuildContext context) async {
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (ctx) => PortalTypeSelectionScreen(currentPortalType: value),
      ),
    );
    if (selected == null || !context.mounted) return;
    onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final normalized = value.trim();
    final def = portalDefinitionForType(normalized);
    final hasValue = normalized.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
            PvzAddButton(
              onPressed: () {
                _pick(context);
              },
              size: 42,
            ),
          ],
        ),
        const SizedBox(height: 6),
        if (!hasValue)
          Text(
            l10n?.noPortalTypeSelected ?? 'No portal type selected',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          Material(
            color: theme.colorScheme.surfaceContainerHighest.withValues(
              alpha: 0.45,
            ),
            borderRadius: BorderRadius.circular(8),
            child: InkWell(
              onTap: () {
                _pick(context);
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            def == null
                                ? normalized
                                : portalTypeDisplayName(l10n, def),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (def != null) ...[
                            const SizedBox(height: 2),
                            Text(
                              normalized,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PortalTypePreviewDialog extends StatelessWidget {
  const _PortalTypePreviewDialog({required this.def});

  final PortalWorldDef def;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final zombieRepo = ZombieRepository();
    final portalName = portalTypeDisplayName(l10n, def);

    return AlertDialog(
      title: Text(
        l10n?.zombiePreview(portalName) ?? '$portalName - Zombie preview',
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n?.thisPortalSpawns ?? 'This portal spawns:',
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 8),
            ...def.representativeZombies.map((typeName) {
              final zombie = zombieRepo.getZombieById(typeName);
              final iconPath = zombie?.iconAssetPath;
              final nameKey = zombieRepo.getName(typeName);
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    iconPath != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: AssetImageWidget(
                              assetPath: iconPath,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                          )
                        : CircleAvatar(
                            child: Text(
                              nameKey.isNotEmpty
                                  ? nameKey[0].toUpperCase()
                                  : '?',
                            ),
                          ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ResourceNames.lookup(context, nameKey),
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(typeName, style: theme.textTheme.bodySmall),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n?.close ?? 'Close'),
        ),
      ],
    );
  }
}
