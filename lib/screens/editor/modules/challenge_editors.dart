import 'package:flutter/material.dart';
import 'package:c_editor/data/challenge_resource_l10n.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/challenge_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/star_challenge_property_editors.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Shows challenge editor in an alert dialog instead of a separate screen.
Future<void> showChallengeEditorDialog(
  BuildContext context, {
  required PvzObject object,
  required VoidCallback onChanged,
  Color? accentColor,
  PvzLevelFile? levelFile,
  void Function(String objClass)? onAddModule,
  Future<void> Function()? onOpenCustomStageSelection,
}) async {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final accent = accentColor ?? (isDark ? pvzOrangeDark : pvzOrangeLight);
  final onAccent = theme.colorScheme.onPrimary;
  final title = _friendlyTitleFor(context, object.objClass, l10n);
  final description = ChallengeRepository.localizedDescription(
    context,
    object.objClass,
  );
  final dialogTheme = theme.copyWith(
    colorScheme: theme.colorScheme.copyWith(primary: accent),
    inputDecorationTheme: theme.inputDecorationTheme.copyWith(
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: accent, width: 2),
      ),
      floatingLabelStyle: WidgetStateTextStyle.resolveWith((states) {
        if (states.contains(WidgetState.focused)) {
          return TextStyle(color: accent);
        }
        return TextStyle(color: theme.colorScheme.onSurface);
      }),
      focusColor: accent,
    ),
  );
  await showDialog<void>(
    context: context,
    builder: (ctx) {
      final compact = MediaQuery.sizeOf(ctx).width < 480;
      final horizontalInset = compact ? 12.0 : 40.0;
      final contentInset = compact ? 20.0 : 24.0;
      return Theme(
        data: dialogTheme,
        child: AlertDialog(
          insetPadding: EdgeInsets.symmetric(
            horizontal: horizontalInset,
            vertical: compact ? 16 : 24,
          ),
          titlePadding: EdgeInsets.fromLTRB(
            contentInset,
            contentInset,
            contentInset,
            12,
          ),
          contentPadding: EdgeInsets.fromLTRB(contentInset, 0, contentInset, 8),
          actionsPadding: EdgeInsets.fromLTRB(
            contentInset,
            8,
            contentInset,
            16,
          ),
          title: Text(
            title,
            style: compact
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  )
                : theme.textTheme.titleLarge,
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (description.trim().isNotEmpty) ...[
                    Text(
                      description,
                      key: const ValueKey('starChallengeDialogDescription'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  ChallengeEditorContent(
                    object: object,
                    onChanged: onChanged,
                    l10n: l10n,
                    levelFile: levelFile,
                    onAddModule: onAddModule,
                    onOpenCustomStageSelection: onOpenCustomStageSelection,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              style: TextButton.styleFrom(foregroundColor: accent),
              child: Text(l10n?.cancel ?? 'Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx),
              style: FilledButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: onAccent,
              ),
              child: Text(l10n?.save ?? 'Save'),
            ),
          ],
        ),
      );
    },
  );
}

Widget _challengeTextFormField({
  Key? key,
  required String label,
  required String initialValue,
  required ValueChanged<String> onChanged,
  TextInputType? keyboardType,
  int maxLines = 1,
}) {
  return EditorResponsiveInputField(
    label: label,
    builder: (context, decoration) => TextFormField(
      key: key,
      initialValue: initialValue,
      decoration: decoration,
      keyboardType: keyboardType,
      maxLines: maxLines,
      onChanged: onChanged,
    ),
  );
}

Widget _challengeEditableEntityField({
  required Widget field,
  required VoidCallback onRemove,
}) {
  return LayoutBuilder(
    builder: (context, constraints) {
      final textScale = MediaQuery.textScalerOf(context).scale(16) / 16;
      final compact = constraints.maxWidth < 360 || textScale > 1.3;
      final removeButton = IconButton(
        icon: const Icon(Icons.delete),
        onPressed: onRemove,
      );
      if (compact) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(alignment: Alignment.centerRight, child: removeButton),
            field,
          ],
        );
      }
      return Row(
        children: [
          Expanded(child: field),
          removeButton,
        ],
      );
    },
  );
}

