import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/minigame_imitater_properties_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;

const String _kUnknownIconPath = 'assets/images/others/unknown.webp';

/// Resolves copycats module data from the current level file, if present.
PVZ1CopycatsModulePropertiesData? copycatsModuleDataFromLevel(
  PvzLevelFile? levelFile,
) {
  if (levelFile == null) return null;
  final obj = levelFile.objects.firstWhereOrNull(
    (o) => o.objClass == 'PVZ1CopycatsModuleProperties',
  );
  if (obj == null) return null;
  try {
    return PVZ1CopycatsModulePropertiesData.fromJson(
      Map<String, dynamic>.from(obj.objData as Map),
    );
  } catch (_) {
    return null;
  }
}

PlantInfo? _resolvePlantFromWhitelistEntry(PlantRepository repo, String raw) {
  final tries = <String>{
    raw,
    raw.trim(),
    normalizeMinigamePlantTypeId(raw),
    raw.toLowerCase().trim(),
  };
  for (final t in tries) {
    if (t.isEmpty) continue;
    final p = repo.getPlantInfoById(t);
    if (p != null) return p;
  }
  return null;
}

/// Plants this hat can spawn: [SpawnPlantWhiteList] for the hat's property sheet,
/// minus [PVZ1CopycatsModuleProperties] `PlantBlackList` when the module is present,
/// intersected with the editor plant catalog.
/// Remaining plants retain their property's whitelist order.
List<PlantInfo> computeMagicHatSpawnablePlants({
  required String hatPlantId,
  PvzLevelFile? levelFile,
}) {
  final repo = PlantRepository();
  if (!repo.isLoaded) return [];

  final props = MinigameImitaterPropertiesRepository.instance;
  final sheetAlias = props.propertySheetAliasForHatPlantId(hatPlantId);
  if (sheetAlias == null) return [];

  final rawList = props.spawnPlantWhiteListForPropertyAlias(sheetAlias);
  if (rawList == null || rawList.isEmpty) return [];

  final data = copycatsModuleDataFromLevel(levelFile);
  final blacklistRaw = data?.plantBlackList ?? <String>[];
  final blacklist = blacklistRaw.map((e) => e.toLowerCase().trim()).toSet();

  final out = <PlantInfo>[];
  final seen = <String>{};
  for (final raw in rawList) {
    final p = _resolvePlantFromWhitelistEntry(repo, raw);
    if (p == null) continue;
    if (blacklist.contains(p.id.toLowerCase())) continue;
    if (seen.contains(p.id)) continue;
    seen.add(p.id);
    out.add(p);
  }
  return out;
}

/// Preview of plants that can appear from a specific magic hat ([SpawnPlantWhiteList]).
class MagicHatSpawnPreviewScreen extends StatefulWidget {
  const MagicHatSpawnPreviewScreen({
    super.key,
    required this.hatPlantId,
    required this.levelFile,
    required this.onBack,
  });

  /// Selected hat plant id, e.g. [minigame_imitater_melee1].
  final String hatPlantId;
  final PvzLevelFile? levelFile;
  final VoidCallback onBack;

  @override
  State<MagicHatSpawnPreviewScreen> createState() =>
      _MagicHatSpawnPreviewScreenState();
}

class _MagicHatSpawnPreviewScreenState
    extends State<MagicHatSpawnPreviewScreen> {
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    Future.wait([
      PlantRepository().init(),
      MinigameImitaterPropertiesRepository.init(),
    ]).then((_) {
      if (mounted) setState(() => _loaded = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final plants = computeMagicHatSpawnablePlants(
      hatPlantId: widget.hatPlantId,
      levelFile: widget.levelFile,
    );

    final hatInfo = PlantRepository().getPlantInfoById(widget.hatPlantId);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBack,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n?.magicHatSpawnPreviewTitle ?? 'Magic hat — possible plants',
            ),
            if (hatInfo != null)
              Text(
                ResourceNames.lookup(context, hatInfo.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                ),
              ),
          ],
        ),
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : plants.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n?.magicHatSpawnPreviewEmpty ??
                      'No plants match this list.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: plants.length,
              itemBuilder: (context, i) {
                final plant = plants[i];
                final iconPath = plant.iconAssetPath;
                final hasIcon = iconPath != null && iconPath.isNotEmpty;
                return ListTile(
                  leading: ClipOval(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: hasIcon
                          ? AssetImageWidget(
                              assetPath: iconPath,
                              altCandidates: imageAltCandidates(iconPath),
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                              cacheWidth: 80,
                              cacheHeight: 80,
                              errorWidget: Image.asset(
                                _kUnknownIconPath,
                                width: 40,
                                height: 40,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Image.asset(
                              _kUnknownIconPath,
                              width: 40,
                              height: 40,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ),
                  title: Text(
                    ResourceNames.lookup(context, plant.name),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    plant.id,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              },
            ),
    );
  }
}
