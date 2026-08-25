import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

class LevelPowerupModuleScreen extends StatefulWidget {
  const LevelPowerupModuleScreen({
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
  State<LevelPowerupModuleScreen> createState() =>
      _LevelPowerupModuleScreenState();
}

class _LevelPowerupModuleScreenState extends State<LevelPowerupModuleScreen> {
  static const _objClass = 'LevelPowerupModuleProperties';

  late String _alias;
  late PvzObject _moduleObject;
  late LevelPowerupModulePropertiesData _data;
  final Map<String, TextEditingController> _controllers = {};

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
          objData: LevelPowerupModulePropertiesData().toJson(),
        );
    if (!widget.levelFile.objects.contains(_moduleObject)) {
      widget.levelFile.objects.add(_moduleObject);
    }
    try {
      _data = LevelPowerupModulePropertiesData.fromJson(
        Map<String, dynamic>.from(_moduleObject.objData as Map),
      );
    } catch (_) {
      _data = LevelPowerupModulePropertiesData();
    }
    for (final typeName
        in LevelPowerupModulePropertiesData.supportedTypeNames) {
      _controllers[typeName] = TextEditingController(
        text: '${_data.entryFor(typeName).freeUseCount}',
      );
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
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
    final l10n = AppLocalizations.of(context)!;
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
              isEvent: false,
              title: l10n.powerUpsHelpTitle,
              sections: [
                HelpSectionData(
                  title: l10n.overview,
                  body: l10n.powerUpsHelpOverview,
                ),
                HelpSectionData(
                  title: l10n.powerToss,
                  body: l10n.powerTossInfo,
                ),
                HelpSectionData(title: l10n.powerZap, body: l10n.powerZapInfo),
                HelpSectionData(
                  title: l10n.powerPinch,
                  body: l10n.powerPinchInfo,
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
            _buildPowerupCard(
              typeName: 'powerupflickzombie',
              icon: Icons.swipe_vertical,
              title: l10n.powerToss,
            ),
            const SizedBox(height: 12),
            _buildPowerupCard(
              typeName: 'powerupwizardfinger',
              icon: Icons.bolt,
              title: l10n.powerZap,
            ),
            const SizedBox(height: 12),
            _buildPowerupCard(
              typeName: 'poweruppinchzombie',
              icon: Icons.content_cut,
              title: l10n.powerPinch,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPowerupCard({
    required String typeName,
    required IconData icon,
    required String title,
  }) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final identity = Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, size: 36, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        typeName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
            final countField = SizedBox(
              width: constraints.maxWidth < 520 ? double.infinity : 300,
              child: EditorResponsiveInputField(
                label: l10n.powerUpsFreeUseCount,
                builder: (context, decoration) => TextField(
                  key: ValueKey('powerupFreeUseCount_$typeName'),
                  controller: _controllers[typeName],
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: decoration,
                  onChanged: (value) {
                    final parsed = int.tryParse(value);
                    if (parsed == null || parsed < 0) return;
                    _data.entryFor(typeName).freeUseCount = parsed;
                    _sync();
                  },
                ),
              ),
            );

            if (constraints.maxWidth < 620) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [identity, const SizedBox(height: 16), countField],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: identity),
                const SizedBox(width: 24),
                countField,
              ],
            );
          },
        ),
      ),
    );
  }
}