String _friendlyTitleFor(
  BuildContext context,
  String objClass,
  AppLocalizations? l10n,
) {
  if (ChallengeRepository.getInfo(objClass) != null) {
    return ChallengeRepository.localizedTitle(context, objClass);
  }
  switch (objClass) {
    case 'ProtectThePlantChallengeProperties':
      return l10n?.protectPlants ?? 'Protect plants';
    case 'ProtectTheGridItemChallengeProperties':
      return l10n?.protectGridItems ?? 'Protect grid items';
    case 'SunBombChallengeProperties':
      return l10n?.sunBomb ?? 'Sun bomb';
    case 'ZombiePotionModuleProperties':
      return l10n?.zombiePotion ?? 'Zombie potion';
    case 'PennyClassroomModuleProperties':
      return l10n?.pennyClassroom ?? 'Penny classroom';
    case 'ManholePipelineModuleProperties':
      return l10n?.manholePipeline ?? 'Manhole pipeline';
    default:
      return objClass;
  }
}

/// Shared editor content used by both full screen and dialog.
class ChallengeEditorContent extends StatelessWidget {
  const ChallengeEditorContent({
    super.key,
    required this.object,
    required this.onChanged,
    this.l10n,
    this.levelFile,
    this.onAddModule,
    this.onOpenCustomStageSelection,
  });

  final PvzObject object;
  final VoidCallback onChanged;
  final AppLocalizations? l10n;
  final PvzLevelFile? levelFile;
  final void Function(String objClass)? onAddModule;
  final Future<void> Function()? onOpenCustomStageSelection;

