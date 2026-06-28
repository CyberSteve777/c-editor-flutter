import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
EditorAliasInputField(
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
            ),
            const SizedBox(height: 16),
                Text(
                  'Params',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _stopColCtrl,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Stop column (StopColumn)',
                    border: OutlineInputBorder(),
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
                  decoration: const InputDecoration(
                    labelText: 'Speed up (SpeedUp)',
                    border: OutlineInputBorder(),
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
