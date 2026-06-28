import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/bloc/editor/editor_cubit.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Seed rain properties editor. Ported from Z-Editor-master SeedRainPropertiesEP.kt
class SeedRainPropertiesScreen extends StatefulWidget {
  const SeedRainPropertiesScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    this.onAddModule,
    this.editorCubit,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(String objClass)? onAddModule;
  final EditorCubit? editorCubit;

  @override
  State<SeedRainPropertiesScreen> createState() =>
      _SeedRainPropertiesScreenState();
}

class _SeedRainPropertiesScreenState extends State<SeedRainPropertiesScreen> {
  static const _objClass = 'SeedRainProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late SeedRainPropertiesData _data;
  late TextEditingController _rainIntervalCtrl;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
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
        objClass: 'SeedRainProperties',
        objData: SeedRainPropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = SeedRainPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = SeedRainPropertiesData();
    }
    _rainIntervalCtrl = TextEditingController(text: '${_data.rainInterval}');
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addPlant(List<String> ids) {
    final newList = List<SeedRainItem>.from(_data.seedRains);
    for (final id in ids) {
      newList.add(
        SeedRainItem(seedRainType: 0, plantTypeName: id, zombieTypeName: null),
      );
    }
    _data = SeedRainPropertiesData(
      rainInterval: _data.rainInterval,
      seedRains: newList,
    );
    _sync();
  }

  void _addZombie(List<String> ids) {
    final newList = List<SeedRainItem>.from(_data.seedRains);
    for (final id in ids) {
      newList.add(
        SeedRainItem(
          seedRainType: 1,
          plantTypeName: null,
          zombieTypeName: ZombieRepository().buildZombieAliases(id),
        ),
      );
    }
    _data = SeedRainPropertiesData(
      rainInterval: _data.rainInterval,
      seedRains: newList,
    );
    _sync();
  }

  void _addCollectable() {
    final newList = List<SeedRainItem>.from(_data.seedRains);
    newList.add(SeedRainItem(seedRainType: 2));
    _data = SeedRainPropertiesData(
      rainInterval: _data.rainInterval,
      seedRains: newList,
    );
    _sync();
  }

  void _updateItem(SeedRainItem oldItem, SeedRainItem newItem) {
    final idx = _data.seedRains.indexOf(oldItem);
    if (idx >= 0) {
      final newList = List<SeedRainItem>.from(_data.seedRains);
      newList[idx] = newItem;
      _data = SeedRainPropertiesData(
        rainInterval: _data.rainInterval,
        seedRains: newList,
      );
      _sync();
    }
  }

  void _deleteItem(SeedRainItem item) {
    final newList = _data.seedRains.where((e) => e != item).toList();
    _data = SeedRainPropertiesData(
      rainInterval: _data.rainInterval,
      seedRains: newList,
    );
    _sync();
  }

  Future<void> _showAddDialog(AppLocalizations? l10n) async {
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.addItem ?? 'Add item'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(l10n?.plant ?? 'Plant'),
              onTap: () => Navigator.pop(ctx, 'plant'),
            ),
            ListTile(
              title: Text(l10n?.zombie ?? 'Zombie'),
              onTap: () => Navigator.pop(ctx, 'zombie'),
            ),
            ListTile(
              title: Text(l10n?.collectable ?? 'Collectable (Plant Food)'),
              onTap: () => Navigator.pop(ctx, 'collectable'),
            ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    if (choice == 'plant') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => PlantSelectionScreen(
            isMultiSelect: true,
            onPlantSelected: (_) {},
            onMultiPlantSelected: (ids) {
              _addPlant(ids);
              Navigator.pop(ctx);
            },
            onBack: () => Navigator.pop(ctx),
            levelFile: widget.levelFile,
            onAddModule: widget.onAddModule,
          ),
        ),
      );
    } else if (choice == 'zombie') {
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (ctx) => ZombieSelectionScreen(
            editorCubit: widget.editorCubit,
            multiSelect: true,
            onZombieSelected: (_) {},
            onMultiZombieSelected: (ids) {
              _addZombie(ids);
              Navigator.pop(ctx);
            },
            onBack: () => Navigator.pop(ctx),
          ),
        ),
      );
    } else if (choice == 'collectable') {
      _addCollectable();
    }
    if (mounted) setState(() {});
  }

  String _getItemName(BuildContext context, SeedRainItem item) {
    switch (item.seedRainType) {
      case 0:
        final alias =
            RtidParser.parse(item.plantTypeName ?? '')?.alias ??
            item.plantTypeName ??
            '';
        return ResourceNames.lookup(context, PlantRepository().getName(alias));
      case 1:
        final alias =
            RtidParser.parse(item.zombieTypeName ?? '')?.alias ??
            item.zombieTypeName ??
            '';
        final typeName = ZombiePropertiesRepository.getTypeNameByAlias(alias);
        return ResourceNames.lookup(
          context,
          ZombieRepository().getName(typeName),
        );
      case 2:
        return 'Plant Food';
      default:
        return 'Unknown';
    }
  }

  void _openEditDialog(SeedRainItem item, AppLocalizations? l10n) {
    var tempWeight = item.weight;
    var tempMaxCount = item.maxCount;
    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            return AlertDialog(
              title: Text(
                l10n?.editAlias(_getItemName(ctx, item)) ??
                    'Edit: ${_getItemName(ctx, item)}',
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n?.weight ?? 'Weight',
                      border: const OutlineInputBorder(),
                    ),
                    initialValue: '$tempWeight',
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null) tempWeight = n;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: l10n?.maxCount ?? 'Max count',
                      border: const OutlineInputBorder(),
                    ),
                    initialValue: '$tempMaxCount',
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null) tempMaxCount = n;
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(l10n?.cancel ?? 'Cancel'),
                ),
                FilledButton(
                  onPressed: () {
                    _updateItem(
                      item,
                      SeedRainItem(
                        seedRainType: item.seedRainType,
                        plantTypeName: item.plantTypeName,
                        zombieTypeName: item.zombieTypeName,
                        weight: tempWeight,
                        maxCount: tempMaxCount,
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                  child: Text(l10n?.save ?? 'Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openDeleteDialog(SeedRainItem item, AppLocalizations? l10n) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.confirmDelete ?? 'Confirm delete'),
        content: Text(
          l10n?.removeItemConfirm(_getItemName(ctx, item)) ??
              'Remove ${_getItemName(ctx, item)}?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _deleteItem(item);
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
        ),
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
                    TextField(
                      controller: _rainIntervalCtrl,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            l10n?.rainIntervalSeconds ??
                            'Rain interval (seconds)',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null) {
                          _data = SeedRainPropertiesData(
                            rainInterval: n,
                            seedRains: _data.seedRains,
                          );
                          _sync();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: () => _showAddDialog(l10n),
                        icon: const Icon(Icons.add),
                        label: Text(l10n?.addDropItem ?? 'Add drop item'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (_data.seedRains.isEmpty)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      l10n?.noItemsAddHint ??
                          'No items. Add plants, zombies, or collectables.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              )
            else
              ..._data.seedRains.map(
                (item) => _SeedRainRowCard(
                  item: item,
                  onTap: () => _openEditDialog(item, l10n),
                  onDelete: () => _openDeleteDialog(item, l10n),
                  getItemName: _getItemName,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SeedRainRowCard extends StatelessWidget {
  const _SeedRainRowCard({
    required this.item,
    required this.onTap,
    required this.onDelete,
    required this.getItemName,
  });

  final SeedRainItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;
  final String Function(BuildContext, SeedRainItem) getItemName;

  String _getDisplayType(SeedRainItem item) {
    switch (item.seedRainType) {
      case 0:
        return 'Plant';
      case 1:
        return 'Zombie';
      case 2:
        return 'Collectable';
      default:
        return 'Unknown';
    }
  }

  String? _getIconPath(SeedRainItem item) {
    switch (item.seedRainType) {
      case 0:
        final alias =
            RtidParser.parse(item.plantTypeName ?? '')?.alias ??
            item.plantTypeName ??
            '';
        final info = PlantRepository().getPlantInfoById(alias);
        if (info?.icon != null) return 'assets/images/plants/${info!.icon}';
        return null;
      case 1:
        final alias =
            RtidParser.parse(item.zombieTypeName ?? '')?.alias ??
            item.zombieTypeName ??
            '';
        final typeName = ZombiePropertiesRepository.getTypeNameByAlias(alias);
        final info = ZombieRepository().getZombieById(typeName);
        if (info?.icon != null) return 'assets/images/zombies/${info!.icon}';
        return null;
      case 2:
        return 'assets/images/others/plantfood.webp';
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeName = getItemName(context, item);
    final displayType = _getDisplayType(item);
    final iconPath = _getIconPath(item);

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: iconPath != null
                    ? AssetImageWidget(
                        assetPath: iconPath,
                        fit: BoxFit.contain,
                        width: 48,
                        height: 48,
                      )
                    : Center(
                        child: Text(
                          typeName.isNotEmpty ? typeName[0] : '?',
                          style: theme.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      typeName,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(displayType, style: theme.textTheme.bodySmall),
                        const SizedBox(width: 12),
                        Text(
                          'Weight: ${item.weight}',
                          style: theme.textTheme.bodySmall,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Max: ${item.maxCount}',
                          style: theme.textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(icon: const Icon(Icons.delete), onPressed: onDelete),
            ],
          ),
        ),
      ),
    );
  }
}