  @override
  Widget build(BuildContext context) {
    final l10n = this.l10n ?? AppLocalizations.of(context);
    switch (object.objClass) {
      case 'StarChallengeBeatTheLevelProps':
        return _BeatTheLevelEditor(
          l10n: l10n,
          object: object,
          onChanged: onChanged,
        );
      case 'StarChallengeSaveMowersProps':
      case 'StarChallengePlantFoodNonuseProps':
        return Center(
          child: Text(
            l10n?.challengeNoConfig ??
                "This challenge doesn't support configuration.",
          ),
        );
      case 'StarChallengePlantsSurviveProps':
        return _SimpleCountEditor(
          object: object,
          field: 'Count',
          onChanged: onChanged,
        );
      case 'StarChallengeZombieDistanceProps':
        return _SimpleDoubleEditor(
          object: object,
          field: 'TargetDistance',
          label: ChallengeResourceL10n.property(
            context,
            object.objClass,
            'TargetDistance',
            l10n?.targetDistance,
          ),
          hint: l10n?.starChallengeTargetDistanceHint,
          onChanged: onChanged,
        );
      case 'StarChallengeSunProducedProps':
        return _SimpleCountEditor(
          object: object,
          field: 'TargetSun',
          onChanged: onChanged,
        );
      case 'StarChallengeSunUsedProps':
        return _SimpleCountEditor(
          object: object,
          field: 'MaximumSun',
          onChanged: onChanged,
        );
      case 'StarChallengeSpendSunHoldoutProps':
        return _SimpleCountEditor(
          object: object,
          field: 'HoldoutSeconds',
          onChanged: onChanged,
        );
      case 'StarChallengeKillZombiesInTimeProps':
        return _KillZombiesInTimeEditor(
          l10n: l10n,
          object: object,
          onChanged: onChanged,
        );
      case 'StarChallengeZombieSpeedProps':
        return _SimpleDoubleEditor(
          object: object,
          field: 'SpeedModifier',
          label: ChallengeResourceL10n.property(
            context,
            object.objClass,
            'SpeedModifier',
            l10n?.speedModifier,
          ),
          hint: l10n?.starChallengeSpeedModifierHint,
          onChanged: onChanged,
        );
      case 'StarChallengeSunReducedProps':
        return _SimpleDoubleEditor(
          object: object,
          field: 'sunModifier',
          label: ChallengeResourceL10n.property(
            context,
            object.objClass,
            'sunModifier',
            l10n?.sunModifier,
          ),
          hint: l10n?.starChallengeSunModifierHint,
          onChanged: onChanged,
        );
      case 'StarChallengePlantsLostProps':
        return _SimpleCountEditor(
          object: object,
          field: 'MaximumPlantsLost',
          onChanged: onChanged,
        );
      case 'StarChallengeSimultaneousPlantsProps':
        return _SimpleCountEditor(
          object: object,
          field: 'MaximumPlants',
          onChanged: onChanged,
        );
      case 'StarChallengeUnfreezePlantsProps':
        return _SimpleCountEditor(
          object: object,
          field: 'Count',
          onChanged: onChanged,
        );
      case 'StarChallengeBlowZombieProps':
        return _SimpleCountEditor(
          object: object,
          field: 'Count',
          onChanged: onChanged,
        );
      case 'StarChallengeTargetScoreProps':
        return _SimpleCountEditor(
          object: object,
          field: 'TargetScore',
          onChanged: onChanged,
        );
      case 'ApplyZombieConditionsChallengeProps':
        return ApplyZombieConditionsChallengeEditor(
          object: object,
          onChanged: onChanged,
        );
      case 'PlantDefeatZombieChallengeProps':
        return PlantDefeatZombieChallengeEditor(
          object: object,
          onChanged: onChanged,
          levelFile: levelFile,
        );
      case 'DefeatZombiesOfTypeChallengeProps':
        return DefeatZombiesOfTypeChallengeEditor(
          object: object,
          onChanged: onChanged,
          levelFile: levelFile,
        );
      case 'DestroyGridItemsChallengeProps':
        return DestroyGridItemsChallengeEditor(
          object: object,
          onChanged: onChanged,
          levelFile: levelFile,
          onAddModule: onAddModule,
          onOpenCustomStageSelection: onOpenCustomStageSelection,
        );
      case 'StarChallengeDisablePlantProps':
        return StarChallengeDisablePlantEditor(
          object: object,
          onChanged: onChanged,
        );
      case 'StarChallengeSandstormZombieKillProps':
      case 'StarChallengeTentZombieKillProps':
      case 'StarChallengeBufferTileZombieKillProps':
      case 'StarChallengePotionZombieKillProps':
      case 'StarChallengeBarrelPowderZombieKillProps':
      case 'StarChallengeBlowBarrelZombieProps':
      case 'StarChallengeFirecrackerZombieKillProps':
      case 'StarChallengeFireworksZombieKillProps':
        return StarChallengeCountFieldEditor(
          object: object,
          onChanged: onChanged,
          field: 'Count',
        );
      case 'ZombiePerfumerChallengeProps':
        return StarChallengeCountFieldEditor(
          object: object,
          onChanged: onChanged,
          field: 'PoisonToClean',
          defaultValue: 3,
        );
      case 'BalletSlipChallengeProps':
        return StarChallengeCountFieldEditor(
          object: object,
          onChanged: onChanged,
          field: 'BalletToSlip',
        );
      case 'ZombieExplodenutChallengeProps':
        return StarChallengeCountFieldEditor(
          object: object,
          onChanged: onChanged,
          field: 'MaximumExplode',
          defaultValue: 5,
        );
      case 'ZombieJalapenoChallengeProps':
        return StarChallengeCountFieldEditor(
          object: object,
          onChanged: onChanged,
          field: 'MaximumJalapeno',
          defaultValue: 5,
        );
      case 'RenaiRollerChallengeProps':
        return StarChallengeCountFieldEditor(
          object: object,
          onChanged: onChanged,
          field: 'MaximumPlantsDied',
          defaultValue: 5,
        );
      case 'ZombiePeaChallengeProps':
        return StarChallengeCountFieldEditor(
          object: object,
          onChanged: onChanged,
          field: 'MaximumPlantsHitted',
          defaultValue: 80,
        );
      case 'SteamManholeChallengeProps':
        return StarChallengeCountFieldEditor(
          object: object,
          onChanged: onChanged,
          field: 'MaximumManholeEntered',
          defaultValue: 5,
        );
      case 'ProtectThePlantChallengeProperties':
        return _ProtectThePlantEditor(
          l10n: l10n,
          object: object,
          onChanged: onChanged,
        );
      case 'ProtectTheGridItemChallengeProperties':
        return _ProtectTheGridItemEditor(
          l10n: l10n,
          object: object,
          onChanged: onChanged,
        );
      case 'SunBombChallengeProperties':
        return _SunBombEditor(l10n: l10n, object: object, onChanged: onChanged);
      case 'ZombiePotionModuleProperties':
        return _ZombiePotionModuleEditor(
          l10n: l10n,
          object: object,
          onChanged: onChanged,
        );
      case 'PennyClassroomModuleProperties':
        return _PennyClassroomEditor(
          l10n: l10n,
          object: object,
          onChanged: onChanged,
        );
      case 'ManholePipelineModuleProperties':
        return _ManholePipelineEditor(
          l10n: l10n,
          object: object,
          onChanged: onChanged,
        );
      default:
        return Text(l10n?.unknownChallengeType ?? 'Unknown challenge type');
    }
  }
}

