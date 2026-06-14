import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/resilience_config_repository.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Custom zombie properties. Ported from CustomZombiePropertiesEP.kt
class CustomZombiePropertiesScreen extends StatefulWidget {
  const CustomZombiePropertiesScreen({
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
  State<CustomZombiePropertiesScreen> createState() =>
      _CustomZombiePropertiesScreenState();
}

class _CustomZombiePropertiesScreenState
    extends State<CustomZombiePropertiesScreen> {
  PvzObject? _typeObj;
  PvzObject? _propsObj;
  PvzObject? _customResilienceObj;
  late ZombieTypeData _typeData;
  late ZombiePropertySheetData _propsData;
  final List<double> _resistances = List<double>.filled(7, 0.0);
  ZombieResilienceData _customResilienceData = ZombieResilienceData();
  bool _resilienceUsePreset = true;
  String? _resiliencePresetAlias;
  String _customResilienceCodename = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final info = RtidParser.parse(widget.rtid);
    final alias = info?.alias ?? '';
    _typeObj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(alias) == true,
    );
    if (_typeObj == null) {
      setState(() {});
      return;
    }
    _typeData = ZombieTypeData.fromJson(
      Map<String, dynamic>.from(_typeObj!.objData as Map),
    );
    final propsAlias = RtidParser.parse(_typeData.properties)?.alias ?? '';
    _propsObj = widget.levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(propsAlias) == true,
    );
    if (_propsObj != null) {
      _propsData = ZombiePropertySheetData.fromJson(
        Map<String, dynamic>.from(_propsObj!.objData as Map),
      );
    }
    final list = _typeData.resistences ?? const [];
    for (var i = 0; i < 7; i++) {
      _resistances[i] = i < list.length ? list[i] : 0.0;
    }
    if (!_supportsResilienceShield) {
      if (_propsData.resilience != null) {
        _stripUnsupportedResilience();
        WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged());
      }
      return;
    }
    _loadResilienceState();
  }

  ZombieResilienceData _resilienceDataFromEntry(ResilienceConfigEntry entry) {
    final d = entry.data;
    return ZombieResilienceData(
      amount: d.amount,
      weakType: d.weakType,
      recoverSpeed: d.recoverSpeed,
      damageThresholdPerSecond: d.damageThresholdPerSecond,
      resilienceBaseDamageThreshold: d.resilienceBaseDamageThreshold,
      resilienceExtraDamageThreshold: d.resilienceExtraDamageThreshold,
      animLabels: List<String>.from(d.animLabels),
    );
  }

  void _removeCustomResilienceFromLevel() {
    if (_customResilienceObj != null) {
      widget.levelFile.objects.remove(_customResilienceObj!);
    } else if (_customResilienceCodename.isNotEmpty) {
      widget.levelFile.objects.removeWhere(
        (o) =>
            o.objClass == 'ZombieResilience' &&
            o.aliases?.contains(_customResilienceCodename) == true,
      );
    }
    _customResilienceObj = null;
    _customResilienceCodename = '';
  }

  void _loadResilienceState() {
    final r = _propsData.resilience;
    if (r == null) {
      _resilienceUsePreset = true;
      _resiliencePresetAlias = null;
      _customResilienceObj = null;
      _customResilienceData = ZombieResilienceData();
      _customResilienceCodename = '';
      return;
    }
    if (r is ZombieResilienceData) {
      _resilienceUsePreset = false;
      _customResilienceData = ZombieResilienceData(
        amount: r.amount,
        weakType: r.weakType,
        recoverSpeed: r.recoverSpeed,
        damageThresholdPerSecond: r.damageThresholdPerSecond,
        resilienceBaseDamageThreshold: r.resilienceBaseDamageThreshold,
        resilienceExtraDamageThreshold: r.resilienceExtraDamageThreshold,
        animLabels: List<String>.from(r.animLabels),
      );
      _customResilienceCodename = _nextCustomResilienceCodename();
      final rtid = _ensureCustomResilienceInLevel();
      _propsData.resilience = rtid;
      _customResilienceObj = widget.levelFile.objects.firstWhereOrNull(
        (o) => o.aliases?.contains(RtidParser.parse(rtid)?.alias ?? '') == true,
      );
      _propsObj?.objData = _propsData.toJson();
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged());
      return;
    }
    if (r is! String || r.isEmpty) return;
    final info = RtidParser.parse(r);
    if (info == null) return;
    if (info.source == 'ResilienceConfig') {
      _resilienceUsePreset = true;
      _resiliencePresetAlias = info.alias;
      _customResilienceObj = null;
      _customResilienceCodename = '';
      final entry = ResilienceConfigRepository.getByAlias(info.alias);
      _customResilienceData = entry != null
          ? _resilienceDataFromEntry(entry)
          : ZombieResilienceData();
    } else {
      _resilienceUsePreset = false;
      _resiliencePresetAlias = null;
      _customResilienceCodename = info.alias;
      _customResilienceObj = widget.levelFile.objects.firstWhereOrNull(
        (o) => o.aliases?.contains(info.alias) == true,
      );
      if (_customResilienceObj?.objData is Map) {
        _customResilienceData = ZombieResilienceData.fromJson(
          Map<String, dynamic>.from(_customResilienceObj!.objData as Map),
        );
        final raw = _customResilienceObj!.objData as Map;
        if (raw['AnimLabels'] == null) {
          _customResilienceObj!.objData = _customResilienceData.toLevelJson();
          WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged());
        }
      }
    }
  }

  String _nextCustomResilienceCodename() {
    var i = 0;
    while (true) {
      final codename = 'CustomResilience$i';
      final exists = widget.levelFile.objects
          .any((o) => o.aliases?.contains(codename) == true);
      if (!exists) return codename;
      i++;
    }
  }

  /// Ensures custom resilience object exists in level. Creates or updates it.
  /// Returns RTID(alias@CurrentLevel).
  String _ensureCustomResilienceInLevel() {
    var codename = _customResilienceCodename.trim();
    if (codename.isEmpty) {
      codename = _nextCustomResilienceCodename();
      _customResilienceCodename = codename;
    }

    if (_customResilienceObj != null) {
      _customResilienceObj!.aliases = [codename];
      _customResilienceObj!.objData = _customResilienceData.toLevelJson();
      return RtidParser.build(codename, 'CurrentLevel');
    }
    final existing = widget.levelFile.objects
        .firstWhereOrNull((o) => o.aliases?.contains(codename) == true);
    if (existing != null && existing.objClass == 'ZombieResilience') {
      _customResilienceObj = existing;
      _customResilienceObj!.objData = _customResilienceData.toLevelJson();
      return RtidParser.build(codename, 'CurrentLevel');
    }
    var finalCodename = codename;
    if (existing != null) {
      finalCodename = _nextCustomResilienceCodename();
      _customResilienceCodename = finalCodename;
    }
    final obj = PvzObject(
      aliases: [finalCodename],
      objClass: 'ZombieResilience',
      objData: _customResilienceData.toLevelJson(),
    );
    widget.levelFile.objects.add(obj);
    _customResilienceObj = obj;
    return RtidParser.build(finalCodename, 'CurrentLevel');
  }

  bool get _isResilienceEnabled => _propsData.resilience != null;

  bool get _supportsResilienceShield =>
      ZombiePropertiesRepository.supportsResilienceShield(_typeData.typeName);

  void _stripUnsupportedResilience() {
    final r = _propsData.resilience;
    if (r == null) return;
    if (r is String) {
      final info = RtidParser.parse(r);
      if (info?.source == 'CurrentLevel') {
        final alias = info!.alias;
        widget.levelFile.objects.removeWhere(
          (o) =>
              o.objClass == 'ZombieResilience' &&
              o.aliases?.contains(alias) == true,
        );
      }
    }
    _propsData.resilience = null;
    _resilienceUsePreset = true;
    _resiliencePresetAlias = null;
    _customResilienceObj = null;
    _customResilienceData = ZombieResilienceData();
    _customResilienceCodename = '';
    _propsObj?.objData = _propsData.toJson();
  }

  void _sync() {
    final allZero = _resistances.every((e) => e == 0.0);
    _typeData.resistences = allZero ? null : List<double>.from(_resistances);
    _typeObj?.objData = _typeData.toJson();
    _propsObj?.objData = _propsData.toJson();
    widget.onChanged();
    setState(() {});
  }

  String _formatRect(RectData? rect) {
    if (rect == null) return 'Default';
    return 'X:${rect.mX}, Y:${rect.mY}, W:${rect.mWidth}, H:${rect.mHeight}';
  }

  String _formatPoint(Point2D? pt) {
    if (pt == null) return 'Default';
    return 'X:${pt.x}, Y:${pt.y}';
  }

  String _formatPoint3D(Point3DDouble? pt) {
    if (pt == null) return 'Default';
    return 'X:${pt.x}, Y:${pt.y}, Z:${pt.z}';
  }

  Future<void> _showRectDialog({
    required String title,
    required RectData initial,
    required ValueChanged<RectData> onConfirm,
  }) async {
    final l10n = AppLocalizations.of(context);
    final xController = TextEditingController(text: '${initial.mX}');
    final yController = TextEditingController(text: '${initial.mY}');
    final wController = TextEditingController(text: '${initial.mWidth}');
    final hController = TextEditingController(text: '${initial.mHeight}');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: _numberField(xController, label: 'X'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _numberField(yController, label: 'Y'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _numberField(wController, label: 'Width'),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _numberField(hController, label: 'Height'),
                ),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onConfirm(
                RectData(
                  mX: int.tryParse(xController.text) ?? initial.mX,
                  mY: int.tryParse(yController.text) ?? initial.mY,
                  mWidth: int.tryParse(wController.text) ?? initial.mWidth,
                  mHeight: int.tryParse(hController.text) ?? initial.mHeight,
                ),
              );
              Navigator.pop(ctx);
            },
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPoint2Dialog({
    required String title,
    required Point2D initial,
    required ValueChanged<Point2D> onConfirm,
  }) async {
    final l10n = AppLocalizations.of(context);
    final xController = TextEditingController(text: '${initial.x}');
    final yController = TextEditingController(text: '${initial.y}');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Row(
          children: [
            Expanded(child: _numberField(xController, label: 'X')),
            const SizedBox(width: 8),
            Expanded(child: _numberField(yController, label: 'Y')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onConfirm(
                Point2D(
                  x: int.tryParse(xController.text) ?? initial.x,
                  y: int.tryParse(yController.text) ?? initial.y,
                ),
              );
              Navigator.pop(ctx);
            },
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showPoint3Dialog({
    required String title,
    required Point3DDouble initial,
    required ValueChanged<Point3DDouble> onConfirm,
  }) async {
    final l10n = AppLocalizations.of(context);
    final xController = TextEditingController(text: '${initial.x}');
    final yController = TextEditingController(text: '${initial.y}');
    final zController = TextEditingController(text: '${initial.z}');
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _numberField(xController, label: 'X', isDouble: true),
            const SizedBox(height: 8),
            _numberField(yController, label: 'Y', isDouble: true),
            const SizedBox(height: 8),
            _numberField(zController, label: 'Z', isDouble: true),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              onConfirm(
                Point3DDouble(
                  x: double.tryParse(xController.text) ?? initial.x,
                  y: double.tryParse(yController.text) ?? initial.y,
                  z: double.tryParse(zController.text) ?? initial.z,
                ),
              );
              Navigator.pop(ctx);
            },
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSizeTypeDialog() async {
    final l10n = AppLocalizations.of(context);
    final options = <String?>[null, 'small', 'mid', 'large'];
    var selected = _propsData.sizeType;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.selectSize ?? 'Select size'),
        content: StatefulBuilder(
          builder: (context, setState) {
            return RadioGroup<String?>(
              groupValue: selected,
              onChanged: (val) {
                setState(() {
                  selected = val;
                });
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: options.map((opt) {
                  return RadioListTile<String?>(
                    value: opt,
                    title: Text(opt ?? 'null'),
                  );
                }).toList(),
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () {
              _propsData.sizeType = selected;
              _sync();
              Navigator.pop(ctx);
            },
            child: Text(l10n?.ok ?? 'OK'),
          ),
        ],
      ),
    );
  }

  Widget _numberField(
    TextEditingController controller, {
    required String label,
    bool isDouble = false,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder()),
      onChanged: (_) {},
    );
  }

  Color get _themeColor =>
      Theme.of(context).brightness == Brightness.dark ? pvzOrangeDark : pvzOrangeLight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeColor = _themeColor;
    final l10n = AppLocalizations.of(context);
    if (_typeObj == null) {
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          title: Text(l10n?.customZombie ?? 'Custom zombie'),
        ),
        body: Center(
          child: Text(
            l10n?.zombieTypeNotFound ?? 'Zombie type object not found.',
            style: theme.textTheme.titleMedium,
          ),
        ),
      );
    }
    if (_propsObj == null) {
      final propsAlias = RtidParser.parse(_typeData.properties)?.alias ?? '';
      return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          title: Text(l10n?.customZombieProperties ?? 'Custom zombie properties'),
          backgroundColor: themeColor,
          foregroundColor: theme.colorScheme.onPrimary,
        ),
        body: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.warning, size: 80, color: themeColor),
              const SizedBox(height: 16),
              Text(
                l10n?.propertyObjectNotFound ?? 'Property object not found',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.propertyObjectNotFoundHint(propsAlias) ?? 'The custom zombie\'s property object ($propsAlias) was not found in the level. The property definition does not point to level internals, so it cannot be edited here.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Text(l10n?.customZombieProperties ?? 'Custom zombie properties'),
        backgroundColor: themeColor,
        foregroundColor: theme.colorScheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              title: l10n?.customZombie ?? 'Custom zombie',
              themeColor: themeColor,
              sections: [
                HelpSectionData(
                  title: l10n?.customZombieHelpIntro ?? 'Brief introduction',
                  body: l10n?.customZombieHelpIntroBody ?? 'This screen edits custom zombie parameters injected into the level. Only common properties are supported; many special attributes require manual JSON editing.',
                ),
                HelpSectionData(
                  title: l10n?.customZombieHelpBase ?? 'Base properties',
                  body: l10n?.customZombieHelpBaseBody ?? 'Custom zombies can modify base stats (HP, speed, eat damage). Custom zombies do not appear in the level preview pool.',
                ),
                HelpSectionData(
                  title: l10n?.customZombieHelpHit ?? 'Hit/position',
                  body: l10n?.customZombieHelpHitBody ?? 'X and Y are offsets; W and H are width and height. Offsetting ArtCenter can hide the zombie sprite. Leaving ground track empty lets the zombie walk in place.',
                ),
                HelpSectionData(
                  title: l10n?.customZombieHelpManual ?? 'Manual editing',
                  body: l10n?.customZombieHelpManualBody ?? 'Custom injection auto-fills all properties from game files. You can further edit the JSON file manually if needed.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.deferToChild,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n?.aliasLabel ?? 'Alias',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: themeColor,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    initialValue: _typeObj!.aliases?.isNotEmpty == true
                        ? _typeObj!.aliases!.first
                        : '',
                    decoration: InputDecoration(
                      border: const OutlineInputBorder(),
                      isDense: true,
                      hintText: l10n?.aliasLabel ?? 'Alias',
                    ),
                    onChanged: (v) {
                      final trimmed = v.trim();
                      if (trimmed.isNotEmpty && _typeObj != null) {
                        _typeObj!.aliases = [trimmed];
                        widget.onChanged();
                        setState(() {});
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n?.baseStats ?? 'Base stats',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  )),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _doubleInput(
                        label: l10n?.hitpoints ?? 'Hitpoints',
                        value: _propsData.hitpoints,
                        onChanged: (v) {
                          _propsData.hitpoints = v;
                          _sync();
                        },
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _doubleInput(
                              label: l10n?.speed ?? 'Speed',
                              value: _propsData.speed,
                              onChanged: (v) {
                                _propsData.speed = v;
                                _sync();
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _doubleInput(
                              label: l10n?.speedVariance ?? 'Speed variance',
                              value: _propsData.speedVariance ?? 0.1,
                              onChanged: (v) {
                                _propsData.speedVariance = v;
                                _sync();
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _doubleInput(
                        label: l10n?.eatDPS ?? 'EatDPS',
                        value: _propsData.eatDPS,
                        onChanged: (v) {
                          _propsData.eatDPS = v;
                          _sync();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n?.hitPosition ?? 'Hit / position',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  )),
              const SizedBox(height: 8),
              Card(
                child: Column(
                  children: [
                    _editRow(
                      title: l10n?.hitRect ?? 'HitRect',
                      subtitle: _formatRect(_propsData.hitRect),
                      icon: Icons.aspect_ratio,
                      onTap: () => _showRectDialog(
                        title: l10n?.editHitRect ?? 'Edit HitRect',
                        initial: _propsData.hitRect ??
                            RectData(mX: 10, mY: 10, mWidth: 32, mHeight: 95),
                        onConfirm: (r) {
                          _propsData.hitRect = r;
                          _sync();
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    _editRow(
                      title: l10n?.attackRect ?? 'AttackRect',
                      subtitle: _formatRect(_propsData.attackRect),
                      icon: Icons.aspect_ratio,
                      onTap: () => _showRectDialog(
                        title: l10n?.editAttackRect ?? 'Edit AttackRect',
                        initial: _propsData.attackRect ??
                            RectData(mX: 15, mY: 0, mWidth: 20, mHeight: 95),
                        onConfirm: (r) {
                          _propsData.attackRect = r;
                          _sync();
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    _editRow(
                      title: l10n?.artCenter ?? 'ArtCenter',
                      subtitle: _formatPoint(_propsData.artCenter),
                      icon: Icons.center_focus_strong,
                      onTap: () => _showPoint2Dialog(
                        title: l10n?.editArtCenter ?? 'Edit ArtCenter',
                        initial:
                            _propsData.artCenter ?? Point2D(x: 90, y: 125),
                        onConfirm: (p) {
                          _propsData.artCenter = p;
                          _sync();
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    _editRow(
                      title: l10n?.shadowOffset ?? 'ShadowOffset',
                      subtitle: _formatPoint3D(_propsData.shadowOffset),
                      icon: Icons.layers,
                      onTap: () => _showPoint3Dialog(
                        title: l10n?.editShadowOffset ?? 'Edit ShadowOffset',
                        initial: _propsData.shadowOffset ??
                            Point3DDouble(x: 5.0, y: 0.0, z: 1.2),
                        onConfirm: (p) {
                          _propsData.shadowOffset = p;
                          _sync();
                        },
                      ),
                    ),
                    const Divider(height: 1),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: DropdownButtonFormField<String>(
                        initialValue: _propsData.groundTrackName == 'ground_swatch'
                            ? 'ground_swatch'
                            : '',
                        decoration: InputDecoration(
                          labelText: l10n?.groundTrackName ?? 'GroundTrackName (行进轨迹)',
                          border: const OutlineInputBorder(),
                        ),
                        items: [
                          DropdownMenuItem(
                            value: 'ground_swatch',
                            child: Text(l10n?.groundTrackNormal ?? 'Normal ground (ground_swatch)'),
                          ),
                          DropdownMenuItem(
                            value: '',
                            child: Text(l10n?.groundTrackNone ?? 'None (null)'),
                          ),
                        ],
                        onChanged: (val) {
                          if (val == null) return;
                          _propsData.groundTrackName = val;
                          _sync();
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(l10n?.appearanceBehavior ?? 'Appearance & behavior',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  )),
              const SizedBox(height: 8),
              Card(
                child: Theme(
                  data: theme.copyWith(
                    switchTheme: SwitchThemeData(
                      trackColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return themeColor; // Amber when on
                        }
                        return null;
                      }),
                      thumbColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return theme.colorScheme.onPrimary;
                        }
                        return null;
                      }),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        InkWell(
                          onTap: _showSizeTypeDialog,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(l10n?.sizeType ?? 'SizeType',
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      _propsData.sizeType ?? 'null',
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.edit, size: 18),
                            ],
                          ),
                        ),
                        const Divider(height: 24),
                      _switchRow(
                        title: l10n?.disableDropFractions ?? 'Disable drop fractions',
                        checked: _propsData.armDropFraction != null ||
                            _propsData.headDropFraction != null,
                        onChanged: (checked) {
                          if (checked) {
                            _propsData.armDropFraction = -1;
                            _propsData.headDropFraction = 0;
                          } else {
                            _propsData.armDropFraction = null;
                            _propsData.headDropFraction = null;
                          }
                          _sync();
                        },
                      ),
                      _switchRow(
                        title: l10n?.immuneToKnockback ?? 'Immune to knockback',
                        checked: _propsData.canBeLaunchedByPlants != null ||
                            _propsData.canBePlantTossedStrong != null ||
                            _propsData.canBePlantTossedweak != null,
                        onChanged: (checked) {
                          if (checked) {
                            _propsData.canBeLaunchedByPlants = false;
                            _propsData.canBePlantTossedweak = false;
                            _propsData.canBePlantTossedStrong = false;
                          } else {
                            _propsData.canBeLaunchedByPlants = null;
                            _propsData.canBePlantTossedweak = null;
                            _propsData.canBePlantTossedStrong = null;
                          }
                          _sync();
                        },
                      ),
                      _switchRow(
                        title: l10n?.showHealthBarOnDamage ?? 'Show health bar on damage',
                        checked: _propsData.enableShowHealthBarByDamage == true,
                        onChanged: (checked) {
                          _propsData.enableShowHealthBarByDamage =
                              checked ? true : null;
                          _propsData.drawHealthBarTime = checked
                              ? (_propsData.drawHealthBarTime ?? 4.0)
                              : null;
                          _sync();
                        },
                      ),
                      if (_propsData.enableShowHealthBarByDamage == true)
                        _doubleInput(
                          label: l10n?.drawHealthBarTime ?? 'DrawHealthBarTime',
                          value: _propsData.drawHealthBarTime ?? 4.0,
                          onChanged: (v) {
                            _propsData.drawHealthBarTime = v;
                            _sync();
                          },
                        ),
                      _switchRow(
                        title: l10n?.enableEliteScale ?? 'Enable elite scale',
                        checked: _propsData.enableEliteScale == true,
                        onChanged: (checked) {
                          _propsData.enableEliteScale = checked ? true : null;
                          _propsData.eliteScale = checked
                              ? (_propsData.eliteScale ?? 1.2)
                              : null;
                          _sync();
                        },
                      ),
                      if (_propsData.enableEliteScale == true)
                        _doubleInput(
                          label: l10n?.eliteScale ?? 'EliteScale',
                          value: _propsData.eliteScale ?? 1.2,
                          onChanged: (v) {
                            _propsData.eliteScale = v;
                            _sync();
                          },
                        ),
                      _switchRow(
                        title: l10n?.enableEliteImmunities ?? 'Enable elite immunities',
                        checked: _propsData.enableEliteImmunities == true,
                        onChanged: (checked) {
                          _propsData.enableEliteImmunities =
                              checked ? true : null;
                          _sync();
                        },
                      ),
                      _switchRow(
                        title: l10n?.canSpawnPlantFood ?? 'Can spawn plant food',
                        checked: _propsData.canSpawnPlantFood,
                        onChanged: (checked) {
                          _propsData.canSpawnPlantFood = checked;
                          _sync();
                        },
                      ),
                      _switchRow(
                        title: l10n?.canSurrender ?? 'Can surrender',
                        checked: _propsData.canSurrender == true,
                        onChanged: (checked) {
                          _propsData.canSurrender = checked ? true : null;
                          _sync();
                        },
                      ),
                      _switchRow(
                        title: l10n?.canTriggerZombieWin ?? 'Can trigger zombie win',
                        checked: _propsData.canTriggerZombieWin != false,
                        onChanged: (checked) {
                          _propsData.canTriggerZombieWin = checked ? null : false;
                          _sync();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
              if (_supportsResilienceShield) ...[
                const SizedBox(height: 16),
                Text(l10n?.resilienceArmor ?? 'Resilience (armor)',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: themeColor,
                    )),
                const SizedBox(height: 8),
                Card(
                  child: Theme(
                    data: theme.copyWith(
                      switchTheme: SwitchThemeData(
                        trackColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return themeColor;
                          }
                          return null;
                        }),
                        thumbColor: WidgetStateProperty.resolveWith((states) {
                          if (states.contains(WidgetState.selected)) {
                            return theme.colorScheme.onPrimary;
                          }
                          return null;
                        }),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _switchRow(
                            title:
                                l10n?.enableResilience ?? 'Enable resilience',
                            checked: _isResilienceEnabled,
                            onChanged: (checked) {
                              if (checked) {
                                if (_resilienceUsePreset) {
                                  final presets =
                                      ResilienceConfigRepository.getAll();
                                  if (presets.isNotEmpty) {
                                    _propsData.resilience = presets.first.rtid;
                                    _resiliencePresetAlias = presets.first.alias;
                                  } else {
                                    _propsData.resilience =
                                        _ensureCustomResilienceInLevel();
                                  }
                                } else {
                                  _propsData.resilience =
                                      _ensureCustomResilienceInLevel();
                                }
                                _loadResilienceState();
                              } else {
                                _removeCustomResilienceFromLevel();
                                _propsData.resilience = null;
                              }
                              _sync();
                            },
                          ),
                          if (_isResilienceEnabled) ...[
                            const Divider(height: 24),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n?.resilienceSource ?? 'Source',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      RadioGroup<bool>(
                                        groupValue: _resilienceUsePreset,
                                        onChanged: (v) {
                                          if (v != null) {
                                            setState(() {
                                              _resilienceUsePreset = v;
                                              if (v) {
                                                _removeCustomResilienceFromLevel();
                                                final presets =
                                                    ResilienceConfigRepository
                                                        .getAll();
                                                _propsData.resilience =
                                                    presets.isNotEmpty
                                                        ? presets.first.rtid
                                                        : null;
                                                _resiliencePresetAlias =
                                                    presets.isNotEmpty
                                                        ? presets.first.alias
                                                        : null;
                                              } else {
                                                if (_resiliencePresetAlias !=
                                                    null) {
                                                  final entry =
                                                      ResilienceConfigRepository
                                                          .getByAlias(
                                                    _resiliencePresetAlias!,
                                                  );
                                                  if (entry != null) {
                                                    _customResilienceData =
                                                        _resilienceDataFromEntry(
                                                      entry,
                                                    );
                                                  }
                                                }
                                                _propsData.resilience =
                                                    _ensureCustomResilienceInLevel();
                                              }
                                            });
                                            _sync();
                                          }
                                        },
                                        child: Row(
                                          children: [
                                            Flexible(
                                              child: RadioListTile<bool>(
                                                value: true,
                                                title: Text(
                                                  l10n?.resiliencePreset ??
                                                      'Preset',
                                                ),
                                              ),
                                            ),
                                            Flexible(
                                              child: RadioListTile<bool>(
                                                value: false,
                                                title: Text(
                                                  l10n?.resilienceCustom ??
                                                      'Custom',
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            if (_resilienceUsePreset)
                              DropdownButtonFormField<String>(
                                isExpanded: true,
                                initialValue: _resiliencePresetAlias ??
                                    (ResilienceConfigRepository.getAll()
                                            .isNotEmpty
                                        ? ResilienceConfigRepository.getAll()
                                            .first
                                            .alias
                                        : null),
                                decoration: InputDecoration(
                                  labelText: l10n?.resiliencePresetSelect ??
                                      'Select preset',
                                  border: const OutlineInputBorder(),
                                ),
                                items: ResilienceConfigRepository.getAll()
                                    .map(
                                      (e) => DropdownMenuItem<String>(
                                        value: e.alias,
                                        child: _WeakTypeDropdownRow(
                                          weakType: e.data.weakType,
                                          label: e.alias,
                                        ),
                                      ),
                                    )
                                    .toList(),
                                onChanged: (v) {
                                  if (v != null) {
                                    setState(() {
                                      _resiliencePresetAlias = v;
                                      _propsData.resilience = RtidParser.build(
                                        v,
                                        'ResilienceConfig',
                                      );
                                      final entry =
                                          ResilienceConfigRepository.getByAlias(
                                        v,
                                      );
                                      if (entry != null) {
                                        _customResilienceData =
                                            _resilienceDataFromEntry(entry);
                                      }
                                    });
                                    _sync();
                                  }
                                },
                              )
                            else
                              _buildCustomResilienceFields(theme, l10n),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              Text(l10n?.resilience ?? 'Resilience',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: themeColor,
                  )),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _resistanceInput(
                        context: context,
                        index: 0,
                        label: l10n?.instantKillResistance ?? 'Instant kill resistance',
                        iconPath: null,
                      ),
                      const SizedBox(height: 12),
                      for (var i = 0; i < 3; i++)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Row(
                            children: [
                              Expanded(
                                child: _resistanceInput(
                                  context: context,
                                  index: 1 + i * 2,
                                  label: _resLabel(context, 1 + i * 2),
                                  iconPath: _resIcons[1 + i * 2],
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _resistanceInput(
                                  context: context,
                                  index: 2 + i * 2,
                                  label: _resLabel(context, 2 + i * 2),
                                  iconPath: _resIcons[2 + i * 2],
                                ),
                              ),
                            ],
                          ),
                        ),
                      Text(
                        l10n?.resilienceHint ?? '0.0 = none, 1.0 = full immunity',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                l10n?.zombieTypeLabel(_typeData.typeName) ?? 'Zombie type: ${_typeData.typeName}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                l10n?.propertyAliasLabel(RtidParser.parse(_typeData.properties)?.alias ?? '') ?? 'Property alias: ${RtidParser.parse(_typeData.properties)?.alias ?? ''}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomResilienceFields(ThemeData theme, AppLocalizations? l10n) {
    void onCustomResilienceChanged() {
      _propsData.resilience = _ensureCustomResilienceInLevel();
      setState(() {});
      _sync();
    }

    void onCodenameChanged(String v) {
      _customResilienceCodename = v;
      onCustomResilienceChanged();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _CodenameInputField(
          key: const ValueKey('resilience_codename'),
          label: l10n?.resilienceCodename ?? 'Codename',
          hint: l10n?.resilienceCodenameHint ?? 'e.g. CustomResilience0',
          value: _customResilienceCodename,
          onChanged: onCodenameChanged,
        ),
        const SizedBox(height: 12),
        _intInput(
          label: l10n?.resilienceAmount ?? 'Amount',
          value: _customResilienceData.amount,
          onChanged: (v) {
            _customResilienceData.amount = v;
            onCustomResilienceChanged();
          },
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: DropdownButtonFormField<int>(
            isExpanded: true,
            initialValue: _customResilienceData.weakType.clamp(1, 6),
            decoration: InputDecoration(
              labelText: l10n?.resilienceWeakType ?? 'Weak type',
              border: const OutlineInputBorder(),
            ),
            items: [1, 2, 3, 4, 5, 6].map((wt) {
              return DropdownMenuItem<int>(
                value: wt,
                child: _WeakTypeDropdownRow(
                  weakType: wt,
                  label: _weakTypeLabel(wt, l10n),
                ),
              );
            }).toList(),
            onChanged: (v) {
              if (v != null) {
                setState(() {
                  _customResilienceData.weakType = v;
                });
                onCustomResilienceChanged();
              }
            },
          ),
        ),
        _doubleInput(
          label: l10n?.resilienceRecoverSpeed ?? 'RecoverSpeed',
          value: _customResilienceData.recoverSpeed,
          onChanged: (v) {
            _customResilienceData.recoverSpeed = v;
            onCustomResilienceChanged();
          },
        ),
        const SizedBox(height: 12),
        _doubleInput(
          label: l10n?.resilienceDamageThresholdPerSecond ??
              'DamageThresholdPerSecond',
          value: _customResilienceData.damageThresholdPerSecond,
          onChanged: (v) {
            _customResilienceData.damageThresholdPerSecond = v;
            onCustomResilienceChanged();
          },
        ),
        const SizedBox(height: 12),
        _intInput(
          label: l10n?.resilienceBaseDamageThreshold ??
              'ResilienceBaseDamageThreshold',
          value: _customResilienceData.resilienceBaseDamageThreshold,
          onChanged: (v) {
            _customResilienceData.resilienceBaseDamageThreshold = v;
            onCustomResilienceChanged();
          },
        ),
        const SizedBox(height: 12),
        _intInput(
          label: l10n?.resilienceExtraDamageThreshold ??
              'ResilienceExtraDamageThreshold',
          value: _customResilienceData.resilienceExtraDamageThreshold,
          onChanged: (v) {
            _customResilienceData.resilienceExtraDamageThreshold = v;
            onCustomResilienceChanged();
          },
        ),
      ],
    );
  }

  String _weakTypeLabel(int weakType, AppLocalizations? l10n) {
    switch (weakType) {
      case 1: return l10n?.resiliencePhysics ?? 'Physics';
      case 2: return l10n?.resiliencePoison ?? 'Poison';
      case 3: return l10n?.resilienceElectric ?? 'Electric';
      case 4: return l10n?.resilienceMagic ?? 'Magic';
      case 5: return l10n?.resilienceIce ?? 'Ice';
      case 6: return l10n?.resilienceFire ?? 'Fire';
      default: return '$weakType';
    }
  }

  Widget _intInput({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return _IntInputField(
      key: ValueKey('int_$label'),
      label: label,
      value: value,
      onChanged: onChanged,
    );
  }

  String _resLabel(BuildContext context, int index) {
    final l10n = AppLocalizations.of(context);
    switch (index) {
      case 1: return l10n?.resiliencePhysics ?? 'Physics';
      case 2: return l10n?.resiliencePoison ?? 'Poison';
      case 3: return l10n?.resilienceElectric ?? 'Electric';
      case 4: return l10n?.resilienceMagic ?? 'Magic';
      case 5: return l10n?.resilienceIce ?? 'Ice';
      case 6: return l10n?.resilienceFire ?? 'Fire';
      default: return '';
    }
  }

  static const _resIcons = [
    null,
    'assets/images/tags/Plant_Physics.webp',
    'assets/images/tags/Plant_Poison.webp',
    'assets/images/tags/Plant_Electric.webp',
    'assets/images/tags/Plant_Magic.webp',
    'assets/images/tags/Plant_Ice.webp',
    'assets/images/tags/Plant_Fire.webp',
  ];

  Widget _resistanceInput({
    required BuildContext context,
    required int index,
    required String label,
    required String? iconPath,
  }) {
    return _ResilienceInputField(
      key: ValueKey('resistance_$index'),
      label: label,
      value: _resistances[index],
      iconPath: iconPath,
      onChanged: (v) {
        _resistances[index] = v.clamp(0.0, 1.0);
        _sync();
      },
    );
  }

  Widget _editRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    final themeColor = _themeColor;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: themeColor),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.edit, size: 18),
          ],
        ),
      ),
    );
  }

  Widget _switchRow({
    required String title,
    required bool checked,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      value: checked,
      onChanged: onChanged,
    );
  }

  Widget _doubleInput({
    required String label,
    required double value,
    required ValueChanged<double> onChanged,
  }) {
    return _DoubleInputField(
      key: ValueKey(label),
      label: label,
      value: value,
      onChanged: onChanged,
    );
  }
}

class _DoubleInputField extends StatefulWidget {
  const _DoubleInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  @override
  State<_DoubleInputField> createState() => _DoubleInputFieldState();
}

class _DoubleInputFieldState extends State<_DoubleInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final focused = _focusNode.hasFocus;
    if (_isFocused != focused) {
      setState(() => _isFocused = focused);
    }
  }

  @override
  void didUpdateWidget(covariant _DoubleInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isFocused && oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (v) {
        final n = double.tryParse(v);
        if (n != null) widget.onChanged(n);
      },
    );
  }
}

class _CodenameInputField extends StatefulWidget {
  const _CodenameInputField({
    super.key,
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final String hint;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  State<_CodenameInputField> createState() => _CodenameInputFieldState();
}

class _CodenameInputFieldState extends State<_CodenameInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final focused = _focusNode.hasFocus;
    if (_isFocused != focused) {
      setState(() => _isFocused = focused);
    }
  }

  @override
  void didUpdateWidget(covariant _CodenameInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isFocused && oldWidget.value != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      decoration: InputDecoration(
        labelText: widget.label,
        hintText: widget.hint,
        border: const OutlineInputBorder(),
      ),
      onChanged: widget.onChanged,
    );
  }
}

class _IntInputField extends StatefulWidget {
  const _IntInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
  });
  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  State<_IntInputField> createState() => _IntInputFieldState();
}

class _IntInputFieldState extends State<_IntInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toString());
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final focused = _focusNode.hasFocus;
    if (_isFocused != focused) {
      setState(() => _isFocused = focused);
    }
  }

  @override
  void didUpdateWidget(covariant _IntInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isFocused && oldWidget.value != widget.value) {
      _controller.text = widget.value.toString();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
      ),
      onChanged: (v) {
        final n = int.tryParse(v);
        if (n != null) widget.onChanged(n);
      },
    );
  }
}

/// Resilience input field with same styling as base stats (_DoubleInputField).
class _ResilienceInputField extends StatefulWidget {
  const _ResilienceInputField({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.iconPath,
  });

  final String label;
  final double value;
  final ValueChanged<double> onChanged;
  final String? iconPath;

  @override
  State<_ResilienceInputField> createState() => _ResilienceInputFieldState();
}

class _ResilienceInputFieldState extends State<_ResilienceInputField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value.toStringAsFixed(2));
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  void _onFocusChange() {
    final focused = _focusNode.hasFocus;
    if (_isFocused != focused) {
      setState(() => _isFocused = focused);
    }
  }

  @override
  void didUpdateWidget(covariant _ResilienceInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isFocused && oldWidget.value != widget.value) {
      _controller.text = widget.value.toStringAsFixed(2);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
        prefixIcon: widget.iconPath != null
            ? Padding(
                padding: const EdgeInsets.all(8),
                child: AssetImageWidget(
                  assetPath: widget.iconPath!,
                  width: 20,
                  height: 20,
                  fit: BoxFit.contain,
                  altCandidates: imageAltCandidates(widget.iconPath!),
                ),
              )
            : null,
      ),
      onChanged: (v) {
        final val = double.tryParse(v);
        if (val != null) {
          widget.onChanged(val.clamp(0.0, 1.0));
        }
      },
    );
  }
}

class _WeakTypeDropdownRow extends StatelessWidget {
  const _WeakTypeDropdownRow({
    required this.weakType,
    required this.label,
  });

  final int weakType;
  final String label;

  @override
  Widget build(BuildContext context) {
    final iconPath = weakType >= 1 && weakType < weakTypeIcons.length
        ? weakTypeIcons[weakType]
        : null;
    return Row(
      children: [
        if (iconPath != null) ...[
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: AssetImageWidget(
              assetPath: iconPath,
              width: 20,
              height: 20,
              fit: BoxFit.contain,
              altCandidates: imageAltCandidates(iconPath),
            ),
          ),
        ],
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
