import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Last stand minigame. Ported from Z-Editor-master LastStandMinigamePropertiesEP.kt
class LastStandMinigameScreen extends StatefulWidget {
  const LastStandMinigameScreen({
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
  State<LastStandMinigameScreen> createState() =>
      _LastStandMinigameScreenState();
}

class _LastStandMinigameScreenState extends State<LastStandMinigameScreen> {
  static const _objClass = 'LastStandMinigameProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late LastStandMinigamePropertiesData _data;
  late TextEditingController _sunController;
  late TextEditingController _plantfoodController;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: _objClass,
        objData: LastStandMinigamePropertiesData().toJson(),
      ),
    );
    try {
      _data = LastStandMinigamePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = LastStandMinigamePropertiesData();
    }
    _sunController = TextEditingController(text: '${_data.startingSun}');
    _plantfoodController = TextEditingController(
      text: '${_data.startingPlantfood}',
    );
  }

  void _save() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
  }

  @override
  void dispose() {
    _sunController.dispose();
    _plantfoodController.dispose();
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
                      'Initial resources',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _sunController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Starting sun',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n >= 0) {
                          _data.startingSun = n;
                          _save();
                        }
                      },
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _plantfoodController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Starting plant food',
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        final n = int.tryParse(v);
                        if (n != null && n >= 0) {
                          _data.startingPlantfood = n;
                          _save();
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
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Adding Last Stand enables manual start in wave manager.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
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
