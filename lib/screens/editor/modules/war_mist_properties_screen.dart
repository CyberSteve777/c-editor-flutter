import 'package:flutter/material.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
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
  late String _alias;
  late PvzObject _moduleObj;
  late WarMistPropertiesData _data;
  late TextEditingController _initPosController;
  late TextEditingController _normValController;
  late TextEditingController _bloverController;

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
        objClass: 'WarMistProperties',
        objData: WarMistPropertiesData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
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
          ],
        ),
      ),
    );
  }
}
