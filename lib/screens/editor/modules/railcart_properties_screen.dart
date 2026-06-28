import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;

/// Railcart properties editor. Ported from Z-Editor-master RailcartPropertiesEP.kt
enum _RailEditMode { rails, carts }

class RailcartPropertiesScreen extends StatefulWidget {
  const RailcartPropertiesScreen({
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
  State<RailcartPropertiesScreen> createState() =>
      _RailcartPropertiesScreenState();
}

class _RailcartPropertiesScreenState extends State<RailcartPropertiesScreen> {
  static const _objClass = 'RailcartProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late RailcartPropertiesData _data;
  _RailEditMode _editMode = _RailEditMode.rails;
  late List<List<bool>> _railsGrid;
  late Set<String> _cartSet;

  late (int rows, int cols) _gridDims;

  int get _gridRows => _gridDims.$1;
  int get _gridCols => _gridDims.$2;

  static const _cartTypeOptions = [
    'railcart_cowboy',
    'railcart_future',
    'railcart_egypt',
    'railcart_pirate',
    'railcart_worldcup',
  ];
  static const _railsAssetPath = 'assets/images/others/rails.webp';
  static const _cartsAssetPath = 'assets/images/others/railcarts.webp';

  String _railcartDisplayName(BuildContext context, String codename) {
    final l10n = AppLocalizations.of(context);
    final name = switch (codename) {
      'railcart_cowboy' => l10n?.railcartCowboy ?? 'Cowboy',
      'railcart_future' => l10n?.railcartFuture ?? 'Future',
      'railcart_egypt' => l10n?.railcartEgypt ?? 'Egypt',
      'railcart_pirate' => l10n?.railcartPirate ?? 'Pirate',
      'railcart_worldcup' => l10n?.railcartWorldcup ?? 'World Cup',
      _ => codename,
    };
    return '$name ($codename)';
  }

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
        objClass: 'RailcartProperties',
        objData: RailcartPropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = RailcartPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = RailcartPropertiesData();
    }
    _gridDims = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    _railsGrid = List.generate(_gridCols, (_) => List.filled(_gridRows, false));
    for (final rail in _data.rails) {
      for (var r = rail.rowStart; r <= rail.rowEnd; r++) {
        if (rail.column >= 0 &&
            rail.column < _gridCols &&
            r >= 0 &&
            r < _gridRows) {
          _railsGrid[rail.column][r] = true;
        }
      }
    }
    _cartSet = _data.railcarts.map((c) => '${c.column},${c.row}').toSet();
  }

