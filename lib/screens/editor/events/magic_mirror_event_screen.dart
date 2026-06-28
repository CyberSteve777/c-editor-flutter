import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Magic mirror event editor. Ported from Z-Editor-master MagicMirrorEventEP.kt
class MagicMirrorEventScreen extends StatefulWidget {
  const MagicMirrorEventScreen({
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
  State<MagicMirrorEventScreen> createState() => _MagicMirrorEventScreenState();
}

class _MagicMirrorEventScreenState extends State<MagicMirrorEventScreen> {
  static const _objClass = 'MagicMirrorWaveActionProps';

  late PvzObject _moduleObj;
  late MagicMirrorWaveActionData _data;
  late String _alias;
  int _selectedIndex = 0;
  bool _isEditingMirror2 = false;

  bool get _isDeepSeaLawn {
    final parsed = LevelParser.parseLevel(widget.levelFile);
    return LevelParser.isDeepSeaLawn(parsed.levelDef, widget.levelFile);
  }

  int get _gridCols => _isDeepSeaLawn ? 10 : 9;
  int get _gridRows => _isDeepSeaLawn ? 6 : 5;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  int _clampCol(int x) => x.clamp(0, _gridCols - 1);
  int _clampRow(int y) => y.clamp(0, _gridRows - 1);

  bool _isOutOfLawn(int x, int y) =>
      x < 0 || x >= _gridCols || y < 0 || y >= _gridRows;

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
        objClass: _objClass,
        objData: MagicMirrorWaveActionData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = MagicMirrorWaveActionData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
      _data = MagicMirrorWaveActionData(
        arrays: _data.arrays
            .map(
              (a) => MagicMirrorArrayData(
                mirror1GridX: _clampCol(a.mirror1GridX),
                mirror1GridY: _clampRow(a.mirror1GridY),
                mirror2GridX: _clampCol(a.mirror2GridX),
                mirror2GridY: _clampRow(a.mirror2GridY),
                typeIndex: a.typeIndex,
                mirrorExistDuration: a.mirrorExistDuration,
              ),
            )
            .toList(),
      );
    } catch (_) {
      _data = MagicMirrorWaveActionData();
    }
    if (_data.arrays.isEmpty) {
      _data = MagicMirrorWaveActionData(
        arrays: [
          MagicMirrorArrayData(
            mirror1GridX: 2,
            mirror1GridY: 2,
            mirror2GridX: 6,
            mirror2GridY: 2,
            typeIndex: null,
            mirrorExistDuration: 300,
          ),
        ],
      );
      _moduleObj.objData = _data.toJson();
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          widget.onChanged();
          setState(() {});
        }
      });
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _updateArray(int index, MagicMirrorArrayData arr) {
    final arrays = List<MagicMirrorArrayData>.from(_data.arrays);
    if (index < arrays.length) {
      arrays[index] = arr;
      _data = MagicMirrorWaveActionData(arrays: arrays);
      _sync();
    }
  }

  void _addArray() {
    _data = MagicMirrorWaveActionData(
      arrays: [
        ..._data.arrays,
        MagicMirrorArrayData(
          mirror1GridX: 2,
          mirror1GridY: 2,
          mirror2GridX: 6,
          mirror2GridY: 2,
          typeIndex: null,
          mirrorExistDuration: 300,
        ),
      ],
    );
    _selectedIndex = _data.arrays.length - 1;
    _sync();
  }

  void _removeArray(int index) {
    if (_data.arrays.length <= 1) return;
    final arrays = List<MagicMirrorArrayData>.from(_data.arrays)
      ..removeAt(index);
    _data = MagicMirrorWaveActionData(arrays: arrays);
    if (_selectedIndex >= arrays.length) _selectedIndex = arrays.length - 1;
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
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);
    final currentArray = _data.arrays.elementAtOrNull(_selectedIndex);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: eventTitle,
          isEvent: true,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              title: l10n?.eventMagicMirror ?? 'Magic mirror event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpMagicMirrorBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.typeIndex ?? 'Type index',
                  body: l10n?.eventHelpMagicMirrorType ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
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
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _data.arrays.length + 1,
                  separatorBuilder: (_, _) => const SizedBox(width: 8),
                  itemBuilder: (context, index) {
                    if (index == _data.arrays.length) {
                      return OutlinedButton.icon(
                        onPressed: _addArray,
                        icon: const Icon(Icons.add),
                        label: Text(l10n?.add ?? 'Add'),
                      );
                    }
                    final selected = index == _selectedIndex;
                    return FilterChip(
                      label: Text(
                        l10n?.groupN(index + 1) ?? 'Group ${index + 1}',
                      ),
                      selected: selected,
                      onSelected: (_) => setState(() => _selectedIndex = index),
                      deleteIcon: const Icon(Icons.close),
                      onDeleted: _data.arrays.length > 1
                          ? () => _removeArray(index)
                          : null,
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              if (currentArray != null) ...[
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n?.groupConfigN(_selectedIndex + 1) ??
                              'Group ${_selectedIndex + 1} config',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<int?>(
                          initialValue:
                              [null, 1, 2, 3].contains(currentArray.typeIndex)
                              ? currentArray.typeIndex
                              : null,
                          decoration: InputDecoration(
                            labelText: l10n?.typeIndex ?? 'Type index',
                            border: const OutlineInputBorder(),
                          ),
                          items: [
                            DropdownMenuItem<int?>(
                              value: null,
                              child: Text(l10n?.noStyle ?? 'No style'),
                            ),
                            ...([1, 2, 3].map(
                              (i) => DropdownMenuItem<int?>(
                                value: i,
                                child: Text(l10n?.styleN(i) ?? 'Style $i'),
                              ),
                            )),
                          ],
                          onChanged: (v) {
                            _updateArray(
                              _selectedIndex,
                              MagicMirrorArrayData(
                                mirror1GridX: currentArray.mirror1GridX,
                                mirror1GridY: currentArray.mirror1GridY,
                                mirror2GridX: currentArray.mirror2GridX,
                                mirror2GridY: currentArray.mirror2GridY,
                                typeIndex: v,
                                mirrorExistDuration:
                                    currentArray.mirrorExistDuration,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          initialValue: currentArray.mirrorExistDuration
                              .toString(),
                          decoration: InputDecoration(
                            labelText:
                                l10n?.existDurationSec ??
                                'Exist duration (sec)',
                            border: const OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (v) {
                            final n = int.tryParse(v);
                            if (n != null) {
                              _updateArray(
                                _selectedIndex,
                                MagicMirrorArrayData(
                                  mirror1GridX: currentArray.mirror1GridX,
                                  mirror1GridY: currentArray.mirror1GridY,
                                  mirror2GridX: currentArray.mirror2GridX,
                                  mirror2GridY: currentArray.mirror2GridY,
                                  typeIndex: currentArray.typeIndex,
                                  mirrorExistDuration: n,
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),
                        SegmentedButton<bool>(
                          segments: [
                            ButtonSegment(
                              value: false,
                              label: Text(l10n?.mirror1 ?? 'Mirror 1'),
                              icon: const Icon(Icons.login),
                            ),
                            ButtonSegment(
                              value: true,
                              label: Text(l10n?.mirror2 ?? 'Mirror 2'),
                              icon: const Icon(Icons.logout),
                            ),
                          ],
                          selected: {_isEditingMirror2},
                          onSelectionChanged: (s) =>
                              setState(() => _isEditingMirror2 = s.first),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            if (_isOutOfLawn(
                              currentArray.mirror1GridX,
                              currentArray.mirror1GridY,
                            ))
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  editorWarningIcon,
                                  color: editorWarningBannerForeground(
                                    theme.brightness,
                                  ),
                                  size: 20,
                                ),
                              ),
                            Text(
                              'M1: R${currentArray.mirror1GridY + 1}:C${currentArray.mirror1GridX + 1}',
                              style: theme.textTheme.bodySmall,
                            ),
                            const Text('  |  '),
                            if (_isOutOfLawn(
                              currentArray.mirror2GridX,
                              currentArray.mirror2GridY,
                            ))
                              Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Icon(
                                  editorWarningIcon,
                                  color: editorWarningBannerForeground(
                                    theme.brightness,
                                  ),
                                  size: 20,
                                ),
                              ),
                            Text(
                              'M2: R${currentArray.mirror2GridY + 1}:C${currentArray.mirror2GridX + 1}',
                              style: theme.textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _buildGrid(theme, currentArray),
              ] else
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Text(
                      l10n?.addMirrorGroup ?? 'Add a mirror group above',
                    ),
                  ),
                ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(ThemeData theme, MagicMirrorArrayData currentArray) {
    return scaleTableForDesktop(
      context: context,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: AspectRatio(
          aspectRatio: _gridCols / _gridRows,
          child: Container(
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: theme.dividerColor),
            ),
            child: Column(
              children: List.generate(_gridRows, (row) {
                return Expanded(
                  child: Row(
                    children: List.generate(_gridCols, (col) {
                      final isTarget = _isEditingMirror2
                          ? col == currentArray.mirror2GridX &&
                                row == currentArray.mirror2GridY
                          : col == currentArray.mirror1GridX &&
                                row == currentArray.mirror1GridY;
                      final mirrorsInCell =
                          _data.arrays.indexed
                              .where((e) {
                                final arr = e.$2;
                                return (arr.mirror1GridX == col &&
                                        arr.mirror1GridY == row) ||
                                    (arr.mirror2GridX == col &&
                                        arr.mirror2GridY == row);
                              })
                              .map((e) => (e.$1, e.$2.typeIndex))
                              .toList()
                            ..sort(
                              (a, b) => a.$1 == _selectedIndex
                                  ? 1
                                  : b.$1 == _selectedIndex
                                  ? -1
                                  : a.$1.compareTo(b.$1),
                            );
                      return Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_isEditingMirror2) {
                              _updateArray(
                                _selectedIndex,
                                MagicMirrorArrayData(
                                  mirror1GridX: currentArray.mirror1GridX,
                                  mirror1GridY: currentArray.mirror1GridY,
                                  mirror2GridX: col,
                                  mirror2GridY: row,
                                  typeIndex: currentArray.typeIndex,
                                  mirrorExistDuration:
                                      currentArray.mirrorExistDuration,
                                ),
                              );
                            } else {
                              _updateArray(
                                _selectedIndex,
                                MagicMirrorArrayData(
                                  mirror1GridX: col,
                                  mirror1GridY: row,
                                  mirror2GridX: currentArray.mirror2GridX,
                                  mirror2GridY: currentArray.mirror2GridY,
                                  typeIndex: currentArray.typeIndex,
                                  mirrorExistDuration:
                                      currentArray.mirrorExistDuration,
                                ),
                              );
                            }
                          },
                          child: Container(
                            margin: const EdgeInsets.all(0.5),
                            decoration: BoxDecoration(
                              color: isTarget
                                  ? theme.colorScheme.primaryContainer
                                  : null,
                              border: Border.all(
                                color: isTarget
                                    ? theme.colorScheme.primary
                                    : theme.dividerColor,
                                width: isTarget ? 1 : 0.5,
                              ),
                            ),
                            clipBehavior: Clip.hardEdge,
                            child: mirrorsInCell.isEmpty
                                ? null
                                : Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      for (final e in mirrorsInCell)
                                        Positioned.fill(
                                          child: Opacity(
                                            opacity: e.$1 == _selectedIndex
                                                ? 1.0
                                                : 0.5,
                                            child: AssetImageWidget(
                                              assetPath: e.$2 == null
                                                  ? 'assets/images/griditems/magic_mirror.webp'
                                                  : 'assets/images/griditems/magic_mirror${e.$2}.png',
                                              fit: BoxFit.cover,
                                              altCandidates: imageAltCandidates(
                                                e.$2 == null
                                                    ? 'assets/images/griditems/magic_mirror.webp'
                                                    : 'assets/images/griditems/magic_mirror${e.$2}.png',
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
    );
  }
}
