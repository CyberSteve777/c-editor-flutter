import 'package:flutter/material.dart';
import 'package:c_editor/data/custom_stage_level_utils.dart';
import 'package:c_editor/data/models/custom_stage_preset.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/custom_stage_editor_widgets.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/selection_grid_layout.dart';

enum _StagePickerTab { builtin, custom }

class _StageSelectionViewState {
  _StageSelectionViewState({
    required this.tab,
    required this.type,
    required this.builtinScrollOffset,
    required this.customScrollOffset,
    required this.typeScrollOffset,
  });

  _StagePickerTab tab;
  StageType type;
  double builtinScrollOffset;
  double customScrollOffset;
  double typeScrollOffset;
}

final Map<String, _StageSelectionViewState> _stageSelectionViewStates = {};

/// Full-screen lawn picker: built-in LevelModules stages or level-local custom lawns.
class StageSelectionScreen extends StatefulWidget {
  const StageSelectionScreen({
    super.key,
    required this.currentStageRtid,
    required this.levelFile,
    required this.onStageSelected,
    required this.onBack,
    this.onCreateCustomStage,
    this.onCreateCustomStageFromPreset,
    this.onOpenCustomStageEditor,
    this.onDeleteCustomStage,
    this.onSwitchFromCustomToBuiltin,
  });

  final String currentStageRtid;
  final PvzLevelFile levelFile;
  final void Function(String rtid) onStageSelected;
  final VoidCallback onBack;
  final VoidCallback? onCreateCustomStage;
  final Future<String?> Function(CustomStagePreset preset)?
  onCreateCustomStageFromPreset;
  final void Function(String alias)? onOpenCustomStageEditor;
  final Future<bool> Function(String alias)? onDeleteCustomStage;
  final Future<bool> Function(String customAlias)? onSwitchFromCustomToBuiltin;

  @override
  State<StageSelectionScreen> createState() => _StageSelectionScreenState();
}

class _StageSelectionScreenState extends State<StageSelectionScreen> {
  late _StagePickerTab _tab;
  late StageType _selectedType;
  String _searchQuery = '';
  String? _currentStageRtidOverride;
  late final ScrollController _builtinScrollController;
  late final ScrollController _customScrollController;

  String get _viewStateKey =>
      'level:${identityHashCode(widget.levelFile)}:stage';

  bool get _canRememberBuiltinScroll => _searchQuery.trim().isEmpty;

