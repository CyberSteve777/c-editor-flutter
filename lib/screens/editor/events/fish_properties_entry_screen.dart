import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/fish_type_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/fish_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';

/// Lawn grid for placing fishes. Row = Y, Column = X, both 0-based.
/// Grid size depends on stage (deep sea 6x10, otherwise 5x9).
class FishPropertiesEntryScreen extends StatefulWidget {
  const FishPropertiesEntryScreen({
    super.key,
    required this.levelFile,
    required this.fishes,
    required this.onChanged,
    required this.onBack,
    this.onEditCustomFish,
    this.onInjectCustomFish,
  });

  final PvzLevelFile levelFile;
  final List<FishSpawnData> fishes;
  final void Function(List<FishSpawnData>) onChanged;
  final VoidCallback onBack;
  final void Function(String rtid)? onEditCustomFish;
  final String? Function(String baseFishAlias)? onInjectCustomFish;

  @override
  State<FishPropertiesEntryScreen> createState() =>
      _FishPropertiesEntryScreenState();
}

class _FishPropertiesEntryScreenState extends State<FishPropertiesEntryScreen> {
  late List<FishSpawnData> _fishes;
  int _selectedCol = 0;
  int _selectedRow = 0;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
  int get _gridRows => _isDeepSeaLawn ? 6 : 5;
  int get _gridCols => _isDeepSeaLawn ? 10 : 9;

  @override
  void initState() {
    super.initState();
    _fishes = List<FishSpawnData>.from(widget.fishes);
  }

  void _sync() {
    widget.onChanged(_fishes);
    setState(() {});
  }

  List<FishSpawnData> _fishesAt(int col, int row) => _fishes
      .where((f) => f.position.mX == col && f.position.mY == row)
      .toList();

  bool _isCustomFish(FishSpawnData fish) {
    final info = RtidParser.parse(fish.type);
    return info?.source == 'CurrentLevel';
  }

  String _getBaseTypeName(FishSpawnData fish) {
    final info = RtidParser.parse(fish.type);
    final alias = info?.alias ?? fish.type;
    if (info?.source == 'CurrentLevel') {
      final obj = widget.levelFile.objects.firstWhereOrNull(
        (o) => o.aliases?.contains(alias) == true,
      );
      if (obj != null && obj.objClass == 'CreatureType' && obj.objData is Map) {
        return (obj.objData as Map)['TypeName'] as String? ?? alias;
      }
      return alias;
    }
    return FishTypeRepository().getFishByAlias(alias)?.typeName ?? alias;
  }

