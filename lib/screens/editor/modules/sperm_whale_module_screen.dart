import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Editor for [SpermWhaleModuleProperties] (Atlantis whale behavior).
class SpermWhaleModuleScreen extends StatefulWidget {
  const SpermWhaleModuleScreen({
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
  State<SpermWhaleModuleScreen> createState() => _SpermWhaleModuleScreenState();
}

class _SpermWhaleModuleScreenState extends State<SpermWhaleModuleScreen> {
  static const _objClass = 'SpermWhaleModuleProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late SpermWhaleModulePropertiesData _data;

  late TextEditingController _swallowIntervalCtrl;
  late TextEditingController _poisonSwallowIntervalCtrl;
  late TextEditingController _swallowDurationCtrl;
  late TextEditingController _poisonTriggerCountCtrl;

  int get _gridRows {
    final (rows, _) = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return rows;
  }

  int get _gridCols {
    final (_, cols) = LevelParser.getGridDimensionsFromFile(widget.levelFile);
    return cols;
  }

  bool get _isDeepSea => LevelParser.isDeepSeaLawnFromFile(widget.levelFile);

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
    _swallowIntervalCtrl = TextEditingController(
      text: _formatNum(_data.swallowInterval),
    );
    _poisonSwallowIntervalCtrl = TextEditingController(
      text: _formatNum(_data.poisonSwallowInterval),
    );
    _swallowDurationCtrl = TextEditingController(
      text: _formatNum(_data.swallowDuration),
    );
    _poisonTriggerCountCtrl = TextEditingController(
      text: '${_data.poisonTriggerCount}',
    );
  }

  static String _formatNum(double v) {
    if (v == v.roundToDouble()) return '${v.toInt()}';
    return '$v';
  }

  void _loadData() {
    final alias = _alias;
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: 'SpermWhaleModuleProperties',
        objData: SpermWhaleModulePropertiesData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = SpermWhaleModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = SpermWhaleModulePropertiesData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  @override
  void dispose() {
    _swallowIntervalCtrl.dispose();
    _poisonSwallowIntervalCtrl.dispose();
    _swallowDurationCtrl.dispose();
    _poisonTriggerCountCtrl.dispose();
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
    final title = l10n?.spermWhaleModuleTitle ?? 'Sperm whale';
    final helpTitle = l10n?.spermWhaleModuleHelpTitle ?? title;

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
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutModule ?? 'About this module',
            onPressed: () => showEditorHelpDialog(
              context,
              title: helpTitle,
              sections: [
                HelpSectionData(
                  title: l10n?.spermWhaleModuleHelpOverview ?? 'Overview',
                  body:
                      l10n?.spermWhaleModuleHelpOverviewBody ??
                      'Underwater whale behavior: swallow intervals, poisoned behavior, and krill requirement. Use on Deep Sea (or Deep Sea Land) stages for the intended lawn size.',
                ),
                HelpSectionData(
                  title: l10n?.spermWhaleModuleHelpFieldsTitle ?? 'Fields',
                  body:
                      l10n?.spermWhaleModuleHelpFieldsBody ??
                      'SwallowInterval / PoisonSwallowInterval / SwallowDuration control timing. PoisonTriggerCount counts pufferfish-stack poison triggers before poison swallow timing applies. In-game, krill spawns matter — at least 3 krill are typically required for the effect.',
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
            ),
            const SizedBox(height: 16),
            if (!_isDeepSea)
              EditorWarningBanner(
                margin: EdgeInsets.zero,
                message:
                    l10n?.spermWhaleModuleNotDeepSeaWarning ??
                    'This module is meant for Deep Sea / Deep Sea Land stages. '
                        'The lawn grid below reflects your current level; for standard lawns it will not match Atlantis gameplay.',
              ),
            if (!_isDeepSea) const SizedBox(height: 16),
            Text(
              l10n?.spermWhaleModuleParameters ?? 'Parameters',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _numField(
              context,
              label:
                  l10n?.spermWhaleModuleSwallowInterval ??
                  'Swallow interval (SwallowInterval)',
              tooltip:
                  l10n?.spermWhaleModuleHelpSwallowInterval ??
                  'Seconds between plant swallows under normal conditions.',
              controller: _swallowIntervalCtrl,
              onValid: (v) {
                _data.swallowInterval = v;
                _sync();
              },
            ),
            const SizedBox(height: 12),
            _numField(
              context,
              label:
                  l10n?.spermWhaleModulePoisonSwallowInterval ??
                  'Poison swallow interval (PoisonSwallowInterval)',
              tooltip:
                  l10n?.spermWhaleModuleHelpPoisonSwallowInterval ??
                  'Seconds between swallows while poison debuff applies.',
              controller: _poisonSwallowIntervalCtrl,
              onValid: (v) {
                _data.poisonSwallowInterval = v;
                _sync();
              },
            ),
            const SizedBox(height: 12),
            _numField(
              context,
              label:
                  l10n?.spermWhaleModuleSwallowDuration ??
                  'Swallow duration (SwallowDuration)',
              tooltip:
                  l10n?.spermWhaleModuleHelpSwallowDuration ??
                  'How long a swallow phase lasts.',
              controller: _swallowDurationCtrl,
              onValid: (v) {
                _data.swallowDuration = v;
                _sync();
              },
            ),
            const SizedBox(height: 12),
            Tooltip(
              message:
                  l10n?.spermWhaleModuleHelpPoisonTriggerCount ??
                  'How many times the pufferfish poison debuff must stack before switching to poison swallow timing.',
              child: TextField(
                controller: _poisonTriggerCountCtrl,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText:
                      l10n?.spermWhaleModulePoisonTriggerCount ??
                      'Poison trigger count (PoisonTriggerCount)',
                  border: const OutlineInputBorder(),
                ),
                onChanged: (v) {
                  final n = int.tryParse(v);
                  if (n != null && n >= 0) {
                    _data.poisonTriggerCount = n;
                    _sync();
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n?.spermWhaleModuleLawnPreview ??
                  'Lawn grid (for layout reference)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n?.spermWhaleModuleLawnPreviewHint ??
                  'Row/column count follows the level stage (Deep Sea: 6×10).',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            scaleTableForDesktop(
              context: context,
              child: Container(
                constraints: const BoxConstraints(maxWidth: 480),
                child: AspectRatio(
                  aspectRatio: _gridCols / _gridRows,
                  child: GridView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: _gridCols,
                      childAspectRatio: 1,
                    ),
                    itemCount: _gridCols * _gridRows,
                    itemBuilder: (context, i) {
                      final col = i % _gridCols;
                      final row = i ~/ _gridCols;
                      final stripe = (col + row).isEven;
                      return Container(
                        decoration: BoxDecoration(
                          color: stripe
                              ? theme.colorScheme.primaryContainer.withValues(
                                  alpha: 0.35,
                                )
                              : theme.colorScheme.surfaceContainerHighest,
                          border: Border.all(
                            color: theme.colorScheme.outlineVariant,
                          ),
                        ),
                      );
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

  Widget _numField(
    BuildContext context, {
    required String label,
    required String tooltip,
    required TextEditingController controller,
    required void Function(double v) onValid,
  }) {
    return Tooltip(
      message: tooltip,
      child: TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        onChanged: (v) {
          final n = double.tryParse(v);
          if (n != null && n >= 0) {
            onValid(n);
          }
        },
      ),
    );
  }
}
