import 'package:flutter/material.dart';
import 'package:c_editor/data/armrack_type_catalog.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/grid_override_placement_grid.dart';

class ArmrackModuleScreen extends StatefulWidget {
  const ArmrackModuleScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;

  @override
  State<ArmrackModuleScreen> createState() => _ArmrackModuleScreenState();
}

class _ArmrackModuleScreenState extends State<ArmrackModuleScreen> {
  late PvzObject _moduleObj;
  late ArmrackPropertiesData _data;
  int _selectedX = 0;
  int _selectedY = 0;
  String _selectedType = kArmrackTypes.first.type;

  int get _gridRows {
    final (rows, _) = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return rows;
  }

  int get _gridCols {
    final (_, cols) = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return cols;
  }

  ArmrackOverrideWaveData get _selectedOverride => _data.overrides.first;

  @override
  void initState() {
    super.initState();
    _loadData();
    _ensureSingleWaveOneOverride();
  }

  void _loadData() {
    final info = RtidParser.parse(widget.rtid);
    final alias = info?.alias ?? 'Armrack';
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: 'ArmrackProperties',
        objData: ArmrackPropertiesData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = ArmrackPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = ArmrackPropertiesData();
    }
  }

  void _ensureSingleWaveOneOverride() {
    final source = _data.overrides.firstWhere(
      (e) => e.wave == gridOverrideFirstWave,
      orElse: () => _data.overrides.isNotEmpty
          ? _data.overrides.first
          : ArmrackOverrideWaveData(wave: gridOverrideFirstWave),
    );
    _data = ArmrackPropertiesData(
      overrides: [
        ArmrackOverrideWaveData(
          wave: gridOverrideFirstWave,
          itemList: source.itemList,
        ),
      ],
    );
    _moduleObj.objData = _data.toJson();
  }

  void _sync() {
    _ensureSingleWaveOneOverride();
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _writeSelectedItems(List<ArmrackOverrideItemData> items) {
    _data = ArmrackPropertiesData(
      overrides: [
        ArmrackOverrideWaveData(
          wave: gridOverrideFirstWave,
          itemList: items,
        ),
      ],
    );
    _sync();
  }

  ArmrackOverrideItemData? _itemAt(int col, int row) {
    final items = _selectedOverride.itemList;
    for (final item in items) {
      if (item.mX == col && item.mY == row) return item;
    }
    return null;
  }

  void _placeAt(int col, int row) {
    final items = _selectedOverride.itemList;
    _selectedX = col;
    _selectedY = row;
    final next = List<ArmrackOverrideItemData>.from(items)
      ..removeWhere((e) => e.mX == col && e.mY == row)
      ..add(
        ArmrackOverrideItemData(
          mX: col,
          mY: row,
          type: _selectedType,
        ),
      );
    _writeSelectedItems(next);
  }

  void _removeAt(int col, int row) {
    final item = _itemAt(col, row);
    if (item == null) return;
    final items = List<ArmrackOverrideItemData>.from(_selectedOverride.itemList)
      ..remove(item);
    _writeSelectedItems(items);
  }

  void _handlePrimaryTap(int col, int row) {
    final existing = _itemAt(col, row);
    if (existing != null && existing.type == _selectedType) {
      setState(() {
        _selectedX = col;
        _selectedY = row;
      });
      return;
    }
    _placeAt(col, row);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final title = l10n?.armrackModuleTitle ?? 'Weapon Stands';
    final helpTitle = l10n?.armrackModuleHelpTitle ?? 'Weapon Stands module';

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () => showEditorHelpDialog(
              context,
              title: helpTitle,
              sections: [
                HelpSectionData(
                  title: l10n?.armrackModuleHelpOverview ?? 'Overview',
                  body:
                      l10n?.armrackModuleHelpOverviewBody ??
                      'Places weapon stands on the lawn. '
                          'This module is required for weapon stands to display properly.',
                ),
                HelpSectionData(
                  title: l10n?.armrackModuleHelpPlacement ?? 'Placement',
                  body:
                      l10n?.armrackModuleHelpPlacementBody ??
                      'Choose a stand type, then tap a tile to place it (one per tile). '
                          'Right-click or long-press a tile to remove its stand.',
                ),
                HelpSectionData(
                  title: l10n?.armrackModuleHelpWaveLimit ?? 'Wave limit',
                  body:
                      l10n?.armrackModuleHelpWaveLimitBody ??
                      'Due to a game limitation, only wave 1 entries take effect in-game. '
                          'This editor saves weapon stands as wave 1 entries automatically.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          margin: EdgeInsets.zero,
          child: Padding(
            padding: kGridOverrideModuleSectionPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n?.armrackModuleTypePalette ?? 'Stand type',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: kArmrackTypes.map((info) {
                    final typeSelected = _selectedType == info.type;
                    final resourceKey = 'armrack_${info.type}';
                    final label = ResourceNames.lookup(context, resourceKey);
                    final displayLabel = label != resourceKey ? label : info.type;
                    return InkWell(
                      onTap: () => setState(() => _selectedType = info.type),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 112,
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: typeSelected
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: typeSelected
                                ? theme.colorScheme.primary
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                              height: 48,
                              child: AssetImageWidget(
                                assetPath:
                                    'assets/images/griditems/${info.iconFile}',
                                fit: BoxFit.contain,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayLabel,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              info.type,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Text(
                  '${l10n?.selectedPosition ?? "Selected position"}: R${_selectedY + 1} : C${_selectedX + 1}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                GridOverridePlacementGrid(
                  gridRows: _gridRows,
                  gridCols: _gridCols,
                  selectedCol: _selectedX,
                  selectedRow: _selectedY,
                  onPrimaryTap: _handlePrimaryTap,
                  onRemoveAt: _removeAt,
                  cellImageAt: (col, row) {
                    final item = _itemAt(col, row);
                    if (item == null) return null;
                    return armrackIconAsset(item.type);
                  },
                  cellImageScaleAt: (col, row) {
                    final item = _itemAt(col, row);
                    if (item == null) return 1.0;
                    return armrackGridScale(item.type);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