  void _addFishAt(int col, int row) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FishSelectionScreen(
          onFishSelected: (alias) {
            Navigator.pop(context);
            final rtid = FishTypeRepository().buildFishRtid(alias);
            _fishes = List<FishSpawnData>.from(_fishes)
              ..add(
                FishSpawnData(
                  type: rtid,
                  position: FishPositionData(mX: col, mY: row),
                ),
              );
            _sync();
          },
          onBack: () => Navigator.pop(context),
        ),
      ),
    );
  }

  List<_CustomFishOption> _findCompatibleCustomFishes(String baseType) {
    return widget.levelFile.objects
        .where((o) => o.objClass == 'CreatureType')
        .where((o) => o.aliases?.isNotEmpty == true)
        .map((o) {
          try {
            final data = o.objData;
            if (data is Map<String, dynamic> && data['TypeName'] == baseType) {
              final alias = o.aliases!.first;
              return _CustomFishOption(
                alias: alias,
                rtid: RtidParser.build(alias, 'CurrentLevel'),
              );
            }
          } catch (_) {}
          return null;
        })
        .whereType<_CustomFishOption>()
        .toList();
  }

  void _showCustomFishSwapDialog({
    required List<_CustomFishOption> options,
    required String currentRtid,
    required FishSpawnData fish,
    required int index,
  }) {
    final l10n = AppLocalizations.of(context);
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.selectCustomFish ?? 'Select custom fish'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: options.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final opt = options[i];
              final isCurrent = opt.rtid == currentRtid;
              return ListTile(
                title: Text(opt.alias),
                trailing: isCurrent
                    ? Text(
                        l10n?.current ?? 'Current',
                        style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                          color: Theme.of(ctx).colorScheme.primary,
                        ),
                      )
                    : null,
                onTap: () {
                  _fishes = List<FishSpawnData>.from(_fishes);
                  _fishes[index] = FishSpawnData(
                    type: opt.rtid,
                    position: fish.position,
                  );
                  _sync();
                  Navigator.pop(ctx);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
        ],
      ),
    );
  }

  void _removeFish(FishSpawnData fish) {
    _fishes = List<FishSpawnData>.from(_fishes)..remove(fish);
    _sync();
  }

  void _copyFish(FishSpawnData fish) {
    _fishes = List<FishSpawnData>.from(_fishes)
      ..add(
        FishSpawnData(
          type: fish.type,
          position: FishPositionData(mX: _selectedCol, mY: _selectedRow),
        ),
      );
    _sync();
  }

  String _fishDisplayName(FishSpawnData fish) {
    final typeName = _getBaseTypeName(fish);
    final nameKey = 'creature_$typeName';
    final name = ResourceNames.lookup(context, nameKey);
    return name != nameKey ? name : typeName;
  }

  String? _fishIconPath(FishSpawnData fish) {
    final info = RtidParser.parse(fish.type);
    final alias = info?.alias ?? fish.type;
    var fishInfo = FishTypeRepository().getFishByAlias(alias);
    if (fishInfo == null && info?.source == 'CurrentLevel') {
      final baseType = _getBaseTypeName(fish);
      fishInfo = FishTypeRepository().getFishByTypeName(baseType);
    }
    return fishInfo?.iconAssetPath;
  }

  void _showFishEditSheet(FishSpawnData fish, int fishIndex, int col, int row) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isCustom = _isCustomFish(fish);
    final baseType = _getBaseTypeName(fish);
    final compatibleCustom = _findCompatibleCustomFishes(
      baseType,
    ).where((opt) => opt.rtid != fish.type).toList();
    final canEditCustom = isCustom && widget.onEditCustomFish != null;
    final canMakeCustom = !isCustom && widget.onInjectCustomFish != null;
    final canSwitchCustom = compatibleCustom.isNotEmpty;
    final iconPath = _fishIconPath(fish);

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (iconPath != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AssetImageWidget(
                      assetPath: iconPath,
                      altCandidates: imageAltCandidates(iconPath),
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                    ),
                  ),
                if (iconPath != null) const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _fishDisplayName(fish),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (isCustom)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${l10n?.customLabel ?? 'Custom'}: ${RtidParser.parse(fish.type)?.alias ?? fish.type}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _copyFish(fish);
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.copy),
                    label: Text(l10n?.copy ?? 'Copy'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                    ),
                    onPressed: () {
                      _removeFish(fish);
                      Navigator.pop(ctx);
                    },
                    icon: const Icon(Icons.delete),
                    label: Text(l10n?.delete ?? 'Delete'),
                  ),
                ),
              ],
            ),
            if (canSwitchCustom || canEditCustom || canMakeCustom) ...[
              const SizedBox(height: 8),
              Builder(
                builder: (ctx) {
                  final isDark = Theme.of(ctx).brightness == Brightness.dark;
                  final primaryBlue = isDark
                      ? const Color(0xFF1976D2)
                      : const Color(0xFF42A5F5);
                  final secondaryBlue = isDark
                      ? const Color(0xFF1565C0)
                      : const Color(0xFF64B5F6);
                  return Row(
                    children: [
                      if (canSwitchCustom)
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              _showCustomFishSwapDialog(
                                options: compatibleCustom,
                                currentRtid: fish.type,
                                fish: fish,
                                index: fishIndex,
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: secondaryBlue,
                              side: BorderSide(color: secondaryBlue),
                            ),
                            icon: const Icon(Icons.swap_horiz),
                            label: Text(
                              '${l10n?.switchCustomFish ?? 'Switch'} (${compatibleCustom.length})',
                            ),
                          ),
                        ),
                      if (canSwitchCustom && (canEditCustom || canMakeCustom))
                        const SizedBox(width: 8),
                      if (canEditCustom)
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              widget.onEditCustomFish!(fish.type);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryBlue,
                            ),
                            icon: const Icon(Icons.edit),
                            label: Text(
                              l10n?.editCustomFishProperties ??
                                  'Edit properties',
                            ),
                          ),
                        )
                      else if (canMakeCustom)
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: () {
                              final newRtid = widget.onInjectCustomFish!(
                                baseType,
                              );
                              if (newRtid != null) {
                                _fishes = List<FishSpawnData>.from(_fishes);
                                _fishes[fishIndex] = FishSpawnData(
                                  type: newRtid,
                                  position: fish.position,
                                );
                                _sync();
                              }
                              Navigator.pop(ctx);
                            },
                            style: FilledButton.styleFrom(
                              backgroundColor: primaryBlue,
                            ),
                            icon: const Icon(Icons.build),
                            label: Text(
                              l10n?.makeFishAsCustom ?? 'Make custom',
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  List<FishSpawnData> get _fishesOutsideLawn => _fishes
      .where(
        (f) =>
            f.position.mX < 0 ||
            f.position.mY < 0 ||
            f.position.mX >= _gridCols ||
            f.position.mY >= _gridRows,
      )
      .toList();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final fishesAtSelected = _fishesAt(_selectedCol, _selectedRow);
    final fishesInBounds = fishesAtSelected
        .where(
          (f) =>
              f.position.mX >= 0 &&
              f.position.mY >= 0 &&
              f.position.mX < _gridCols &&
              f.position.mY < _gridRows,
        )
        .toList();
    final outsideLawn = _fishesOutsideLawn;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(
          l10n?.fishPropertiesGrid ?? 'Fish placement (row Y, column X)',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: true,
              title: l10n?.fishPropertiesGrid ?? 'Fish placement',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body:
                      l10n?.eventHelpZombieFishWaveFish ??
                      'Place fishes on the grid. Row = Y, Column = X. Grid size depends on stage (deep sea 6×10, otherwise 5×9).',
                ),
                HelpSectionData(
                  title: l10n?.fishAtPosition ?? 'Fish at position',
                  body:
                      l10n?.fishPropertiesEntryHelp ??
                      'Tap a grid cell to select it, then add fishes. Tap + to add built-in fish. Tap a fish card to copy, delete, switch custom variant, or make custom. Custom fishes show a blue "C" badge.',
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
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          l10n?.fishSelectedPosition ?? 'Selected:',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${l10n?.fishRow ?? "Row"}=$_selectedRow, ${l10n?.fishColumn ?? "Column"}=$_selectedCol',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    scaleTableForDesktop(
                      context: context,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 480),
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
                                    children: List.generate(_gridCols, (col) {
                                      final isSelected =
                                          row == _selectedRow &&
                                          col == _selectedCol;
                                      final cellFishes = _fishesAt(col, row);
                                      final first = cellFishes.firstOrNull;
                                      return Expanded(
                                        child: GestureDetector(
                                          onTap: () => setState(() {
                                            _selectedCol = col;
                                            _selectedRow = row;
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
                                            child:
                                                cellFishes.isNotEmpty &&
                                                    first != null
                                                ? LayoutBuilder(
                                                    builder: (
                                                      context,
                                                      constraints,
                                                    ) {
                                                      return Stack(
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
                                                                child: _FishIconSmall(
                                                                  iconPath:
                                                                      _fishIconPath(
                                                                        first,
                                                                      ),
                                                                  isCustom:
                                                                      _isCustomFish(
                                                                        first,
                                                                      ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          if (cellFishes
                                                                  .length >
                                                              1)
                                                            GridCellCountBadge(
                                                              label:
                                                                  '+${cellFishes.length - 1}',
                                                              cellWidth:
                                                                  constraints
                                                                      .maxWidth,
                                                            ),
                                                        ],
                                                      );
                                                    },
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${l10n?.fishAtPosition ?? "Fish at position"}:',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ...fishesInBounds.map((fish) {
                  final idx = _fishes.indexOf(fish);
                  return _FishIconCard(
                    fish: fish,
                    displayName: _fishDisplayName(fish),
                    iconPath: _fishIconPath(fish),
                    isCustom: _isCustomFish(fish),
                    onTap: () => _showFishEditSheet(
                      fish,
                      idx,
                      _selectedCol,
                      _selectedRow,
                    ),
                  );
                }),
                AddItemCard(
                  onPressed: () => _addFishAt(_selectedCol, _selectedRow),
                ),
              ],
            ),
            if (outsideLawn.isNotEmpty) ...[
              const SizedBox(height: 24),
              Row(
                children: [
                  Icon(
                    editorWarningIcon,
                    color: theme.colorScheme.error,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      l10n?.outsideLawnItems ?? 'Objects outside the lawn',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.error,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: outsideLawn.map((fish) {
                  final idx = _fishes.indexOf(fish);
                  return _FishIconCard(
                    fish: fish,
                    displayName: _fishDisplayName(fish),
                    iconPath: _fishIconPath(fish),
                    isCustom: _isCustomFish(fish),
                    showCoordinates: true,
                    gridCols: _gridCols,
                    gridRows: _gridRows,
                    onTap: () => _showFishEditSheet(
                      fish,
                      idx,
                      fish.position.mX,
                      fish.position.mY,
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _FishIconCard extends StatelessWidget {
  const _FishIconCard({
    required this.fish,
    required this.displayName,
    required this.iconPath,
    required this.isCustom,
    required this.onTap,
    this.showCoordinates = false,
    this.gridCols = 10,
    this.gridRows = 6,
  });

  final FishSpawnData fish;
  final String displayName;
  final String? iconPath;
  final bool isCustom;
  final VoidCallback onTap;
  final bool showCoordinates;
  final int gridCols;
  final int gridRows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final path = iconPath ?? 'assets/images/others/unknown.webp';
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: 100,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                child: Center(
                  child: FishIconCard(
                    iconPath: path,
                    isCustom: isCustom,
                    onTap: onTap,
                    size: 64,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 4, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
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
                              Icons.grid_on,
                              size: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${fish.position.mX},${fish.position.mY}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
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
      ),
    );
  }
}

class _CustomFishOption {
  const _CustomFishOption({required this.alias, required this.rtid});
  final String alias;
  final String rtid;
}

class _FishIconSmall extends StatelessWidget {
  const _FishIconSmall({required this.iconPath, required this.isCustom});

  final String? iconPath;
  final bool isCustom;

  @override
  Widget build(BuildContext context) {
    final path = iconPath ?? 'assets/images/others/unknown.webp';
    return SizedBox(
      width: 32,
      height: 32,
      child: Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: AssetImageWidget(
              assetPath: path,
              fit: BoxFit.cover,
              width: 32,
              height: 32,
              altCandidates: imageAltCandidates(path),
            ),
          ),
          if (isCustom)
            Positioned(
              top: 0,
              left: 0,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 0),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF1976D2)
                      : const Color(0xFF42A5F5),
                  borderRadius: const BorderRadius.only(
                    bottomRight: Radius.circular(4),
                  ),
                ),
                child: const Text(
                  'C',
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