class ChallengeEditorScreen extends StatefulWidget {
  const ChallengeEditorScreen({
    super.key,
    required this.object,
    required this.onChanged,
  });

  final PvzObject object;
  final VoidCallback onChanged;

  @override
  State<ChallengeEditorScreen> createState() => _ChallengeEditorScreenState();
}

class _ChallengeEditorScreenState extends State<ChallengeEditorScreen> {
  String _friendlyTitle(AppLocalizations? l10n) {
    return _friendlyTitleFor(context, widget.object.objClass, l10n);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.maybePop(context),
        ),
        title: Text(_friendlyTitle(l10n)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: ChallengeEditorContent(
          object: widget.object,
          onChanged: widget.onChanged,
          l10n: l10n,
        ),
      ),
    );
  }
}

class _BeatTheLevelEditor extends StatefulWidget {
  const _BeatTheLevelEditor({
    required this.l10n,
    required this.object,
    required this.onChanged,
  });
  final AppLocalizations? l10n;
  final PvzObject object;
  final VoidCallback onChanged;

  @override
  State<_BeatTheLevelEditor> createState() => _BeatTheLevelEditorState();
}

class _BeatTheLevelEditorState extends State<_BeatTheLevelEditor> {
  late TextEditingController _nameController;

  Map<String, dynamic> get _data =>
      widget.object.objData as Map<String, dynamic>;

  String get _objClass => widget.object.objClass;

  @override
  void initState() {
    super.initState();
    _data.putIfAbsent('Description', () => '');
    _data.putIfAbsent('DescriptiveName', () => '');
    _nameController = TextEditingController(
      text: _data['DescriptiveName'] as String? ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n ?? AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        StarChallengeDescriptionField(
          label: ChallengeResourceL10n.property(
            context,
            _objClass,
            'Description',
          ),
          hint: l10n?.beatTheLevelDialogHint,
          value: _data['Description'] as String? ?? '',
          onChanged: (v) {
            setState(() {
              _data['Description'] = v;
              _save();
            });
          },
        ),
        const SizedBox(height: 12),
        EditorResponsiveInputField(
          label: ChallengeResourceL10n.property(
            context,
            _objClass,
            'DescriptiveName',
            l10n?.descriptiveName,
          ),
          builder: (context, decoration) => TextField(
            controller: _nameController,
            decoration: decoration,
            onChanged: (v) {
              _data['DescriptiveName'] = v;
              _save();
            },
          ),
        ),
      ],
    );
  }
}

class _SimpleCountEditor extends StatelessWidget {
  const _SimpleCountEditor({
    required this.object,
    required this.field,
    required this.onChanged,
  });

  final PvzObject object;
  final String field;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final data = object.objData as Map<String, dynamic>;
    return EditorResponsiveInputField(
      label: ChallengeResourceL10n.property(context, object.objClass, field),
      builder: (context, decoration) => TextFormField(
        initialValue: (data[field] ?? 0).toString(),
        decoration: decoration,
        keyboardType: TextInputType.number,
        onChanged: (val) {
          data[field] = int.tryParse(val) ?? 0;
          onChanged();
        },
      ),
    );
  }
}

class _SimpleDoubleEditor extends StatelessWidget {
  const _SimpleDoubleEditor({
    required this.object,
    required this.field,
    required this.label,
    this.hint,
    required this.onChanged,
  });

  final PvzObject object;
  final String field;
  final String label;
  final String? hint;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final data = object.objData as Map<String, dynamic>;
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EditorResponsiveInputField(
          label: label,
          builder: (context, decoration) => TextFormField(
            initialValue: (data[field] ?? 0.0).toString(),
            decoration: decoration,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (val) {
              data[field] = double.tryParse(val) ?? 0.0;
              onChanged();
            },
          ),
        ),
        if (hint?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 6),
          Text(
            hint!,
            key: ValueKey('starChallengeHint_$field'),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ],
    );
  }
}

