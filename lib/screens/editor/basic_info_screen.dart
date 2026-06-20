import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart' show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/widgets/editor_components.dart';
// Options matching LevelDefinitionEP.kt (keep codenames)
const _musicTypeOptions = [
  ('MainPath', 'MainPath'),
  ('MiniGame_A', 'MiniGame_A'),
  ('MiniGame_B', 'MiniGame_B'),
  ('MiniGame_C', 'MiniGame_C'),
  ('MiniGame_D', 'MiniGame_D'),
  ('MiniGame_E', 'MiniGame_E'),
];

const _lootOptions = [
  ('RTID(DefaultLoot@LevelModules)', 'DefaultLoot'),
  ('RTID(NoLoot@LevelModules)', 'NoLoot'),
];
const _victoryOptions = [
  ('RTID(VictoryOutro@LevelModules)', 'VictoryOutro'),
  ('RTID(ZombossVictoryOutro@LevelModules)', 'ZombossVictoryOutro'),
];

class _BasicInfoEscapeIntent extends Intent {
  const _BasicInfoEscapeIntent();
}

/// Full-screen level basic info editor. Ported from Z-Editor-master LevelDefinitionEP.kt
class BasicInfoScreen extends StatefulWidget {
  const BasicInfoScreen({
    super.key,
    required this.levelFile,
    required this.levelDef,
    required this.onBack,
    required     this.onStageTap,
    required this.onChanged,
  });

  final PvzLevelFile levelFile;
  final LevelDefinitionData levelDef;
  final VoidCallback onBack;
  final Future<void> Function(
    LevelDefinitionData levelDef,
    VoidCallback onStagePicked,
  )? onStageTap;
  final VoidCallback onChanged;

  @override
  State<BasicInfoScreen> createState() => _BasicInfoScreenState();
}

