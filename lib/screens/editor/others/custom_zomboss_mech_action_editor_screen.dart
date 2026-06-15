import 'dart:async';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models/PvzObject.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
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
  late TextEditingController _aliasCtrl;
  List<ZombossMechObjclassGroup> get _groups {
    final groups = widget.retreatOnly
        ? widget.catalog.actions.where((g) => g.tag == 'retreat')
        : widget.catalog.actions.where((g) => g.tag != 'retreat');
    final seen = <String>{};
    return groups.where((g) => seen.add(g.objclass)).toList();
  }

  ZombossMechObjclassGroup? get _group =>
      _groups.where((g) => g.objclass == _objclass).firstOrNull;

  @override
  void initState() {
    super.initState();
    if (widget.existingRtid != null) {
      _loadExisting(widget.existingRtid!);
    } else {
      final group = _groups.firstOrNull ?? widget.catalog.actions.first;
      _objclass = group.objclass;
      final sampleAlias = group.implementations.keys.firstOrNull ?? 'CustomAction';
      _alias = ZombossMechActionUtils.uniqueCustomAlias(
        widget.levelFile,
        sampleAlias,
      );
      _data = ZombossMechActionUtils.defaultsFromFields(group.fields);
      if (group.implementations.isNotEmpty) {
        _data = ZombossMechActionUtils.cloneMap(
          group.implementations.values.first,
        );
      }
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
      _obj!.aliases = [_alias];
      _obj!.objData = Map<String, dynamic>.from(_data);
    }
    widget.onPropsSync?.call();
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
          TextButton(
            onPressed: _saveAndPop,
            child: Text(l10n?.save ?? 'Save'),
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
              hintText: l10n?.zombossMechActionAliasHint ??
                  'Codename used in RTID(alias@CurrentLevel).',
            ),
            onFieldSubmitted: _applyAlias,
            onEditingComplete: () => _applyAlias(_aliasCtrl.text),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _groups.any((g) => g.objclass == _objclass)
                ? _objclass
                : _groups.firstOrNull?.objclass,
            decoration: editorInputDecoration(
              context,
              labelText: l10n?.zombossMechActionBaseObjclass ?? 'Base objclass',
            ),
            selectedItemBuilder: (context) => [
              for (final g in _groups)
                Text(
                  ZombossMechL10n.actionLabel(
                    context,
                    widget.catalog.id,
                    g.objclass,
                    fallback: g.objclass,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
            ],
            items: [
              for (final g in _groups)
                DropdownMenuItem(
                  value: g.objclass,
                  child: Text(
                    ZombossMechL10n.actionLabel(
                      context,
                      widget.catalog.id,
                      g.objclass,
                      fallback: g.objclass,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
            onChanged: widget.existingRtid == null ? _onObjclassChanged : null,
          ),
          const SizedBox(height: 16),
          if (group != null)
            ZombossMechActionFieldsEditor(
              mechId: widget.catalog.id,
              fields: group.fields,
              data: _data,
              objclass: _objclass,
              levelFile: widget.levelFile,
              onChanged: () {
                _syncObject();
                setState(() {});
              },
            ),
        ],
      ),
    );
  }
}
