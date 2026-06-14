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
  late PvzObject _moduleObj;
  late ProtectTheGridItemChallengePropertiesData _data;
  late TextEditingController _descController;
  int _selectedX = 0;
  int _selectedY = 0;

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
              ..removeWhere((e) => e.gridX == _selectedX && e.gridY == _selectedY)
              ..add(ProtectGridItemData(
                gridX: _selectedX,
                gridY: _selectedY,
                gridItemType: id,
              ));
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
    return LevelParser.isDeepSeaLawn(parsed.levelDef);
  }

  int get _gridRows => _isDeepSeaLawn ? 6 : 5;
  int get _gridCols => _isDeepSeaLawn ? 10 : 9;

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
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
        title: const Text('Protect items'),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () => showEditorHelpDialog(
              context,
              title: 'Protect items',
              sections: const [
                HelpSectionData(
                  title: 'Overview',
                  body: 'Grid items listed here must survive; losing them fails the level.',
                ),
                HelpSectionData(
                  title: 'Auto count',
                  body: 'The required count follows the number of listed items.',
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Description',
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
                              'Selected position',
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
                          label: const Text('Add item'),
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
              'Protected list',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ...sorted.map((item) => _GridItemTile(
                  item: item,
                  gridRows: _gridRows,
                  gridCols: _gridCols,
                  onDelete: () => _removeItem(item),
                  onSelect: () => setState(() {
                    _selectedX = item.gridX;
                    _selectedY = item.gridY;
                  }),
                  deleteTooltip: l10n?.delete ?? 'Delete',
                )),
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
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.2)
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
                                                badgeScaleFactor:
                                                    1.25 * cellBadgeScale),
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

  bool get _isOutOfBounds =>
      item.gridX >= gridCols || item.gridY >= gridRows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final displayName = ResourceNames.lookup(context, 'griditem_${item.gridItemType}');
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
                  Icons.warning_amber_rounded,
                  color: Colors.amber.shade700,
                  size: 24,
                ),
              ),
            GridItemIcon(
              typeName: item.gridItemType,
              size: 40,
              fit: BoxFit.contain,
              iconScaleFactor: GridItemRepository.isRenaiStatueNonHalf(
                      item.gridItemType)
                  ? 3.0
                  : 1.5,
              badgeScaleFactor: 1.25,
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
