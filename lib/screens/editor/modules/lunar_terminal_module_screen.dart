import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

class LunarTerminalModuleScreen extends StatefulWidget {
  const LunarTerminalModuleScreen({
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
  State<LunarTerminalModuleScreen> createState() =>
      _LunarTerminalModuleScreenState();
}

class _LunarTerminalModuleScreenState extends State<LunarTerminalModuleScreen> {
  static const _objClass = 'LunarTerminalModuleProperties';
  late String _alias;
  late PvzObject _moduleObject;
  late LunarTerminalModulePropertiesData _data;
  late TextEditingController _cooldownCtrl;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _moduleObject =
        widget.levelFile.objects.firstWhereOrNull(
          (object) => object.aliases?.contains(_alias) == true,
        ) ??
        PvzObject(
          aliases: [_alias],
          objClass: _objClass,
          objData: LunarTerminalModulePropertiesData().toJson(),
        );
    if (!widget.levelFile.objects.contains(_moduleObject)) {
      widget.levelFile.objects.add(_moduleObject);
    }
    try {
      _data = LunarTerminalModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObject.objData as Map),
      );
    } catch (_) {
      _data = LunarTerminalModulePropertiesData();
    }
    _cooldownCtrl = TextEditingController(text: '${_data.collectorCooldown}');
  }

  @override
  void dispose() {
    _cooldownCtrl.dispose();
    super.dispose();
  }

  void _sync() {
    _moduleObject.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _handleAliasChanged(String value) {
    renameLevelObjectAlias(
      levelFile: widget.levelFile,
      oldAlias: _alias,
      newAlias: value,
      onChanged: widget.onChanged,
    );
    setState(() => _alias = value);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n?.lunarTerminalHelpTitle ?? 'Lunar Terminal',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.lunarTerminalHelpOverview ?? '',
                ),
                HelpSectionData(
                  title:
                      l10n?.lunarTerminalHelpFixedTitle ??
                      'Deployment cooldown',
                  body: l10n?.lunarTerminalHelpFixed ?? '',
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
                child: EditorResponsiveInputField(
                  label:
                      l10n?.lunarTerminalCollectorCooldown ??
                      'Robot deployment cooldown (CollectorCooldown, seconds)',
                  builder: (context, decoration) => TextField(
                    controller: _cooldownCtrl,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    decoration: decoration,
                    onChanged: (value) {
                      final parsed = double.tryParse(value);
                      if (parsed != null && parsed >= 0) {
                        _data.collectorCooldown = parsed;
                        _sync();
                      }
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
