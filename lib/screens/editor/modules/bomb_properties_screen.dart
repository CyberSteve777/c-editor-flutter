import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Bomb properties (barrel/cherry bomb fuze) editor.
class BombPropertiesScreen extends StatefulWidget {
  const BombPropertiesScreen({
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
  State<BombPropertiesScreen> createState() => _BombPropertiesScreenState();
}

class _BombPropertiesScreenState extends State<BombPropertiesScreen> {
  static const _objClass = 'BombProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late BombPropertiesData _data;
  late TextEditingController _flameSpeedCtrl;

  int get _expectedRowCount {
    final dims = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return dims.$1;
  }

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  @override
  void dispose() {
    _flameSpeedCtrl.dispose();
    super.dispose();
  }

  void _adjustFuseLengthsToRowCount() {
    final expected = _expectedRowCount;
    final current = _data.fuseLengths;
    if (current.length == expected) return;
    final adjusted = List<String>.from(current);
    while (adjusted.length < expected) {
      adjusted.add('8');
    }
    if (adjusted.length > expected) {
      adjusted.length = expected;
    }
    _data = BombPropertiesData(
      flameSpeed: _data.flameSpeed,
      fuseLengths: adjusted,
    );
    _moduleObj.objData = _data.toJson();
  }

  void _loadData() {
    final alias = _alias;
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: 'BombProperties',
        objData: BombPropertiesData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = BombPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = BombPropertiesData();
    }
    _adjustFuseLengthsToRowCount();
    // Defer onChanged to avoid setState during build (triggers parent _markDirty)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onChanged();
    });
    _flameSpeedCtrl = TextEditingController(text: _data.flameSpeed.toString());
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
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
            onPressed: () => showEditorHelpDialog(
              context,
              title: l10n?.bombProperties ?? 'Bomb properties',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.bombPropertiesHelpBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.bombPropertiesHelpFuse ?? 'Fuse lengths',
                  body: l10n?.bombPropertiesHelpFuseBody ?? '',
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
                      Text(
                        l10n?.bombPropertiesFlameSpeed ??
                            'Flame speed (FlameSpeed)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _flameSpeedCtrl,
                        decoration: const InputDecoration(
                          labelText: 'FlameSpeed',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (v) {
                          final n = double.tryParse(v);
                          if (n != null) {
                            _data = BombPropertiesData(
                              flameSpeed: n,
                              fuseLengths: _data.fuseLengths,
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
                        l10n?.bombPropertiesFuseLengths ??
                            'Fuse lengths (FuseLengths)',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n?.bombPropertiesFuseLengthsHint ??
                            'One value per row (0–4 standard, 0–5 Deep Sea). Array size auto-adjusts on open.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...List.generate(_data.fuseLengths.length, (i) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 80,
                                child: Text(
                                  l10n?.rowN(i + 1) ?? 'Row ${i + 1}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              Expanded(
                                child: TextFormField(
                                  key: ValueKey(
                                    'fuse_${i}_${_data.fuseLengths[i]}',
                                  ),
                                  initialValue: _data.fuseLengths[i],
                                  decoration: InputDecoration(
                                    labelText:
                                        l10n?.bombPropertiesFuseLength ??
                                        'Length',
                                    border: const OutlineInputBorder(),
                                  ),
                                  keyboardType: TextInputType.text,
                                  onChanged: (v) {
                                    final lengths = List<String>.from(
                                      _data.fuseLengths,
                                    );
                                    lengths[i] = v;
                                    _data = BombPropertiesData(
                                      flameSpeed: _data.flameSpeed,
                                      fuseLengths: lengths,
                                    );
                                    _sync();
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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
