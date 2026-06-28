import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Tidal change event editor. Ported from Z-Editor-master TidalChangeEventEP.kt
class TidalChangeEventScreen extends StatefulWidget {
  const TidalChangeEventScreen({
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
  State<TidalChangeEventScreen> createState() => _TidalChangeEventScreenState();
}

class _TidalChangeEventScreenState extends State<TidalChangeEventScreen> {
  static const _objClass = 'TidalChangeWaveActionProps';

  late PvzObject _moduleObj;
  late TidalChangeWaveActionData _data;
  late String _alias;

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
        objClass: _objClass,
        objData: TidalChangeWaveActionData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = TidalChangeWaveActionData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = TidalChangeWaveActionData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  bool _isCellInWater(int col) {
    final waterStartCol = _gridCols - _data.tidalChange.changeAmount;
    return col >= waterStartCol;
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
    final hasTideModule = widget.levelFile.objects.any(
      (o) => o.objClass == 'TideProperties',
    );

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
              title:
                  l10n?.eventTitle_TidalChangeWaveActionProps ??
                  'Tidal change event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body:
                      l10n?.eventHelpTidalChangeBody ??
                      'This event changes the tide position during a wave.',
                ),
                HelpSectionData(
                  title: l10n?.position ?? 'Position',
                  body:
                      l10n?.eventHelpTidalChangePosition ??
                      'Column 0 is rightmost, 9 is leftmost. ChangeAmount sets the water boundary.',
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
              if (!hasTideModule)
                Card(
                  color: theme.colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(editorErrorIcon, color: theme.colorScheme.error),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n?.missingTideModule ??
                                    'Missing tide module',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.error,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                l10n?.levelHasNoTideProperties ??
                                    'Level has no TideProperties. This event may not work.',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.error,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (!hasTideModule) const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.changePositionChangeAmount ??
                            'Change position (ChangeAmount)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _data.tidalChange.changeAmount.toString(),
                        decoration: InputDecoration(
                          labelText:
                              l10n?.waterBoundaryColumn ??
                              'Water boundary column',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) {
                            _data = TidalChangeWaveActionData(
                              tidalChange: TidalChangeInternalData(
                                changeAmount: n,
                                changeType: _data.tidalChange.changeType,
                              ),
                            );
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
                        l10n?.preview ?? 'Preview',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      AspectRatio(
                        aspectRatio: _gridCols / _gridRows,
                        child: Container(
                          decoration: BoxDecoration(
                            color: theme.brightness == Brightness.dark
                                ? const Color(0xFF2C2C2C)
                                : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: theme.colorScheme.outline,
                            ),
                          ),
                          child: Column(
                            children: List.generate(_gridRows, (row) {
                              return Expanded(
                                child: Row(
                                  children: List.generate(_gridCols, (col) {
                                    final inWater = _isCellInWater(col);
                                    return Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.all(0.5),
                                        decoration: BoxDecoration(
                                          color: inWater
                                              ? theme.colorScheme.primary
                                                    .withValues(alpha: 0.6)
                                              : (theme.brightness ==
                                                        Brightness.dark
                                                    ? const Color(0xFF2C2C2C)
                                                    : Colors.white),
                                          border: Border.all(
                                            color: theme.colorScheme.outline
                                                .withValues(alpha: 0.5),
                                            width: 0.5,
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
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: 0.6,
                              ),
                              border: Border.all(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n?.water ?? 'Water',
                            style: theme.textTheme.bodySmall,
                          ),
                          const SizedBox(width: 24),
                          Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? const Color(0xFF2C2C2C)
                                  : Colors.white,
                              border: Border.all(
                                color: theme.colorScheme.outline,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            l10n?.land ?? 'Land',
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n?.eventHelpTidalChangePosition ??
                              'Column 0 is rightmost, 9 is leftmost.',
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
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
}
