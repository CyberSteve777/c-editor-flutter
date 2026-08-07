import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/portal_type_selector.dart';

/// Spawn modern portals event editor. Ported from Z-Editor-master ModernPortalEventEP.kt
class ModernPortalsEventScreen extends StatefulWidget {
  const ModernPortalsEventScreen({
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
  State<ModernPortalsEventScreen> createState() =>
      _ModernPortalsEventScreenState();
}

class _ModernPortalsEventScreenState extends State<ModernPortalsEventScreen> {
  static const _objClass = 'SpawnModernPortalsWaveActionProps';

  late PvzObject _moduleObj;
  late PortalEventData _data;
  late String _alias;

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
        objData: PortalEventData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = PortalEventData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = PortalEventData();
    }
  }

  void _sync() {
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);

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
              title: l10n?.eventTimeRift ?? 'Time rift event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpModernPortalsBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.portalType ?? 'Portal type',
                  body: l10n?.eventHelpModernPortalsType ?? '',
                ),
                HelpSectionData(
                  title: l10n?.ignoreGravestone ?? 'Ignore gravestone',
                  body: l10n?.eventHelpModernPortalsIgnore ?? '',
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                              Text(
                                l10n?.selectedPosition ?? 'Selected position',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              Text(
                                'R${_data.portalRow + 1} : C${_data.portalColumn + 1}',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      scaleTableForDesktop(
                        context: context,
                        child: Container(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: AspectRatio(
                            aspectRatio: _gridCols / _gridRows,
                            child: GridView.builder(
                              physics: const NeverScrollableScrollPhysics(),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: _gridCols,
                                    childAspectRatio: 1,
                                  ),
                              itemCount: _gridCols * _gridRows,
                              itemBuilder: (context, i) {
                                final col = i % _gridCols;
                                final row = i ~/ _gridCols;
                                final isSelected =
                                    row == _data.portalRow &&
                                    col == _data.portalColumn;
                                return GestureDetector(
                                  onTap: () {
                                    _data = PortalEventData(
                                      portalType: _data.portalType,
                                      portalColumn: col,
                                      portalRow: row,
                                      spawnEffect: _data.spawnEffect,
                                      spawnSoundID: _data.spawnSoundID,
                                      ignoreGraveStone: _data.ignoreGraveStone,
                                    );
                                    _sync();
                                  },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? theme.colorScheme.primary
                                          : theme
                                                .colorScheme
                                                .surfaceContainerHighest,
                                      border: Border.all(
                                        color: theme.colorScheme.outlineVariant,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Icon(
                                            Icons.check,
                                            color: theme.colorScheme.onPrimary,
                                            size: 16,
                                          )
                                        : null,
                                  ),
                                );
                              },
                            ),
                          ),
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
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.portalType ?? 'Portal type',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      PortalTypeChooserGrid(
                        selectedPortalType: _data.portalType,
                        onSelected: (def) {
                          _data = PortalEventData(
                            portalType: def.typeCode,
                            portalColumn: _data.portalColumn,
                            portalRow: _data.portalRow,
                            spawnEffect: _data.spawnEffect,
                            spawnSoundID: _data.spawnSoundID,
                            ignoreGraveStone: _data.ignoreGraveStone,
                          );
                          _sync();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: SwitchListTile(
                  title: Text(
                    l10n?.ignoreGravestone ??
                        'Ignore gravestone (IgnoreGraveStone)',
                  ),
                  subtitle: Text(
                    l10n?.ignoreGravestoneSubtitle ??
                        'Enable to spawn regardless of obstacles',
                  ),
                  value: _data.ignoreGraveStone,
                  onChanged: (v) {
                    _data = PortalEventData(
                      portalType: _data.portalType,
                      portalColumn: _data.portalColumn,
                      portalRow: _data.portalRow,
                      spawnEffect: _data.spawnEffect,
                      spawnSoundID: _data.spawnSoundID,
                      ignoreGraveStone: v,
                    );
                    _sync();
                  },
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
