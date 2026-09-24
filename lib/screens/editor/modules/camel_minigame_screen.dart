import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart'
    show
        EditorResponsiveInputField,
        HelpSectionData,
        showEditorHelpDialog;
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

  late PvzObject _moduleObj;
  late CamelMinigamePropertiesData _data;
  late String _alias;

  late TextEditingController _xBufferCtrl;
  late TextEditingController _riseStaggerCtrl;
  late TextEditingController _cardMatchTimeCtrl;
  late TextEditingController _cardMatchingTimeCtrl;
  late TextEditingController _cardNoMatchTimeCtrl;
  late TextEditingController _cardTypesUsedCtrl;
  late TextEditingController _tutorialRiseDelayCtrl;
  late TextEditingController _maxSpawnXCtrl;
  late TextEditingController _minSpawnXEndCtrl;
  late TextEditingController _minSpawnXStartCtrl;

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
        objData: CamelMinigamePropertiesData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = CamelMinigamePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = CamelMinigamePropertiesData();
    }
    _xBufferCtrl = TextEditingController(
      text: _data.additionalXBufferBetweenChains.toString(),
    );
    _riseStaggerCtrl = TextEditingController(
      text: _data.camelSegmentRiseStagger.toString(),
    );
    _cardMatchTimeCtrl = TextEditingController(
      text: _data.cardMatchTime.toString(),
    );
    _cardMatchingTimeCtrl = TextEditingController(
      text: _data.cardMatchingTime.toString(),
    );
    _cardNoMatchTimeCtrl = TextEditingController(
      text: _data.cardNoMatchTime.toString(),
    );
    _cardTypesUsedCtrl = TextEditingController(
      text: _data.cardTypesUsed.toString(),
    );
    _tutorialRiseDelayCtrl = TextEditingController(
      text: _data.initialTutorialZombieRiseDelay.toString(),
    );
    _maxSpawnXCtrl = TextEditingController(
      text: _data.maxSpawnX.toString(),
    );
    _minSpawnXEndCtrl = TextEditingController(
      text: _data.minSpawnXEnd.toString(),
    );
    _minSpawnXStartCtrl = TextEditingController(
      text: _data.minSpawnXStart.toString(),
    );
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  @override
  void dispose() {
    _xBufferCtrl.dispose();
    _riseStaggerCtrl.dispose();
    _cardMatchTimeCtrl.dispose();
    _cardMatchingTimeCtrl.dispose();
    _cardNoMatchTimeCtrl.dispose();
    _cardTypesUsedCtrl.dispose();
    _tutorialRiseDelayCtrl.dispose();
    _maxSpawnXCtrl.dispose();
    _minSpawnXEndCtrl.dispose();
    _minSpawnXStartCtrl.dispose();
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
              title:
                  l10n?.moduleTitle_CamelMinigameProperties ??
                  'Camel Card Match',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body:
                      l10n?.moduleHelpCamelOverviewBody ??
                      'Camel card matching minigame.',
                ),
                HelpSectionData(
                  title: l10n?.editing ?? 'Timings',
                  body:
                      l10n?.moduleHelpCamelTimingsBody ??
                      'Card timing parameters.',
                ),
                HelpSectionData(
                  title: l10n?.position ?? 'Spawning',
                  body:
                      l10n?.moduleHelpCamelSpawningBody ??
                      'Card chain spawning range.',
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
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.editing ?? 'Timings',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildIntField(
                      l10n?.camelCardTypesUsed ?? 'Card types (1-7)',
                      _cardTypesUsedCtrl,
                      (v) {
                        final n = int.tryParse(v);
                        if (n != null && n >= 1 && n <= 7) {
                          _data.cardTypesUsed = n;
                          _sync();
                        }
                      },
                    ),
                    const SizedBox(height: 4),
                    _buildCardTypeIcons(),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF9A825),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            size: 20,
                            color: Color(0xFF3E2723),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              l10n?.camelRiseFromGroundOnlyCamelTouch ??
                                  'Rise from ground only works with camel '
                                      'touch zombies. Other zombies cannot use '
                                      'this spawn mode in Camel Minigame.',
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: const Color(0xFF3E2723)),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildDoubleField(
                      l10n?.camelRiseStagger ?? 'Rise stagger (s)',
                      _riseStaggerCtrl,
                      (v) {
                        final n = double.tryParse(v);
                        if (n != null && n >= 0) {
                          _data.camelSegmentRiseStagger = n;
                          _sync();
                        }
                      },
                    ),
                    _buildDoubleField(
                      l10n?.camelCardMatchTime ?? 'Match success delay (s)',
                      _cardMatchTimeCtrl,
                      (v) {
                        final n = double.tryParse(v);
                        if (n != null && n >= 0) {
                          _data.cardMatchTime = n;
                          _sync();
                        }
                      },
                    ),
                    _buildDoubleField(
                      l10n?.camelCardMatchingTime ?? 'Flip animation (s)',
                      _cardMatchingTimeCtrl,
                      (v) {
                        final n = double.tryParse(v);
                        if (n != null && n >= 0) {
                          _data.cardMatchingTime = n;
                          _sync();
                        }
                      },
                    ),
                    _buildDoubleField(
                      l10n?.camelCardNoMatchTime ?? 'Mismatch idle (s)',
                      _cardNoMatchTimeCtrl,
                      (v) {
                        final n = double.tryParse(v);
                        if (n != null && n >= 0) {
                          _data.cardNoMatchTime = n;
                          _sync();
                        }
                      },
                    ),
                    _buildDoubleField(
                      l10n?.camelTutorialRiseDelay ?? 'Tutorial rise delay (s)',
                      _tutorialRiseDelayCtrl,
                      (v) {
                        final n = double.tryParse(v);
                        if (n != null && n >= 0) {
                          _data.initialTutorialZombieRiseDelay = n;
                          _sync();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n?.position ?? 'Spawning',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildIntField(
                      l10n?.camelAdditionalXBuffer ?? 'Chain X buffer',
                      _xBufferCtrl,
                      (v) {
                        final n = int.tryParse(v);
                        if (n != null && n >= 0) {
                          _data.additionalXBufferBetweenChains = n;
                          _sync();
                        }
                      },
                    ),
                    _buildIntField(
                      l10n?.camelMaxSpawnX ?? 'Max spawn X',
                      _maxSpawnXCtrl,
                      (v) {
                        final n = int.tryParse(v);
                        if (n != null) {
                          _data.maxSpawnX = n;
                          _sync();
                        }
                      },
                    ),
                    _buildIntField(
                      l10n?.camelMinSpawnXStart ?? 'Min spawn X start',
                      _minSpawnXStartCtrl,
                      (v) {
                        final n = int.tryParse(v);
                        if (n != null) {
                          _data.minSpawnXStart = n;
                          _sync();
                        }
                      },
                    ),
                    _buildIntField(
                      l10n?.camelMinSpawnXEnd ?? 'Min spawn X end',
                      _minSpawnXEndCtrl,
                      (v) {
                        final n = int.tryParse(v);
                        if (n != null) {
                          _data.minSpawnXEnd = n;
                          _sync();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                title: Text(l10n?.camelShowTutorial ?? 'Show tutorial'),
                value: _data.showTutorial,
                onChanged: (v) {
                  _data.showTutorial = v;
                  _sync();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoubleField(
    String label,
    TextEditingController ctrl,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: EditorResponsiveInputField(
        label: label,
        builder: (context, decoration) => TextField(
          controller: ctrl,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: decoration,
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildCardTypeIcons() {
    const cardTypeAssets = [
      'assets/images/others/camelminigame_1.png',
      'assets/images/others/camelminigame_2.png',
      'assets/images/others/camelminigame_3.png',
      'assets/images/others/camelminigame_4.png',
      'assets/images/others/camelminigame_5.png',
      'assets/images/others/camelminigame_6.png',
      'assets/images/others/camelminigame_7.png',
    ];
    final used = _data.cardTypesUsed;
    return Row(
      children: [
        for (var i = 0; i < cardTypeAssets.length; i++)
          Padding(
            padding: const EdgeInsets.only(right: 6),
            child: Opacity(
              opacity: i < used ? 1.0 : 0.25,
              child: Image.asset(
                cardTypeAssets[i],
                width: 20,
                height: 20,
                fit: BoxFit.contain,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildIntField(
    String label,
    TextEditingController ctrl,
    ValueChanged<String> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: EditorResponsiveInputField(
        label: label,
        builder: (context, decoration) => TextField(
          controller: ctrl,
          keyboardType: TextInputType.number,
          decoration: decoration,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
