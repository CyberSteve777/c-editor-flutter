import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Bowling minigame editor. Ported from Z-Editor-master BowlingMinigamePropertiesEP.kt
class BowlingMinigameScreen extends StatefulWidget {
  const BowlingMinigameScreen({
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
  State<BowlingMinigameScreen> createState() => _BowlingMinigameScreenState();
}

class _BowlingMinigameScreenState extends State<BowlingMinigameScreen> {
  static const _objClass = 'BowlingMinigameProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late BowlingMinigamePropertiesData _data;
  late TextEditingController _foulLineCtrl;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
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
        objClass: 'BowlingMinigameProperties',
        objData: BowlingMinigamePropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = BowlingMinigamePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = BowlingMinigamePropertiesData();
    }
    _foulLineCtrl = TextEditingController(text: '${_data.bowlingFoulLine}');
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  @override
  void dispose() {
    _foulLineCtrl.dispose();
    super.dispose();
  }

  void _showHelp(
    BuildContext context,
    AppLocalizations? l10n,
    Color accentColor,
  ) {
    showEditorHelpDialog(
      context,
      title: l10n?.bowlingMinigame ?? 'Bulb Bowling module',
      themeColor: accentColor,
      sections: [
        HelpSectionData(
          title: l10n?.overview ?? 'Overview',
          body:
              l10n?.bowlingMinigameHelpOverview ??
              'Sets the no-planting line column for bulb bowling levels.',
        ),
        HelpSectionData(
          title: l10n?.bowlingFoulLine ?? 'No-planting line',
          body:
              l10n?.bowlingMinigameHelpFoulLine ??
              'Column index from the left (0-based).',
        ),
      ],
    );
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
    final accentColor = isDark ? pvzGreenDark : pvzGreenLight;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
          foregroundColor: Colors.white,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () => _showHelp(context, l10n, accentColor),
          ),
        ],
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
              accentColor: accentColor,
            ),
            const SizedBox(height: 16),
                Text(
                  l10n?.bowlingMinigameParams ?? 'Parameters',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _foulLineCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n?.bowlingFoulLine ?? 'No-planting line',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (v) {
                    final n = int.tryParse(v);
                    if (n != null) {
                      _data.bowlingFoulLine = n;
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
