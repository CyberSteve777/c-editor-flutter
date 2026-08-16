import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Zombie move fast module editor. Ported from Z-Editor-master ZombieMoveFastModulePropertiesEP.kt
class ZombieMoveFastModuleScreen extends StatefulWidget {
  const ZombieMoveFastModuleScreen({
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
  State<ZombieMoveFastModuleScreen> createState() =>
      _ZombieMoveFastModuleScreenState();
}

class _ZombieMoveFastModuleScreenState
    extends State<ZombieMoveFastModuleScreen> {
  static const _objClass = 'ZombieMoveFastModuleProperties';
  static const _stopColumnField = 'StopColumn';
  static const _speedUpField = 'SpeedUp';
  late String _alias;
  late PvzObject _moduleObj;
  late ZombieMoveFastModulePropertiesData _data;
  late TextEditingController _stopColCtrl;
  late TextEditingController _speedUpCtrl;

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
        objClass: 'ZombieMoveFastModuleProperties',
        objData: ZombieMoveFastModulePropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = ZombieMoveFastModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = ZombieMoveFastModulePropertiesData();
    }
    _stopColCtrl = TextEditingController(text: '${_data.stopColumn}');
    _speedUpCtrl = TextEditingController(text: '${_data.speedUp}');
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  @override
  void dispose() {
    _stopColCtrl.dispose();
    _speedUpCtrl.dispose();
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
    final l10n = AppLocalizations.of(context);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title:
                  l10n?.moduleTitle_ZombieMoveFastModuleProperties ??
                  'Fast Entry',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body:
                      l10n?.moduleHelpZombieMoveFastBody ??
                      'Makes zombies move quickly as they enter the lawn, returning to normal speed after they reach the specified column. This module appears in the Zombie Elimination Initiative.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
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
                Text(
                  l10n?.parameters ?? 'Parameters',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _stopColCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: localizedPropertyLabel(
                      context,
                      l10n?.stopColumn ?? 'Stop Column',
                      _stopColumnField,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null) {
                      _data.stopColumn = n;
                      _sync();
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _speedUpCtrl,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: localizedPropertyLabel(
                      context,
                      l10n?.speedUp ?? 'Speed Multiplier',
                      _speedUpField,
                    ),
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    final n = double.tryParse(v);
                    if (n != null) {
                      _data.speedUp = n;
                      _sync();
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
