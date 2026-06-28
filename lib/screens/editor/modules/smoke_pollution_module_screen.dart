import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Steam Ages smoke pollution module editor (SmokeManhole placements).
class SmokePollutionModuleScreen extends StatefulWidget {
  const SmokePollutionModuleScreen({
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
  State<SmokePollutionModuleScreen> createState() =>
      _SmokePollutionModuleScreenState();
}

class _SmokePollutionModuleScreenState
    extends State<SmokePollutionModuleScreen> {
  static const _objClass = 'SmokePollutionModuleProperties';
  late String _alias;
  static const _gridItemType = SmokePollutionModulePropertiesData.gridItemType;

  late PvzObject _moduleObj;
  late SmokePollutionModulePropertiesData _data;
  int _selectedX = 0;
  int _selectedY = 0;
  SmokeManholeEntryData? _itemToDelete;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);

  int get _gridCols => _isDeepSeaLawn ? 10 : 9;
  int get _gridRows => _isDeepSeaLawn ? 6 : 5;

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
        objClass: 'SmokePollutionModuleProperties',
        objData: SmokePollutionModulePropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = SmokePollutionModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = SmokePollutionModulePropertiesData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addManhole() {
    _data = SmokePollutionModulePropertiesData(
      gridItem: _data.gridItem,
      smokeManholeList: [
        ..._data.smokeManholeList,
        SmokeManholeEntryData(
          gridColumn: _selectedX,
          gridRow: _selectedY,
          startTime: 0,
        ),
      ],
    );
    _sync();
  }

  void _removeManhole(SmokeManholeEntryData item) {
    _data = SmokePollutionModulePropertiesData(
      gridItem: _data.gridItem,
      smokeManholeList: _data.smokeManholeList.where((t) => t != item).toList(),
    );
    _sync();
  }

  void _updateStartTime(SmokeManholeEntryData item, int startTime) {
    final index = _data.smokeManholeList.indexOf(item);
    if (index < 0) return;
    final updated = [..._data.smokeManholeList];
    updated[index] = SmokeManholeEntryData(
      gridColumn: item.gridColumn,
      gridRow: item.gridRow,
      startTime: startTime,
    );
    _data = SmokePollutionModulePropertiesData(
      gridItem: _data.gridItem,
      smokeManholeList: updated,
    );
    _sync();
  }

  List<SmokeManholeEntryData> get _itemsAtPosition => _data.smokeManholeList
      .where(
        (t) =>
            t.gridColumn == _selectedX &&
            t.gridRow == _selectedY &&
            t.gridColumn >= 0 &&
            t.gridRow >= 0 &&
            t.gridColumn < _gridCols &&
            t.gridRow < _gridRows,
      )
      .toList();

  List<SmokeManholeEntryData> get _itemsOutsideLawn => _data.smokeManholeList
      .where(
        (t) =>
            t.gridColumn < 0 ||
            t.gridRow < 0 ||
            t.gridColumn >= _gridCols ||
            t.gridRow >= _gridRows,
      )
      .toList();


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
    final title = l10n?.smokePollutionModuleTitle ?? 'Smoke pollution module';
    final helpTitle =
        l10n?.smokePollutionModuleHelpTitle ?? 'Smoke pollution module help';

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
              title: helpTitle,
              sections: [
                HelpSectionData(
                  title: l10n?.smokePollutionModuleHelpOverview ?? 'Overview',
                  body: l10n?.smokePollutionModuleHelpOverviewBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.smokePollutionModuleHelpManholes ?? 'Manholes',
                  body: l10n?.smokePollutionModuleHelpManholesBody ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Stack(
          children: [
            SingleChildScrollView(
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
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n?.selectedPosition ?? 'Selected position',
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
                          const SizedBox(height: 16),
                          _buildGrid(),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.itemsSortedByRow ?? 'Item(s) in selected tile',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      ..._itemsAtPosition.map(
                        (item) => _SmokeManholeCard(
                          item: item,
                          showCoordinates: false,
                          onDelete: () => setState(() => _itemToDelete = item),
                          onStartTimeChanged: (t) => _updateStartTime(item, t),
                          deleteTooltip: l10n?.delete ?? 'Delete',
                        ),
                      ),
                      AddItemCard(
                        onPressed: _addManhole,
                        width: 140,
                        minHeight: 195,
                      ),
                    ],
                  ),
                  if (_itemsOutsideLawn.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    Text(
                      l10n?.outsideLawnItems ?? 'Objects outside the lawn',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _itemsOutsideLawn
                          .map(
                            (item) => _SmokeManholeCard(
                              item: item,
                              showCoordinates: true,
                              onDelete: () =>
                                  setState(() => _itemToDelete = item),
                              onStartTimeChanged: (t) =>
                                  _updateStartTime(item, t),
                              deleteTooltip: l10n?.delete ?? 'Delete',
                            ),
                          )
                          .toList(),
                    ),
                  ],
                  const SizedBox(height: 32),
                ],
              ),
            ),
            if (_itemToDelete != null) _buildDeleteDialog(),
          ],
        ),
      ),
    );
  }

  Widget _buildGrid() {
    final theme = Theme.of(context);
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
                      final cellItems = _data.smokeManholeList
                          .where((t) => t.gridColumn == col && t.gridRow == row)
                          .toList();
                      final count = cellItems.length;
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
                            child: count > 0
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Positioned.fill(
                                        child: Padding(
                                          padding: const EdgeInsets.all(2),
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                              child: Image.asset(
                                                GridItemRepository.getIconPath(
                                                  _gridItemType,
                                                ),
                                                fit: BoxFit.contain,
                                                filterQuality:
                                                    FilterQuality.medium,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      if (count > 1)
                                        Positioned(
                                          top: 3,
                                          right: 3,
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme
                                                  .colorScheme
                                                  .onSurfaceVariant,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                    bottomLeft: Radius.circular(
                                                      6,
                                                    ),
                                                  ),
                                            ),
                                            child: Text(
                                              '+${count - 1}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
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

  Widget _buildDeleteDialog() {
    final l10n = AppLocalizations.of(context);
    final item = _itemToDelete!;
    final displayName = ResourceNames.lookup(
      context,
      'griditem_$_gridItemType',
    );
    final name = displayName != 'griditem_$_gridItemType'
        ? displayName
        : _gridItemType;
    return AlertDialog(
      title: Text(l10n?.removeItem ?? 'Remove item'),
      content: Text(
        l10n?.removeItemConfirm(
              'R${item.gridRow + 1}:C${item.gridColumn + 1} $name',
            ) ??
            'Remove R${item.gridRow + 1}:C${item.gridColumn + 1} $name?',
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _itemToDelete = null),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        TextButton(
          onPressed: () {
            _removeManhole(item);
            setState(() => _itemToDelete = null);
          },
          style: TextButton.styleFrom(
            foregroundColor: Theme.of(context).colorScheme.error,
          ),
          child: Text(l10n?.remove ?? 'Remove'),
        ),
      ],
    );
  }
}

class _SmokeManholeCard extends StatefulWidget {
  const _SmokeManholeCard({
    required this.item,
    required this.showCoordinates,
    required this.onDelete,
    required this.onStartTimeChanged,
    required this.deleteTooltip,
  });

  final SmokeManholeEntryData item;
  final bool showCoordinates;
  final VoidCallback onDelete;
  final void Function(int startTime) onStartTimeChanged;
  final String deleteTooltip;

  @override
  State<_SmokeManholeCard> createState() => _SmokeManholeCardState();
}

class _SmokeManholeCardState extends State<_SmokeManholeCard> {
  late TextEditingController _startTimeCtrl;

  @override
  void initState() {
    super.initState();
    _startTimeCtrl = TextEditingController(text: '${widget.item.startTime}');
  }

  @override
  void didUpdateWidget(covariant _SmokeManholeCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.startTime != widget.item.startTime) {
      _startTimeCtrl.text = '${widget.item.startTime}';
    }
  }

  @override
  void dispose() {
    _startTimeCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    const typeName = SmokePollutionModulePropertiesData.gridItemType;
    final displayName = ResourceNames.lookup(context, 'griditem_$typeName');
    final name = displayName != 'griditem_$typeName' ? displayName : typeName;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: EditorItemCardLayout.cardWidth(context, base: 140),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EditorDeletableIconHeader(
              onDelete: widget.onDelete,
              deleteTooltip: widget.deleteTooltip,
              icon: GridItemIcon(
                typeName: typeName,
                size: 64,
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (widget.showCoordinates)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            editorWarningIcon,
                            color: editorWarningBannerForeground(
                              theme.brightness,
                            ),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'R${widget.item.gridRow + 1}:C${widget.item.gridColumn + 1}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: editorWarningBannerForeground(
                                theme.brightness,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _startTimeCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText:
                          l10n?.smokePollutionModuleStartTimeLabel ??
                          'Start time (s)',
                      border: const OutlineInputBorder(),
                      isDense: true,
                    ),
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null && n >= 0) {
                        widget.onStartTimeChanged(n);
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
