import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/screens/select/grid_item_selection_screen.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Protect-the-grid-item challenge. Ported from ProtectTheGridItemChallengePropertiesEP.kt
class ProtectGridItemChallengeScreen extends StatefulWidget {
  const ProtectGridItemChallengeScreen({
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
  State<ProtectGridItemChallengeScreen> createState() =>
      _ProtectGridItemChallengeScreenState();
}

class _ProtectGridItemChallengeScreenState
    extends State<ProtectGridItemChallengeScreen> {
  static const _objClass = 'ProtectTheGridItemChallengeProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late ProtectTheGridItemChallengePropertiesData _data;
  late TextEditingController _descController;
  int _selectedX = 0;
  int _selectedY = 0;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: 'ProtectTheGridItemChallengeProperties',
        objData: ProtectTheGridItemChallengePropertiesData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = ProtectTheGridItemChallengePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = ProtectTheGridItemChallengePropertiesData();
    }
    _descController = TextEditingController(text: _data.description);
  }

  void _sync() {
    _data.mustProtectCount = _data.gridItems.length;
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GridItemSelectionScreen(
          filterMode: GridItemFilterMode.restricted,
          onGridItemSelected: (id) {
            Navigator.pop(context);
            final list = List<ProtectGridItemData>.from(_data.gridItems)
              ..removeWhere(
                (e) => e.gridX == _selectedX && e.gridY == _selectedY,
              )
              ..add(
                ProtectGridItemData(
                  gridX: _selectedX,
                  gridY: _selectedY,
                  gridItemType: id,
                ),
              );
            _data = ProtectTheGridItemChallengePropertiesData(
              description: _data.description,
              gridItems: list,
              mustProtectCount: list.length,
            );
            _sync();
          },
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _removeItem(ProtectGridItemData item) {
    final list = List<ProtectGridItemData>.from(_data.gridItems)..remove(item);
    _data = ProtectTheGridItemChallengePropertiesData(
      description: _data.description,
      gridItems: list,
      mustProtectCount: list.length,
    );
    _sync();
  }

  bool get _isDeepSeaLawn {
    final parsed = LevelParser.parseLevel(widget.levelFile);
    return LevelParser.isDeepSeaLawn(parsed.levelDef, widget.levelFile);
  }

  int get _gridRows => _isDeepSeaLawn ? 6 : 5;
  int get _gridCols => _isDeepSeaLawn ? 10 : 9;

  @override
  void dispose() {
    _descController.dispose();
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final sorted = List<ProtectGridItemData>.from(_data.gridItems)
      ..sort((a, b) {
        final c = a.gridY.compareTo(b.gridY);
        return c != 0 ? c : a.gridX.compareTo(b.gridX);
      });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () => showEditorHelpDialog(
              context,
              title:
                  l10n?.protectGridItemChallengeHelpTitle ??
                  'Protect Item Challenge Guide',
              sections: [
                HelpSectionData(
                  title: l10n?.briefOverview ?? 'Brief Overview',
                  body:
                      l10n?.protectGridItemChallengeHelpOverview ??
                      'Defines the items that must be protected in the level. If these items are destroyed, the level fails.',
                ),
                HelpSectionData(
                  title: l10n?.automaticCount ?? 'Automatic Count',
                  body:
                      l10n?.protectGridItemChallengeHelpAutoCountBody ??
                      'The editor automatically updates the number of grid items that must be protected based on the items you add.',
                ),
                HelpSectionData(
                  title: l10n?.operationGuide ?? 'Operation Guide',
                  body:
                      l10n?.protectGridItemChallengeHelpOperationGuide ??
                      'Tap a coordinate in the grid above, then tap Add Target to choose the type of item to protect.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                      l10n?.description ?? 'Challenge Description',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _descController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        _data = ProtectTheGridItemChallengePropertiesData(
                          description: v,
                          gridItems: _data.gridItems,
                          mustProtectCount: _data.mustProtectCount,
                        );
                        _sync();
                      },
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n?.mustProtectCount(_data.mustProtectCount) ??
                          'Must protect count: ${_data.mustProtectCount}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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
                child: Column(
                  children: [
                    Row(
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.selectedPosition ?? 'Target Position',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              'R${_selectedY + 1} : C${_selectedX + 1}',
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        FilledButton.icon(
                          onPressed: _addItem,
                          icon: const Icon(Icons.add, size: 18),
                          label: Text(l10n?.addItem ?? 'Add Target'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _buildGrid(theme),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.protectedList ?? 'Protected Target List',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...sorted.map(
              (item) => _GridItemTile(
                item: item,
                gridRows: _gridRows,
                gridCols: _gridCols,
                onDelete: () => _removeItem(item),
                onSelect: () => setState(() {
                  _selectedX = item.gridX;
                  _selectedY = item.gridY;
                }),
                deleteTooltip: l10n?.delete ?? 'Delete',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(ThemeData theme) {
    return scaleTableForDesktop(
      context: context,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: EditorItemCardLayout.gridPreviewMaxWidth(context),
        ),
        child: AspectRatio(
          aspectRatio: _gridCols / _gridRows,
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF31383B)
                  : const Color(0xFFD7ECF1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: const Color(0xFF6B899A), width: 1),
            ),
            child: Column(
              children: List.generate(_gridRows, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(_gridCols, (col) {
                      final isSelected = row == _selectedY && col == _selectedX;
                      final item = _data.gridItems.firstWhereOrNull(
                        (p) => p.gridX == col && p.gridY == row,
                      );
                      return Expanded(
                        child: GestureDetector(
                          onTap: () => setState(() {
                            _selectedX = col;
                            _selectedY = row;
                          }),
                          child: Container(
                            margin: const EdgeInsets.all(0.5),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? theme.colorScheme.primary.withValues(
                                      alpha: 0.2,
                                    )
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? theme.colorScheme.primary
                                    : const Color(0xFF6B899A),
                                width: 0.5,
                              ),
                            ),
                            child: item != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Positioned.fill(
                                        child: Padding(
                                          padding: const EdgeInsets.all(2),
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: GridItemIcon(
                                              typeName: item.gridItemType,
                                              size: 32,
                                              fit: BoxFit.contain,
                                              borderRadius: 4,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : null,
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _GridItemTile extends StatelessWidget {
  const _GridItemTile({
    required this.item,
    required this.gridRows,
    required this.gridCols,
    required this.onDelete,
    required this.onSelect,
    required this.deleteTooltip,
  });

  final ProtectGridItemData item;
  final int gridRows;
  final int gridCols;
  final VoidCallback onDelete;
  final VoidCallback onSelect;
  final String deleteTooltip;

  bool get _isOutOfBounds => item.gridX >= gridCols || item.gridY >= gridRows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = ResourceNames.lookup(
      context,
      'griditem_${item.gridItemType}',
    );
    final name = displayName != 'griditem_${item.gridItemType}'
        ? displayName
        : item.gridItemType;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onSelect,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_isOutOfBounds)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(
                  editorWarningIcon,
                  color: editorWarningBannerForeground(theme.brightness),
                  size: 24,
                ),
              ),
            GridItemIcon(
              typeName: item.gridItemType,
              size: 40,
              fit: BoxFit.contain,
            ),
          ],
        ),
        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(
          'R${item.gridY + 1}:C${item.gridX + 1}',
          style: theme.textTheme.bodySmall,
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          tooltip: deleteTooltip,
          onPressed: onDelete,
        ),
      ),
    );
  }
}
