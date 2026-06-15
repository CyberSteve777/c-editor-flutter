import 'package:flutter/material.dart';

import 'package:c_editor/data/pvz_models.dart';

import 'package:c_editor/data/resilience_shield_utils.dart';

import 'package:c_editor/data/rtid_parser.dart';

import 'package:c_editor/l10n/app_localizations.dart';

import 'package:c_editor/widgets/alias_rename_dialog.dart';

import 'package:c_editor/widgets/resilience_shield_widgets.dart';



/// Creates or edits a level-local [ZombieResilience] object. Object is added on save only.

class CustomResilienceShieldEditorScreen extends StatefulWidget {

  const CustomResilienceShieldEditorScreen({

    super.key,

    required this.levelFile,

    this.existingRtid,

    this.onChanged,

  });



  final PvzLevelFile levelFile;

  final String? existingRtid;

  final VoidCallback? onChanged;



  @override

  State<CustomResilienceShieldEditorScreen> createState() =>

      _CustomResilienceShieldEditorScreenState();

}



class _CustomResilienceShieldEditorScreenState

    extends State<CustomResilienceShieldEditorScreen> {

  PvzObject? _obj;

  late ZombieResilienceData _data;

  late String _alias;

  late TextEditingController _codenameCtrl;

  late TextEditingController _amountCtrl;

  late TextEditingController _recoverSpeedCtrl;

  late TextEditingController _damageThresholdCtrl;

  late TextEditingController _baseThresholdCtrl;

  late TextEditingController _extraThresholdCtrl;



  bool get _isNew => widget.existingRtid == null;



  @override

  void initState() {

    super.initState();

    if (widget.existingRtid != null) {

      _loadExisting(widget.existingRtid!);

    } else {

      _data = ZombieResilienceData();

      _alias = ResilienceShieldUtils.nextCustomCodename(widget.levelFile);

      _codenameCtrl = TextEditingController(text: _alias);

    }

    _amountCtrl = TextEditingController(text: '${_data.amount}');

    _recoverSpeedCtrl = TextEditingController(text: '${_data.recoverSpeed}');

    _damageThresholdCtrl =

        TextEditingController(text: '${_data.damageThresholdPerSecond}');

    _baseThresholdCtrl = TextEditingController(

      text: '${_data.resilienceBaseDamageThreshold}',

    );

    _extraThresholdCtrl = TextEditingController(

      text: '${_data.resilienceExtraDamageThreshold}',

    );

  }



  void _loadExisting(String rtid) {

    _obj = ResilienceShieldUtils.findLevelObject(widget.levelFile, rtid);

    final info = RtidParser.parse(rtid);

    _alias = info?.alias ?? '';

    _codenameCtrl = TextEditingController(text: _alias);

    final raw = _obj?.objData;

    _data = raw is Map

        ? ZombieResilienceData.fromJson(Map<String, dynamic>.from(raw))

        : ZombieResilienceData();

  }



  @override

  void dispose() {

    _codenameCtrl.dispose();

    _amountCtrl.dispose();

    _recoverSpeedCtrl.dispose();

    _damageThresholdCtrl.dispose();

    _baseThresholdCtrl.dispose();

    _extraThresholdCtrl.dispose();

    super.dispose();

  }



  Future<bool> _tryApplyAlias(String newAlias) async {

    final trimmed = newAlias.trim();

    if (trimmed.isEmpty) return false;

    if (trimmed == _alias) return true;



    if (!ResilienceShieldUtils.isCodenameAvailable(

      widget.levelFile,

      trimmed,

      except: _obj,

    )) {

      await showAliasAlreadyTakenDialog(context);

      _codenameCtrl.text = _alias;

      return false;

    }



    if (!_isNew) {

      final confirmed = await showAliasRenameConfirmDialog(

        context,

        oldAlias: _alias,

        newAlias: trimmed,

      );

      if (!confirmed) {

        _codenameCtrl.text = _alias;

        return false;

      }

      ResilienceShieldUtils.renameCustomShield(

        levelFile: widget.levelFile,

        oldAlias: _alias,

        newAlias: trimmed,

        obj: _obj,

      );

      widget.onChanged?.call();

    }



    setState(() => _alias = trimmed);

    return true;

  }



  Future<void> _saveAndPop() async {

    final codename = _codenameCtrl.text.trim();

    if (codename.isEmpty) return;



    if (!_isNew) {

      final aliasOk = await _tryApplyAlias(codename);

      if (!aliasOk || !mounted) return;

    } else if (!ResilienceShieldUtils.isCodenameAvailable(

      widget.levelFile,

      codename,

    )) {

      await showAliasAlreadyTakenDialog(context);

      return;

    } else {

      _alias = codename;

    }



    final amount = int.tryParse(_amountCtrl.text);

    final recoverSpeed = double.tryParse(_recoverSpeedCtrl.text);

    final damageThreshold = double.tryParse(_damageThresholdCtrl.text);

    final baseThreshold = int.tryParse(_baseThresholdCtrl.text);

    final extraThreshold = int.tryParse(_extraThresholdCtrl.text);

    if (amount != null) _data.amount = amount;

    if (recoverSpeed != null) _data.recoverSpeed = recoverSpeed;

    if (damageThreshold != null) {

      _data.damageThresholdPerSecond = damageThreshold;

    }

    if (baseThreshold != null) {

      _data.resilienceBaseDamageThreshold = baseThreshold;

    }

    if (extraThreshold != null) {

      _data.resilienceExtraDamageThreshold = extraThreshold;

    }



    final payload = _data.toLevelJson();

    if (_obj == null) {

      _obj = ResilienceShieldUtils.createCustomShield(

        levelFile: widget.levelFile,

        alias: _alias,

        data: _data,

      );

    } else {

      _obj!.aliases = [_alias];

      _obj!.objData = payload;

    }

    widget.onChanged?.call();

    if (!mounted) return;

    Navigator.pop(

      context,

      RtidParser.build(_alias, ResilienceShieldUtils.customSource),

    );

  }



  @override

  Widget build(BuildContext context) {

    final l10n = AppLocalizations.of(context);



    return Scaffold(

      appBar: AppBar(

        title: Text(

          _isNew

              ? (l10n?.resilienceCreateCustom ?? 'New custom shield')

              : (l10n?.resilienceEditCustom ?? 'Edit custom shield'),

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

            controller: _codenameCtrl,

            decoration: InputDecoration(

              labelText:

                  l10n?.resilienceCodename ?? 'Resilience codename (aliases)',

              hintText:

                  l10n?.resilienceCodenameHint ?? 'e.g. CustomResilience0',

              border: const OutlineInputBorder(),

            ),

            onFieldSubmitted: _tryApplyAlias,

            onEditingComplete: () => _tryApplyAlias(_codenameCtrl.text),

          ),

          const SizedBox(height: 12),

          TextFormField(

            controller: _amountCtrl,

            keyboardType: TextInputType.number,

            decoration: InputDecoration(

              labelText: l10n?.resilienceAmount ?? 'Resilience value (Amount)',

              border: const OutlineInputBorder(),

            ),

            onChanged: (v) {

              final n = int.tryParse(v);

              if (n != null) setState(() => _data.amount = n);

            },

          ),

          const SizedBox(height: 12),

          DropdownButtonFormField<int>(

            isExpanded: true,

            initialValue: _data.weakType.clamp(1, 6),

            decoration: InputDecoration(

              labelText:

                  l10n?.resilienceWeakType ?? 'Resilience type (WeakType)',

              border: const OutlineInputBorder(),

            ),

            items: [1, 2, 3, 4, 5, 6].map((wt) {

              return DropdownMenuItem(

                value: wt,

                child: ResilienceWeakTypeLabelRow(

                  weakType: wt,

                  label: resilienceWeakTypeLabel(l10n, wt),

                ),

              );

            }).toList(),

            onChanged: (v) {

              if (v != null) setState(() => _data.weakType = v);

            },

          ),

          const SizedBox(height: 12),

          TextFormField(

            controller: _recoverSpeedCtrl,

            keyboardType: const TextInputType.numberWithOptions(decimal: true),

            decoration: InputDecoration(

              labelText: l10n?.resilienceRecoverSpeed ??

                  'Resilience bar recovery speed (RecoverSpeed)',

              border: const OutlineInputBorder(),

            ),

            onChanged: (v) {

              final n = double.tryParse(v);

              if (n != null) setState(() => _data.recoverSpeed = n);

            },

          ),

          const SizedBox(height: 12),

          TextFormField(

            controller: _damageThresholdCtrl,

            keyboardType: const TextInputType.numberWithOptions(decimal: true),

            decoration: InputDecoration(

              labelText: l10n?.resilienceDamageThresholdPerSecond ??

                  'Zombie damage threshold per second (DamageThresholdPerSecond)',

              border: const OutlineInputBorder(),

            ),

            onChanged: (v) {

              final n = double.tryParse(v);

              if (n != null) setState(() => _data.damageThresholdPerSecond = n);

            },

          ),

          const SizedBox(height: 12),

          TextFormField(

            controller: _baseThresholdCtrl,

            keyboardType: TextInputType.number,

            decoration: InputDecoration(

              labelText: l10n?.resilienceBaseDamageThreshold ??

                  'Resilience base damage threshold (ResilienceBaseDamageThreshold)',

              border: const OutlineInputBorder(),

            ),

            onChanged: (v) {

              final n = int.tryParse(v);

              if (n != null) {

                setState(() => _data.resilienceBaseDamageThreshold = n);

              }

            },

          ),

          const SizedBox(height: 12),

          TextFormField(

            controller: _extraThresholdCtrl,

            keyboardType: TextInputType.number,

            decoration: InputDecoration(

              labelText: l10n?.resilienceExtraDamageThreshold ??

                  'Resilience extra damage threshold (ResilienceExtraDamageThreshold)',

              border: const OutlineInputBorder(),

            ),

            onChanged: (v) {

              final n = int.tryParse(v);

              if (n != null) {

                setState(() => _data.resilienceExtraDamageThreshold = n);

              }

            },

          ),

        ],

      ),

    );

  }

}

