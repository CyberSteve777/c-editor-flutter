import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zombie_properties_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;
import 'package:c_editor/theme/app_theme.dart'
    show pvzPurpleDark, pvzPurpleLight;
import 'package:c_editor/widgets/editor_components.dart'
    show showEditorHelpDialog, HelpSectionData, editorInputDecoration;

class _LootTypeOption {
  const _LootTypeOption(this.value, this.labelKey, this.fallback);
  final String value;
  final String labelKey;
  final String fallback;
}

const List<_LootTypeOption> _lootTypes = [
  _LootTypeOption('GoldCoin', 'pickupCollectableLootGoldCoin', 'Gold coin'),
];

/// Pickup collectable tutorial module: zombie that drops item + pickup/post-pickup text.
/// Ported from Z-Editor-master PickupCollectableTutorialEP.kt
class PickupCollectableTutorialScreen extends StatefulWidget {
  const PickupCollectableTutorialScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
    required this.onRequestZombieSelection,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;
  final void Function(void Function(String) onSelected)
  onRequestZombieSelection;

  @override
  State<PickupCollectableTutorialScreen> createState() =>
      _PickupCollectableTutorialScreenState();
}

class _PickupCollectableTutorialScreenState
    extends State<PickupCollectableTutorialScreen> {
  static const _objClass = 'PickupCollectableTutorialProperties';
  late String _alias;
  late PvzObject _moduleObj;
  late PickupCollectableTutorialData _data;
  late TextEditingController _pickupController;
  late TextEditingController _postPickupController;
  late FocusNode _pickupFocusNode;
  late FocusNode _postPickupFocusNode;

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
    _pickupFocusNode = FocusNode();
    _postPickupFocusNode = FocusNode();
    _pickupFocusNode.addListener(() => setState(() {}));
    _postPickupFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _pickupFocusNode.dispose();
    _postPickupFocusNode.dispose();
    _pickupController.dispose();
    _postPickupController.dispose();
    super.dispose();
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
        objClass: 'PickupCollectableTutorialProperties',
        objData: PickupCollectableTutorialData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = PickupCollectableTutorialData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = PickupCollectableTutorialData();
    }
    if (_data.dropperZombieType.isEmpty) {
      _data = PickupCollectableTutorialData(
        dropperZombieType: ZombieRepository().buildZombieAliases(
          'zombie_tutorial',
        ),
        lootType: _data.lootType,
        pickupAdvice: _data.pickupAdvice,
        postPickupAdvice: _data.postPickupAdvice,
      );
      _moduleObj.objData = _data.toJson();
      WidgetsBinding.instance.addPostFrameCallback((_) => widget.onChanged());
    }
    _pickupController = TextEditingController(text: _data.pickupAdvice);
    _postPickupController = TextEditingController(text: _data.postPickupAdvice);
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
  }

  String _lootLabel(String value, AppLocalizations? l10n) {
    final entry = _lootTypes.firstWhereOrNull((e) => e.value == value);
    if (entry == null) return value;
    switch (entry.labelKey) {
      case 'pickupCollectableLootGoldCoin':
        return l10n?.pickupCollectableLootGoldCoin ?? entry.fallback;
      default:
        return entry.fallback;
    }
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
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final appBarColor = isDark ? pvzPurpleDark : pvzPurpleLight;

    return Scaffold(
      appBar: AppBar(
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
          foregroundColor: Colors.white,
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              title:
                  l10n?.pickupCollectableTutorialHelpTitle ?? 'Pickup tutorial',
              themeColor: appBarColor,
              sections: [
                HelpSectionData(
                  title:
                      l10n?.pickupCollectableTutorialHelpBasic ?? 'Description',
                  body:
                      l10n?.pickupCollectableTutorialHelpBasicBody ??
                      'Configure a zombie that drops a collectable and the dialog text before/after pickup. First kill of that zombie type in the level shows the dialog.',
                ),
                HelpSectionData(
                  title:
                      l10n?.pickupCollectableTutorialHelpDialogs ?? 'Dialogs',
                  body:
                      l10n?.pickupCollectableTutorialHelpDialogsBody ??
                      'Dialogs appear before and after picking up the item and can pause the level.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
EditorAliasInputField(
              alias: _alias,
              levelFile: widget.levelFile,
              onAliasChanged: _handleAliasChanged,
              onChanged: widget.onChanged,
              accentColor: appBarColor,
            ),
            const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.pickupCollectableTutorialCoreConfig ??
                            'Core config',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: appBarColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n?.pickupCollectableTutorialZombieLabel ??
                            'Zombie that carries the item',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildZombieSelector(theme, appBarColor, l10n),
                      const SizedBox(height: 12),
                      Text(
                        l10n?.pickupCollectableTutorialLootType ?? 'Loot type',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildLootDropdown(theme, appBarColor, l10n),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.pickupCollectableTutorialGuideText ??
                            'Guide text',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: appBarColor,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        focusNode: _pickupFocusNode,
                        controller: _pickupController,
                        decoration: editorInputDecoration(
                          context,
                          labelText:
                              l10n?.pickupCollectableTutorialPickupAdvice ??
                              'Before pickup (PickupAdvice)',
                          focusColor: appBarColor,
                          isFocused: _pickupFocusNode.hasFocus,
                        ),
                        minLines: 2,
                        maxLines: 3,
                        onChanged: (v) {
                          _data = PickupCollectableTutorialData(
                            dropperZombieType: _data.dropperZombieType,
                            lootType: _data.lootType,
                            pickupAdvice: v,
                            postPickupAdvice: _data.postPickupAdvice,
                          );
                          _sync();
                        },
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        focusNode: _postPickupFocusNode,
                        controller: _postPickupController,
                        decoration: editorInputDecoration(
                          context,
                          labelText:
                              l10n?.pickupCollectableTutorialPostPickupAdvice ??
                              'After pickup (PostPickupAdvice)',
                          focusColor: appBarColor,
                          isFocused: _postPickupFocusNode.hasFocus,
                        ),
                        minLines: 2,
                        maxLines: 3,
                        onChanged: (v) {
                          _data = PickupCollectableTutorialData(
                            dropperZombieType: _data.dropperZombieType,
                            lootType: _data.lootType,
                            pickupAdvice: _data.pickupAdvice,
                            postPickupAdvice: v,
                          );
                          _sync();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildZombieSelector(
    ThemeData theme,
    Color appBarColor,
    AppLocalizations? l10n,
  ) {
    final typeId = ZombiePropertiesRepository.getTypeNameByAlias(
      _data.dropperZombieType,
    );
    final info =
        ZombieRepository().getZombieById(typeId) ??
        ZombieRepository().getZombieById(typeId.replaceAll('_elite', ''));
    final path = info?.icon != null
        ? 'assets/images/zombies/${info!.icon}'
        : 'assets/images/others/unknown.webp';
    final nameKey = ZombieRepository().getName(typeId);
    final name = ResourceNames.lookup(context, nameKey);

    return Material(
      color: theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: () {
          widget.onRequestZombieSelection((selectedId) {
            final alias = ZombieRepository().buildZombieAliases(selectedId);
            _data = PickupCollectableTutorialData(
              dropperZombieType: alias,
              lootType: _data.lootType,
              pickupAdvice: _data.pickupAdvice,
              postPickupAdvice: _data.postPickupAdvice,
            );
            _sync();
          });
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AssetImageWidget(
                  assetPath: path,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  altCandidates: imageAltCandidates(path),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      _data.dropperZombieType.isEmpty
                          ? (l10n?.pickupCollectableTutorialNotSet ?? 'Not set')
                          : _data.dropperZombieType,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLootDropdown(
    ThemeData theme,
    Color appBarColor,
    AppLocalizations? l10n,
  ) {
    // final currentLabel = _lootLabel(_data.lootType, l10n);
    return DropdownButtonFormField<String>(
      initialValue: _lootTypes.any((e) => e.value == _data.lootType)
          ? _data.lootType
          : _lootTypes.first.value,
      decoration: editorInputDecoration(context, focusColor: appBarColor),
      items: _lootTypes
          .map(
            (e) => DropdownMenuItem(
              value: e.value,
              child: Text(_lootLabel(e.value, l10n)),
            ),
          )
          .toList(),
      onChanged: (v) {
        if (v != null) {
          _data = PickupCollectableTutorialData(
            dropperZombieType: _data.dropperZombieType,
            lootType: v,
            pickupAdvice: _data.pickupAdvice,
            postPickupAdvice: _data.postPickupAdvice,
          );
          _sync();
        }
      },
    );
  }
}
