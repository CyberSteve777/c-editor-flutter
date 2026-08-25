import 'dart:async';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/models/zomboss_custom_action_preset.dart';
import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models/PvzObject.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/repository/zomboss_custom_action_preset_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/zomboss_mech_action_ordering.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:c_editor/data/zomboss_mech_l10n.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/alias_rename_dialog.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/separated_option_picker_field.dart';
import 'package:c_editor/widgets/zomboss_mech_action_fields.dart';

/// Creates or edits a level-local zomboss action ([CurrentLevel]).
class CustomZombossMechActionEditorScreen extends StatefulWidget {
  const CustomZombossMechActionEditorScreen({
    super.key,
    required this.catalog,
    required this.levelFile,
    this.existingRtid,
    this.retreatOnly = false,
    this.propsData,
    this.onPropsSync,
  });

  final ZombossMechCatalogEntry catalog;
  final PvzLevelFile levelFile;
  final String? existingRtid;
  final bool retreatOnly;
  final Map<String, dynamic>? propsData;
  final VoidCallback? onPropsSync;

  @override
  State<CustomZombossMechActionEditorScreen> createState() =>
      _CustomZombossMechActionEditorScreenState();
}

class _CustomZombossMechActionEditorScreenState
    extends State<CustomZombossMechActionEditorScreen> {
  PvzObject? _obj;
  late Map<String, dynamic> _data;
  late String _alias;
  late String _objclass;
  late String _baseActionAlias;
  late TextEditingController _aliasCtrl;
  late bool _aliasManuallyEdited;
  late final PvzLevelFile _initialLevelSnapshot;
  late final Map<String, dynamic>? _initialPropsSnapshot;
  late final Map<String, dynamic> _initialDataSnapshot;
  late final String _initialAliasText;
  late final String _initialObjclass;
  late final String _initialBaseActionAlias;
  bool _canPop = false;
  bool _exitDialogOpen = false;

  List<ZombossMechCatalogAction> get _baseActions {
    if (widget.retreatOnly) return widget.catalog.retreatCatalogActions;
    return ZombossMechActionOrdering.sortedCatalogActions(widget.catalog);
  }

  List<ZombossMechObjclassGroup> get _groups {
    final groups = widget.retreatOnly
        ? widget.catalog.actions.where((g) => g.tag == 'retreat')
        : widget.catalog.actions.where((g) => g.tag != 'retreat');
    final seen = <String>{};
    final list = groups.where((g) => seen.add(g.objclass)).toList();
    if (!widget.retreatOnly) {
      for (final group
          in ZombossCustomActionPresetRepository.actionGroupsForMech(
            widget.catalog.editableInstance,
          )) {
        if (seen.add(group.objclass)) {
          list.add(group);
        }
      }
    }
    return list;
  }

  ZombossMechObjclassGroup? get _group =>
      _groups.where((g) => g.objclass == _objclass).firstOrNull;

  ZombossCustomActionOrigin get _actionOrigin => _obj == null
      ? ZombossCustomActionOrigin.userCreated
      : ZombossCustomActionPresetRepository.originForObject(_obj!);

  bool get _usesBaseActionPicker =>
      _actionOrigin == ZombossCustomActionOrigin.userCreated;

  ZombossCustomActionPreset? get _dependencyPreset {
    if (_obj == null || _usesBaseActionPicker) return null;
    return ZombossCustomActionPresetRepository.presetForObject(_obj!);
  }

  ZombossCustomActionPresetDependency? get _awardDropDependencySpec {
    final preset = _dependencyPreset;
    if (preset == null) return null;
    final dependencyId = preset.dependencyRtidFields['AwardDrop'];
    if (dependencyId == null) return null;
    return preset.dependencies.firstWhereOrNull(
      (dependency) => dependency.id == dependencyId,
    );
  }

  String _actionTypeLabel(
    BuildContext context,
    ZombossMechObjclassGroup group,
  ) {
    return ZombossMechL10n.objclassLabel(context, group.objclass);
  }

  String _actionTypeName(BuildContext context, ZombossMechObjclassGroup group) {
    return ZombossMechL10n.actionLabel(
      context,
      widget.catalog.id,
      group.objclass,
      fallback: group.objclass,
    );
  }

  String _baseActionLabel(
    BuildContext context,
    ZombossMechCatalogAction action,
  ) {
    return ZombossMechL10n.implementationDisplayLabel(
      context,
      widget.catalog.id,
      action.alias,
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.existingRtid != null) {
      _loadExisting(widget.existingRtid!);
    } else {
      final action = _baseActions.firstOrNull;
      final group = _groups.firstOrNull ?? widget.catalog.actions.first;
      _objclass = action?.objclass ?? group.objclass;
      _baseActionAlias =
          action?.alias ??
          group.implementations.keys.firstOrNull ??
          'CustomAction';
      final sampleAlias = _baseActionAlias;
      _alias = ZombossMechActionUtils.uniqueCustomAlias(
        widget.levelFile,
        sampleAlias,
      );
      _data = action == null
          ? ZombossMechActionUtils.defaultsFromFields(group.fields)
          : ZombossMechActionUtils.dataFromCatalogAction(action);
    }
    _aliasCtrl = TextEditingController(text: _alias);
    _aliasManuallyEdited =
        widget.existingRtid != null &&
        !_looksLikeGeneratedAlias(_alias, _baseActionAlias);
    _initialLevelSnapshot = _cloneLevel(widget.levelFile);
    _initialPropsSnapshot = widget.propsData == null
        ? null
        : _cloneMap(widget.propsData!);
    _initialDataSnapshot = _cloneMap(_data);
    _initialAliasText = _aliasCtrl.text;
    _initialObjclass = _objclass;
    _initialBaseActionAlias = _baseActionAlias;
  }

  PvzLevelFile _cloneLevel(PvzLevelFile levelFile) => PvzLevelFile.fromJson(
    jsonDecode(jsonEncode(levelFile.toJson())) as Map<String, dynamic>,
  );

  Map<String, dynamic> _cloneMap(Map<String, dynamic> value) =>
      Map<String, dynamic>.from(
        jsonDecode(jsonEncode(value)) as Map<String, dynamic>,
      );

  bool get _hasUnsavedChanges {
    const equality = DeepCollectionEquality();
    return _aliasCtrl.text != _initialAliasText ||
        _objclass != _initialObjclass ||
        _baseActionAlias != _initialBaseActionAlias ||
        !equality.equals(_data, _initialDataSnapshot) ||
        !equality.equals(
          widget.levelFile.toJson(),
          _initialLevelSnapshot.toJson(),
        ) ||
        !equality.equals(widget.propsData, _initialPropsSnapshot);
  }

  bool _looksLikeGeneratedAlias(String alias, String baseAlias) {
    if (alias == baseAlias) return true;
    return RegExp('^${RegExp.escape(baseAlias)}_[0-9]+\$').hasMatch(alias);
  }

  void _loadExisting(String rtid) {
    final info = RtidParser.parse(rtid);
    _alias = info?.alias ?? 'CustomAction';
    _obj = ZombossMechActionUtils.findLevelObject(widget.levelFile, rtid);
    _objclass = _obj?.objClass ?? _groups.first.objclass;
    final raw = _obj?.objData;
    _data = raw is Map<String, dynamic>
        ? Map<String, dynamic>.from(raw)
        : raw is Map
        ? Map<String, dynamic>.from(raw)
        : {};
    _baseActionAlias =
        ZombossMechActionUtils.inferBaseCatalogAction(
          catalog: widget.catalog,
          customAlias: _alias,
          objclass: _objclass,
          data: _data,
          retreatOnly: widget.retreatOnly,
        )?.alias ??
        _baseActions
            .where((action) => action.objclass == _objclass)
            .firstOrNull
            ?.alias ??
        _baseActions.firstOrNull?.alias ??
        '';
  }

  @override
  void dispose() {
    _aliasCtrl.dispose();
    super.dispose();
  }

  void _syncObject() {
    if (_obj == null) {
      _obj = ZombossMechActionUtils.createCustomAction(
        levelFile: widget.levelFile,
        objclass: _objclass,
        alias: _alias,
        data: _data,
      );
    } else {
      _obj!.aliases =
          ZombossCustomActionPresetRepository.aliasesWithPrimaryAlias(
            _alias,
            _obj!.aliases,
          );
      _obj!.objData = Map<String, dynamic>.from(_data);
    }
    widget.onPropsSync?.call();
  }

  PvzObject? _awardDropObject() {
    final value = _data['AwardDrop']?.toString() ?? '';
    return ZombossMechActionUtils.findLevelObject(widget.levelFile, value);
  }

  bool _hasValidAwardDrop() {
    final spec = _awardDropDependencySpec;
    if (spec == null) return true;
    return ZombossCustomActionPresetRepository.isValidDependencyObject(
      _awardDropObject(),
      spec,
    );
  }

  void _restoreDefaultAwardDrop() {
    final spec = _awardDropDependencySpec;
    if (spec == null) return;
    final created =
        ZombossCustomActionPresetRepository.createDependencyForField(
          levelFile: widget.levelFile,
          spec: spec,
        );
    setState(() {
      _data['AwardDrop'] = created.rtid;
      _syncObject();
    });
  }

  Widget _buildAwardDropEditor(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final spec = _awardDropDependencySpec;
    if (spec == null) return const SizedBox.shrink();
    final rtid = _data['AwardDrop']?.toString() ?? '';
    final dependency = _awardDropObject();
    final valid = ZombossCustomActionPresetRepository.isValidDependencyObject(
      dependency,
      spec,
    );
    if (!valid) {
      final colors = Theme.of(context).colorScheme;
      return Card(
        color: colors.errorContainer,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.error_outline, color: colors.onErrorContainer),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      l10n?.zombossMechAwardDropInvalidTitle ??
                          'Invalid SpawnBall reference',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: colors.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.zombossMechAwardDropInvalidBody(rtid) ??
                    'AwardDrop points to "$rtid", but it is not a valid CurrentLevel ZombieDropProps object.',
                style: TextStyle(color: colors.onErrorContainer),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: FilledButton.tonalIcon(
                  onPressed: _restoreDefaultAwardDrop,
                  icon: const Icon(Icons.cleaning_services_outlined),
                  label: Text(
                    l10n?.zombossMechAwardDropClearInvalid ??
                        'Clear invalid value and restore default',
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final raw = dependency!.objData;
    final dependencyData = raw is Map<String, dynamic>
        ? raw
        : Map<String, dynamic>.from(raw as Map);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n?.zombossMechSpawnBallSettings ??
                  'SpawnBall contents (ZombieDropProps)',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              rtid,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            ZombossMechActionFieldsEditor(
              mechId: widget.catalog.id,
              fields: spec.fields,
              data: dependencyData,
              objclass: spec.objclass,
              levelFile: widget.levelFile,
              onChanged: () {
                dependency.objData =
                    ZombossCustomActionPresetRepository.cloneDependencyData(
                      dependencyData,
                    );
                _syncObject();
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _tryApplyAlias(
    String newAlias, {
    bool confirmRename = true,
  }) async {
    final trimmed = newAlias.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed == _alias) {
      _aliasCtrl.text = trimmed;
      return true;
    }

    if (!ZombossMechActionUtils.isAliasAvailable(
      widget.levelFile,
      trimmed,
      except: _obj,
    )) {
      await showAliasAlreadyTakenDialog(context);
      _aliasCtrl.text = _alias;
      return false;
    }

    if (widget.existingRtid != null || _obj != null) {
      if (confirmRename) {
        final confirmed = await showAliasRenameConfirmDialog(
          context,
          oldAlias: _alias,
          newAlias: trimmed,
        );
        if (!confirmed) {
          _aliasCtrl.text = _alias;
          return false;
        }
      }
      ZombossMechActionUtils.renameCustomActionInLevel(
        levelFile: widget.levelFile,
        oldAlias: _alias,
        newAlias: trimmed,
        obj: _obj,
      );
      if (widget.propsData != null) {
        ZombossMechActionUtils.renameCustomActionReferences(
          propsData: widget.propsData!,
          oldAlias: _alias,
          newAlias: trimmed,
        );
      }
      widget.onPropsSync?.call();
    }

    setState(() {
      _alias = trimmed;
      _aliasCtrl.text = trimmed;
      _syncObject();
    });
    return true;
  }

  void _applyAlias(String newAlias) {
    unawaited(_tryApplyAlias(newAlias));
  }

  void _onObjclassChanged(String? value) {
    if (value == null || value == _objclass) return;
    final group = _groups.where((g) => g.objclass == value).firstOrNull;
    if (group == null) return;
    setState(() {
      _objclass = value;
      if (group.implementations.isNotEmpty) {
        _data = ZombossMechActionUtils.cloneMap(
          group.implementations.values.first,
        );
      } else {
        _data = ZombossMechActionUtils.defaultsFromFields(group.fields);
      }
      _syncObject();
    });
  }

  Future<void> _onBaseActionChanged(String alias) async {
    if (alias == _baseActionAlias) return;
    final action = _baseActions
        .where((candidate) => candidate.alias == alias)
        .firstOrNull;
    if (action == null) return;

    final suggestedAlias = ZombossMechActionUtils.uniqueCustomAlias(
      widget.levelFile,
      action.alias,
      except: _obj,
    );
    var syncAlias = !_aliasManuallyEdited;
    if (_aliasManuallyEdited) {
      final l10n = AppLocalizations.of(context);
      syncAlias =
          await showDialog<bool>(
            context: context,
            builder: (dialogContext) => AlertDialog(
              title: Text(
                l10n?.zombossMechBaseActionAliasSyncTitle ??
                    'Update the action codename?',
              ),
              content: Text(
                l10n?.zombossMechBaseActionAliasSyncMessage(suggestedAlias) ??
                    'Also update the action codename to "$suggestedAlias"?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext, false),
                  child: Text(
                    l10n?.zombossMechBaseActionAliasKeep ??
                        'Keep current codename',
                  ),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(dialogContext, true),
                  child: Text(
                    l10n?.zombossMechBaseActionAliasUpdate ?? 'Update codename',
                  ),
                ),
              ],
            ),
          ) ??
          false;
      if (!mounted) return;
    }

    if (syncAlias) {
      final applied = await _tryApplyAlias(
        suggestedAlias,
        confirmRename: false,
      );
      if (!mounted) return;
      if (applied) _aliasManuallyEdited = false;
    }
    setState(() {
      _baseActionAlias = action.alias;
      _objclass = action.objclass;
      _data = ZombossMechActionUtils.dataFromCatalogAction(action);
      _syncObject();
    });
  }

  Future<String?> _saveAction() async {
    if (widget.existingRtid == null && _obj == null) {
      final trimmed = _aliasCtrl.text.trim();
      if (trimmed.isEmpty) return null;
      if (!ZombossMechActionUtils.isAliasAvailable(widget.levelFile, trimmed)) {
        await showAliasAlreadyTakenDialog(context);
        return null;
      }
      _alias = trimmed;
    } else {
      final aliasOk = await _tryApplyAlias(_aliasCtrl.text);
      if (!aliasOk || !mounted) return null;
    }
    if (_obj == null && !_hasValidAwardDrop()) {
      _restoreDefaultAwardDrop();
    }
    _syncObject();
    return RtidParser.build(_alias, ZombossMechActionUtils.customSource);
  }

  void _exitWithResult(String? result) {
    if (!mounted) return;
    setState(() => _canPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.pop(context, result);
    });
  }

  Future<void> _saveAndExit() async {
    final result = await _saveAction();
    if (result != null && mounted) _exitWithResult(result);
  }

  void _restoreInitialState() {
    final restored = _cloneLevel(_initialLevelSnapshot);
    widget.levelFile
      ..objects.clear()
      ..objects.addAll(restored.objects)
      ..version = restored.version;
    if (widget.propsData != null && _initialPropsSnapshot != null) {
      widget.propsData!
        ..clear()
        ..addAll(_cloneMap(_initialPropsSnapshot));
    }
    widget.onPropsSync?.call();
  }

  Future<void> _confirmExit() async {
    if (_exitDialogOpen || !mounted) return;
    if (!_hasUnsavedChanges) {
      _exitWithResult(null);
      return;
    }
    _exitDialogOpen = true;
    final l10n = AppLocalizations.of(context);
    final choice = await showDialog<_CustomActionExitChoice>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n?.unsavedChanges ?? 'Unsaved changes'),
        content: Text(l10n?.saveBeforeLeaving ?? 'Save before leaving?'),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(dialogContext).colorScheme.error,
              foregroundColor: Theme.of(dialogContext).colorScheme.onError,
            ),
            onPressed: () =>
                Navigator.pop(dialogContext, _CustomActionExitChoice.discard),
            child: Text(l10n?.discard ?? 'Discard'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n?.stayInEditor ?? 'Stay'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, _CustomActionExitChoice.save),
            child: Text(l10n?.save ?? 'Save'),
          ),
        ],
      ),
    );
    _exitDialogOpen = false;
    if (!mounted) return;
    switch (choice) {
      case _CustomActionExitChoice.discard:
        _restoreInitialState();
        _exitWithResult(null);
        return;
      case _CustomActionExitChoice.save:
        await _saveAndExit();
        return;
      case null:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final group = _group;
    final isNew = widget.existingRtid == null;

    return PopScope(
      canPop: _canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _confirmExit();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _confirmExit,
          ),
          title: Text(
            isNew
                ? (l10n?.zombossMechCreateCustomAction ?? 'New custom action')
                : (l10n?.zombossMechEditCustomAction ?? 'Edit custom action'),
          ),
          actions: [
            IconButton(
              onPressed: _saveAndExit,
              tooltip: l10n?.save ?? 'Save',
              icon: Icon(
                Icons.save,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _aliasCtrl,
              decoration: editorInputDecoration(
                context,
                labelText: l10n?.aliasLabel ?? 'Alias',
                hintText:
                    l10n?.zombossMechActionAliasHint ??
                    'Codename used in RTID(alias@CurrentLevel).',
              ),
              onChanged: (_) => _aliasManuallyEdited = true,
              onFieldSubmitted: _applyAlias,
            ),
            const SizedBox(height: 12),
            if (_usesBaseActionPicker)
              SeparatedOptionPickerField<String>(
                labelText: l10n?.zombossMechActionBaseAction ?? 'Base Action',
                value:
                    _baseActions.any(
                      (action) => action.alias == _baseActionAlias,
                    )
                    ? _baseActionAlias
                    : _baseActions.firstOrNull?.alias,
                items: [
                  for (final action in _baseActions)
                    SeparatedOptionPickerItem(
                      value: action.alias,
                      label: ZombossMechL10n.implementationLabel(
                        context,
                        widget.catalog.id,
                        action.alias,
                      ),
                      subtitle: action.alias,
                      fieldLabel: _baseActionLabel(context, action),
                    ),
                ],
                onChanged: _onBaseActionChanged,
              )
            else
              SeparatedOptionPickerField<String>(
                labelText:
                    l10n?.zombossMechActionBaseObjclass ?? 'Base objclass',
                value: _groups.any((g) => g.objclass == _objclass)
                    ? _objclass
                    : _groups.firstOrNull?.objclass,
                items: [
                  for (final g in _groups)
                    SeparatedOptionPickerItem(
                      value: g.objclass,
                      label: _actionTypeName(context, g),
                      subtitle: g.objclass,
                      fieldLabel: _actionTypeLabel(context, g),
                    ),
                ],
                enabled: widget.existingRtid == null,
                onChanged: (value) => _onObjclassChanged(value),
              ),
            const SizedBox(height: 16),
            if (group != null)
              ZombossMechActionFieldsEditor(
                mechId: widget.catalog.id,
                fields: group.fields,
                data: _data,
                objclass: _objclass,
                levelFile: widget.levelFile,
                hiddenFieldNames: _awardDropDependencySpec == null
                    ? const {}
                    : const {'AwardDrop'},
                onChanged: () {
                  _syncObject();
                  setState(() {});
                },
              ),
            if (_awardDropDependencySpec != null) ...[
              const SizedBox(height: 16),
              _buildAwardDropEditor(context),
            ],
          ],
        ),
      ),
    );
  }
}

enum _CustomActionExitChoice { discard, save }
