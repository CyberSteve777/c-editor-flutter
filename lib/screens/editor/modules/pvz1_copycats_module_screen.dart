import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/bloc/editor/editor_cubit.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/theme/app_theme.dart' show pvzBrownDark, pvzBrownLight;
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart'
    show editorInputDecoration, HelpSectionData, showEditorHelpDialog;

const String _kUnknownIconPath = 'assets/images/others/unknown.webp';
const double _kListIconSize = 40;

/// Editor for the "Guess who I am" (PVZ1 copycats / magic hat) module.
class PVZ1CopycatsModuleScreen extends StatefulWidget {
  const PVZ1CopycatsModuleScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    this.editorCubit,
    this.onAddModule,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final EditorCubit? editorCubit;
  final void Function(String objClass)? onAddModule;

  @override
  State<PVZ1CopycatsModuleScreen> createState() =>
      _PVZ1CopycatsModuleScreenState();
}

class _PVZ1CopycatsModuleScreenState extends State<PVZ1CopycatsModuleScreen> {
  static const _objClass = 'PVZ1CopycatsModuleProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late PVZ1CopycatsModulePropertiesData _data;
  late TextEditingController _zombieWeightCtrl;
  late TextEditingController _spawnLevelCtrl;
  late FocusNode _zombieWeightFocus;
  late FocusNode _spawnLevelFocus;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    PlantRepository().init();
    ZombieRepository().init();
    _loadData();
    _zombieWeightFocus = FocusNode()..addListener(() => setState(() {}));
    _spawnLevelFocus = FocusNode()..addListener(() => setState(() {}));
    _zombieWeightCtrl = TextEditingController(
      text: _formatDouble(_data.zombieWeight),
    );
    _spawnLevelCtrl = TextEditingController(text: '${_data.spawnPlantLevel}');
  }

  void _loadData() {
    final alias = _alias;
    final existing = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (existing != null) {
      _moduleObj = existing;
    } else {
      _moduleObj = PvzObject(
        aliases: [alias],
        objClass: 'PVZ1CopycatsModuleProperties',
        objData: PVZ1CopycatsModulePropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = PVZ1CopycatsModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = PVZ1CopycatsModulePropertiesData();
    }
    _data = PVZ1CopycatsModulePropertiesData(
      zombieWeight: _data.zombieWeight,
      spawnPlantLevel: _data.spawnPlantLevel,
      plantBlackList: List<String>.from(_data.plantBlackList),
      zombieWhiteList: List<String>.from(_data.zombieWhiteList),
    );
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  static String _formatDouble(double v) {
    if (v == v.roundToDouble()) return '${v.toInt()}';
    final s = v.toStringAsFixed(4);
    return s.replaceFirst(RegExp(r'\.?0+$'), '');
  }

  Future<void> _addPlantsToBlackList() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => PlantSelectionScreen(
          isMultiSelect: true,
          onPlantSelected: (_) {},
          onMultiPlantSelected: (ids) {
            setState(() {
              _data.plantBlackList = List<String>.from(ids);
              _sync();
            });
            Navigator.pop(ctx);
          },
          onBack: () => Navigator.pop(ctx),
          initialSelectedIds: _data.plantBlackList,
          levelFile: widget.levelFile,
          onAddModule: widget.onAddModule,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  Future<void> _addZombiesToWhiteList() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => ZombieSelectionScreen(
          editorCubit: widget.editorCubit,
          multiSelect: true,
          onZombieSelected: (_) {},
          onMultiZombieSelected: (ids) {
            setState(() {
              _data.zombieWhiteList = List<String>.from(ids);
              _sync();
            });
            Navigator.pop(ctx);
          },
          onBack: () => Navigator.pop(ctx),
          initialSelectedIds: _data.zombieWhiteList,
        ),
      ),
    );
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _zombieWeightCtrl.dispose();
    _spawnLevelCtrl.dispose();
    _zombieWeightFocus.dispose();
    _spawnLevelFocus.dispose();
    super.dispose();
  }


  void _handleAliasChanged(String newAlias) {
    renameLevelObjectAlias(
      levelFile: widget.levelFile,
      oldAlias: _alias,
      newAlias: newAlias,
      onChanged: widget.onChanged,
    );
    setState(() => _alias = newAlias);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? pvzBrownDark : pvzBrownLight;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
          foregroundColor: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () {
              showEditorHelpDialog(
                context,
                title: l10n?.pvz1CopycatsModuleTitle ?? 'Guess who I am',
                themeColor: accentColor,
                sections: [
                  HelpSectionData(
                    title: l10n?.overview ?? 'Overview',
                    body: l10n?.pvz1CopycatsHelpOverview ?? '',
                  ),
                  HelpSectionData(
                    title: l10n?.pvz1CopycatsHelpFieldsTitle ?? 'Fields',
                    body:
                        '${l10n?.pvz1CopycatsFieldZombieWeightLabel ?? 'ZombieWeight'}\n'
                        '${l10n?.pvz1CopycatsHelpZombieWeight ?? ''}\n\n'
                        '${l10n?.pvz1CopycatsFieldSpawnPlantLevelLabel ?? 'SpawnPlantLevel'}\n'
                        '${l10n?.pvz1CopycatsHelpSpawnPlantLevel ?? ''}\n\n'
                        '${l10n?.pvz1CopycatsSectionPlantBlackList ?? 'Plant blacklist'}\n'
                        '${l10n?.pvz1CopycatsHelpPlantBlackList ?? ''}\n\n'
                        '${l10n?.pvz1CopycatsSectionZombieWhiteList ?? 'Zombie whitelist'}\n'
                        '${l10n?.pvz1CopycatsHelpZombieWhiteList ?? ''}\n\n'
                        '${l10n?.pvz1CopycatsHelpTip ?? ''}',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
EditorAliasInputField(
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.pvz1CopycatsSectionParams ?? 'Parameters',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Tooltip(
                      message: l10n?.pvz1CopycatsHelpZombieWeight ?? '',
                      child: TextField(
                        focusNode: _zombieWeightFocus,
                        controller: _zombieWeightCtrl,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: editorInputDecoration(
                          context,
                          labelText:
                              l10n?.pvz1CopycatsFieldZombieWeightLabel ??
                              'Zombie spawn weight (ZombieWeight)',
                          focusColor: accentColor,
                          isFocused: _zombieWeightFocus.hasFocus,
                        ),
                        onChanged: (v) {
                          final n = double.tryParse(v.replaceAll(',', '.'));
                          if (n != null) {
                            _data.zombieWeight = n;
                            _sync();
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 12),
                    Tooltip(
                      message: l10n?.pvz1CopycatsHelpSpawnPlantLevel ?? '',
                      child: TextField(
                        focusNode: _spawnLevelFocus,
                        controller: _spawnLevelCtrl,
                        keyboardType: TextInputType.number,
                        decoration: editorInputDecoration(
                          context,
                          labelText:
                              l10n?.pvz1CopycatsFieldSpawnPlantLevelLabel ??
                              'Custom plant tier (SpawnPlantLevel)',
                          focusColor: accentColor,
                          isFocused: _spawnLevelFocus.hasFocus,
                        ),
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) {
                            _data.spawnPlantLevel = n;
                            _sync();
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildIdListCard(
                  context,
                  accentColor: accentColor,
                  title:
                      l10n?.pvz1CopycatsSectionPlantBlackList ??
                      'Plants that cannot be summoned',
                  emptyHint: l10n?.pvz1CopycatsPlantListEmpty ?? 'No entries',
                  ids: _data.plantBlackList,
                  isPlant: true,
                  displayName: (id) => ResourceNames.lookup(
                    context,
                    PlantRepository().getName(id),
                  ),
                  onRemove: (i) {
                    setState(() {
                      _data.plantBlackList.removeAt(i);
                      _sync();
                    });
                  },
                  onAdd: _addPlantsToBlackList,
                  addTooltip: l10n?.pvz1CopycatsAddPlant ?? 'Add plant',
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: _buildIdListCard(
                  context,
                  accentColor: accentColor,
                  title:
                      l10n?.pvz1CopycatsSectionZombieWhiteList ??
                      'Zombies that can be summoned',
                  emptyHint: l10n?.pvz1CopycatsZombieListEmpty ?? 'No entries',
                  ids: _data.zombieWhiteList,
                  isPlant: false,
                  displayName: (id) => ResourceNames.lookup(
                    context,
                    ZombieRepository().getName(id),
                  ),
                  onRemove: (i) {
                    setState(() {
                      _data.zombieWhiteList.removeAt(i);
                      _sync();
                    });
                  },
                  onAdd: _addZombiesToWhiteList,
                  addTooltip: l10n?.pvz1CopycatsAddZombie ?? 'Add zombie',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIdListCard(
    BuildContext context, {
    required Color accentColor,
    required String title,
    required String emptyHint,
    required List<String> ids,
    required bool isPlant,
    required String Function(String id) displayName,
    required void Function(int index) onRemove,
    required VoidCallback onAdd,
    required String addTooltip,
  }) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: accentColor,
                ),
              ),
            ),
            IconButton(
              tooltip: addTooltip,
              onPressed: onAdd,
              icon: const Icon(Icons.add_circle_outline),
              color: accentColor,
            ),
          ],
        ),
        if (ids.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              emptyHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: ids.length,
            itemBuilder: (ctx, i) {
              final id = ids[i];
              return Card(
                child: ListTile(
                  leading: _buildRegistryIcon(isPlant: isPlant, id: id),
                  title: Text(
                    displayName(id),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    id,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => onRemove(i),
                    color: theme.colorScheme.error,
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  /// Rounded icon from plant/zombie registry, or [unknown] when missing.
  Widget _buildRegistryIcon({required bool isPlant, required String id}) {
    final Widget inner;
    if (isPlant) {
      final plant = PlantRepository().getPlantInfoById(id);
      final path = plant?.iconAssetPath;
      if (path != null) {
        inner = AssetImageWidget(
          assetPath: path,
          altCandidates: imageAltCandidates(path),
          width: _kListIconSize,
          height: _kListIconSize,
          fit: BoxFit.cover,
          errorWidget: Image.asset(
            _kUnknownIconPath,
            width: _kListIconSize,
            height: _kListIconSize,
            fit: BoxFit.cover,
          ),
        );
      } else {
        inner = Image.asset(
          _kUnknownIconPath,
          width: _kListIconSize,
          height: _kListIconSize,
          fit: BoxFit.cover,
        );
      }
    } else {
      final zombie = ZombieRepository().getZombieById(id);
      final path = zombie?.iconAssetPath;
      if (path != null) {
        inner = AssetImageWidget(
          assetPath: path,
          altCandidates: imageAltCandidates(path),
          width: _kListIconSize,
          height: _kListIconSize,
          fit: BoxFit.cover,
          errorWidget: Image.asset(
            _kUnknownIconPath,
            width: _kListIconSize,
            height: _kListIconSize,
            fit: BoxFit.cover,
          ),
        );
      } else {
        inner = Image.asset(
          _kUnknownIconPath,
          width: _kListIconSize,
          height: _kListIconSize,
          fit: BoxFit.cover,
        );
      }
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: _kListIconSize,
        height: _kListIconSize,
        child: inner,
      ),
    );
  }
}