class _BasicInfoScreenState extends State<BasicInfoScreen> {
  late TextEditingController _nameCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _levelNumCtrl;
  late TextEditingController _sunCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.levelDef.name);
    _descCtrl = TextEditingController(text: widget.levelDef.description);
    _levelNumCtrl = TextEditingController(text: '${widget.levelDef.levelNumber ?? 1}');
    _sunCtrl = TextEditingController(text: '${widget.levelDef.startingSun ?? 200}');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    _levelNumCtrl.dispose();
    _sunCtrl.dispose();
    super.dispose();
  }

  Widget _rectangularTextField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    required VoidCallback onChanged,
  }) {
    final focusColor = Theme.of(context).colorScheme.primary;
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      decoration: editorInputDecoration(
        context,
        labelText: label,
        focusColor: focusColor,
      ),
      onChanged: (_) => onChanged(),
    );
  }

  void _sync() {
    final def = widget.levelDef;
    def.name = _nameCtrl.text;
    def.description = _descCtrl.text;
    def.levelNumber = int.tryParse(_levelNumCtrl.text) ?? 1;
    def.startingSun = int.tryParse(_sunCtrl.text) ?? 200;
    final obj = widget.levelFile.objects.where((o) => o.objClass == 'LevelDefinition').firstOrNull;
    if (obj != null) obj.objData = def.toJson();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final def = widget.levelDef;
    final theme = Theme.of(context);
    final stageInfo = RtidParser.parse(def.stageModule);
    final isDesktop = theme.platform == TargetPlatform.windows ||
        theme.platform == TargetPlatform.macOS ||
        theme.platform == TargetPlatform.linux;
    final sectionStyle = theme.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.primary,
    );

    Widget scaffold = Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        title: Text(l10n?.levelBasicInfo ?? 'Level basic info'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n?.basicInfoSection ?? 'Basic info', style: sectionStyle),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _rectangularTextField(
                      context,
                      controller: _nameCtrl,
                      label: '${l10n?.name ?? 'Name'} (Name)',
                      onChanged: _sync,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _rectangularTextField(
                            context,
                            controller: _levelNumCtrl,
                            label: l10n?.levelNumber ?? 'Level number',
                            keyboardType: TextInputType.number,
                            onChanged: _sync,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _rectangularTextField(
                            context,
                            controller: _sunCtrl,
                            label: l10n?.startingSun ?? 'Initial sun',
                            keyboardType: TextInputType.number,
                            onChanged: _sync,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    _rectangularTextField(
                      context,
                      controller: _descCtrl,
                      label: '${l10n?.description ?? 'Description'} (Description)',
                      maxLines: 2,
                      onChanged: _sync,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(l10n?.sceneSettingsSection ?? 'Scene settings', style: sectionStyle),
            const SizedBox(height: 12),
            Card(
              child: InkWell(
                onTap: () {
                  widget.onStageTap?.call(def, () {
                    if (mounted) setState(() {});
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: SizedBox(
                          width: 96,
                          height: 96,
                          child: () {
                            if (stageInfo == null) {
                              return const AssetImageWidget(
                                assetPath: 'assets/images/others/unknown.webp',
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              );
                            }
                            final stageItem = StageRepository.allItems
                                .where((s) => s.alias == stageInfo.alias)
                                .firstOrNull;
                            final iconName = stageItem?.iconName;
                            if (iconName != null) {
                              return AssetImageWidget(
                                assetPath: 'assets/images/round_icons/$iconName',
                                altCandidates: imageAltCandidates('assets/images/round_icons/$iconName'),
                                width: 96,
                                height: 96,
                                fit: BoxFit.cover,
                              );
                            }
                            return const AssetImageWidget(
                              assetPath: 'assets/images/others/unknown.webp',
                              width: 96,
                              height: 96,
                              fit: BoxFit.cover,
                            );
                          }(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${l10n?.stageModule ?? 'Stage module'} (StageModule)',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            Text(
                              stageInfo != null
                                  ? ResourceNames.lookup(
                                      context,
                                      StageRepository.getName(stageInfo.alias),
                                    )
                                  : def.stageModule,
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios, size: 16),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  initialValue: _musicTypeOptions.map((e) => e.$1).contains(def.musicType)
                      ? def.musicType
                      : 'MainPath',
                  decoration: editorInputDecoration(
                    context,
                    labelText: '${l10n?.musicType ?? 'Music type'} (MusicType)',
                    focusColor: theme.colorScheme.primary,
                  ),
                  items: _musicTypeOptions.map((e) => DropdownMenuItem(
                    value: e.$1,
                    child: Text(e.$2),
                  )).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        def.musicType = v;
                        _sync();
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  initialValue: _lootOptions.map((e) => e.$1).contains(def.loot)
                      ? def.loot
                      : _lootOptions.first.$1,
                  decoration: editorInputDecoration(
                    context,
                    labelText: '${l10n?.loot ?? 'Loot'} (Loot)',
                    focusColor: theme.colorScheme.primary,
                  ),
                  items: _lootOptions.map((e) => DropdownMenuItem(
                    value: e.$1,
                    child: Text(e.$2),
                  )).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        def.loot = v;
                        _sync();
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: DropdownButtonFormField<String>(
                  initialValue: _victoryOptions.map((e) => e.$1).contains(def.victoryModule)
                      ? def.victoryModule
                      : _victoryOptions.first.$1,
                  decoration: editorInputDecoration(
                    context,
                    labelText: '${l10n?.victoryModule ?? 'Victory module'} (VictoryModule)',
                    focusColor: theme.colorScheme.primary,
                  ),
                  items: _victoryOptions.map((e) => DropdownMenuItem(
                    value: e.$1,
                    child: Text(e.$2),
                  )).toList(),
                  onChanged: (v) {
                    if (v != null) {
                      setState(() {
                        def.victoryModule = v;
                        _sync();
                      });
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 8),
            EditorWarningBanner(
              margin: EdgeInsets.zero,
              message: l10n?.victoryModuleWarning ??
                  'Using non-default victory modules may cause level crashes due to module conflicts. Use with caution.',
            ),
            const SizedBox(height: 24),
            Text(l10n?.restrictionsSection ?? 'Restrictions', style: sectionStyle),
            const SizedBox(height: 12),
            Card(
              child: SwitchListTile(
                title: Text(l10n?.disablePeavine ?? 'Disable peavine', style: theme.textTheme.bodyMedium),
                value: def.disablePeavine ?? false,
                onChanged: (v) {
                  setState(() {
                    def.disablePeavine = v;
                    _sync();
                  });
                },
              ),
            ),
            Card(
              child: SwitchListTile(
                title: Text(l10n?.disableArtifact ?? 'Disable artifact', style: theme.textTheme.bodyMedium),
                value: def.isArtifactDisabled ?? false,
                onChanged: (v) {
                  setState(() {
                    def.isArtifactDisabled = v;
                    _sync();
                  });
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (isDesktop) {
      scaffold = Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.escape): _BasicInfoEscapeIntent(),
        },
        child: Actions(
          actions: {
            _BasicInfoEscapeIntent: CallbackAction<_BasicInfoEscapeIntent>(
              onInvoke: (_) {
                widget.onBack();
                return null;
              },
            ),
          },
          child: scaffold,
        ),
      );
    }
    return scaffold;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    return it.moveNext() ? it.current : null;
  }
}

