import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

class OakTrainScreen extends StatefulWidget {
  const OakTrainScreen({
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
  State<OakTrainScreen> createState() => _OakTrainScreenState();
}

class _OakTrainScreenState extends State<OakTrainScreen> {
  static const _objClass = 'OakTrainProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late OakTrainPropertiesData _data;

  late TextEditingController _totalLifeController;
  late TextEditingController _arrowScoreController;
  late TextEditingController _wizardScoreController;
  late TextEditingController _archmageScoreController;
  late TextEditingController _bossScoreController;
  late TextEditingController _healNumController;
  late TextEditingController _arrowPowerNumController;
  late TextEditingController _arrowMultipleNumController;
  late TextEditingController _initNormalController;
  late TextEditingController _initPowerController;
  late TextEditingController _initSplitController;
  late TextEditingController _initUnusedController;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    _moduleObj = widget.levelFile.objects.firstWhere(
      (object) => object.aliases?.contains(_alias) == true,
      orElse: () => PvzObject(
        aliases: [_alias],
        objClass: _objClass,
        objData: OakTrainPropertiesData().toJson(),
      ),
    );
    try {
      _data = OakTrainPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = OakTrainPropertiesData();
    }
    _totalLifeController = TextEditingController(text: '${_data.totalLife}');
    _arrowScoreController = TextEditingController(text: '${_data.arrowScore}');
    _wizardScoreController = TextEditingController(
      text: '${_data.wizardScore}',
    );
    _archmageScoreController = TextEditingController(
      text: '${_data.archmageScore}',
    );
    _bossScoreController = TextEditingController(text: '${_data.bossScore}');
    _healNumController = TextEditingController(text: '${_data.healNum}');
    _arrowPowerNumController = TextEditingController(
      text: '${_data.arrowPowerNum}',
    );
    _arrowMultipleNumController = TextEditingController(
      text: '${_data.arrowMultipleNum}',
    );
    _initNormalController = TextEditingController(
      text: '${_data.initArrowNormal}',
    );
    _initPowerController = TextEditingController(
      text: '${_data.initArrowPower}',
    );
    _initSplitController = TextEditingController(
      text: '${_data.initArrowSplit}',
    );
    _initUnusedController = TextEditingController(
      text: '${_data.initArrowUnused}',
    );
  }

  @override
  void dispose() {
    _totalLifeController.dispose();
    _arrowScoreController.dispose();
    _wizardScoreController.dispose();
    _archmageScoreController.dispose();
    _bossScoreController.dispose();
    _healNumController.dispose();
    _arrowPowerNumController.dispose();
    _arrowMultipleNumController.dispose();
    _initNormalController.dispose();
    _initPowerController.dispose();
    _initSplitController.dispose();
    _initUnusedController.dispose();
    super.dispose();
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

  void _parseInt(String value, void Function(int) assign) {
    final n = int.tryParse(value.trim());
    if (n != null && n >= 0) {
      assign(n);
      _sync();
    }
  }

  Widget _intField({
    required String label,
    required TextEditingController controller,
    required void Function(int) onParsed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: EditorResponsiveInputField(
        label: label,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        builder: (context, decoration) => TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: decoration,
          onChanged: (v) => _parseInt(v, onParsed),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

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
          tooltip: l10n.back,
          onPressed: widget.onBack,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n.tooltipAboutModule,
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n.moduleTitle_OakTrainProperties,
              sections: [
                HelpSectionData(
                  title: l10n.overview,
                  body: l10n.moduleHelpOakTrainOverviewBody,
                ),
                HelpSectionData(
                  title: l10n.oakTrainArrowScore,
                  body: l10n.moduleHelpOakTrainScoresBody,
                ),
                HelpSectionData(
                  title: l10n.oakTrainInitArrowsNum,
                  body: l10n.moduleHelpOakTrainArrowsBody,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ModuleAliasInputField(
              rtid: widget.rtid,
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      l10n.moduleTitle_OakTrainProperties,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _intField(
                      label: l10n.oakTrainTotalLife,
                      controller: _totalLifeController,
                      onParsed: (v) => _data.totalLife = v,
                    ),
                    _intField(
                      label: l10n.oakTrainArrowScore,
                      controller: _arrowScoreController,
                      onParsed: (v) => _data.arrowScore = v,
                    ),
                    _intField(
                      label: l10n.oakTrainWizardScore,
                      controller: _wizardScoreController,
                      onParsed: (v) => _data.wizardScore = v,
                    ),
                    _intField(
                      label: l10n.oakTrainArchmageScore,
                      controller: _archmageScoreController,
                      onParsed: (v) => _data.archmageScore = v,
                    ),
                    _intField(
                      label: l10n.oakTrainBossScore,
                      controller: _bossScoreController,
                      onParsed: (v) => _data.bossScore = v,
                    ),
                    _intField(
                      label: l10n.oakTrainHealNum,
                      controller: _healNumController,
                      onParsed: (v) => _data.healNum = v,
                    ),
                    _intField(
                      label: l10n.oakTrainArrowPowerNum,
                      controller: _arrowPowerNumController,
                      onParsed: (v) => _data.arrowPowerNum = v,
                    ),
                    _intField(
                      label: l10n.oakTrainArrowMultipleNum,
                      controller: _arrowMultipleNumController,
                      onParsed: (v) => _data.arrowMultipleNum = v,
                    ),
                    Text(
                      l10n.oakTrainInitArrowsNum,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 12),
                    _intField(
                      label: l10n.oakTrainInitArrowNormal,
                      controller: _initNormalController,
                      onParsed: (v) => _data.initArrowNormal = v,
                    ),
                    _intField(
                      label: l10n.oakTrainInitArrowPower,
                      controller: _initPowerController,
                      onParsed: (v) => _data.initArrowPower = v,
                    ),
                    _intField(
                      label: l10n.oakTrainInitArrowSplit,
                      controller: _initSplitController,
                      onParsed: (v) => _data.initArrowSplit = v,
                    ),
                    _intField(
                      label: l10n.oakTrainInitArrowUnused,
                      controller: _initUnusedController,
                      onParsed: (v) => _data.initArrowUnused = v,
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