class _KillZombiesInTimeEditor extends StatelessWidget {
  const _KillZombiesInTimeEditor({
    required this.l10n,
    required this.object,
    required this.onChanged,
  });
  final AppLocalizations? l10n;
  final PvzObject object;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final data = object.objData as Map<String, dynamic>;
    return Column(
      children: [
        EditorResponsiveInputField(
          label: l10n?.zombiesToKill ?? 'Zombies To Kill',
          builder: (context, decoration) => TextFormField(
            initialValue: (data['ZombiesToKill'] ?? 10).toString(),
            decoration: decoration,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              data['ZombiesToKill'] = int.tryParse(val) ?? 10;
              onChanged();
            },
          ),
        ),
        const SizedBox(height: 12),
        _challengeTextFormField(
          key: const ValueKey('starChallengeKillTime'),
          label: l10n?.timeSeconds ?? 'Time (Seconds)',
          initialValue: (data['Time'] ?? 10).toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            data['Time'] = int.tryParse(val) ?? 10;
            onChanged();
          },
        ),
      ],
    );
  }
}

class _ProtectThePlantEditor extends StatefulWidget {
  const _ProtectThePlantEditor({
    required this.l10n,
    required this.object,
    required this.onChanged,
  });
  final AppLocalizations? l10n;
  final PvzObject object;
  final VoidCallback onChanged;

  @override
  State<_ProtectThePlantEditor> createState() => _ProtectThePlantEditorState();
}

class _ProtectThePlantEditorState extends State<_ProtectThePlantEditor> {
  late ProtectThePlantChallengePropertiesData _data;

  @override
  void initState() {
    super.initState();
    _data = ProtectThePlantChallengePropertiesData.fromJson(
      widget.object.objData as Map<String, dynamic>,
    );
  }

  void _save() {
    widget.object.objData = _data.toJson();
    widget.onChanged();
  }

  void _addPlant() {
    setState(() {
      _data.plants.add(ProtectPlantData());
      _save();
    });
  }

