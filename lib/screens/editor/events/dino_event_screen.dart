import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/dino_type_catalog.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

/// Dino event editor. Ported from Z-Editor-master DinoEventEP.kt
class DinoEventScreen extends StatefulWidget {
  const DinoEventScreen({
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
  State<DinoEventScreen> createState() => _DinoEventScreenState();
}

class _DinoEventScreenState extends State<DinoEventScreen> {
  static const _objClass = 'DinoWaveActionProps';

  late PvzObject _moduleObj;
  late DinoWaveActionPropsData _data;
  late String _alias;

  bool get _isDeepSeaLawn =>
      LevelParser.isDeepSeaLawnFromFile(widget.levelFile);
  int get _maxRowIndex => _isDeepSeaLawn ? 5 : 4;

  String _dinoTypeLabel(BuildContext context, String typeId) {
    final key = 'dinoType_$typeId';
    final localized = ResourceNames.lookup(context, key);
    return localized != key ? localized : typeId;
  }

  @override
  void initState() {
    super.initState();
    _alias = aliasFromRtid(widget.rtid);
    _loadData();
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
        objClass: _objClass,
        objData: DinoWaveActionPropsData().toJson(),
      );
      widget.levelFile.objects.add(_moduleObj);
    }
    try {
      _data = DinoWaveActionPropsData.fromJson(
        Map<String, dynamic>.from(_moduleObj.objData as Map),
      );
    } catch (_) {
      _data = DinoWaveActionPropsData();
    }
  }

  void _sync() {
    _moduleObj.objData = _data.toJson();
    widget.onChanged();
    setState(() {});
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

  /// Icon edge length: 20% of [availableWidth], reduced when the field is narrow.
  double _dinoIconSizeForWidth(double availableWidth) {
    const minIcon = 28.0;
    const maxIcon = 72.0;
    // Padding + gap + chevron + minimum text run.
    const reserved = 14 + 14 + 10 + 32 + 40;
    final preferred = availableWidth * 0.2;
    final maxFit = (availableWidth - reserved).clamp(minIcon, maxIcon);
    return preferred.clamp(minIcon, maxFit);
  }

  Widget _dinoLeadingIcon(String typeId, double size) {
    final px = (size * MediaQuery.devicePixelRatioOf(context)).round();
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: AssetImageWidget(
          assetPath: dinoSpawnImageAsset(typeId),
          altCandidates: dinoSpawnImageCandidates(typeId),
          width: size,
          height: size,
          fit: BoxFit.cover,
          cacheWidth: px,
          cacheHeight: px,
        ),
      ),
    );
  }

  Widget _dinoDropdownLabel(String typeId, double iconSize) {
    return SizedBox(
      height: iconSize,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _dinoLeadingIcon(typeId, iconSize),
          const SizedBox(width: 10),
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                _dinoTypeLabel(context, typeId),
                style: const TextStyle(fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final eventTitle = resolveEventTitleByObjClass(context, _objClass, l10n);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: eventTitle,
          isEvent: true,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              title: l10n?.eventDino ?? 'Dino event',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.eventHelpDinoBody ?? '',
                ),
                HelpSectionData(
                  title: l10n?.dinoType ?? 'Dinosaur type',
                  body: l10n?.eventHelpDinoType ?? '',
                ),
                HelpSectionData(
                  title: l10n?.dinoRowTitle ?? 'Row',
                  body: l10n?.eventHelpDinoRow ?? '',
                ),
                HelpSectionData(
                  title: l10n?.dinoWaveDuration ?? 'Stay duration',
                  body:
                      l10n?.eventHelpDinoWaveDuration ??
                      l10n?.eventHelpDinoDuration ??
                      '',
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
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n?.positionAndDuration ?? 'Position & timing',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              l10n?.dinoRow(_data.dinoRow + 1) ??
                                  'Row: ${_data.dinoRow + 1}',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: _data.dinoRow > 0
                                ? () {
                                    _data = DinoWaveActionPropsData(
                                      dinoRow: _data.dinoRow - 1,
                                      dinoType: _data.dinoType,
                                      dinoWaveDuration: _data.dinoWaveDuration,
                                    );
                                    _sync();
                                  }
                                : null,
                          ),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: _data.dinoRow < _maxRowIndex
                                ? () {
                                    _data = DinoWaveActionPropsData(
                                      dinoRow: _data.dinoRow + 1,
                                      dinoType: _data.dinoType,
                                      dinoWaveDuration: _data.dinoWaveDuration,
                                    );
                                    _sync();
                                  }
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        initialValue: _data.dinoWaveDuration.toString(),
                        decoration: InputDecoration(
                          labelText:
                              l10n?.dinoWaveDuration ?? 'Stay duration (waves)',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) {
                          final n = int.tryParse(v);
                          if (n != null) {
                            _data = DinoWaveActionPropsData(
                              dinoRow: _data.dinoRow,
                              dinoType: _data.dinoType,
                              dinoWaveDuration: n,
                            );
                            _sync();
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final iconSize = _dinoIconSizeForWidth(
                        constraints.maxWidth,
                      );
                      // Menu rows must be >= kMinInteractiveDimension.
                      final itemHeight = iconSize < kMinInteractiveDimension
                          ? kMinInteractiveDimension
                          : iconSize + 8;
                      final selectedId =
                          kDinoSpawnTypeIds.contains(_data.dinoType)
                          ? _data.dinoType
                          : kDinoSpawnTypeIds.first;

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.pets,
                                color: theme.colorScheme.secondary,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  l10n?.dinoType ?? 'Dinosaur type',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Avoid DropdownButtonFormField: it clamps the
                          // selected row to a text-field height and squashes
                          // square icons. InputDecorator sizes to the child.
                          SizedBox(
                            width: constraints.maxWidth,
                            child: PopupMenuButton<String>(
                              initialValue: selectedId,
                              position: PopupMenuPosition.under,
                              padding: EdgeInsets.zero,
                              tooltip:
                                  l10n?.dinoType ?? 'Dinosaur type',
                              constraints: BoxConstraints(
                                minWidth: constraints.maxWidth,
                                maxWidth: constraints.maxWidth,
                              ),
                              onSelected: (v) {
                                _data = DinoWaveActionPropsData(
                                  dinoRow: _data.dinoRow,
                                  dinoType: v,
                                  dinoWaveDuration: _data.dinoWaveDuration,
                                );
                                _sync();
                              },
                              itemBuilder: (context) => [
                                for (final id in kDinoSpawnTypeIds)
                                  PopupMenuItem<String>(
                                    value: id,
                                    height: itemHeight,
                                    child: _dinoDropdownLabel(id, iconSize),
                                  ),
                              ],
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  contentPadding: const EdgeInsets.fromLTRB(
                                    14,
                                    12,
                                    8,
                                    12,
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.arrow_drop_down,
                                  ),
                                ),
                                child: _dinoDropdownLabel(
                                  selectedId,
                                  iconSize,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
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
}
