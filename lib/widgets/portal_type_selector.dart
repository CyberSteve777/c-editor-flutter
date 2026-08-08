import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_portal_level_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/portal_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/others/custom_portal_properties_screen.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart';

const _kUnknownZombieIcon = 'assets/images/others/unknown.webp';

enum PortalTypeCatalog { regular, zomboss }

PortalWorldDef? portalDefinitionForType(
  String? typeCode, [
  PvzLevelFile? levelFile,
]) {
  if (typeCode == null || typeCode.isEmpty) return null;
  if (levelFile != null) {
    final custom = CustomPortalLevelUtils.find(levelFile, typeCode);
    if (custom != null) {
      return PortalWorldDef(
        typeCode: custom.portalType,
        name: 'Custom Portal',
        representativeZombies: custom.representativeZombies,
        isCustom: true,
        customIndex: custom.index,
      );
    }
  }
  return PortalRepository.portalDefinitions.firstWhereOrNull(
    (def) => def.typeCode == typeCode,
  );
}

String portalTypeDisplayName(AppLocalizations? l10n, PortalWorldDef def) {
  if (def.isCustom) {
    return l10n?.customPortalSingleName ?? 'Custom Portal';
  }
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

String portalTypeDisplayNameForCode(
  BuildContext context,
  String typeCode, [
  PvzLevelFile? levelFile,
]) {
  final def = portalDefinitionForType(typeCode, levelFile);
  if (def == null) return typeCode;
  return portalTypeDisplayName(AppLocalizations.of(context), def);
}

String zombossPortalTypeDisplayName(BuildContext context, PortalWorldDef def) {
  final resourceNameKey = def.resourceNameKey;
  if (resourceNameKey == null || resourceNameKey.isEmpty) return def.name;
  final localized = ResourceNames.lookup(context, resourceNameKey);
  return localized == resourceNameKey ? def.name : localized;
}

String portalTypeIconAssetPath(PortalWorldDef? def) {
  final firstZombie = def?.representativeZombies.firstOrNull;
  if (firstZombie == null || firstZombie.isEmpty) return _kUnknownZombieIcon;
  return ZombieRepository().getZombieById(firstZombie)?.iconAssetPath ??
      _kUnknownZombieIcon;
}

Future<void> showPortalTypePreviewDialog(
  BuildContext context,
  PortalWorldDef def, {
  String? displayName,
}) {
  return showDialog<void>(
    context: context,
    builder: (ctx) =>
        _PortalTypePreviewDialog(def: def, displayName: displayName),
  );
}

class PortalTypeChooserGrid extends StatefulWidget {
  const PortalTypeChooserGrid({
    super.key,
    required this.selectedPortalType,
    required this.onSelected,
    this.levelFile,
    this.onLevelChanged,
    this.allowCustomPortal = true,
  });

  final String selectedPortalType;
  final ValueChanged<PortalWorldDef> onSelected;
  final PvzLevelFile? levelFile;
  final VoidCallback? onLevelChanged;
  final bool allowCustomPortal;

  @override
  State<PortalTypeChooserGrid> createState() => _PortalTypeChooserGridState();
}

class _PortalTypeChooserGridState extends State<PortalTypeChooserGrid> {
  bool get _hasCustomPortal {
    final levelFile = widget.levelFile;
    return levelFile != null &&
        CustomPortalLevelUtils.find(
              levelFile,
              CustomPortalLevelUtils.portalTypeBase,
            ) !=
            null;
  }

  List<PortalWorldDef> get _definitions {
    final levelFile = widget.levelFile;
    if (levelFile == null) return PortalRepository.portalDefinitions;
    final custom = CustomPortalLevelUtils.list(levelFile)
        .map(
          (item) => PortalWorldDef(
            typeCode: item.portalType,
            name: 'Custom Portal',
            representativeZombies: item.representativeZombies,
            isCustom: true,
            customIndex: item.index,
          ),
        )
        .toList();
    final customCodes = custom.map((item) => item.typeCode).toSet();
    return [
      ...PortalRepository.portalDefinitions.where(
        (item) => !customCodes.contains(item.typeCode),
      ),
      ...custom,
    ];
  }

  Future<void> _createCustomPortal() async {
    final levelFile = widget.levelFile;
    if (levelFile == null) return;
    final existing = portalDefinitionForType(
      CustomPortalLevelUtils.portalTypeBase,
      levelFile,
    );
    if (existing?.isCustom == true) {
      await _editCustomPortal(existing!);
      return;
    }
    final basePortalType = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const _CustomPortalBaseSelectionScreen(),
      ),
    );
    if (basePortalType == null || !mounted) return;
    final created = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomPortalPropertiesScreen(
          levelFile: levelFile,
          basePortalType: basePortalType.isEmpty ? null : basePortalType,
        ),
      ),
    );
    if (created == null || !mounted) return;
    widget.onLevelChanged?.call();
    setState(() {});
    final def = portalDefinitionForType(created, levelFile);
    if (def != null) widget.onSelected(def);
  }

  Future<void> _editCustomPortal(PortalWorldDef def) async {
    final levelFile = widget.levelFile;
    if (levelFile == null) return;
    final saved = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => CustomPortalPropertiesScreen(
          levelFile: levelFile,
          existingPortalType: def.typeCode,
        ),
      ),
    );
    if (saved == null || !mounted) return;
    widget.onLevelChanged?.call();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 8.0;
        const preferredWidth = 150.0;
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : preferredWidth;
        final calculatedColumns =
            ((availableWidth + spacing) / (preferredWidth + spacing)).floor();
        final columnCount = calculatedColumns < 1 ? 1 : calculatedColumns;
        final cardWidth =
            (availableWidth - spacing * (columnCount - 1)) / columnCount;
        final cards = <Widget>[
          for (final def in _definitions)
            _buildPortalCard(context, def, width: cardWidth),
          if (widget.allowCustomPortal &&
              widget.levelFile != null &&
              !_hasCustomPortal)
            _buildCreateCard(context, width: cardWidth),
        ];
        return Wrap(spacing: spacing, runSpacing: spacing, children: cards);
      },
    );
  }

  Widget _buildPortalCard(
    BuildContext context,
    PortalWorldDef def, {
    required double width,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isSelected = def.typeCode == widget.selectedPortalType;
    return SizedBox(
      width: width,
      height: 72,
      child: Card(
        margin: EdgeInsets.zero,
        color: isSelected ? theme.colorScheme.primaryContainer : null,
        child: InkWell(
          onTap: () => widget.onSelected(def),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                if (def.isCustom) ...[
                  CustomResourceBadge(
                    color: userCustomResourceBadgeColor(context),
                  ),
                  const SizedBox(width: 6),
                ],
                Expanded(
                  child: Text(
                    portalTypeDisplayName(l10n, def),
                    style: theme.textTheme.bodySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(def.isCustom ? Icons.edit : Icons.info_outline),
                  iconSize: 18,
                  tooltip: def.isCustom
                      ? (l10n?.edit ?? 'Edit')
                      : (l10n?.info ?? 'Info'),
                  onPressed: () {
                    if (def.isCustom) {
                      _editCustomPortal(def);
                    } else {
                      showPortalTypePreviewDialog(context, def);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCreateCard(BuildContext context, {required double width}) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final background =
        theme.floatingActionButtonTheme.backgroundColor ??
        theme.colorScheme.primaryContainer;
    final foreground =
        theme.floatingActionButtonTheme.foregroundColor ??
        theme.colorScheme.onPrimaryContainer;
    return SizedBox(
      width: width,
      height: 72,
      child: Card(
        margin: EdgeInsets.zero,
        color: background,
        child: InkWell(
          onTap: _createCustomPortal,
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add, color: foreground, size: 18),
                const SizedBox(width: 4),
                Flexible(
                  child: Text(
                    l10n?.customPortalAdd ?? 'New custom portal',
                    style: TextStyle(
                      color: foreground,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomPortalBaseSelectionScreen extends StatelessWidget {
  const _CustomPortalBaseSelectionScreen();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.customPortalSelectBaseTitle ?? 'Select a base portal',
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.add_box_outlined),
              title: Text(
                l10n?.customPortalBlankTemplate ?? 'Blank portal template',
              ),
              subtitle: Text(
                l10n?.customPortalBlankTemplateSubtitle ??
                    'Start with the standard portal structure and no zombies.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pop(context, ''),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n?.customPortalBuiltInBases ?? 'Built-in portal bases',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          for (final def in PortalRepository.portalDefinitions) ...[
            _PortalBaseSelectionCard(
              def: def,
              onTap: () => Navigator.pop(context, def.typeCode),
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}

class _PortalBaseSelectionCard extends StatelessWidget {
  const _PortalBaseSelectionCard({
    required this.def,
    required this.onTap,
    this.displayName,
    this.onInfo,
    this.selected = false,
  });

  final PortalWorldDef def;
  final VoidCallback onTap;
  final String? displayName;
  final VoidCallback? onInfo;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primaryContainer.withValues(alpha: 0.65)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
            ),
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: AssetImageWidget(
                  assetPath: portalTypeIconAssetPath(def),
                  width: 52,
                  height: 52,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName ?? portalTypeDisplayName(l10n, def),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      def.typeCode,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              if (onInfo != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: l10n?.info ?? 'Info',
                  icon: const Icon(Icons.info_outline),
                  onPressed: onInfo,
                ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class ZombossPortalTypeSelectionScreen extends StatelessWidget {
  const ZombossPortalTypeSelectionScreen({
    super.key,
    required this.currentPortalType,
  });

  final String currentPortalType;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final definitions = PortalRepository.bossPortalDefinitions;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.selectPortalType ?? 'Select portal type'),
      ),
      body: definitions.isEmpty
          ? Center(
              child: Text(l10n?.noPortalTypesFound ?? 'No portal types found'),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: definitions.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final def = definitions[index];
                final displayName = zombossPortalTypeDisplayName(context, def);
                return _PortalBaseSelectionCard(
                  def: def,
                  displayName: displayName,
                  selected: def.typeCode == currentPortalType,
                  onInfo: () => showPortalTypePreviewDialog(
                    context,
                    def,
                    displayName: displayName,
                  ),
                  onTap: () => Navigator.pop(context, def.typeCode),
                );
              },
            ),
    );
  }
}

class PortalTypeSelectionScreen extends StatelessWidget {
  const PortalTypeSelectionScreen({
    super.key,
    required this.currentPortalType,
    this.levelFile,
    this.onLevelChanged,
  });

  final String currentPortalType;
  final PvzLevelFile? levelFile;
  final VoidCallback? onLevelChanged;

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
              child: SizedBox(
                width: double.infinity,
                child: PortalTypeChooserGrid(
                  selectedPortalType: currentPortalType,
                  onSelected: (def) => Navigator.pop(context, def.typeCode),
                  levelFile: levelFile,
                  onLevelChanged: onLevelChanged,
                ),
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
    this.editable = true,
    this.levelFile,
    this.onLevelChanged,
    this.catalog = PortalTypeCatalog.regular,
  });

  final String label;
  final String value;
  final ValueChanged<String> onChanged;
  final bool editable;
  final PvzLevelFile? levelFile;
  final VoidCallback? onLevelChanged;
  final PortalTypeCatalog catalog;

  Future<void> _pick(BuildContext context) async {
    final selected = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (ctx) => catalog == PortalTypeCatalog.zomboss
            ? ZombossPortalTypeSelectionScreen(currentPortalType: value)
            : PortalTypeSelectionScreen(
                currentPortalType: value,
                levelFile: levelFile,
                onLevelChanged: onLevelChanged,
              ),
      ),
    );
    if (selected == null || !context.mounted) return;
    final previous = value.trim();
    onChanged(selected);
    if (catalog == PortalTypeCatalog.regular &&
        previous != selected &&
        levelFile != null &&
        context.mounted) {
      final removed = await CustomPortalLevelUtils.maybePromptRemoveUnused(
        context: context,
        levelFile: levelFile!,
        portalType: previous,
      );
      if (removed) onLevelChanged?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final normalized = value.trim();
    final def = catalog == PortalTypeCatalog.zomboss
        ? PortalRepository.bossPortalDefinitionForType(normalized)
        : portalDefinitionForType(normalized, levelFile);
    final hasValue = normalized.isNotEmpty;
    final iconPath = portalTypeIconAssetPath(def);
    final displayName = def == null
        ? normalized
        : catalog == PortalTypeCatalog.zomboss
        ? zombossPortalTypeDisplayName(context, def)
        : portalTypeDisplayName(l10n, def);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: theme.textTheme.titleSmall)),
            if (editable)
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () {
                  _pick(context);
                },
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
              onTap: editable
                  ? () {
                      _pick(context);
                    }
                  : null,
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: AssetImageWidget(
                        assetPath: iconPath,
                        width: 48,
                        height: 48,
                        fit: BoxFit.contain,
                        altCandidates: imageAltCandidates(iconPath),
                      ),
                    ),
                    const SizedBox(width: 10),
                    if (def?.isCustom == true) ...[
                      CustomResourceBadge(
                        color: userCustomResourceBadgeColor(context),
                      ),
                      const SizedBox(width: 8),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
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
                    if (def != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        tooltip: l10n?.info ?? 'Info',
                        icon: const Icon(Icons.info_outline),
                        onPressed: () {
                          showPortalTypePreviewDialog(
                            context,
                            def,
                            displayName: displayName,
                          );
                        },
                      ),
                    if (editable) const Icon(Icons.chevron_right),
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
  const _PortalTypePreviewDialog({required this.def, this.displayName});

  final PortalWorldDef def;
  final String? displayName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final zombieRepo = ZombieRepository();
    final portalName = displayName ?? portalTypeDisplayName(l10n, def);

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