  void _removePlant(int index) {
    setState(() {
      _data.plants.removeAt(index);
      _save();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n ?? AppLocalizations.of(context);
    return Column(
      children: [
        EditorResponsiveInputField(
          label: l10n?.mustProtectCountAll ?? 'Must Protect Count (0 = All)',
          builder: (context, decoration) => TextFormField(
            initialValue: _data.mustProtectCount.toString(),
            decoration: decoration,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              _data.mustProtectCount = int.tryParse(val) ?? 0;
              _save();
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n?.protectedPlants ?? 'Protected Plants',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _data.plants.length,
          itemBuilder: (ctx, idx) {
            final item = _data.plants[idx];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _challengeEditableEntityField(
                      field: _challengeTextFormField(
                        label: l10n?.plantType ?? 'Plant Type',
                        initialValue: item.plantType,
                        onChanged: (val) {
                          item.plantType = val;
                          _save();
                        },
                      ),
                      onRemove: () => _removePlant(idx),
                    ),
                    EditorResponsiveFieldRow(
                      children: [
                        _challengeTextFormField(
                          label: l10n?.gridX ?? 'Grid X',
                          initialValue: item.gridX.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            item.gridX = int.tryParse(val) ?? 0;
                            _save();
                          },
                        ),
                        _challengeTextFormField(
                          label: l10n?.gridY ?? 'Grid Y',
                          initialValue: item.gridY.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            item.gridY = int.tryParse(val) ?? 0;
                            _save();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        FilledButton.icon(
          onPressed: _addPlant,
          icon: const Icon(Icons.add),
          label: Text(l10n?.addPlant ?? 'Add Plant'),
        ),
      ],
    );
  }
}

class _ProtectTheGridItemEditor extends StatefulWidget {
  const _ProtectTheGridItemEditor({
    required this.l10n,
    required this.object,
    required this.onChanged,
  });
  final AppLocalizations? l10n;
  final PvzObject object;
  final VoidCallback onChanged;

  @override
  State<_ProtectTheGridItemEditor> createState() =>
      _ProtectTheGridItemEditorState();
}

class _ProtectTheGridItemEditorState extends State<_ProtectTheGridItemEditor> {
  late ProtectTheGridItemChallengePropertiesData _data;

  @override
  void initState() {
    super.initState();
    _data = ProtectTheGridItemChallengePropertiesData.fromJson(
      widget.object.objData as Map<String, dynamic>,
    );
  }

  void _save() {
    widget.object.objData = _data.toJson();
    widget.onChanged();
  }

  void _addItem() {
    setState(() {
      _data.gridItems.add(ProtectGridItemData());
      _save();
    });
  }

  void _removeItem(int index) {
    setState(() {
      _data.gridItems.removeAt(index);
      _save();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n ?? AppLocalizations.of(context);
    return Column(
      children: [
        _challengeTextFormField(
          label: l10n?.description ?? 'Description',
          initialValue: _data.description,
          maxLines: 3,
          onChanged: (val) {
            _data.description = val;
            _save();
          },
        ),
        EditorResponsiveInputField(
          label:
              l10n?.mustProtectCount(_data.mustProtectCount) ??
              'Must Protect Count',
          builder: (context, decoration) => TextFormField(
            initialValue: _data.mustProtectCount.toString(),
            decoration: decoration,
            keyboardType: TextInputType.number,
            onChanged: (val) {
              _data.mustProtectCount = int.tryParse(val) ?? 0;
              _save();
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          l10n?.protectedGridItems ?? 'Protected Grid Items',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _data.gridItems.length,
          itemBuilder: (ctx, idx) {
            final item = _data.gridItems[idx];
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    _challengeEditableEntityField(
                      field: _challengeTextFormField(
                        label: l10n?.gridItemType ?? 'Grid Item Type',
                        initialValue: item.gridItemType,
                        onChanged: (val) {
                          item.gridItemType = val;
                          _save();
                        },
                      ),
                      onRemove: () => _removeItem(idx),
                    ),
                    EditorResponsiveFieldRow(
                      children: [
                        _challengeTextFormField(
                          label: l10n?.gridX ?? 'Grid X',
                          initialValue: item.gridX.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            item.gridX = int.tryParse(val) ?? 0;
                            _save();
                          },
                        ),
                        _challengeTextFormField(
                          label: l10n?.gridY ?? 'Grid Y',
                          initialValue: item.gridY.toString(),
                          keyboardType: TextInputType.number,
                          onChanged: (val) {
                            item.gridY = int.tryParse(val) ?? 0;
                            _save();
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        FilledButton.icon(
          onPressed: _addItem,
          icon: const Icon(Icons.add),
          label: Text(l10n?.addGridItem ?? 'Add Grid Item'),
        ),
      ],
    );
  }
}

class _SunBombEditor extends StatefulWidget {
  const _SunBombEditor({
    required this.l10n,
    required this.object,
    required this.onChanged,
  });
  final AppLocalizations? l10n;
  final PvzObject object;
  final VoidCallback onChanged;

  @override
  State<_SunBombEditor> createState() => _SunBombEditorState();
}

class _SunBombEditorState extends State<_SunBombEditor> {
  late SunBombChallengeData _data;

  @override
  void initState() {
    super.initState();
    _data = SunBombChallengeData.fromJson(
      widget.object.objData as Map<String, dynamic>,
    );
  }

  void _save() {
    widget.object.objData = _data.toJson();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n ?? AppLocalizations.of(context);
    return Column(
      children: [
        _challengeTextFormField(
          label: l10n?.plantBombRadius ?? 'Plant Bomb Radius',
          initialValue: _data.plantBombExplosionRadius.toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            _data.plantBombExplosionRadius = int.tryParse(val) ?? 25;
            _save();
          },
        ),
        const SizedBox(height: 12),
        _challengeTextFormField(
          label: l10n?.zombieBombRadius ?? 'Zombie Bomb Radius',
          initialValue: _data.zombieBombExplosionRadius.toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            _data.zombieBombExplosionRadius = int.tryParse(val) ?? 80;
            _save();
          },
        ),
        const SizedBox(height: 12),
        _challengeTextFormField(
          label: l10n?.plantDamage ?? 'Plant Damage',
          initialValue: _data.plantDamage.toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            _data.plantDamage = int.tryParse(val) ?? 1000;
            _save();
          },
        ),
        const SizedBox(height: 12),
        _challengeTextFormField(
          label: l10n?.zombieDamage ?? 'Zombie Damage',
          initialValue: _data.zombieDamage.toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            _data.zombieDamage = int.tryParse(val) ?? 500;
            _save();
          },
        ),
      ],
    );
  }
}

class _ZombiePotionModuleEditor extends StatefulWidget {
  const _ZombiePotionModuleEditor({
    required this.l10n,
    required this.object,
    required this.onChanged,
  });
  final AppLocalizations? l10n;
  final PvzObject object;
  final VoidCallback onChanged;

  @override
  State<_ZombiePotionModuleEditor> createState() =>
      _ZombiePotionModuleEditorState();
}

class _ZombiePotionModuleEditorState extends State<_ZombiePotionModuleEditor> {
  static const _initialField = 'Initial';
  static const _maxCountField = 'MaxCount';
  static const _potionSpawnTimerField = 'PotionSpawnTimer';

  late ZombiePotionModulePropertiesData _data;

  @override
  void initState() {
    super.initState();
    _data = ZombiePotionModulePropertiesData.fromJson(
      widget.object.objData as Map<String, dynamic>,
    );
  }

  void _save() {
    widget.object.objData = _data.toJson();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = widget.l10n ?? AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _challengeTextFormField(
          label: localizedPropertyLabel(
            context,
            l10n.initialCount,
            _initialField,
          ),
          initialValue: _data.initialPotionCount.toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            _data.initialPotionCount = int.tryParse(val) ?? 10;
            _save();
          },
        ),
        const SizedBox(height: 12),
        _challengeTextFormField(
          label: localizedPropertyLabel(
            context,
            l10n.maximumCount,
            _maxCountField,
          ),
          initialValue: _data.maxPotionCount.toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            _data.maxPotionCount = int.tryParse(val) ?? 60;
            _save();
          },
        ),
        const SizedBox(height: 8),
        Text(
          localizedPropertyLabel(
            context,
            l10n.spawnInterval,
            _potionSpawnTimerField,
          ),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        EditorResponsiveFieldRow(
          children: [
            _challengeTextFormField(
              label: l10n.minimumIntervalSeconds,
              initialValue: _data.potionSpawnTimer.min.toString(),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                _data.potionSpawnTimer.min = int.tryParse(val) ?? 12;
                _save();
              },
            ),
            _challengeTextFormField(
              label: l10n.maximumIntervalSeconds,
              initialValue: _data.potionSpawnTimer.max.toString(),
              keyboardType: TextInputType.number,
              onChanged: (val) {
                _data.potionSpawnTimer.max = int.tryParse(val) ?? 16;
                _save();
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          l10n.potionTypesConfigured(_data.potionTypes.length),
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _PennyClassroomEditor extends StatefulWidget {
  const _PennyClassroomEditor({
    required this.l10n,
    required this.object,
    required this.onChanged,
  });
  final AppLocalizations? l10n;
  final PvzObject object;
  final VoidCallback onChanged;

  @override
  State<_PennyClassroomEditor> createState() => _PennyClassroomEditorState();
}

class _PennyClassroomEditorState extends State<_PennyClassroomEditor> {
  late PennyClassroomModuleData _data;

  @override
  void initState() {
    super.initState();
    _data = PennyClassroomModuleData.fromJson(
      widget.object.objData as Map<String, dynamic>,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n ?? AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.plantLevelsCount(_data.plantMap.length) ??
              'Plant levels: ${_data.plantMap.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ..._data.plantMap.entries.map((e) {
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Row(
                children: [
                  Expanded(child: Text(e.key)),
                  Text(l10n?.lvN(e.value) ?? 'Lv ${e.value}'),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _ManholePipelineEditor extends StatefulWidget {
  const _ManholePipelineEditor({
    required this.l10n,
    required this.object,
    required this.onChanged,
  });
  final AppLocalizations? l10n;
  final PvzObject object;
  final VoidCallback onChanged;

  @override
  State<_ManholePipelineEditor> createState() => _ManholePipelineEditorState();
}

class _ManholePipelineEditorState extends State<_ManholePipelineEditor> {
  late ManholePipelineModuleData _data;

  @override
  void initState() {
    super.initState();
    _data = ManholePipelineModuleData.fromJson(
      widget.object.objData as Map<String, dynamic>,
    );
  }

  void _save() {
    widget.object.objData = _data.toJson();
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = widget.l10n ?? AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _challengeTextFormField(
          label: l10n?.operationTimePerGrid ?? 'Operation Time Per Grid',
          initialValue: _data.operationTimePerGrid.toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            _data.operationTimePerGrid = int.tryParse(val) ?? 1;
            _save();
          },
        ),
        const SizedBox(height: 12),
        _challengeTextFormField(
          label: l10n?.damagePerSecond ?? 'Damage Per Second',
          initialValue: _data.damagePerSecond.toString(),
          keyboardType: TextInputType.number,
          onChanged: (val) {
            _data.damagePerSecond = int.tryParse(val) ?? 30;
            _save();
          },
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.pipelinesCount(_data.pipelineList.length) ??
              'Pipelines: ${_data.pipelineList.length}',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
