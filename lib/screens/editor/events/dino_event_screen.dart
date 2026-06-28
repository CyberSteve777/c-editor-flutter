import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Dino event editor. Ported from Z-Editor-master DinoEventEP.kt
class DinoEventScreen extends StatefulWidget {
  const DinoEventScreen({
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
  State<DinoEventScreen> createState() => _DinoEventScreenState();
}

class _DinoEventScreenState extends State<DinoEventScreen> {
  static const _objClass = 'DinoWaveActionProps';

  late PvzObject _moduleObj;
  late DinoWaveActionPropsData _data;
  late String _alias;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
  int get _maxRowIndex => _isDeepSeaLawn ? 5 : 4;

  static const _dinoTypeIds = ['raptor', 'stego', 'ptero', 'tyranno', 'ankylo'];

  String _dinoTypeLabel(BuildContext context, String typeId) {
    final key = 'dinoType_$typeId';
    final localized = ResourceNames.lookup(context, key);
    return localized != key ? localized : typeId;
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
        objClass: _objClass,
        objData: DinoWaveActionPropsData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = DinoWaveActionPropsData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = DinoWaveActionPropsData();
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
              title: l10n?.eventDino ?? 'Dino event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpDinoBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.dinoType ?? 'Dinosaur type',
                  body: l10n?.eventHelpDinoType ?? '',
                ),
                HelpSectionData(
                  title: l10n?.dinoRowTitle ?? 'Row',
                  body: l10n?.eventHelpDinoRow ?? '',
                ),
                HelpSectionData(
                  title: l10n?.dinoWaveDuration ?? 'Stay duration',
                  body:
                      l10n?.eventHelpDinoWaveDuration ??
                      l10n?.eventHelpDinoDuration ??
                      '',
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
                          Icon(Icons.pets, color: theme.colorScheme.secondary),
                          const SizedBox(width: 8),
                          Text(
                            l10n?.dinoType ?? 'Dinosaur type',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField<String>(
                        initialValue: _dinoTypeIds.contains(_data.dinoType)
                            ? _data.dinoType
                            : null,
                        decoration: InputDecoration(
                          labelText: l10n?.dinoType ?? 'Dinosaur type',
                          border: const OutlineInputBorder(),
                        ),
                        items: _dinoTypeIds
                            .map(
                              (id) => DropdownMenuItem(
                                value: id,
                                child: Text(_dinoTypeLabel(context, id)),
                              ),
                            )
                            .toList(),
                        onChanged: (v) {
                          if (v != null) {
                            _data = DinoWaveActionPropsData(
                              dinoRow: _data.dinoRow,
                              dinoType: v,
                              dinoWaveDuration: _data.dinoWaveDuration,
                            );
                            _sync();
                          }
                        },
                      ),

                      const SizedBox(height: 16),

                      Center(
                        child: Container(
                          width: 220,
                          height: 160,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: theme.colorScheme.secondary.withValues(
                                alpha: 0.3,
                              ),
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Image.asset(
                              'assets/images/others/dino_${_data.dinoType}.webp',
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) => const Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 48,
                                ),
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
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.positionAndDuration ?? 'Position & timing',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            l10n?.dinoRow(_data.dinoRow + 1) ??
                                'Row: ${_data.dinoRow + 1}',
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _data.dinoRow > 0
                                ? () {
                                    _data = DinoWaveActionPropsData(
                                      dinoRow: _data.dinoRow - 1,
                                      dinoType: _data.dinoType,
                                      dinoWaveDuration: _data.dinoWaveDuration,
                                    );
                                    _sync();
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _data.dinoRow < _maxRowIndex
                                ? () {
                                    _data = DinoWaveActionPropsData(
                                      dinoRow: _data.dinoRow + 1,
                                      dinoType: _data.dinoType,
                                      dinoWaveDuration: _data.dinoWaveDuration,
                                    );
                                    _sync();
                                  }
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _data.dinoWaveDuration.toString(),
                        decoration: InputDecoration(
                          labelText:
                              l10n?.dinoWaveDuration ?? 'Stay duration (waves)',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) {
                            _data = DinoWaveActionPropsData(
                              dinoRow: _data.dinoRow,
                              dinoType: _data.dinoType,
                              dinoWaveDuration: n,
                            );
                            _sync();
                          }
                        },
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
