import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Sun dropper properties editor. Ported from Z-Editor SunDropperPropertiesEP.kt
class SunDropperPropertiesScreen extends StatefulWidget {
  const SunDropperPropertiesScreen({
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
  State<SunDropperPropertiesScreen> createState() =>
      _SunDropperPropertiesScreenState();
}

class _SunDropperPropertiesScreenState
    extends State<SunDropperPropertiesScreen> {
  static const _defaultAlias = 'DefaultSunDropper';
  static const _objClass = 'SunDropperProperties';
  late String _alias;

  late SunDropperPropertiesData _data;
  late TextEditingController _initialDelayCtrl;
  late TextEditingController _countdownBaseCtrl;
  late TextEditingController _countdownMaxCtrl;
  late TextEditingController _countdownRangeCtrl;
  late TextEditingController _increasePerSunCtrl;

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
        _data = SunDropperPropertiesData.fromJson(
          Map<String, dynamic>.from(existing.objData as Map),
        );
      } catch (_) {
        _data = SunDropperPropertiesData();
      }
    } else {
      _data = SunDropperPropertiesData();
    }
    _initialDelayCtrl = TextEditingController(
      text: '${_data.initialSunDropDelay}',
    );
    _countdownBaseCtrl = TextEditingController(
      text: '${_data.sunCountdownBase}',
    );
    _countdownMaxCtrl = TextEditingController(text: '${_data.sunCountdownMax}');
    _countdownRangeCtrl = TextEditingController(
      text: '${_data.sunCountdownRange}',
    );
    _increasePerSunCtrl = TextEditingController(
      text: '${_data.sunCountdownIncreasePerSun}',
    );
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
      final alias = info?.alias ?? '';
      return alias == _defaultAlias;
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
    _initialDelayCtrl.dispose();
    _countdownBaseCtrl.dispose();
    _countdownMaxCtrl.dispose();
    _countdownRangeCtrl.dispose();
    _increasePerSunCtrl.dispose();
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
    // Original editor: orange in light mode, yellow in dark mode
    final themeColor = isDark ? pvzYellowDark : pvzOrangeLight;
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
              title: l10n?.sunDropperHelpTitle ?? 'Sun dropper module',
              themeColor: themeColor,
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body:
                      l10n?.sunDropperHelpIntro ??
                      'This module configures falling sun parameters. Consider not adding it for night levels.',
                ),
                HelpSectionData(
                  title: l10n?.sunDropperHelpParams ?? 'Parameter config',
                  body:
                      l10n?.sunDropperHelpParamsBody ??
                      'By default the module uses game definitions. You can enable custom mode to edit parameters locally.',
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
            // Mode switch card
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(Icons.wb_sunny, color: themeColor),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n?.customLocalParams ?? 'Custom local params',
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
            // Parameter edit area (visible only in custom mode)
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
                              l10n?.paramAdjust ?? 'Parameter adjust',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: themeColor,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _buildNumberField(
                              controller: _initialDelayCtrl,
                              label: l10n?.firstDropDelay ?? 'First drop delay',
                              onChanged: (v) {
                                final n = double.tryParse(v);
                                if (n != null) {
                                  _data.initialSunDropDelay = n;
                                  _sync();
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildNumberField(
                              controller: _countdownBaseCtrl,
                              label:
                                  l10n?.initialDropInterval ??
                                  'Initial drop interval',
                              onChanged: (v) {
                                final n = double.tryParse(v);
                                if (n != null) {
                                  _data.sunCountdownBase = n;
                                  _sync();
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildNumberField(
                              controller: _countdownMaxCtrl,
                              label:
                                  l10n?.maxDropInterval ?? 'Max drop interval',
                              onChanged: (v) {
                                final n = double.tryParse(v);
                                if (n != null) {
                                  _data.sunCountdownMax = n;
                                  _sync();
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildNumberField(
                              controller: _countdownRangeCtrl,
                              label:
                                  l10n?.intervalFloatRange ??
                                  'Interval float range',
                              onChanged: (v) {
                                final n = double.tryParse(v);
                                if (n != null) {
                                  _data.sunCountdownRange = n;
                                  _sync();
                                }
                              },
                            ),
                            const SizedBox(height: 12),
                            _buildNumberField(
                              controller: _increasePerSunCtrl,
                              label: l10n?.increasePerSun ?? 'Increase per sun',
                              onChanged: (v) {
                                final n = double.tryParse(v);
                                if (n != null) {
                                  _data.sunCountdownIncreasePerSun = n;
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

  Widget _buildNumberField({
    required TextEditingController controller,
    required String label,
    required void Function(String) onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