  void _sync() {
    final newRails = <RailData>[];
    for (var c = 0; c < _gridCols; c++) {
      int? start;
      for (var r = 0; r < _gridRows; r++) {
        final hasRail = _railsGrid[c][r];
        if (hasRail) {
          start ??= r;
        } else {
          if (start != null) {
            newRails.add(RailData(column: c, rowStart: start, rowEnd: r - 1));
            start = null;
          }
        }
      }
      if (start != null) {
        newRails.add(
          RailData(column: c, rowStart: start, rowEnd: _gridRows - 1),
        );
      }
    }
    final newCarts = _cartSet.map((s) {
      final parts = s.split(',');
      return RailcartData(
        column: int.tryParse(parts[0]) ?? 0,
        row: int.tryParse(parts[1]) ?? 0,
      );
    }).toList();
    _data = RailcartPropertiesData(
      railcartType: _data.railcartType,
      rails: newRails,
      railcarts: newCarts,
    );
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _handleGridClick(int col, int row) {
    if (_editMode == _RailEditMode.rails) {
      _railsGrid[col][row] = !_railsGrid[col][row];
    } else {
      final key = '$col,$row';
      if (_cartSet.contains(key)) {
        _cartSet.remove(key);
      } else {
        _cartSet.add(key);
      }
    }
    _sync();
  }

  bool _hasOutOfAreaWarning() {
    for (final r in _data.rails) {
      if (r.column < 0 ||
          r.column >= _gridCols ||
          r.rowStart < 0 ||
          r.rowEnd >= _gridRows) {
        return true;
      }
    }
    for (final c in _data.railcarts) {
      if (c.column < 0 ||
          c.column >= _gridCols ||
          c.row < 0 ||
          c.row >= _gridRows) {
        return true;
      }
    }
    return false;
  }

  bool _hasStageSwitchWarning() {
    if (_gridRows == 6) return false;
    for (final r in _data.rails) {
      if (r.rowEnd >= 5) return true;
    }
    for (final c in _data.railcarts) {
      if (c.row >= 5) return true;
    }
    return false;
  }

  void _clearAll() {
    for (var c = 0; c < _gridCols; c++) {
      for (var r = 0; r < _gridRows; r++) {
        _railsGrid[c][r] = false;
      }
    }
    _cartSet.clear();
    _sync();
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
    final isDark = theme.brightness == Brightness.dark;
    final gridColor = isDark
        ? const Color(0xFF503C34)
        : const Color(0xFFD7CCC8);
    final borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade400;

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
            if (_hasOutOfAreaWarning())
              EditorWarningBanner(
                margin: EdgeInsets.zero,
                message:
                    l10n?.warningObjectsOutsideArea(_gridRows, _gridCols) ??
                    'Some objects are outside the playable area ($_gridRows rows × $_gridCols cols).',
              ),
            if (_hasStageSwitchWarning())
              EditorWarningBanner(
                margin: EdgeInsets.zero,
                message:
                    l10n?.warningStageSwitchedTo5Rows ??
                    'Stage uses 5 rows but some data references row 6.',
              ),
            if (_hasOutOfAreaWarning() || _hasStageSwitchWarning())
              const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      key: ValueKey(_data.railcartType),
                      initialValue:
                          _cartTypeOptions.contains(_data.railcartType)
                          ? _data.railcartType
                          : _cartTypeOptions.first,
                      decoration: InputDecoration(
                        labelText: l10n?.railcartType ?? 'Railcart type',
                        border: const OutlineInputBorder(),
                      ),
                      items: _cartTypeOptions
                          .map(
                            (e) => DropdownMenuItem(
                              value: e,
                              child: Text(_railcartDisplayName(context, e)),
                            ),
                          )
                          .toList(),
                      onChanged: (v) {
                        if (v != null) {
                          _data = RailcartPropertiesData(
                            railcartType: v,
                            rails: _data.rails,
                            railcarts: _data.railcarts,
                          );
                          _sync();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    LayoutBuilder(
                      builder: (ctx, constraints) {
                        return Row(
                          children: [
                            Expanded(
                              child: _ModeChip(
                                icon: Icons.add_road,
                                label: l10n?.layRails ?? 'Lay rails',
                                selected: _editMode == _RailEditMode.rails,
                                onTap: () => setState(
                                  () => _editMode = _RailEditMode.rails,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ModeChip(
                                icon: Icons.inbox,
                                label: l10n?.placeCarts ?? 'Place carts',
                                selected: _editMode == _RailEditMode.carts,
                                onTap: () => setState(
                                  () => _editMode = _RailEditMode.carts,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            scaleTableForDesktop(
              context: context,
              desktopScale: 0.5,
              child: Container(
                decoration: BoxDecoration(
                  color: gridColor,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: borderColor),
                ),
                child: AspectRatio(
                  aspectRatio: _gridCols / _gridRows,
                  child: Column(
                    children: List.generate(_gridRows, (r) {
                      return Expanded(
                        child: Row(
                          children: List.generate(_gridCols, (c) {
                            final hasRail = _railsGrid[c][r];
                            final hasCart = _cartSet.contains('$c,$r');
                            return Expanded(
                              child: GestureDetector(
                                onTap: () => _handleGridClick(c, r),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border(
                                      right: BorderSide(
                                        color: borderColor,
                                        width: 0.5,
                                      ),
                                      bottom: BorderSide(
                                        color: borderColor,
                                        width: 0.5,
                                      ),
                                    ),
                                  ),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      if (hasRail)
                                        Positioned.fill(
                                          child: Opacity(
                                            opacity: 0.85,
                                            child: AssetImageWidget(
                                              assetPath: _railsAssetPath,
                                              altCandidates: imageAltCandidates(
                                                _railsAssetPath,
                                              ),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ),
                                      if (hasCart)
                                        Positioned.fill(
                                          child: Center(
                                            child: Transform.scale(
                                              scale: 0.9,
                                              child: AssetImageWidget(
                                                assetPath: _cartsAssetPath,
                                                altCandidates:
                                                    imageAltCandidates(
                                                      _cartsAssetPath,
                                                    ),
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
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
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${l10n?.railSegments ?? 'Rail segments'}: ${_data.rails.length}',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          '${l10n?.railcartCount ?? 'Railcart count'}: ${_data.railcarts.length}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    Flexible(
                      child: FilledButton.icon(
                        onPressed: _clearAll,
                        icon: const Icon(Icons.delete, size: 18),
                        label: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(l10n?.clearAll ?? 'Clear all'),
                        ),
                        style: FilledButton.styleFrom(
                          backgroundColor: theme.colorScheme.error,
                        ),
                      ),
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

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primary
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 18,
                color: selected
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: selected
                          ? theme.colorScheme.onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
