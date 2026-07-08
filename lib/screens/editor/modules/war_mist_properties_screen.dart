import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// War mist properties. Ported from Z-Editor-master WarMistPropertiesEP.kt
class WarMistPropertiesScreen extends StatefulWidget {
  const WarMistPropertiesScreen({
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
  State<WarMistPropertiesScreen> createState() =>
      _WarMistPropertiesScreenState();
}

class _WarMistPropertiesScreenState extends State<WarMistPropertiesScreen> {
  static const _objClass = 'WarMistProperties';
  static const _unitsPerTile = 64;

  late String _alias;
  late PvzObject _moduleObj;
  late WarMistPropertiesData _data;
  late TextEditingController _initPosController;
  late TextEditingController _normValController;
  late TextEditingController _bloverController;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
  int get _gridRows => _isDeepSeaLawn ? 6 : 5;
  int get _gridCols => _isDeepSeaLawn ? 10 : 9;

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
        objClass: 'WarMistProperties',
        objData: WarMistPropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = WarMistPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = WarMistPropertiesData();
    }
    _initPosController = TextEditingController(text: '${_data.initMistPosX}');
    _normValController = TextEditingController(text: '${_data.normValX}');
    _bloverController = TextEditingController(
      text: '${_data.bloverEffectInterval}',
    );
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  /// Horizontal fog coverage within [col], as a fraction of the cell width [0, 1].
  double _fogFillFractionForColumn(int col) {
    if (col < 0 || col >= _gridCols) return 0;

    final startUnit = _data.initMistPosX * _unitsPerTile;
    final endUnit = startUnit + _data.normValX;
    final colStart = col * _unitsPerTile;
    final colEnd = (col + 1) * _unitsPerTile;

    final overlapStart = startUnit > colStart ? startUnit : colStart;
    final overlapEnd = endUnit < colEnd ? endUnit : colEnd;
    if (overlapEnd <= overlapStart) return 0;

    return (overlapEnd - overlapStart) / _unitsPerTile;
  }

  Color _fogColor(bool isDark) {
    if (isDark) {
      return Color.lerp(Colors.white, Colors.grey, 0.45)!
          .withValues(alpha: 0.72);
    }
    return Color.lerp(const Color(0xFFBDBDBD), const Color(0xFF616161), 0.55)!
        .withValues(alpha: 0.72);
  }

  @override
  void dispose() {
    _initPosController.dispose();
    _normValController.dispose();
    _bloverController.dispose();
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
    final isDark = theme.brightness == Brightness.dark;
    final fogColor = _fogColor(isDark);
    return Scaffold(
      appBar: AppBar(
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ModuleAliasInputField(
              rtid: widget.rtid,
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
                      l10n?.mistParameters ?? 'Mist parameters',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _initPosController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            l10n?.initialMistPositionX ??
                            'Initial mist position X',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n >= 0) {
                          _data.initMistPosX = n;
                          _sync();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _normValController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: l10n?.normalValueX ?? 'Normal value X',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n >= 0) {
                          _data.normValX = n;
                          _sync();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _bloverController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText:
                            l10n?.bloverEffectInterval ??
                            'Blover effect interval (seconds)',
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n >= 0) {
                          _data.bloverEffectInterval = n;
                          _sync();
                        }
                      },
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.fogPreview ?? 'Fog preview',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    scaleTableForDesktop(
                      context: context,
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 480),
                        child: AspectRatio(
                          aspectRatio: _gridCols / _gridRows,
                          child: Container(
                            decoration: BoxDecoration(
                              color: isDark
                                  ? const Color(0xFF2A2A2A)
                                  : const Color(0xFFE8E8E8),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: theme.dividerColor),
                            ),
                            child: Column(
                              children: List.generate(_gridRows, (row) {
                                return Expanded(
                                  child: Row(
                                    children: List.generate(_gridCols, (col) {
                                      final fill = _fogFillFractionForColumn(
                                        col,
                                      );
                                      return Expanded(
                                        child: Container(
                                          margin: const EdgeInsets.all(0.5),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              color: theme.dividerColor,
                                              width: 0.5,
                                            ),
                                          ),
                                          child: fill > 0
                                              ? Align(
                                                  alignment:
                                                      Alignment.centerLeft,
                                                  child: FractionallySizedBox(
                                                    widthFactor: fill,
                                                    heightFactor: 1,
                                                    child: ColoredBox(
                                                      color: fogColor,
                                                    ),
                                                  ),
                                                )
                                              : null,
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
          ],
        ),
      ),
    );
  }
}
