import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart' show pvzBrownDark, pvzBrownLight;
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Tunnel defend (mausoleum) module. Ported from TunnelDefendModuleEP.kt
class TunnelDefendModuleScreen extends StatefulWidget {
  const TunnelDefendModuleScreen({
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
  State<TunnelDefendModuleScreen> createState() =>
      _TunnelDefendModuleScreenState();
}

class _TunnelDefendModuleScreenState extends State<TunnelDefendModuleScreen> {
  static const _objClass = 'TunnelDefendModuleProperties';
  late String _alias;
  static const _assetWidth = 128.0;
  static const _assetHeight = 152.0;

  bool get _isDeepSeaLawn {
    final parsed = LevelParser.parseLevel(widget.levelFile);
    return LevelParser.isDeepSeaLawn(parsed.levelDef, widget.levelFile);
  }

  int get _gridCols => _isDeepSeaLawn ? 10 : 9;
  int get _gridRows => _isDeepSeaLawn ? 6 : 5;
  double get _gridAspectRatio =>
      (_gridCols * _assetWidth) / (_gridRows * _assetHeight);

  static const _availableAssets = [
    'IMAGE_UI_MAUSOLEUM_TUNNEL_DOWN',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_DOWN_2',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_DOWN_3',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_DOWN_LEFT',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_DOWN_LEFT_2',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_DOWN_LEFT_3',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_LEFT',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_LEFT_2',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_LEFT_3',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_LEFT_4',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_LEFT_5',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_LEFT_6',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_LEFT_7',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_2',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_3',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_LEFT',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_LEFT_2',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_LEFT_3',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_DOWN',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_DOWN_2',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_DOWN_LEFT',
    'IMAGE_UI_MAUSOLEUM_TUNNEL_UP_DOWN_LEFT_2',
  ];

  late PvzObject _moduleObj;
  late TunnelDefendModuleData _data;
  late List<List<String?>> _gridState;
  late TextEditingController _sequenceIntervalCtrl;
  String _selectedImg = _availableAssets[0];

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
        objClass: 'TunnelDefendModuleProperties',
        objData: TunnelDefendModuleData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = TunnelDefendModuleData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = TunnelDefendModuleData();
    }
    _gridState = List.generate(_gridCols, (_) => List.filled(_gridRows, null));
    for (final road in _data.roads) {
      if (road.gridX >= 0 &&
          road.gridX < _gridCols &&
          road.gridY >= 0 &&
          road.gridY < _gridRows) {
        _gridState[road.gridX][road.gridY] = road.img;
      }
    }
    _selectedImg = _availableAssets[0];
    _sequenceIntervalCtrl = TextEditingController(
      text: '${_data.tunnelSequenceInterval}',
    );
  }

  @override
  void dispose() {
    _sequenceIntervalCtrl.dispose();
    super.dispose();
  }

