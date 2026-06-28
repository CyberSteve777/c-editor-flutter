import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/theme/app_theme.dart'
    show pvzLightOrangeDark, pvzLightOrangeLight;
import 'package:c_editor/widgets/editor_components.dart'
    show showEditorHelpDialog, HelpSectionData, editorInputDecoration;

class MaxSunModuleScreen extends StatefulWidget {
  const MaxSunModuleScreen({
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
  State<MaxSunModuleScreen> createState() => _MaxSunModuleScreenState();
}

class _MaxSunModuleScreenState extends State<MaxSunModuleScreen> {
  static const _objClass = 'LevelMutatorMaxSunProps';
  late String _alias;
  late PvzObject _moduleObj;
  late LevelMutatorMaxSunPropsData _data;
  late TextEditingController _sunController;
  late FocusNode _sunFocusNode;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
    _sunFocusNode = FocusNode();
    _sunFocusNode.addListener(() => setState(() {}));
  }

  void _loadData() {
    final alias = _alias;
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: 'LevelMutatorMaxSunProps',
        objData: LevelMutatorMaxSunPropsData().toJson(),
      ),
    );
    try {
      _data = LevelMutatorMaxSunPropsData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = LevelMutatorMaxSunPropsData();
    }
    _sunController = TextEditingController(text: '${_data.maxSunOverride}');
  }

  void _save() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
  }

  @override
  void dispose() {
    _sunController.dispose();
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
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
          foregroundColor: Colors.white,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () {
              showEditorHelpDialog(
                context,
                title: l10n?.maxSunHelpTitle ?? 'Max Sun Module',
                themeColor: accentColor,
                sections: [
                  HelpSectionData(
                    title: l10n?.overview ?? 'Overview',
                    body:
                        l10n?.maxSunHelpOverview ??
                        'This module was originally used to control different difficulty levels in Panchase. Use it to override the maximum sun that can be stored in the level.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
EditorAliasInputField(
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
              accentColor: accentColor,
            ),
            const SizedBox(height: 16),
            Text(
              l10n?.maxSunOverride ?? 'Max Sun Override',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            TextField(
              focusNode: _sunFocusNode,
              controller: _sunController,
              keyboardType: TextInputType.number,
              decoration: editorInputDecoration(
                context,
                hintText: l10n?.enterMaxSunHint ?? 'Enter max sun (e.g., 9900)',
                focusColor: accentColor,
                isFocused: _sunFocusNode.hasFocus,
              ),
              onChanged: (value) {
                final parsed = int.tryParse(value) ?? _data.maxSunOverride;
                setState(() {
                  _data.maxSunOverride = parsed.clamp(0, 99999);
                  _save();
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
