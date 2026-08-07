import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/models/zomboss_custom_action_preset.dart';
import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models/PvzObject.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/repository/zomboss_custom_action_preset_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/zomboss_mech_action_utils.dart';
import 'package:c_editor/data/zomboss_mech_l10n.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/alias_rename_dialog.dart';
import 'package:c_editor/widgets/editor_components.dart';
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

  List<ZombossMechCatalogAction> get _baseActions => widget
      .catalog
      .catalogActions
      .where(
        (action) => widget.retreatOnly
            ? action.tag == 'retreat'
            : action.tag != 'retreat',
      )
      .toList(growable: false);
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

  Future<bool> _tryApplyAlias(String newAlias) async {
    final trimmed = newAlias.trim();
    if (trimmed.isEmpty) return false;
    if (trimmed == _alias) return true;

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
      final confirmed = await showAliasRenameConfirmDialog(
        context,
        oldAlias: _alias,
        newAlias: trimmed,
      );
      if (!confirmed) {
        _aliasCtrl.text = _alias;
        return false;
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

  void _onBaseActionChanged(String? alias) {
    if (alias == null || alias == _baseActionAlias) return;
    final action = _baseActions
        .where((candidate) => candidate.alias == alias)
        .firstOrNull;
    if (action == null) return;
    setState(() {
      _baseActionAlias = action.alias;
      _objclass = action.objclass;
      _data = ZombossMechActionUtils.dataFromCatalogAction(action);
      _syncObject();
    });
  }

  Future<void> _saveAndPop() async {
    if (widget.existingRtid == null && _obj == null) {
      final trimmed = _aliasCtrl.text.trim();
      if (trimmed.isEmpty) return;
      if (!ZombossMechActionUtils.isAliasAvailable(widget.levelFile, trimmed)) {
        await showAliasAlreadyTakenDialog(context);
        return;
      }
      _alias = trimmed;
    } else {
      final aliasOk = await _tryApplyAlias(_aliasCtrl.text);
      if (!aliasOk || !mounted) return;
    }
    if (_obj == null && !_hasValidAwardDrop()) {
      _restoreDefaultAwardDrop();
    }
    _syncObject();
    if (!mounted) return;
    Navigator.pop(
      context,
      RtidParser.build(_alias, ZombossMechActionUtils.customSource),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final group = _group;
    final isNew = widget.existingRtid == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isNew
              ? (l10n?.zombossMechCreateCustomAction ?? 'New custom action')
              : (l10n?.zombossMechEditCustomAction ?? 'Edit custom action'),
        ),
        actions: [
          TextButton(onPressed: _saveAndPop, child: Text(l10n?.save ?? 'Save')),
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
            onFieldSubmitted: _applyAlias,
            onEditingComplete: () => _applyAlias(_aliasCtrl.text),
          ),
          const SizedBox(height: 12),
          if (_usesBaseActionPicker)
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue:
                  _baseActions.any((action) => action.alias == _baseActionAlias)
                  ? _baseActionAlias
                  : _baseActions.firstOrNull?.alias,
              decoration: editorInputDecoration(
                context,
                labelText: l10n?.zombossMechActionBaseAction ?? 'Base Action',
              ),
              selectedItemBuilder: (context) => [
                for (final action in _baseActions)
                  Text(
                    _baseActionLabel(context, action),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
              items: [
                for (final action in _baseActions)
                  DropdownMenuItem(
                    value: action.alias,
                    child: Text(
                      _baseActionLabel(context, action),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: _onBaseActionChanged,
            )
          else
            DropdownButtonFormField<String>(
              isExpanded: true,
              initialValue: _groups.any((g) => g.objclass == _objclass)
                  ? _objclass
                  : _groups.firstOrNull?.objclass,
              decoration: editorInputDecoration(
                context,
                labelText:
                    l10n?.zombossMechActionBaseObjclass ?? 'Base objclass',
              ),
              selectedItemBuilder: (context) => [
                for (final g in _groups)
                  Text(
                    _actionTypeLabel(context, g),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
              items: [
                for (final g in _groups)
                  DropdownMenuItem(
                    value: g.objclass,
                    child: Text(
                      _actionTypeLabel(context, g),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: widget.existingRtid == null
                  ? _onObjclassChanged
                  : null,
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
    );
  }
}
