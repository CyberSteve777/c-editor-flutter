import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Final zomboss stage time limit challenge (`ZombossFinalStageTimeLimitedChallengeProperties`).
///
/// **Unwired:** the editor no longer opens this screen. The game reads the
/// desperation timer from zomboss property sheets (e.g. `ZombossFinalStageTimeLimited`
/// on `ZombieZombossQinShiHuangProps`), not from editable module parameters.
/// Kept for potential future support when custom `@CurrentLevel` overrides work.
class FinalStageTimeLimitedChallengePropertiesScreen extends StatefulWidget {
  const FinalStageTimeLimitedChallengePropertiesScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.levelDef,
    required this.onChanged,
    required this.onBack,
    this.onModeToggled,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final LevelDefinitionData levelDef;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(String newRtid)? onModeToggled;

  @override
  State<FinalStageTimeLimitedChallengePropertiesScreen> createState() =>
      _FinalStageTimeLimitedChallengePropertiesScreenState();
}

class _FinalStageTimeLimitedChallengePropertiesScreenState
    extends State<FinalStageTimeLimitedChallengePropertiesScreen> {
  static const _defaultAlias = 'FinalStageTimeLimitedChallenge';
  static const _objClass = 'ZombossFinalStageTimeLimitedChallengeProperties';
  late String _alias;

  late ZombossFinalStageTimeLimitedChallengePropertiesData _data;
  late TextEditingController _timeLimitCtrl;

  bool get _isCustomMode {
    final info = RtidParser.parse(widget.rtid);
    return info?.source == 'CurrentLevel';
  }

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
      try {
        _data = ZombossFinalStageTimeLimitedChallengePropertiesData.fromJson(
          Map<String, dynamic>.from(existing.objData as Map),
        );
      } catch (_) {
        _data = ZombossFinalStageTimeLimitedChallengePropertiesData();
      }
    } else {
      _data = ZombossFinalStageTimeLimitedChallengePropertiesData();
    }
    _timeLimitCtrl = TextEditingController(text: '${_data.zombossTimeLimit}');
  }

  void _sync() {
    final info = RtidParser.parse(widget.rtid);
    final alias = info?.alias ?? _defaultAlias;
    final obj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (obj != null) {
      obj.objData = _data.toJson();
    }
    widget.onChanged();
    setState(() {});
  }

  void _onToggleMode(bool enableCustom) {
    final levelDef = widget.levelDef;
    final objects = widget.levelFile.objects;

    var moduleIndex = levelDef.modules.indexWhere((rtid) {
      final info = RtidParser.parse(rtid);
      return (info?.alias ?? '') == _defaultAlias;
    });

    if (enableCustom) {
      final newRtid = RtidParser.build(_defaultAlias, 'CurrentLevel');
      if (moduleIndex != -1) {
        levelDef.modules[moduleIndex] = newRtid;
      } else {
        levelDef.modules.add(newRtid);
      }
      final existing = objects.firstWhereOrNull(
        (o) => o.aliases?.contains(_defaultAlias) == true,
      );
      if (existing == null) {
        objects.add(
          PvzObject(
            aliases: [_defaultAlias],
            objClass: _objClass,
            objData: _data.toJson(),
          ),
        );
      } else {
        existing.objData = _data.toJson();
      }
    } else {
      final newRtid = RtidParser.build(_defaultAlias, 'LevelModules');
      if (moduleIndex != -1) {
        levelDef.modules[moduleIndex] = newRtid;
      } else {
        levelDef.modules.add(newRtid);
      }
      objects.removeWhere((o) => o.aliases?.contains(_defaultAlias) == true);
    }

    final levelDefObj = objects.firstWhereOrNull(
      (o) => o.objClass == 'LevelDefinition',
    );
    if (levelDefObj != null) {
      levelDefObj.objData = levelDef.toJson();
    }

    widget.onChanged();
    final newRtid = enableCustom
        ? RtidParser.build(_defaultAlias, 'CurrentLevel')
        : RtidParser.build(_defaultAlias, 'LevelModules');
    widget.onModeToggled?.call(newRtid);
  }

  @override
  void dispose() {
    _timeLimitCtrl.dispose();
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
    final themeColor = isDark ? pvzOrangeDark : pvzOrangeLight;
    final isCustom = _isCustomMode;

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
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        backgroundColor: themeColor,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              title:
                  l10n?.finalStageTimeLimitedChallengeHelpTitle ??
                  'Final stage time limit challenge',
              themeColor: themeColor,
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body:
                      l10n?.finalStageTimeLimitedChallengeHelpIntro ??
                      'Adds a timed kill challenge during the final zomboss stage.',
                ),
                HelpSectionData(
                  title:
                      l10n?.finalStageTimeLimitedChallengeHelpParams ??
                      'Parameter configuration',
                  body:
                      l10n?.finalStageTimeLimitedChallengeHelpParamsBody ??
                      'By default this module uses the game definition from LevelModules. Enable custom local parameters to override ZombossTimeLimit.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
EditorAliasInputField(
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
              accentColor: themeColor,
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.timer, color: themeColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.customLocalParams ??
                                'Custom local parameters',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: themeColor,
                            ),
                          ),
                          Text(
                            isCustom
                                ? (l10n?.currentModeLocal ??
                                      'Current: local (@CurrentLevel)')
                                : (l10n?.currentModeSystem ??
                                      'Current: system default (@LevelModules)'),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Theme(
                      data: theme.copyWith(
                        switchTheme: SwitchThemeData(
                          thumbColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? themeColor
                                : null,
                          ),
                          trackColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.selected)
                                ? themeColor.withValues(alpha: 0.5)
                                : null,
                          ),
                        ),
                      ),
                      child: Switch(value: isCustom, onChanged: _onToggleMode),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              child: isCustom
                  ? Card(
                      key: const ValueKey('params'),
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n?.paramAdjust ?? 'Parameter adjustment',
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _timeLimitCtrl,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              decoration: InputDecoration(
                                labelText:
                                    l10n?.finalStageTimeLimitedChallengeTimeLimit ??
                                    'Zomboss time limit (ZombossTimeLimit, seconds)',
                                border: const OutlineInputBorder(),
                              ),
                              onChanged: (value) {
                                final parsed = double.tryParse(value);
                                if (parsed != null && parsed >= 0) {
                                  _data.zombossTimeLimit = parsed;
                                  _sync();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                    )
                  : const SizedBox.shrink(key: ValueKey('empty')),
            ),
          ],
        ),
      ),
    );
  }
}
