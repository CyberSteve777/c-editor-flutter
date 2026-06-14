import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/select/grid_item_selection_screen.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Initial grid item entry. Ported from Z-Editor-master InitialGridItemEntryEP.kt
class InitialGridItemEntryScreen extends StatefulWidget {
  const InitialGridItemEntryScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    this.onAddModule,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(String objClass)? onAddModule;

  @override
  State<InitialGridItemEntryScreen> createState() =>
      _InitialGridItemEntryScreenState();
}

class _InitialGridItemEntryScreenState extends State<InitialGridItemEntryScreen> {
  late PvzObject _moduleObj;
  late InitialGridItemEntryData _data;
  int _selectedX = 0;
  int _selectedY = 0;
  InitialGridItemData? _itemToDelete;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final info = RtidParser.parse(widget.rtid);
    final alias = info?.alias ?? '';
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: 'InitialGridItemProperties',
        objData: InitialGridItemEntryData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = InitialGridItemEntryData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = InitialGridItemEntryData();
    }
    _data = InitialGridItemEntryData(placements: List.from(_data.placements));
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _handleSelectItem() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => GridItemSelectionScreen(
          filterMode: GridItemFilterMode.all,
          levelFile: widget.levelFile,
          onAddModule: widget.onAddModule,
          onGridItemSelected: (typeName) {
            Navigator.pop(context);
            final newList = List<InitialGridItemData>.from(_data.placements);
            newList.add(InitialGridItemData(
              gridX: _selectedX,
              gridY: _selectedY,
              typeName: typeName,
            ));
            _data = InitialGridItemEntryData(placements: newList);
            _sync();
          },
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _deleteItem(InitialGridItemData target) {
    final newList = List<InitialGridItemData>.from(_data.placements);
    newList.remove(target);
    _data = InitialGridItemEntryData(placements: newList);
    _sync();
  }

  bool get _isDeepSeaLawn {
    final parsed = LevelParser.parseLevel(widget.levelFile);
    return LevelParser.isDeepSeaLawn(parsed.levelDef);
  }

  int get _gridRows => _isDeepSeaLawn ? 6 : 5;
  int get _gridCols => _isDeepSeaLawn ? 10 : 9;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final itemsAtPosition = _data.placements
        .where((p) =>
            p.gridX == _selectedX &&
            p.gridY == _selectedY &&
            p.gridX >= 0 &&
            p.gridY >= 0 &&
            p.gridX < _gridCols &&
            p.gridY < _gridRows)
        .toList();
    final itemsOutsideLawn = _data.placements
        .where((p) =>
            p.gridX < 0 ||
            p.gridY < 0 ||
            p.gridX >= _gridCols ||
            p.gridY >= _gridRows)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.gridItemLayout ?? 'Grid item layout',
          overflow: TextOverflow.ellipsis,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                  l10n?.itemListRowFirst ?? 'Item list (row-first)',
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
                    ...itemsAtPosition.map((item) => _GridItemCard(
                      item: item,
                      gridRows: _gridRows,
                      gridCols: _gridCols,
                      showCoordinates: false,
                      onDelete: () => setState(() => _itemToDelete = item),
                      deleteTooltip: l10n?.delete ?? 'Delete',
                    )),
                    AddItemCard(
                      onPressed: _handleSelectItem,
                      minHeight: 130,
                    ),
                  ],
                ),
                if (itemsOutsideLawn.isNotEmpty) ...[
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
                    children: itemsOutsideLawn
                        .map((item) => _GridItemCard(
                              item: item,
                              gridRows: _gridRows,
                              gridCols: _gridCols,
                              showCoordinates: true,
                              onDelete: () => setState(() => _itemToDelete = item),
                              deleteTooltip: l10n?.delete ?? 'Delete',
                            ))
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          if (_itemToDelete != null) _buildDeleteDialog(),
        ],
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
                      final cellItems = _data.placements
                          .where((p) => p.gridX == col && p.gridY == row)
                          .toList();
                      final firstItem = cellItems.firstOrNull;
                      final count = cellItems.length;
                      final cellBadgeScale =
                          EditorItemCardLayout.gridCellBadgeScale(context);
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
                            child: count > 0 && firstItem != null
                                ? Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Positioned.fill(
                                        child: Padding(
                                          padding: const EdgeInsets.all(2),
                                          child: FittedBox(
                                            fit: BoxFit.contain,
                                            child: GridItemIcon(
                                                typeName: firstItem.typeName,
                                                size: 32,
                                                fit: BoxFit.contain,
                                                borderRadius: 4,
                                                badgeScaleFactor:
                                                    1.25 * cellBadgeScale),
                                          ),
                                        ),
                                      ),
                                      if (count > 1)
                                        Positioned(
                                          top: 2,
                                          right: 2,
                                          child: Transform.scale(
                                            scale: cellBadgeScale,
                                            alignment: Alignment.topRight,
                                            child: Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                              horizontal: 6,
                                              vertical: 3,
                                            ),
                                            decoration: BoxDecoration(
                                              color: theme.colorScheme
                                                  .onSurfaceVariant,
                                              borderRadius:
                                                  const BorderRadius.only(
                                                bottomLeft: Radius.circular(6),
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
    final displayName = ResourceNames.lookup(context, 'griditem_${item.typeName}');
    final name = displayName != 'griditem_${item.typeName}' ? displayName : item.typeName;
    return AlertDialog(
      title: Text(l10n?.removeItem ?? 'Remove item'),
      content: Text(
        l10n?.removeItemConfirm('R${item.gridY + 1}:C${item.gridX + 1} $name') ?? 'Remove R${item.gridY + 1}:C${item.gridX + 1} $name?',
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _itemToDelete = null),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        TextButton(
          onPressed: () {
            _deleteItem(item);
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

class _GridItemCard extends StatelessWidget {
  const _GridItemCard({
    required this.item,
    required this.gridRows,
    required this.gridCols,
    required this.showCoordinates,
    required this.onDelete,
    required this.deleteTooltip,
  });

  final InitialGridItemData item;
  final int gridRows;
  final int gridCols;
  final bool showCoordinates;
  final VoidCallback onDelete;
  final String deleteTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = ResourceNames.lookup(context, 'griditem_${item.typeName}');
    final name = displayName != 'griditem_${item.typeName}'
        ? displayName
        : item.typeName;

    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: EditorItemCardLayout.cardWidth(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EditorDeletableIconHeader(
              onDelete: onDelete,
              deleteTooltip: deleteTooltip,
              icon: GridItemIcon(
                typeName: item.typeName,
                size: 64,
                fit: BoxFit.contain,
                iconScaleFactor:
                    GridItemRepository.isRenaiStatueNonHalf(item.typeName)
                        ? 3.0
                        : 1.5,
                badgeScaleFactor: 1.25,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      overflow: TextOverflow.ellipsis,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (showCoordinates)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.amber.shade700,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'R${item.gridY + 1}:C${item.gridX + 1}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.amber.shade700,
                            ),
                          ),
                        ],
                      ),
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
