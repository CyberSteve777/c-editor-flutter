import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

enum _BeginStringMode { hidden, defaultText, custom }

class CowboyMinigameScreen extends StatefulWidget {
  const CowboyMinigameScreen({
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
  State<CowboyMinigameScreen> createState() => _CowboyMinigameScreenState();
}

class _CowboyMinigameScreenState extends State<CowboyMinigameScreen> {
  static const _objClass = 'CowboyMinigameProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late CowboyMinigamePropertiesData _data;
  late _BeginStringMode _beginStringMode;
  late TextEditingController _customTextController;

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
        objData: CowboyMinigamePropertiesData().toJson(),
      ),
    );
    try {
      _data = CowboyMinigamePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = CowboyMinigamePropertiesData();
    }
    _beginStringMode = switch (_data.beginString) {
      '' => _BeginStringMode.hidden,
      CowboyMinigamePropertiesData.defaultBeginString =>
        _BeginStringMode.defaultText,
      _ => _BeginStringMode.custom,
    };
    _customTextController = TextEditingController(
      text: _beginStringMode == _BeginStringMode.custom
          ? _data.beginString
          : '',
    );
  }

  @override
  void dispose() {
    _customTextController.dispose();
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

  void _setBeginStringMode(_BeginStringMode mode) {
    _beginStringMode = mode;
    _data.beginString = switch (mode) {
      _BeginStringMode.hidden => '',
      _BeginStringMode.defaultText =>
        CowboyMinigamePropertiesData.defaultBeginString,
      _BeginStringMode.custom => _customTextController.text,
    };
    _sync();
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
              title: l10n.cowboyMinigameHelpTitle,
              sections: [
                HelpSectionData(
                  title: l10n.overview,
                  body: l10n.cowboyMinigameHelpOverviewBody,
                ),
                HelpSectionData(
                  title: l10n.cowboyMinigameBeginString,
                  body: l10n.cowboyMinigameHelpBeginStringBody,
                ),
                HelpSectionData(
                  title: l10n.cowboyMinigameShowTutorial,
                  body: l10n.cowboyMinigameHelpTutorialBody,
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
                      l10n.cowboyMinigameSettings,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<_BeginStringMode>(
                      initialValue: _beginStringMode,
                      decoration: InputDecoration(
                        labelText: localizedPropertyLabel(
                          context,
                          l10n.cowboyMinigameBeginString,
                          'BeginString',
                        ),
                        border: const OutlineInputBorder(),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: _BeginStringMode.hidden,
                          child: Text(l10n.cowboyMinigameBeginStringHidden),
                        ),
                        DropdownMenuItem(
                          value: _BeginStringMode.defaultText,
                          child: Text(l10n.cowboyMinigameBeginStringDefault),
                        ),
                        DropdownMenuItem(
                          value: _BeginStringMode.custom,
                          child: Text(l10n.cowboyMinigameBeginStringCustom),
                        ),
                      ],
                      onChanged: (value) {
                        if (value != null) _setBeginStringMode(value);
                      },
                    ),
                    if (_beginStringMode == _BeginStringMode.custom) ...[
                      const SizedBox(height: 16),
                      TextField(
                        controller: _customTextController,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: l10n.cowboyMinigameCustomTextInput,
                          border: const OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          _data.beginString = value;
                          _sync();
                        },
                      ),
                    ],
                    const SizedBox(height: 8),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(
                        localizedPropertyLabel(
                          context,
                          l10n.cowboyMinigameShowTutorial,
                          'ShowTutorial',
                        ),
                      ),
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
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.cowboyMinigameBeginStringHint,
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
