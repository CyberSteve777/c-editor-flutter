import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Sun bomb challenge editor. Ported from SunBombChallengePropertiesEP.kt
class SunBombChallengeScreen extends StatefulWidget {
  const SunBombChallengeScreen({
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
  State<SunBombChallengeScreen> createState() => _SunBombChallengeScreenState();
}

class _SunBombChallengeScreenState extends State<SunBombChallengeScreen> {
  static const _objClass = 'SunBombChallengeProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late SunBombChallengeData _data;
  late TextEditingController _plantRadiusCtrl;
  late TextEditingController _zombieRadiusCtrl;
  late TextEditingController _plantDamageCtrl;
  late TextEditingController _zombieDamageCtrl;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
  }

  void _loadData() {
    final alias = _alias;
    _moduleObj = widget.levelFile.objects.firstWhere(
      (o) => o.aliases?.contains(alias) == true,
      orElse: () => PvzObject(
        aliases: [alias],
        objClass: 'SunBombChallengeProperties',
        objData: SunBombChallengeData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObj)) {
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = SunBombChallengeData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = SunBombChallengeData();
    }
    _plantRadiusCtrl = TextEditingController(
      text: '${_data.plantBombExplosionRadius}',
    );
    _zombieRadiusCtrl = TextEditingController(
      text: '${_data.zombieBombExplosionRadius}',
    );
    _plantDamageCtrl = TextEditingController(text: '${_data.plantDamage}');
    _zombieDamageCtrl = TextEditingController(text: '${_data.zombieDamage}');
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  @override
  void dispose() {
    _plantRadiusCtrl.dispose();
    _zombieRadiusCtrl.dispose();
    _plantDamageCtrl.dispose();
    _zombieDamageCtrl.dispose();
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
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
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
              title: l10n.sunBomb,
              sections: [
                HelpSectionData(
                  title: l10n.sunBombHelpOverview,
                  body: l10n.sunBombHelpBody,
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
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.explosionRadius,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _intField(
                            controller: _plantRadiusCtrl,
                            label: l10n.plantRadius,
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null) {
                                _data.plantBombExplosionRadius = n;
                                _sync();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _intField(
                            controller: _zombieRadiusCtrl,
                            label: l10n.zombieRadius,
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null) {
                                _data.zombieBombExplosionRadius = n;
                                _sync();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.damage,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _intField(
                            controller: _plantDamageCtrl,
                            label: l10n.plantDamage,
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null) {
                                _data.plantDamage = n;
                                _sync();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _intField(
                            controller: _zombieDamageCtrl,
                            label: l10n.zombieDamage,
                            onChanged: (v) {
                              final n = int.tryParse(v);
                              if (n != null) {
                                _data.zombieDamage = n;
                                _sync();
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      l10n.radiusPixelsHint,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
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

  Widget _intField({
    required TextEditingController controller,
    required String label,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      onChanged: onChanged,
    );
  }
}
