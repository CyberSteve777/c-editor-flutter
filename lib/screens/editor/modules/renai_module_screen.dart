import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/renai_statue_selection_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Renai (Renaissance) module editor. Enables roller/tiles, configures day/night statues.
class RenaiModuleScreen extends StatefulWidget {
  const RenaiModuleScreen({
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
  State<RenaiModuleScreen> createState() => _RenaiModuleScreenState();
}

class _RenaiModuleScreenState extends State<RenaiModuleScreen> {
  static const _objClass = 'RenaiModuleProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late RenaiModulePropertiesData _data;
  late TextEditingController _nightStartCtrl;
  int _selectedX = 0;
  int _selectedY = 0;
  bool _isDayStatues = true;
  RenaiStatueInfoData? _itemToDelete;

  int get _gridRows {
    final (rows, _) = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return rows;
  }

  int get _gridCols {
    final (_, cols) = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return cols;
  }

  List<RenaiStatueInfoData> get _currentList =>
      _isDayStatues ? _data.statueInfos : _data.statueNightInfos;

  List<RenaiStatueInfoData> get _selectedCellStatues => _currentList
      .where((p) => p.gridX == _selectedX && p.gridY == _selectedY)
      .toList();

  List<RenaiStatueInfoData> get _statuesOutsideLawn {
    final all = [..._data.statueInfos, ..._data.statueNightInfos];
    return all
        .where(
          (p) =>
              p.gridX < 0 ||
              p.gridY < 0 ||
              p.gridX >= _gridCols ||
              p.gridY >= _gridRows,
        )
        .toList();
  }

  bool get _canShowNightStatues => _data.nightEnabled;

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
        objClass: 'RenaiModuleProperties',
        objData: RenaiModulePropertiesData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = RenaiModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = RenaiModulePropertiesData();
    }
    _nightStartCtrl = TextEditingController(text: '${_data.nightStartWaveNum}');
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _addStatue() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RenaiStatueSelectionScreen(
          onStatueSelected: (typeName) {
            Navigator.pop(context);
            final s = RenaiStatueInfoData(
              gridX: _selectedX,
              gridY: _selectedY,
              waveNumber: 0,
              typeName: typeName,
            );
            if (_isDayStatues) {
              _data = RenaiModulePropertiesData(
                nightEnabled: _data.nightEnabled,
                nightStartWaveNum: _data.nightStartWaveNum,
                statueInfos: [..._data.statueInfos, s],
                statueNightInfos: _data.statueNightInfos,
              );
            } else {
              _data = RenaiModulePropertiesData(
                nightEnabled: _data.nightEnabled,
                nightStartWaveNum: _data.nightStartWaveNum,
                statueInfos: _data.statueInfos,
                statueNightInfos: [..._data.statueNightInfos, s],
              );
            }
            _sync();
          },
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  void _deleteStatue(RenaiStatueInfoData target) {
    if (_isDayStatues) {
      _data = RenaiModulePropertiesData(
        nightEnabled: _data.nightEnabled,
        nightStartWaveNum: _data.nightStartWaveNum,
        statueInfos: _data.statueInfos.where((e) => e != target).toList(),
        statueNightInfos: _data.statueNightInfos,
      );
    } else {
      _data = RenaiModulePropertiesData(
        nightEnabled: _data.nightEnabled,
        nightStartWaveNum: _data.nightStartWaveNum,
        statueInfos: _data.statueInfos,
        statueNightInfos: _data.statueNightInfos
            .where((e) => e != target)
            .toList(),
      );
    }
    _sync();
  }

  void _updateStatueWave(RenaiStatueInfoData s, int waveNumber) {
    final repl = RenaiStatueInfoData(
      gridX: s.gridX,
      gridY: s.gridY,
      waveNumber: waveNumber,
      typeName: s.typeName,
    );
    if (_isDayStatues) {
      final idx = _data.statueInfos.indexOf(s);
      if (idx >= 0) {
        final list = List<RenaiStatueInfoData>.from(_data.statueInfos);
        list[idx] = repl;
        _data = RenaiModulePropertiesData(
          nightEnabled: _data.nightEnabled,
          nightStartWaveNum: _data.nightStartWaveNum,
          statueInfos: list,
          statueNightInfos: _data.statueNightInfos,
        );
      }
    } else {
      final idx = _data.statueNightInfos.indexOf(s);
      if (idx >= 0) {
        final list = List<RenaiStatueInfoData>.from(_data.statueNightInfos);
        list[idx] = repl;
        _data = RenaiModulePropertiesData(
          nightEnabled: _data.nightEnabled,
          nightStartWaveNum: _data.nightStartWaveNum,
          statueInfos: _data.statueInfos,
          statueNightInfos: list,
        );
      }
    }
    _sync();
  }

  @override
  void dispose() {
    _nightStartCtrl.dispose();
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
    final title = l10n?.renaiModuleTitle ?? 'Renaissance module';
    final helpTitle = l10n?.renaiModuleHelpTitle ?? 'Renaissance module help';

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
                  title: l10n?.renaiModuleHelpOverview ?? 'Overview',
                  body:
                      l10n?.renaiModuleHelpOverviewBody ??
                      'Enables Renai roller and tiles. Night start wave (0-based) switches to night mode. Day and night statues carve at their configured wave.',
                ),
                HelpSectionData(
                  title: l10n?.renaiModuleHelpStatues ?? 'Statues',
                  body:
                      l10n?.renaiModuleHelpStatuesBody ??
                      'Day statues: day phase. Night statues: after night start. Night start wave and carve wave use 0-based indices (0 = first wave).',
                ),
              ],
            ),
          ),
        ],
      ),
      body: Stack(
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
                  child: SwitchListTile(
                    title: Text(
                      l10n?.renaiModuleEnableNight ?? 'Enable night',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    subtitle: Text(
                      l10n?.renaiModuleEnableNightSubtitle ??
                          'Allow night start wave and night statues',
                      style: theme.textTheme.bodySmall,
                    ),
                    value: _data.nightEnabled,
                    onChanged: (v) {
                      _data = RenaiModulePropertiesData(
                        nightEnabled: v,
                        nightStartWaveNum: v ? _data.nightStartWaveNum : 0,
                        statueInfos: _data.statueInfos,
                        statueNightInfos: v ? _data.statueNightInfos : [],
                      );
                      if (!v) {
                        _nightStartCtrl.text = '0';
                        _isDayStatues = true;
                      }
                      _sync();
                    },
                  ),
                ),
                if (_data.nightEnabled) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.renaiModuleNightStart ?? 'Night start wave',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: 120,
                            child: TextField(
                              controller: _nightStartCtrl,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: l10n?.waveLabel ?? 'Wave',
                                helperText: l10n?.moduleWaveIndexZeroBasedHint,
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (v) {
                                final n = int.tryParse(v);
                                if (n != null && n >= 0) {
                                  _data = RenaiModulePropertiesData(
                                    nightEnabled: _data.nightEnabled,
                                    nightStartWaveNum: n,
                                    statueInfos: _data.statueInfos,
                                    statueNightInfos: _data.statueNightInfos,
                                  );
                                  _sync();
                                }
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment(
                      value: true,
                      label: Text(l10n?.renaiModuleDayStatues ?? 'Day statues'),
                      icon: const Icon(Icons.wb_sunny),
                    ),
                    ButtonSegment(
                      value: false,
                      label: Opacity(
                        opacity: _canShowNightStatues ? 1 : 0.5,
                        child: Text(
                          l10n?.renaiModuleNightStatues ?? 'Night statues',
                        ),
                      ),
                      icon: Opacity(
                        opacity: _canShowNightStatues ? 1 : 0.5,
                        child: const Icon(Icons.nightlight_round),
                      ),
                    ),
                  ],
                  selected: {_isDayStatues},
                  onSelectionChanged: (s) {
                    if (s.first == false && !_canShowNightStatues) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFFB3E5FC),
                          content: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.info_outline,
                                color: Color(0xFF01579B),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n?.renaiModuleNightStatuesDisabledHint ??
                                      'Enable night first to add night statues',
                                  style: const TextStyle(
                                    color: Color(0xFF01579B),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                      return;
                    }
                    setState(() => _isDayStatues = s.first);
                  },
                ),
                const SizedBox(height: 12),
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
                        scaleTableForDesktop(
                          context: context,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  EditorItemCardLayout.gridPreviewMaxWidth(
                                    context,
                                  ),
                            ),
                            child: AspectRatio(
                              aspectRatio: _gridCols / _gridRows,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: theme.brightness == Brightness.dark
                                      ? const Color(0xFF31383B)
                                      : const Color(0xFFD7ECF1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFF6B899A),
                                    width: 1,
                                  ),
                                ),
                                child: Column(
                                  children: List.generate(_gridRows, (row) {
                                    return Expanded(
                                      child: Row(
                                        children: List.generate(_gridCols, (
                                          col,
                                        ) {
                                          final isSelected =
                                              row == _selectedY &&
                                              col == _selectedX;
                                          final cellItems = _currentList
                                              .where(
                                                (p) =>
                                                    p.gridX == col &&
                                                    p.gridY == row,
                                              )
                                              .toList();
                                          final firstItem =
                                              cellItems.firstOrNull;
                                          final count = cellItems.length;
                                          return Expanded(
                                            child: GestureDetector(
                                              onTap: () => setState(() {
                                                _selectedX = col;
                                                _selectedY = row;
                                              }),
                                              child: Container(
                                                margin: const EdgeInsets.all(
                                                  0.5,
                                                ),
                                                decoration: BoxDecoration(
                                                  color: isSelected
                                                      ? theme
                                                            .colorScheme
                                                            .primary
                                                            .withValues(
                                                              alpha: 0.2,
                                                            )
                                                      : Colors.transparent,
                                                  border: Border.all(
                                                    color: isSelected
                                                        ? theme
                                                              .colorScheme
                                                              .primary
                                                        : const Color(
                                                            0xFF6B899A,
                                                          ),
                                                    width: 0.5,
                                                  ),
                                                ),
                                                child:
                                                    count > 0 &&
                                                        firstItem != null
                                                    ? Stack(
                                                        fit: StackFit.expand,
                                                        children: [
                                                          Positioned.fill(
                                                            child: Padding(
                                                              padding:
                                                                  const EdgeInsets.all(
                                                                    2,
                                                                  ),
                                                              child: FittedBox(
                                                                fit: BoxFit
                                                                    .contain,
                                                                child: RenaiStatueIcon(
                                                                  typeName:
                                                                      firstItem
                                                                          .typeName,
                                                                  size: 32,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          if (count > 1)
                                                            Positioned(
                                                              top: 3,
                                                              right: 3,
                                                              child: Container(
                                                                padding:
                                                                    const EdgeInsets.symmetric(
                                                                      horizontal:
                                                                          6,
                                                                      vertical:
                                                                          3,
                                                                    ),
                                                                decoration: BoxDecoration(
                                                                  color: theme
                                                                      .colorScheme
                                                                      .onSurfaceVariant,
                                                                  borderRadius:
                                                                      const BorderRadius.only(
                                                                        bottomLeft:
                                                                            Radius.circular(
                                                                              6,
                                                                            ),
                                                                      ),
                                                                ),
                                                                child: Text(
                                                                  '+${count - 1}',
                                                                  style: const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        12,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
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
                        ),
                        const SizedBox(height: 16),
                        Text(
                          l10n?.renaiModuleStatuesInCell ??
                              'Statues in selected cell',
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
                            ..._selectedCellStatues.map(
                              (item) => _StatueCard(
                                item: item,
                                showCoordinates: false,
                                onDelete: () =>
                                    setState(() => _itemToDelete = item),
                                onWaveChanged: (w) =>
                                    _updateStatueWave(item, w),
                                deleteTooltip: l10n?.delete ?? 'Delete',
                              ),
                            ),
                            AddItemCard(
                              onPressed: _addStatue,
                              width: RenaiStatueCardLayout.compact(context)
                                  ? 156
                                  : 180,
                            ),
                          ],
                        ),
                        if (_statuesOutsideLawn.isNotEmpty) ...[
                          const SizedBox(height: 24),
                          Text(
                            l10n?.outsideLawnItems ??
                                'Objects outside the lawn',
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _statuesOutsideLawn
                                .map(
                                  (item) => _StatueCard(
                                    item: item,
                                    showCoordinates: true,
                                    onDelete: () =>
                                        setState(() => _itemToDelete = item),
                                    onWaveChanged: (w) =>
                                        _updateStatueWave(item, w),
                                    deleteTooltip: l10n?.delete ?? 'Delete',
                                  ),
                                )
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_itemToDelete != null) _buildDeleteDialog(),
        ],
      ),
    );
  }

  Widget _buildDeleteDialog() {
    final l10n = AppLocalizations.of(context);
    final item = _itemToDelete!;
    final displayName = ResourceNames.lookup(
      context,
      'griditem_${item.typeName}',
    );
    final name = displayName != 'griditem_${item.typeName}'
        ? displayName
        : item.typeName;
    return AlertDialog(
      title: Text(l10n?.removeItem ?? 'Remove item'),
      content: Text(
        l10n?.removeItemConfirm('W${item.waveNumber} $name') ??
            'Remove W${item.waveNumber} $name?',
      ),
      actions: [
        TextButton(
          onPressed: () => setState(() => _itemToDelete = null),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        TextButton(
          onPressed: () {
            _deleteStatue(item);
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

class _StatueCard extends StatefulWidget {
  const _StatueCard({
    required this.item,
    required this.showCoordinates,
    required this.onDelete,
    required this.onWaveChanged,
    required this.deleteTooltip,
  });

  final RenaiStatueInfoData item;
  final bool showCoordinates;
  final VoidCallback onDelete;
  final void Function(int wave) onWaveChanged;
  final String deleteTooltip;

  @override
  State<_StatueCard> createState() => _StatueCardState();
}

class _StatueCardState extends State<_StatueCard> {
  late TextEditingController _waveCtrl;

  @override
  void initState() {
    super.initState();
    _waveCtrl = TextEditingController(text: '${widget.item.waveNumber}');
  }

  @override
  void didUpdateWidget(covariant _StatueCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.item.waveNumber != widget.item.waveNumber) {
      _waveCtrl.text = '${widget.item.waveNumber}';
    }
  }

  @override
  void dispose() {
    _waveCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    final displayName = ResourceNames.lookup(
      context,
      'griditem_${item.typeName}',
    );
    final name = displayName != 'griditem_${item.typeName}'
        ? displayName
        : item.typeName;
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        width: RenaiStatueCardLayout.tileCardWidth(context),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            EditorDeletableIconHeader(
              onDelete: widget.onDelete,
              deleteTooltip: widget.deleteTooltip,
              iconSize: RenaiStatueCardLayout.tileIconSize(context),
              icon: GridItemIcon(
                typeName: item.typeName,
                size: RenaiStatueCardLayout.tileIconSize(context),
                fit: BoxFit.contain,
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(name, style: theme.textTheme.labelMedium, maxLines: 3),
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
                          Expanded(
                            child: Text(
                              'R${widget.item.gridY + 1}:C${widget.item.gridX + 1}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: editorWarningBannerForeground(
                                  theme.brightness,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _waveCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText:
                          AppLocalizations.of(context)?.renaiModuleCarveWave ??
                          'Carve wave',
                      helperText: AppLocalizations.of(
                        context,
                      )?.moduleWaveIndexZeroBasedHint,
                      border: const OutlineInputBorder(),
                    ),
                    onChanged: (v) {
                      final n = int.tryParse(v);
                      if (n != null && n >= 0) {
                        widget.onWaveChanged(n);
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
