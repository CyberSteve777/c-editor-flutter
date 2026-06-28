import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Thunder wave event editor. Thunders can be positive or negative.
class ThunderWaveEventScreen extends StatefulWidget {
  const ThunderWaveEventScreen({
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
  State<ThunderWaveEventScreen> createState() => _ThunderWaveEventScreenState();
}

class _ThunderWaveEventScreenState extends State<ThunderWaveEventScreen> {
  static const _objClass = 'ThunderWaveActionProps';

  late PvzObject _moduleObj;
  late ThunderWaveActionPropsData _data;
  late String _alias;

  static const _typePositive = 'positive';
  static const _typeNegative = 'negative';

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
        objData: ThunderWaveActionPropsData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = ThunderWaveActionPropsData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = ThunderWaveActionPropsData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  String _typeLabel(String type, AppLocalizations? l10n) {
    switch (type) {
      case _typePositive:
        return l10n?.thunderWaveTypePositive ?? 'Positive';
      case _typeNegative:
        return l10n?.thunderWaveTypeNegative ?? 'Negative';
      default:
        return type;
    }
  }

  void _addThunder() {
    _data = ThunderWaveActionPropsData(
      thunders: [
        ..._data.thunders,
        ThunderEntryData(type: _typePositive),
      ],
      killRate: _data.killRate,
    );
    _sync();
  }

  void _removeThunder(int index) {
    final thunders = List<ThunderEntryData>.from(_data.thunders)
      ..removeAt(index);
    _data = ThunderWaveActionPropsData(
      thunders: thunders,
      killRate: _data.killRate,
    );
    _sync();
  }

  void _updateThunder(int index, ThunderEntryData entry) {
    final thunders = List<ThunderEntryData>.from(_data.thunders);
    thunders[index] = entry;
    _data = ThunderWaveActionPropsData(
      thunders: thunders,
      killRate: _data.killRate,
    );
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
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
              title: l10n?.eventThunderWave ?? 'Thunder event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpThunderWaveBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.thunderWaveHelpTypes ?? 'Thunder types',
                  body: l10n?.eventHelpThunderWaveTypes ?? '',
                ),
                HelpSectionData(
                  title: l10n?.thunderWaveHelpKillRate ?? 'Kill rate',
                  body: l10n?.eventHelpThunderWaveKillRate ?? '',
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
              // Kill rate
              Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.thunderWaveKillRate ?? 'Kill rate',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        key: const ValueKey('killRate'),
                        initialValue: _data.killRate.toString(),
                        decoration: InputDecoration(
                          hintText: '0.0 - 1.0',
                          border: const OutlineInputBorder(),
                          isDense: true,
                          helperText:
                              l10n?.thunderWaveKillRateHint ??
                              'Probability of killing plants on lightning strike (0.0–1.0)',
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (v) {
                          final rate = double.tryParse(v);
                          if (rate != null && rate >= 0 && rate <= 1) {
                            _data = ThunderWaveActionPropsData(
                              thunders: _data.thunders,
                              killRate: rate,
                            );
                            _sync();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Text(
                l10n?.thunderWaveThunders ?? 'Thunders',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              ...List.generate(_data.thunders.length, (i) {
                return _buildThunderCard(context, i, theme, l10n);
              }),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _addThunder,
                icon: const Icon(Icons.add),
                label: Text(l10n?.thunderWaveAddThunder ?? 'Add thunder'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThunderCard(
    BuildContext context,
    int index,
    ThemeData theme,
    AppLocalizations? l10n,
  ) {
    final entry = _data.thunders[index];

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(
              Icons.thunderstorm,
              color: entry.type == _typePositive ? Colors.blue : Colors.red,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${l10n?.thunderWaveThunder ?? 'Thunder'} ${index + 1}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: DropdownButtonFormField<String>(
                initialValue:
                    entry.type == _typePositive || entry.type == _typeNegative
                    ? entry.type
                    : _typePositive,
                items: [
                  DropdownMenuItem(
                    value: _typePositive,
                    child: Text(_typeLabel(_typePositive, l10n)),
                  ),
                  DropdownMenuItem(
                    value: _typeNegative,
                    child: Text(_typeLabel(_typeNegative, l10n)),
                  ),
                ],
                onChanged: (v) {
                  if (v != null) {
                    _updateThunder(index, ThunderEntryData(type: v));
                  }
                },
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  isDense: true,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () => _removeThunder(index),
            ),
          ],
        ),
      ),
    );
  }
}