  void _sync() {
    final roads = <TunnelRoadData>[];
    for (var x = 0; x < _gridCols; x++) {
      for (var y = 0; y < _gridRows; y++) {
        final img = _gridState[x][y];
        if (img != null && img.isNotEmpty) {
          roads.add(TunnelRoadData(gridX: x, gridY: y, img: img));
        }
      }
    }
    for (final road in _data.roads) {
      if (road.gridX < 0 ||
          road.gridX >= _gridCols ||
          road.gridY < 0 ||
          road.gridY >= _gridRows) {
        roads.add(road);
      }
    }
    _data = TunnelDefendModuleData(
      roads: roads,
      brickMapIndex: _data.brickMapIndex,
      tunnelSequenceInterval: _data.tunnelSequenceInterval,
    );
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _handleGridClick(int x, int y) {
    final current = _gridState[x][y];
    if (current == _selectedImg) {
      _gridState[x][y] = null;
    } else {
      _gridState[x][y] = _selectedImg;
    }
    _sync();
  }

  Future<void> _requestClearAll() async {
    if (_data.roads.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n?.tunnelDefendClearConfirmTitle ?? 'Clear all tunnel components?',
        ),
        content: Text(
          l10n?.tunnelDefendClearConfirmMessage ??
              'Remove all placed tunnel components from the grid. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
              foregroundColor: Theme.of(ctx).colorScheme.onError,
            ),
            child: Text(l10n?.tunnelDefendClearAll ?? 'Clear all'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) _clearAll();
  }

  void _clearAll() {
    for (var x = 0; x < _gridCols; x++) {
      for (var y = 0; y < _gridRows; y++) {
        _gridState[x][y] = null;
      }
    }
    _sync();
  }

  List<TunnelRoadData> get _roadsOutsideLawn => _data.roads
      .where(
        (r) =>
            r.gridX < 0 ||
            r.gridX >= _gridCols ||
            r.gridY < 0 ||
            r.gridY >= _gridRows,
      )
      .toList();

  bool get _isDefaultLawnSize => _gridRows == 5 && _gridCols == 9;

  String _roadDisplayName(String img) =>
      img.replaceAll('IMAGE_UI_MAUSOLEUM_TUNNEL_', '');

  Future<void> _requestDeleteOutsideLawn() async {
    final outside = _roadsOutsideLawn;
    if (outside.isEmpty) return;
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          l10n?.tunnelDefendDeleteOutsideConfirmTitle ??
              'Delete path elements outside lawn?',
        ),
        content: Text(
          l10n?.tunnelDefendDeleteOutsideConfirmMessage ??
              'Remove path elements that are outside the 5×9 lawn grid. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.black87,
            ),
            child: Text(
              l10n?.tunnelDefendDeleteOutside ??
                  'Delete path elements outside lawn',
            ),
          ),
        ],
      ),
    );
    if (ok == true && mounted) _deleteRoadsOutsideLawn();
  }

  void _deleteRoadsOutsideLawn() {
    final inside = _data.roads
        .where(
          (r) =>
              r.gridX >= 0 &&
              r.gridX < _gridCols &&
              r.gridY >= 0 &&
              r.gridY < _gridRows,
        )
        .toList();
    _data = TunnelDefendModuleData(
      roads: inside,
      brickMapIndex: _data.brickMapIndex,
      tunnelSequenceInterval: _data.tunnelSequenceInterval,
    );
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
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
    final gridBg = isDark ? const Color(0xFF3E2723) : const Color(0xFFEFEBE9);
    const gridBorder = Color(0xFF9E9E9E);

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
            icon: Icon(Icons.help_outline, color: gridBg),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () {
              showEditorHelpDialog(
                context,
                title: l10n?.tunnelDefendTitle ?? 'Tunnel defend',
                themeColor: accentColor,
                sections: [
                  HelpSectionData(
                    title: l10n?.overview ?? 'Overview',
                    body:
                        l10n?.tunnelDefendHelpOverview ??
                        'Add mausoleum tunnel paths. Some zombies and plants interact with tunnels.',
                  ),
                  HelpSectionData(
                    title: l10n?.tunnelDefendHelpUsage ?? 'Usage',
                    body:
                        l10n?.tunnelDefendHelpUsageBody ??
                        'Select a tunnel piece below, then tap the grid to place. Tap the same piece again to remove. Tap a different piece to replace.',
                  ),
                  HelpSectionData(
                    title:
                        l10n?.tunnelDefendHelpSequenceInterval ??
                        'Sequence interval',
                    body:
                        l10n?.tunnelDefendHelpSequenceIntervalBody ??
                        'Delay between tunnel sequence steps. Lower values make pathways appear faster.',
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
EditorAliasInputField(
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
              accentColor: accentColor,
            ),
            const SizedBox(height: 16),
            InputDecorator(
              decoration: InputDecoration(
                labelText:
                    l10n?.tunnelDefendTileStylePreset ?? 'Tile style preset',
                filled: true,
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  isExpanded: true,
                  value: _data.brickMapIndex == 2 ? 2 : 1,
                  items: [
                    DropdownMenuItem(
                      value: 1,
                      child: Text(l10n?.tunnelDefendTileStylePart1 ?? 'part 1'),
                    ),
                    DropdownMenuItem(
                      value: 2,
                      child: Text(l10n?.tunnelDefendTileStylePart2 ?? 'part 2'),
                    ),
                  ],
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() {
                      _data.brickMapIndex = v;
                      _moduleObj.objData = _data.toJson();
                    });
                    widget.onChanged();
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _sequenceIntervalCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText:
                    l10n?.tunnelDefendSequenceInterval ??
                    'Tunnel sequence interval (TunnelSequenceInterval, seconds)',
                filled: true,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                final parsed = double.tryParse(value);
                if (parsed != null && parsed >= 0) {
                  setState(() => _data.tunnelSequenceInterval = parsed);
                  _moduleObj.objData = _data.toJson();
                  widget.onChanged();
                }
              },
            ),
            const SizedBox(height: 16),
            scaleTableForDesktop(
              context: context,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 560),
                child: AspectRatio(
                  aspectRatio: _gridAspectRatio,
                  child: Container(
                    decoration: BoxDecoration(
                      color: gridBg,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: gridBorder, width: 1),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(5),
                      child: Column(
                        children: List.generate(_gridRows, (row) {
                          return Expanded(
                            child: Row(
                              children: List.generate(_gridCols, (col) {
                                final imgName = _gridState[col][row];
                                return Expanded(
                                  child: GestureDetector(
                                    onTap: () => _handleGridClick(col, row),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        border: Border.all(
                                          color: gridBorder.withValues(
                                            alpha: 0.5,
                                          ),
                                          width: 0.5,
                                        ),
                                      ),
                                      clipBehavior: Clip.hardEdge,
                                      child: imgName != null
                                          ? AssetImageWidget(
                                              assetPath:
                                                  'assets/images/tunnels/$imgName.webp',
                                              altCandidates: imageAltCandidates(
                                                'assets/images/tunnels/$imgName.webp',
                                              ),
                                              fit: BoxFit.contain,
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
            ),
            const SizedBox(height: 16),
            Card(
              color: gridBg,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${l10n?.tunnelDefendPlacedCount ?? 'Placed'}: ${_data.roads.length}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    FilledButton.icon(
                      onPressed: _data.roads.isEmpty ? null : _requestClearAll,
                      style: FilledButton.styleFrom(
                        backgroundColor: theme.colorScheme.error,
                        foregroundColor: theme.colorScheme.onError,
                      ),
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: Text(l10n?.tunnelDefendClearAll ?? 'Clear all'),
                    ),
                  ],
                ),
              ),
            ),
            if (_isDefaultLawnSize && _roadsOutsideLawn.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                color: gridBg,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: RichText(
                              text: TextSpan(
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                children: [
                                  TextSpan(
                                    text:
                                        l10n?.tunnelDefendPathOutsideLawn ??
                                        'Path elements outside of the lawn: ',
                                  ),
                                  TextSpan(
                                    text: _roadsOutsideLawn
                                        .map(
                                          (r) =>
                                              '${_roadDisplayName(r.img)} (R${r.gridY + 1}:C${r.gridX + 1})',
                                        )
                                        .join(', '),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: _requestDeleteOutsideLawn,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.amber.shade700,
                              foregroundColor: Colors.black87,
                            ),
                            icon: const Icon(Icons.delete_outline, size: 18),
                            label: Text(
                              l10n?.tunnelDefendDeleteOutside ??
                                  'Delete path elements outside lawn',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Card(
              color: gridBg,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.tunnelDefendSelectComponent ?? 'Select component',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: accentColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final cellWidth = 88.0;
                        const spacing = 12.0;
                        final cols =
                            (constraints.maxWidth / (cellWidth + spacing))
                                .floor()
                                .clamp(1, 999);
                        final rows = (_availableAssets.length / cols).ceil();
                        final heightNeeded = rows * _assetHeight;
                        final height =
                            (heightNeeded < 420 ? heightNeeded : 420.0)
                                .toDouble();
                        return SizedBox(
                          height: height,
                          child: GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithMaxCrossAxisExtent(
                                  maxCrossAxisExtent: 88,
                                  childAspectRatio: 0.75,
                                  crossAxisSpacing: 12,
                                  mainAxisSpacing: 12,
                                ),
                            itemCount: _availableAssets.length,
                            itemBuilder: (context, i) {
                              final asset = _availableAssets[i];
                              final isSelected = _selectedImg == asset;
                              return GestureDetector(
                                onTap: () {
                                  HapticFeedback.selectionClick();
                                  setState(() => _selectedImg = asset);
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? accentColor.withValues(alpha: 0.15)
                                        : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isSelected
                                          ? accentColor
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 4,
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: AssetImageWidget(
                                          assetPath:
                                              'assets/images/tunnels/$asset.webp',
                                          altCandidates: imageAltCandidates(
                                            'assets/images/tunnels/$asset.webp',
                                          ),
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Flexible(
                                        flex: 1,
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          alignment: Alignment.center,
                                          child: Text(
                                            asset.replaceAll(
                                              'IMAGE_UI_MAUSOLEUM_TUNNEL_',
                                              '',
                                            ),
                                            style: theme.textTheme.labelMedium
                                                ?.copyWith(
                                                  color: isSelected
                                                      ? accentColor
                                                      : theme
                                                            .colorScheme
                                                            .onSurface,
                                                ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                            textAlign: TextAlign.center,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
