import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/rift_theme_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/rift_theme_selection_screen.dart';
import 'package:c_editor/theme/app_theme.dart'
    show pvzPurpleDark, pvzPurpleLight;
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Custom rift theme list module (`RiftThemeDemoModuleProperties`).
class RiftThemeModuleScreen extends StatefulWidget {
  const RiftThemeModuleScreen({
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
  State<RiftThemeModuleScreen> createState() => _RiftThemeModuleScreenState();
}

class _RiftThemeModuleScreenState extends State<RiftThemeModuleScreen> {
  static const _defaultAlias = 'RiftTheme';
  static const _objClass = 'RiftThemeDemoModuleProperties';
  late String _alias;

  late PvzObject _moduleObj;
  late RiftThemeDemoModulePropertiesData _data;

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
        objClass: _objClass,
        objData: RiftThemeDemoModulePropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = RiftThemeDemoModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = RiftThemeDemoModulePropertiesData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  void _removeTheme(int index) {
    final themes = List<String>.from(_data.demoRiftThemeName)..removeAt(index);
    _data = RiftThemeDemoModulePropertiesData(demoRiftThemeName: themes);
    _sync();
  }

  Future<void> _openThemeSelection(AppLocalizations? l10n) async {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accentColor = isDark ? pvzPurpleDark : pvzPurpleLight;

    final result = await Navigator.push<List<String>>(
      context,
      MaterialPageRoute(
        builder: (_) => RiftThemeSelectionScreen(
          initialSelectedIds: _data.demoRiftThemeName,
          accentColor: accentColor,
          onThemesConfirmed: (ids) => Navigator.pop(context, ids),
          onBack: () => Navigator.pop(context),
        ),
      ),
    );

    if (result != null && mounted) {
      _data = RiftThemeDemoModulePropertiesData(demoRiftThemeName: result);
      _sync();
    }
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
    final accentColor = isDark ? pvzPurpleDark : pvzPurpleLight;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
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
            icon: const Icon(Icons.help_outline, color: Colors.white),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () => showEditorHelpDialog(
              context,
              title: l10n?.riftThemeHelpTitle ?? 'Rift theme module',
              themeColor: accentColor,
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.riftThemeHelpOverview ?? '',
                ),
                HelpSectionData(
                  title: l10n?.riftThemeHelpUsage ?? 'Usage',
                  body: l10n?.riftThemeHelpUsageBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.riftThemeHelpUnique ?? 'Unique themes',
                  body: l10n?.riftThemeHelpUniqueBody ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: EditorAliasInputField(
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
              accentColor: accentColor,
            ),
          ),
          Expanded(
            child: _data.demoRiftThemeName.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n?.riftThemeEmpty ??
                      'No themes selected. Tap the button below to choose themes.',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _data.demoRiftThemeName.length,
              itemBuilder: (context, index) {
                final id = _data.demoRiftThemeName[index];
                final nameKey = RiftThemeRepository.nameKey(id);
                final name = ResourceNames.lookup(context, nameKey);
                final displayName = name != nameKey ? name : id;
                final isUnknown = !RiftThemeRepository.isKnown(id);
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: accentColor.withValues(alpha: 0.15),
                      foregroundColor: accentColor,
                      child: Text('${index + 1}'),
                    ),
                    title: Text(
                      displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(id),
                    trailing: isUnknown
                        ? Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                editorWarningIcon,
                                color: editorWarningBannerForeground(
                                  theme.brightness,
                                ),
                                size: 20,
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline),
                                tooltip: l10n?.delete ?? 'Delete',
                                onPressed: () => _removeTheme(index),
                              ),
                            ],
                          )
                        : IconButton(
                            icon: const Icon(Icons.delete_outline),
                            tooltip: l10n?.delete ?? 'Delete',
                            onPressed: () => _removeTheme(index),
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openThemeSelection(l10n),
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        tooltip: l10n?.riftThemeSelectThemes ?? 'Select themes',
        child: const Icon(Icons.edit),
      ),
    );
  }
}