  @override
  void initState() {
    super.initState();
    final info = RtidParser.parse(widget.currentStageRtid);
    final remembered = _stageSelectionViewStates[_viewStateKey];
    _tab =
        remembered?.tab ??
        (info?.source == CustomStageLevelUtils.currentLevel
            ? _StagePickerTab.custom
            : _StagePickerTab.builtin);
    _selectedType = remembered?.type ?? StageType.all;
    _builtinScrollController = ScrollController(
      initialScrollOffset: remembered?.builtinScrollOffset ?? 0,
    )..addListener(_rememberScrollOffsets);
    _customScrollController = ScrollController(
      initialScrollOffset: remembered?.customScrollOffset ?? 0,
    )..addListener(_rememberScrollOffsets);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreCurrentTabScrollOffset();
    });
  }

  @override
  void dispose() {
    _rememberScrollOffsets();
    _builtinScrollController.dispose();
    _customScrollController.dispose();
    super.dispose();
  }

  void _setTab(_StagePickerTab tab) {
    if (_tab == tab) return;
    _rememberScrollOffsets();
    setState(() => _tab = tab);
    _rememberViewState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _restoreCurrentTabScrollOffset();
    });
  }

  void _setType(StageType type) {
    if (_selectedType == type) return;
    setState(() => _selectedType = type);
    _resetBuiltinScrollOffset();
    _rememberViewState(builtinScrollOffset: 0);
  }

  void _setSearchQuery(String query) {
    if (_searchQuery == query) return;
    setState(() => _searchQuery = query);
    _resetBuiltinScrollOffset(persist: query.trim().isEmpty);
  }

  void _rememberViewState({
    double? builtinScrollOffset,
    double? customScrollOffset,
    double? typeScrollOffset,
  }) {
    final state = _stageSelectionViewStates.putIfAbsent(
      _viewStateKey,
      () => _StageSelectionViewState(
        tab: _tab,
        type: _selectedType,
        builtinScrollOffset: 0,
        customScrollOffset: 0,
        typeScrollOffset: 0,
      ),
    );
    state.tab = _tab;
    state.type = _selectedType;
    if (builtinScrollOffset != null) {
      state.builtinScrollOffset = builtinScrollOffset;
    }
    if (customScrollOffset != null) {
      state.customScrollOffset = customScrollOffset;
    }
    if (typeScrollOffset != null) {
      state.typeScrollOffset = typeScrollOffset;
    }
  }

  void _rememberTypeScrollOffset(double offset) {
    _rememberViewState(typeScrollOffset: offset);
  }

  void _rememberScrollOffsets() {
    double? builtinOffset;
    double? customOffset;
    if (_canRememberBuiltinScroll && _builtinScrollController.hasClients) {
      builtinOffset = _builtinScrollController.offset;
    }
    if (_customScrollController.hasClients) {
      customOffset = _customScrollController.offset;
    }
    _rememberViewState(
      builtinScrollOffset: builtinOffset,
      customScrollOffset: customOffset,
    );
  }

  void _resetBuiltinScrollOffset({bool persist = true}) {
    if (persist) _rememberViewState(builtinScrollOffset: 0);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_builtinScrollController.hasClients) return;
      _builtinScrollController.jumpTo(0);
    });
  }

  void _restoreCurrentTabScrollOffset() {
    if (!mounted) return;
    final state = _stageSelectionViewStates[_viewStateKey];
    final controller = _tab == _StagePickerTab.builtin
        ? _builtinScrollController
        : _customScrollController;
    if (!controller.hasClients) return;
    final offset = _tab == _StagePickerTab.builtin
        ? state?.builtinScrollOffset ?? 0
        : state?.customScrollOffset ?? 0;
    final position = controller.position;
    final target = offset
        .clamp(position.minScrollExtent, position.maxScrollExtent)
        .toDouble();
    if (controller.offset != target) controller.jumpTo(target);
  }

  String get _effectiveCurrentStageRtid =>
      _currentStageRtidOverride ?? widget.currentStageRtid;

  bool get _isCustomCurrent =>
      CustomStageLevelUtils.isCustomStageRtid(_effectiveCurrentStageRtid);

  String? get _currentAlias =>
      RtidParser.parse(_effectiveCurrentStageRtid)?.alias;

  List<PvzObject> get _customStages =>
      CustomStageLevelUtils.customStageObjectsInLevel(widget.levelFile);

  Future<void> _selectBuiltin(String rtid) async {
    if (_isCustomCurrent) {
      final alias = _currentAlias;
      if (alias != null && widget.onSwitchFromCustomToBuiltin != null) {
        final confirmed = await widget.onSwitchFromCustomToBuiltin!(alias);
        if (!confirmed) return;
      }
    }
    widget.onStageSelected(rtid);
  }

  Future<void> _copyPreset(CustomStagePreset preset) async {
    final createPreset = widget.onCreateCustomStageFromPreset;
    if (createPreset == null) return;
    final alias = await createPreset(preset);
    if (!mounted || alias == null || alias.isEmpty) return;
    setState(() {
      _currentStageRtidOverride = RtidParser.build(
        alias,
        CustomStageLevelUtils.currentLevel,
      );
    });
  }

  String _customDisplayName(BuildContext context, PvzObject stageObj) {
    final l10n = AppLocalizations.of(context);
    final alias = stageObj.aliases?.firstOrNull ?? '';
    final objdata = stageObj.objData is Map
        ? Map<String, dynamic>.from(stageObj.objData as Map)
        : const <String, dynamic>{};
    final suffix =
        l10n?.customStageNameSuffix ??
        CustomStageLevelUtils.displayNameSuffixDefault;
    final nameKey = CustomStageLevelUtils.displayStageBaseNameKey(
      objclass: stageObj.objClass,
      objdata: objdata,
    );
    if (nameKey.isNotEmpty) {
      return '${ResourceNames.lookup(context, nameKey)}$suffix';
    }
    return '$alias$suffix';
  }

  String? _customIconFile(PvzObject stageObj) {
    if (stageObj.objData is! Map) return null;
    return CustomStageLevelUtils.displayIconFileName(
      objclass: stageObj.objClass,
      objdata: Map<String, dynamic>.from(stageObj.objData as Map),
    );
  }

  CustomStagePreset? _selectedPresetForAlias(
    List<CustomStagePreset> presets,
    String? alias,
  ) {
    if (!_isCustomCurrent || alias == null || alias.isEmpty) return null;
    for (final preset in presets) {
      if (_isAliasFromPreset(alias, preset.alias)) return preset;
    }
    return null;
  }

  bool _isAliasFromPreset(String alias, String presetAlias) {
    if (alias == presetAlias) return true;
    if (!alias.startsWith(presetAlias)) return false;
    final suffix = alias.substring(presetAlias.length);
    return suffix.isNotEmpty && int.tryParse(suffix) != null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: responsiveSelectionToolbarHeight(context),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(
          l10n?.selectStage ?? 'Select lawn',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),
      body: Column(
        children: [
          Material(
            color:
                theme.appBarTheme.backgroundColor ?? theme.colorScheme.surface,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                  child: SegmentedButton<_StagePickerTab>(
                    segments: [
                      ButtonSegment(
                        value: _StagePickerTab.builtin,
                        label: Text(
                          l10n?.stageSelectionTabBuiltin ?? 'Built-in',
                        ),
                        icon: const Icon(Icons.grass),
                      ),
                      ButtonSegment(
                        value: _StagePickerTab.custom,
                        label: Text(l10n?.stageSelectionTabCustom ?? 'Custom'),
                        icon: const Icon(Icons.edit_note),
                      ),
                    ],
                    selected: {_tab},
                    onSelectionChanged: (values) {
                      _setTab(values.first);
                    },
                  ),
                ),
                if (_tab == _StagePickerTab.builtin) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: SelectionSearchField(
                      hintText: l10n?.searchStage ?? 'Search stage',
                      query: _searchQuery,
                      onChanged: _setSearchQuery,
                      onClear: () => _setSearchQuery(''),
                    ),
                  ),
                  HorizontalTagScroller(
                    onAccentBar: true,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    initialScrollOffset:
                        _stageSelectionViewStates[_viewStateKey]
                            ?.typeScrollOffset ??
                        0,
                    onScrollOffsetChanged: _rememberTypeScrollOffset,
                    children: StageType.values.map((t) {
                      return AccentBarChoiceChip(
                        label: _typeLabel(t, l10n),
                        selected: _selectedType == t,
                        onSelected: (_) => _setType(t),
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
          Expanded(
            child: _tab == _StagePickerTab.builtin
                ? _buildBuiltinTab(context, l10n, theme)
                : _buildCustomTab(context, l10n, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildBuiltinTab(
    BuildContext context,
    AppLocalizations? l10n,
    ThemeData theme,
  ) {
    final currentAlias = _currentAlias ?? '';
    var items = StageRepository.getByType(_selectedType);
    if (normalizeSelectionSearchQuery(_searchQuery).isNotEmpty) {
      items = items.where((s) {
        final nameKey = StageRepository.getName(s.alias);
        return matchesSelectionSearch(_searchQuery, [
          s.alias,
          nameKey,
          ResourceNames.lookup(context, nameKey),
        ]);
      }).toList();
    }

    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64, color: theme.colorScheme.outline),
            const SizedBox(height: 16),
            Text(
              l10n?.noStageFound ?? 'No stage found',
              style: theme.textTheme.bodyLarge,
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _builtinScrollController,
      padding: const EdgeInsets.all(16),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 180,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        mainAxisExtent: responsiveSelectionGridTileExtent(
          context,
          baseExtent: 242,
        ),
      ),
      itemCount: items.length,
      itemBuilder: (_, i) {
        final stage = items[i];
        final isSelected = !_isCustomCurrent && stage.alias == currentAlias;
        return _BuiltinStageGridItem(
          stage: stage,
          stageName: ResourceNames.lookup(
            context,
            StageRepository.getName(stage.alias),
          ),
          isSelected: isSelected,
          onTap: () =>
              _selectBuiltin(RtidParser.build(stage.alias, 'LevelModules')),
        );
      },
    );
  }

  Widget _buildCustomTab(
    BuildContext context,
    AppLocalizations? l10n,
    ThemeData theme,
  ) {
    final customStages = _customStages;
    final presets = CustomStagePresetRepository.presets;
    final currentAlias = _currentAlias;
    final currentCustomStageExists =
        currentAlias != null &&
        customStages.any(
          (stageObj) => stageObj.aliases?.contains(currentAlias) == true,
        );
    final selectedPreset = currentCustomStageExists
        ? _selectedPresetForAlias(presets, currentAlias)
        : null;
    final presetsLocked = selectedPreset != null;
    final displayPresets = selectedPreset == null
        ? presets
        : [
            selectedPreset,
            ...presets.where((preset) => preset.alias != selectedPreset.alias),
          ];

    return ListView(
      controller: _customScrollController,
      padding: const EdgeInsets.all(16),
      children: [
        if (widget.onCreateCustomStage != null && customStages.isEmpty)
          Card(
            color: theme.colorScheme.primaryContainer,
            child: ListTile(
              leading: const Icon(Icons.add_circle_outline),
              title: Text(
                l10n?.createCustomStage ?? 'Create custom lawn',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(
                l10n?.createCustomStageHint ??
                    'Pick a base lawn appearance and edit it locally in this level.',
              ),
              onTap: widget.onCreateCustomStage,
            ),
          ),
        if (customStages.isEmpty) ...[
          const SizedBox(height: 32),
          Center(
            child: Text(
              l10n?.customStageSelectionEmpty ??
                  'No custom lawn in this level yet.',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ] else ...[
          const SizedBox(height: 8),
          Text(
            l10n?.customStageSelectionInLevel ?? 'Custom lawns in this level',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...customStages.map((stageObj) {
            final alias = stageObj.aliases?.firstOrNull ?? '';
            final isSelected = _isCustomCurrent && alias == currentAlias;
            final origin = CustomStagePresetRepository.originForObject(
              stageObj,
            );
            final iconFile = _customIconFile(stageObj);
            final iconPath = iconFile == null
                ? 'assets/images/others/unknown.webp'
                : 'assets/images/round_icons/$iconFile';
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Card(
                elevation: isSelected ? 2 : 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: isSelected
                      ? BorderSide(color: theme.colorScheme.outline, width: 1)
                      : BorderSide.none,
                ),
                child: InkWell(
                  onTap: () => widget.onOpenCustomStageEditor?.call(alias),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      children: [
                        Stack(
                          children: [
                            ClipOval(
                              child: SizedBox(
                                width: 96,
                                height: 96,
                                child: AssetImageWidget(
                                  assetPath: iconPath,
                                  altCandidates: imageAltCandidates(iconPath),
                                  width: 96,
                                  height: 96,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            Positioned(
                              top: 4,
                              left: 4,
                              child: _CurrentCustomStageBadge(origin: origin),
                            ),
                          ],
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _customDisplayName(context, stageObj),
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                alias,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (widget.onDeleteCustomStage != null)
                          IconButton(
                            tooltip: l10n?.delete ?? 'Delete',
                            icon: const Icon(Icons.delete_outline),
                            onPressed: () async {
                              final deleted = await widget.onDeleteCustomStage!(
                                alias,
                              );
                              if (deleted && mounted) {
                                setState(() {
                                  if (_isCustomCurrent &&
                                      alias == _currentAlias) {
                                    _currentStageRtidOverride =
                                        CustomStageLevelUtils
                                            .defaultBuiltinStageRtid;
                                  }
                                });
                              }
                            },
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),
        ],
        if (presets.isNotEmpty && customStages.isEmpty) ...[
          SizedBox(height: customStages.isEmpty ? 32 : 16),
          Text(
            l10n?.customStagePresetSectionTitle ??
                'Preset custom lawn templates',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ...displayPresets.map((preset) {
            final isSelectedPreset = selectedPreset?.alias == preset.alias;
            final isDisabled =
                presetsLocked || widget.onCreateCustomStageFromPreset == null;
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _PresetCustomStageCard(
                preset: preset,
                displayName: ResourceNames.lookup(context, preset.nameKey),
                source: ResourceNames.lookup(context, preset.sourceKey),
                selected: isSelectedPreset,
                disabled: isDisabled,
                onTap: () => _copyPreset(preset),
              ),
            );
          }),
        ],
      ],
    );
  }

  String _typeLabel(StageType t, AppLocalizations? l10n) {
    switch (t) {
      case StageType.all:
        return l10n?.stageTypeAll ?? 'All';
      case StageType.main:
        return l10n?.stageTypeMain ?? 'Main';
      case StageType.extra:
        return l10n?.stageTypeExtra ?? 'Extra';
      case StageType.seasons:
        return l10n?.stageTypeSeasons ?? 'Seasons';
      case StageType.special:
        return l10n?.stageTypeSpecial ?? 'Special';
    }
  }
}

class _CurrentCustomStageBadge extends StatelessWidget {
  const _CurrentCustomStageBadge({required this.origin});

  final CustomStageOrigin origin;

  @override
  Widget build(BuildContext context) {
    return CustomResourceBadge(color: _badgeColor(context));
  }

  Color _badgeColor(BuildContext context) {
    return switch (origin) {
      CustomStageOrigin.presetTemplate => presetCustomResourceBadgeColor(
        context,
      ),
      CustomStageOrigin.presetDerived => customStageBadgeColor(context),
      CustomStageOrigin.userCreated => userCustomResourceBadgeColor(context),
    };
  }
}

class _PresetCustomStageCard extends StatelessWidget {
  const _PresetCustomStageCard({
    required this.preset,
    required this.displayName,
    required this.source,
    required this.selected,
    required this.disabled,
    required this.onTap,
  });

  final CustomStagePreset preset;
  final String displayName;
  final String source;
  final bool selected;
  final bool disabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final iconPath = 'assets/images/round_icons/${preset.iconName}';
    final effectiveOnTap = disabled || selected ? null : onTap;
    final visualDisabled = disabled && !selected;

    return Opacity(
      opacity: visualDisabled ? 0.48 : 1,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: InkWell(
          onTap: effectiveOnTap,
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final textScale = MediaQuery.textScalerOf(
                  context,
                ).scale(1).clamp(1.0, 2.5);
                final stackedBreakpoint = 400 + (textScale - 1) * 140;
                final stacked = constraints.maxWidth < stackedBreakpoint;
                final action = IconButton(
                  tooltip: selected
                      ? displayName
                      : l10n?.createCustomStage ?? 'Create custom lawn',
                  icon: Icon(selected ? Icons.check : Icons.add_circle_outline),
                  onPressed: effectiveOnTap,
                );

                if (stacked) {
                  return Column(
                    children: [
                      SizedBox(
                        height: 96,
                        width: double.infinity,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            _buildIcon(iconPath),
                            Positioned(right: 0, top: 0, child: action),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildDetails(context, stacked: true),
                    ],
                  );
                }

                return Row(
                  children: [
                    _buildIcon(iconPath),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDetails(context, stacked: false)),
                    action,
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(String iconPath) {
    return ClipOval(
      child: SizedBox(
        width: 96,
        height: 96,
        child: AssetImageWidget(
          assetPath: iconPath,
          altCandidates: imageAltCandidates(iconPath),
          width: 96,
          height: 96,
          fit: BoxFit.cover,
        ),
      ),
    );
  }

  Widget _buildDetails(BuildContext context, {required bool stacked}) {
    final theme = Theme.of(context);
    final alignment = stacked
        ? CrossAxisAlignment.center
        : CrossAxisAlignment.start;
    final textAlign = stacked ? TextAlign.center : TextAlign.start;
    return Column(
      crossAxisAlignment: alignment,
      children: [
        Text(
          displayName,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: textAlign,
          maxLines: stacked ? 4 : 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          source,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: textAlign,
          maxLines: stacked ? 6 : 4,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          preset.alias,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
          textAlign: textAlign,
          maxLines: stacked ? 2 : 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

class _BuiltinStageGridItem extends StatelessWidget {
  const _BuiltinStageGridItem({
    required this.stage,
    required this.stageName,
    required this.isSelected,
    required this.onTap,
  });

  final StageItem stage;
  final String stageName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      color: isSelected ? theme.colorScheme.primaryContainer : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipOval(
                child: SizedBox(
                  width: 96,
                  height: 96,
                  child: stage.iconName != null
                      ? AssetImageWidget(
                          assetPath:
                              'assets/images/round_icons/${stage.iconName!}',
                          altCandidates: imageAltCandidates(
                            'assets/images/round_icons/${stage.iconName!}',
                          ),
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        )
                      : const AssetImageWidget(
                          assetPath: 'assets/images/others/unknown.webp',
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                stageName,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                stage.alias,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
