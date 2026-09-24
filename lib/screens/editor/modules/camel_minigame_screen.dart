import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

class CamelMinigameScreen extends StatefulWidget {
  const CamelMinigameScreen({
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
  State<CamelMinigameScreen> createState() => _CamelMinigameScreenState();
}

class _CamelMinigameScreenState extends State<CamelMinigameScreen> {
  static const _objClass = 'CamelMinigameProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late CamelMinigamePropertiesData _data;

  late TextEditingController _xBufferController;
  late TextEditingController _riseStaggerController;
  late TextEditingController _cardMatchController;
  late TextEditingController _cardMatchingController;
  late TextEditingController _cardNoMatchController;
  late TextEditingController _tutorialRiseController;
  late TextEditingController _maxSpawnXController;
  late TextEditingController _minSpawnXStartController;
  late TextEditingController _minSpawnXEndController;

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
        objData: CamelMinigamePropertiesData().toJson(),
      ),
    );
    try {
      _data = CamelMinigamePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = CamelMinigamePropertiesData();
    }
    _xBufferController = TextEditingController(
      text: _fmt(_data.additionalXBufferBetweenChains),
    );
    _riseStaggerController = TextEditingController(
      text: _fmt(_data.riseStaggerBetweenCamels),
    );
    _cardMatchController = TextEditingController(
      text: _fmt(_data.cardMatchTime),
    );
    _cardMatchingController = TextEditingController(
      text: _fmt(_data.cardMatchingTime),
    );
    _cardNoMatchController = TextEditingController(
      text: _fmt(_data.cardNoMatchTime),
    );
    _tutorialRiseController = TextEditingController(
      text: _fmt(_data.tutorialZombieRiseDelay),
    );
    _maxSpawnXController = TextEditingController(
      text: _fmt(_data.maxSpawnX),
    );
    _minSpawnXStartController = TextEditingController(
      text: _fmt(_data.minSpawnXStart),
    );
    _minSpawnXEndController = TextEditingController(
      text: _fmt(_data.minSpawnXEnd),
    );
  }

  String _fmt(double v) {
    if (v == v.roundToDouble()) return '${v.toInt()}';
    return '$v';
  }

  @override
  void dispose() {
    _xBufferController.dispose();
    _riseStaggerController.dispose();
    _cardMatchController.dispose();
    _cardMatchingController.dispose();
    _cardNoMatchController.dispose();
    _tutorialRiseController.dispose();
    _maxSpawnXController.dispose();
    _minSpawnXStartController.dispose();
    _minSpawnXEndController.dispose();
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

  void _parseDouble(String value, void Function(double) assign) {
    final n = double.tryParse(value.trim());
    if (n != null) {
      assign(n);
      _sync();
    }
  }

  Widget _doubleField({
    required String label,
    required TextEditingController controller,
    required void Function(double) onParsed,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: EditorResponsiveInputField(
        label: label,
        decoration: const InputDecoration(border: OutlineInputBorder()),
        builder: (context, decoration) => TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: decoration,
          onChanged: (v) => _parseDouble(v, onParsed),
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
              title: l10n.moduleTitle_CamelMinigameProperties,
              sections: [
                HelpSectionData(
                  title: l10n.overview,
                  body: l10n.moduleHelpCamelOverviewBody,
                ),
                HelpSectionData(
                  title: l10n.camelCardMatchTime,
                  body: l10n.moduleHelpCamelTimingsBody,
                ),
                HelpSectionData(
                  title: l10n.camelMaxSpawnX,
                  body: l10n.moduleHelpCamelSpawningBody,
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
                      l10n.moduleTitle_CamelMinigameProperties,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _doubleField(
                      label: l10n.camelAdditionalXBuffer,
                      controller: _xBufferController,
                      onParsed: (v) =>
                          _data.additionalXBufferBetweenChains = v,
                    ),
                    _doubleField(
                      label: l10n.camelRiseStagger,
                      controller: _riseStaggerController,
                      onParsed: (v) => _data.riseStaggerBetweenCamels = v,
                    ),
                    _doubleField(
                      label: l10n.camelCardMatchTime,
                      controller: _cardMatchController,
                      onParsed: (v) => _data.cardMatchTime = v,
                    ),
                    _doubleField(
                      label: l10n.camelCardMatchingTime,
                      controller: _cardMatchingController,
                      onParsed: (v) => _data.cardMatchingTime = v,
                    ),
                    _doubleField(
                      label: l10n.camelCardNoMatchTime,
                      controller: _cardNoMatchController,
                      onParsed: (v) => _data.cardNoMatchTime = v,
                    ),
                    _doubleField(
                      label: l10n.camelTutorialRiseDelay,
                      controller: _tutorialRiseController,
                      onParsed: (v) => _data.tutorialZombieRiseDelay = v,
                    ),
                    _doubleField(
                      label: l10n.camelMaxSpawnX,
                      controller: _maxSpawnXController,
                      onParsed: (v) => _data.maxSpawnX = v,
                    ),
                    _doubleField(
                      label: l10n.camelMinSpawnXStart,
                      controller: _minSpawnXStartController,
                      onParsed: (v) => _data.minSpawnXStart = v,
                    ),
                    _doubleField(
                      label: l10n.camelMinSpawnXEnd,
                      controller: _minSpawnXEndController,
                      onParsed: (v) => _data.minSpawnXEnd = v,
                    ),
                    Text(
                      l10n.camelCardTypesUsed,
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (var type = 1; type <= 7; type++)
                          FilterChip(
                            label: Text('$type'),
                            selected: _data.cardTypesUsed.contains(type),
                            onSelected: (selected) {
                              if (selected) {
                                if (!_data.cardTypesUsed.contains(type)) {
                                  _data.cardTypesUsed.add(type);
                                  _data.cardTypesUsed.sort();
                                }
                              } else {
                                _data.cardTypesUsed.remove(type);
                              }
                              _sync();
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.camelShowTutorial),
                      value: _data.showTutorial,
                      onChanged: (value) {
                        _data.showTutorial = value;
                        _sync();
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
