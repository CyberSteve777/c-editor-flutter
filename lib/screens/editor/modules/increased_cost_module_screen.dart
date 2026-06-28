import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/editor_components.dart'
    show editorInputDecoration;

/// Increased cost module editor. Ported from Z-Editor-master IncreasedCostModulePropertiesEP.kt
class IncreasedCostModuleScreen extends StatefulWidget {
  const IncreasedCostModuleScreen({
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
  State<IncreasedCostModuleScreen> createState() =>
      _IncreasedCostModuleScreenState();
}

class _IncreasedCostModuleScreenState extends State<IncreasedCostModuleScreen> {
  static const _objClass = 'IncreasedCostModuleProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late IncreasedCostModulePropertiesData _data;
  late TextEditingController _baseCostCtrl;
  late TextEditingController _maxCountCtrl;
  late FocusNode _baseCostFocusNode;
  late FocusNode _maxCountFocusNode;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
    _baseCostFocusNode = FocusNode();
    _maxCountFocusNode = FocusNode();
    _baseCostFocusNode.addListener(() => setState(() {}));
    _maxCountFocusNode.addListener(() => setState(() {}));
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
        objData: IncreasedCostModulePropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = IncreasedCostModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = IncreasedCostModulePropertiesData();
    }
    _baseCostCtrl = TextEditingController(text: '${_data.baseCostIncreased}');
    _maxCountCtrl = TextEditingController(text: '${_data.maxIncreasedCount}');
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  @override
  void dispose() {
    _baseCostFocusNode.dispose();
    _maxCountFocusNode.dispose();
    _baseCostCtrl.dispose();
    _maxCountCtrl.dispose();
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
                  AppLocalizations.of(context)?.inflationParams ??
                      'Inflation params',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  focusNode: _baseCostFocusNode,
                  controller: _baseCostCtrl,
                  keyboardType: TextInputType.number,
                  decoration: editorInputDecoration(
                    context,
                    labelText:
                        AppLocalizations.of(context)?.baseCostIncreaseLabel ??
                        'Base cost increase (BaseCostIncreased)',
                    focusColor: Theme.of(context).colorScheme.primary,
                    isFocused: _baseCostFocusNode.hasFocus,
                  ),
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null) {
                      _data.baseCostIncreased = n;
                      _sync();
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  focusNode: _maxCountFocusNode,
                  controller: _maxCountCtrl,
                  keyboardType: TextInputType.number,
                  decoration: editorInputDecoration(
                    context,
                    labelText:
                        AppLocalizations.of(context)?.maxIncreaseCountLabel ??
                        'Max increase count (MaxIncreasedCount)',
                    focusColor: Theme.of(context).colorScheme.primary,
                    isFocused: _maxCountFocusNode.hasFocus,
                  ),
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null) {
                      _data.maxIncreasedCount = n;
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
