import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

class IntroSingleHandedPropertiesScreen extends StatefulWidget {
  const IntroSingleHandedPropertiesScreen({
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
  State<IntroSingleHandedPropertiesScreen> createState() =>
      _IntroSingleHandedPropertiesScreenState();
}

class _IntroSingleHandedPropertiesScreenState
    extends State<IntroSingleHandedPropertiesScreen> {
  static const _objClass = 'IntroSingleHandedProperties';
  late String _alias;
  late PvzObject _moduleObject;
  late IntroSingleHandedPropertiesData _data;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    _moduleObject = widget.levelFile.objects.firstWhere(
      (object) =>
          object.objClass == _objClass &&
          object.aliases?.contains(_alias) == true,
      orElse: () {
        final object = PvzObject(
          aliases: [_alias],
          objClass: _objClass,
          objData: IntroSingleHandedPropertiesData().toJson(),
        );
        widget.levelFile.objects.add(object);
        return object;
      },
    );
    try {
      _data = IntroSingleHandedPropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObject.objData as Map),
      );
    } catch (_) {
      _data = IntroSingleHandedPropertiesData();
    }
  }

  void _save() {
    _moduleObject.objData = _data.toJson();
    widget.onChanged();
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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.back,
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
            tooltip: l10n.tooltipAboutModule,
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n.singleHandedTutorialHelpTitle,
              sections: [
                HelpSectionData(
                  title: l10n.singleHandedTutorialHelpPromptsTitle,
                  body: l10n.singleHandedTutorialHelpPromptsBody,
                ),
                HelpSectionData(
                  title: l10n.singleHandedTutorialHelpWaveTitle,
                  body: l10n.singleHandedTutorialHelpWaveBody,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
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
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        EditorResponsiveInputField(
                          label: localizedPropertyLabel(
                            context,
                            l10n.singleHandedTutorialWaveForStartRocket,
                            'WaveForStartRocket',
                          ),
                          builder: (context, decoration) => TextFormField(
                            key: const ValueKey(
                              'singleHandedTutorialWaveForStartRocket',
                            ),
                            initialValue: _data.waveForStartRocket.toString(),
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: decoration,
                            onChanged: (raw) {
                              final value = int.tryParse(raw);
                              if (value == null) return;
                              _data.waveForStartRocket = value;
                              _save();
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
