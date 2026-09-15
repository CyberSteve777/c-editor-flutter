import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/theme/app_theme.dart'
    show pvzLightOrangeDark, pvzLightOrangeLight;
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/editor_components.dart'
    show
        EditorResponsiveInputField,
        HelpSectionData,
        editorInputDecoration,
        showEditorHelpDialog;

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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? pvzLightOrangeDark : pvzLightOrangeLight;

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
          foregroundColor: Colors.white,
        ),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n?.inflationHelpTitle ?? 'Inflation module',
              themeColor: accentColor,
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body:
                      l10n?.inflationHelpOverview ??
                      'Each time a plant is planted, its sun cost increases.',
                ),
                HelpSectionData(
                  title:
                      l10n?.inflationHelpParametersTitle ??
                      'Parameter description',
                  body:
                      l10n?.inflationHelpParametersBody ??
                      'Configure the sun cost increase per planting and the maximum number of increases.',
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
              ModuleAliasInputField(
                rtid: widget.rtid,
                alias: _alias,
                levelFile: widget.levelFile,
                onAliasChanged: _handleAliasChanged,
                onChanged: widget.onChanged,
                accentColor: accentColor,
              ),
              const SizedBox(height: 16),
              Card(
                key: const ValueKey('inflationParametersCard'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.inflationParams ?? 'Inflation parameters',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accentColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      EditorResponsiveInputField(
                        label:
                            l10n?.baseCostIncreaseLabel ??
                            'Cost increase per planting (BaseCostIncreased)',
                        decoration: editorInputDecoration(
                          context,
                          focusColor: accentColor,
                          isFocused: _baseCostFocusNode.hasFocus,
                        ),
                        builder: (context, decoration) => TextField(
                          key: const ValueKey('inflationBaseCostField'),
                          focusNode: _baseCostFocusNode,
                          controller: _baseCostCtrl,
                          keyboardType: TextInputType.number,
                          decoration: decoration,
                          onChanged: (v) {
                            final n = int.tryParse(v);
                            if (n != null) {
                              _data.baseCostIncreased = n;
                              _sync();
                            }
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      EditorResponsiveInputField(
                        label:
                            l10n?.maxIncreaseCountLabel ??
                            'Max increase count (MaxIncreasedCount)',
                        decoration: editorInputDecoration(
                          context,
                          focusColor: accentColor,
                          isFocused: _maxCountFocusNode.hasFocus,
                        ),
                        builder: (context, decoration) => TextField(
                          key: const ValueKey('inflationMaxCountField'),
                          focusNode: _maxCountFocusNode,
                          controller: _maxCountCtrl,
                          keyboardType: TextInputType.number,
                          decoration: decoration,
                          onChanged: (v) {
                            final n = int.tryParse(v);
                            if (n != null) {
                              _data.maxIncreasedCount = n;
                              _sync();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                key: const ValueKey('inflationLimitationCard'),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Icon(Icons.info_outline, color: accentColor, size: 28),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n?.inflationMaxIncreaseCountWarning ??
                              'Changing the maximum increase count currently has no effect; the game only reads the default value of 10.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: accentColor,
                            height: 1.4,
                          ),
                        ),
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
