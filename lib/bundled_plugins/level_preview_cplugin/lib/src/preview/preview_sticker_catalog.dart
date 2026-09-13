import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:c_editor/data/asset_loader.dart';
import 'package:c_editor/data/dino_type_catalog.dart';
import 'package:c_editor/data/music_suffix_catalog.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';
import 'package:c_editor/data/repository/fish_type_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/rift_theme_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/tool_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';

/// Display order, rather than the order of image directories in the manifest.
const kPreviewStickerTags = <String>[
  'plants',
  'zombies',
  'griditems',
  'round_icons',
  'ui',
  'worlds',
  'others',
];

class PreviewSticker {
  const PreviewSticker({
    required this.assetPath,
    required this.tag,
    this.resourceNameKey,
    this.labelKey,
    this.searchTerms = const [],
    this.nameResolver,
  });

  final String assetPath;
  final String tag;
  final String? resourceNameKey;
  final String? labelKey;
  final List<String> searchTerms;
  final String Function(BuildContext context)? nameResolver;

  String localizedName(
    BuildContext context,
    String Function(String key, [String? fallback]) t,
  ) {
    if (nameResolver != null && AppLocalizations.of(context) != null) {
      return nameResolver!(context);
    }
    final fallback = labelKey == null
        ? t('previewStickerUnnamed', 'Sticker')
        : t(labelKey!);
    if (resourceNameKey == null) return fallback;
    return ResourceNames.lookupOrFallback(context, resourceNameKey!, fallback);
  }
}

String _imageStem(String path) => path.replaceFirst(RegExp(r'\.[^/.]+$'), '');

int _imagePriority(String path) {
  final extension = path.split('.').last.toLowerCase();
  return const ['gif', 'webp', 'png', 'jpg', 'jpeg'].indexOf(extension);
}

/// Matches catalog icons to their actual packaged format (including GIFs).
/// Shared icons occur once, at their first position in the editor catalogs.
List<PreviewSticker> orderPreviewStickers({
  required Iterable<String> assetPaths,
  required Iterable<PreviewSticker> orderedEntries,
}) {
  final images = <String, String>{};
  for (final path in assetPaths) {
    if (!path.startsWith('assets/images/') ||
        !RegExp(
          r'\.(gif|webp|png|jpe?g)$',
          caseSensitive: false,
        ).hasMatch(path)) {
      continue;
    }
    final stem = _imageStem(path).toLowerCase();
    final previous = images[stem];
    if (previous == null || _imagePriority(path) < _imagePriority(previous)) {
      images[stem] = path;
    }
  }

  final buckets = {
    for (final tag in kPreviewStickerTags) tag: <PreviewSticker>[],
  };
  final seen = <String>{};
  void add(PreviewSticker entry) {
    final stem = _imageStem(entry.assetPath).toLowerCase();
    final actual = images[stem];
    if (actual == null || !seen.add(stem)) return;
    final tag = buckets.containsKey(entry.tag) ? entry.tag : 'others';
    buckets[tag]!.add(
      PreviewSticker(
        assetPath: actual,
        tag: tag,
        resourceNameKey: entry.resourceNameKey,
        labelKey: entry.labelKey,
        searchTerms: entry.searchTerms,
        nameResolver: entry.nameResolver,
      ),
    );
  }

  for (final entry in orderedEntries) {
    add(entry);
  }
  // A newly shipped image remains selectable even before its catalog is updated.
  // Known images are all named below; this fallback never exposes filenames.
  for (final path in images.values.toList()..sort()) {
    if (seen.contains(_imageStem(path).toLowerCase())) continue;
    final folder = path.split('/')[2];
    final stem = path.split('/').last.split('.').first;
    String? resourceKey;
    for (final candidate in [
      stem,
      'plant_$stem',
      'zombie_$stem',
      'griditem_$stem',
    ]) {
      if (ResourceNames.lookupWithLocale('en', candidate) != candidate ||
          ResourceNames.lookupWithLocale('zh', candidate) != candidate) {
        resourceKey = candidate;
        break;
      }
    }
    add(
      PreviewSticker(
        assetPath: path,
        tag: kPreviewStickerTags.contains(folder) ? folder : 'others',
        resourceNameKey: resourceKey,
        searchTerms: [stem],
      ),
    );
  }
  return List.unmodifiable(buckets.values.expand((entries) => entries));
}

Future<List<PreviewSticker>> loadPreviewStickerCatalog() async {
  final catalogPaths = [
    'Plants',
    'Zombies',
    'ZombossMechs',
    'Zombosses',
    'GridItems',
  ];
  final catalogs = await Future.wait([
    for (final name in catalogPaths)
      loadJsonString(
        'assets/resources/$name.json',
      ).then((source) => (jsonDecode(source) as List).cast<Map>()),
  ]);
  await Future.wait([
    StageRepository.init(),
    CustomStagePresetRepository.init(),
    MusicSuffixCatalog.init(),
    FishTypeRepository().init(),
    ResourceNames.ensureLoaded(),
  ]);
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  final ordered = <PreviewSticker>[];
  for (var catalogIndex = 0; catalogIndex < catalogs.length; catalogIndex++) {
    final folder = catalogIndex == 0
        ? 'plants'
        : catalogIndex == 4
        ? 'griditems'
        : 'zombies';
    for (final raw in catalogs[catalogIndex]) {
      final icon = raw['icon'] as String?;
      if (icon == null || icon.isEmpty) continue;
      final id = (raw['id'] ?? raw['typeName']) as String;
      final key =
          raw['name'] as String? ?? (catalogIndex == 4 ? 'griditem_$id' : id);
      ordered.add(
        PreviewSticker(
          assetPath: 'assets/images/$folder/$icon',
          tag: folder,
          resourceNameKey: key,
          labelKey: id == 'gravestone_tutorial'
              ? 'previewStickerNameTutorialGravestone'
              : null,
          searchTerms: [
            id,
            ...(raw['variations'] as List? ?? []).cast<String>(),
          ],
        ),
      );
    }
  }

  for (final stage in StageRepository.allItems) {
    final icon = stage.iconName;
    if (icon == null || icon == 'unknown.webp') continue;
    ordered.add(
      PreviewSticker(
        assetPath: 'assets/images/round_icons/$icon',
        tag: 'round_icons',
        resourceNameKey: StageRepository.getName(stage.alias),
        searchTerms: [stage.alias],
      ),
    );
  }
  for (final preset in CustomStagePresetRepository.presets) {
    ordered.add(
      PreviewSticker(
        assetPath: 'assets/images/round_icons/${preset.iconName}',
        tag: 'round_icons',
        resourceNameKey: preset.nameKey,
        searchTerms: [preset.alias],
      ),
    );
  }
  for (final code in MusicSuffixCatalog.orderedCodes) {
    final path = MusicSuffixCatalog.iconAsset(code);
    if (path == MusicSuffixCatalog.unknownIconAsset) continue;
    ordered.add(
      PreviewSticker(
        assetPath: path,
        tag: 'round_icons',
        resourceNameKey: MusicSuffixCatalog.resourceKey(code),
        searchTerms: [code],
      ),
    );
  }

  for (final card in ToolRepository.toolCards) {
    if (card.icon == null) continue;
    ordered.add(
      PreviewSticker(
        assetPath: 'assets/images/tools/${card.icon}',
        tag: 'griditems',
        resourceNameKey: card.id,
        searchTerms: [card.id],
      ),
    );
  }
  for (final id in kDinoSpawnTypeIds) {
    ordered.add(
      PreviewSticker(
        assetPath: dinoSpawnImageAsset(id),
        tag: 'griditems',
        resourceNameKey: 'dinoType_$id',
        searchTerms: [id],
      ),
    );
  }
  for (final fish in FishTypeRepository().allFishes) {
    if (!FishInfo.hasEditorIcon(fish.alias)) continue;
    ordered.add(
      PreviewSticker(
        assetPath: fish.iconAssetPath,
        tag: 'griditems',
        resourceNameKey: 'creature_${FishInfo.normalizeFishAlias(fish.alias)}',
        searchTerms: [fish.alias, fish.typeName],
      ),
    );
  }
  for (final category in [
    PlantCategory.quality,
    PlantCategory.role,
    PlantCategory.attribute,
  ]) {
    for (final tag in PlantTag.values) {
      if (tag.category != category || tag.iconAssetPath == null) continue;
      ordered.add(
        PreviewSticker(
          assetPath: tag.iconAssetPath!,
          tag: 'ui',
          nameResolver: tag.getLabel,
          searchTerms: [tag.name],
        ),
      );
    }
  }
  for (final tag in ZombieTag.values) {
    if (tag.iconAssetPath == null) continue;
    ordered.add(
      PreviewSticker(
        assetPath: tag.iconAssetPath!,
        tag: 'ui',
        nameResolver: tag.getLabel,
        searchTerms: [tag.name],
      ),
    );
  }
  for (final id in RiftThemeRepository.themeIds) {
    final path = RiftThemeRepository.iconAssetPath(id);
    final isSharedPursuitIcon = path.endsWith('/pursuit.webp');
    ordered.add(
      PreviewSticker(
        assetPath: path,
        tag: 'ui',
        resourceNameKey: isSharedPursuitIcon ? null : 'rift_theme_$id',
        labelKey: isSharedPursuitIcon ? 'previewStickerNamePursuit' : null,
        searchTerms: [id],
      ),
    );
  }
  final perkNames = <String, String Function(AppLocalizations)>{
    'Crystal': (s) => s.ztPerkCategoryCrystal,
    'Attack': (s) => s.ztPerkCategoryAttack,
    'Speed': (s) => s.ztPerkCategorySpeed,
    'Shield': (s) => s.ztPerkCategoryShield,
    'Gravity': (s) => s.ztPerkCategoryGravity,
    'ImmuneControl': (s) => s.ztPerkCategoryImmuneControl,
    'AntiControl': (s) => s.ztPerkCategoryAntiControl,
  };
  for (final entry in perkNames.entries) {
    ordered.add(
      PreviewSticker(
        assetPath: 'assets/images/ztalemate_perks/${entry.key}.webp',
        tag: 'ui',
        nameResolver: (context) => entry.value(AppLocalizations.of(context)!),
        searchTerms: [entry.key],
      ),
    );
  }
  ordered.addAll(_supplementalStickers());
  return orderPreviewStickers(
    assetPaths: manifest.listAssets(),
    orderedEntries: ordered,
  );
}

Iterable<PreviewSticker> _supplementalStickers() sync* {
  const resources = <String, String>{
    'zombies/zombie_general_zmech_phase': 'zombie_general_zmech_phase1',
    'zombies/zombie_renai_toxicwater': 'zombie_beach_snorkel',
    'zombies/zombie_zombie_towerdefend_boss': 'zombie_zombie_towerdefend_boss',
    'zombies/zombie_zombie_towerdefend_wolf_fire':
        'zombie_zombie_towerdefend_wolf_fire',
    'zombies/zombie_zombie_towerdefend_wolf_imp':
        'zombie_zombie_towerdefend_wolf_imp',
    'griditems/ArmrackArmor': 'armrack_ArmrackArmor',
    'griditems/ArmrackBlade': 'armrack_ArmrackBlade',
    'griditems/ArmrackBomb': 'armrack_ArmrackBomb',
    'griditems/ArmrackFlag': 'armrack_ArmrackFlag',
    'griditems/ArmrackHammer': 'armrack_ArmrackHammer',
    'griditems/ArmrackNunchaku': 'armrack_ArmrackNunchaku',
    'griditems/ArmrackTorch': 'armrack_ArmrackTorch',
    'griditems/steam_up': 'griditem_steam_up',
    'griditems/steam_down': 'griditem_steam_down',
    'griditems/SmokeManhole': 'griditem_SmokeManhole',
    'griditems/lunar_mine_vein': 'griditem_lunar_mine_vein',
    'griditems/radiation_meteor_ore': 'griditem_radiation_meteor_ore',
    'griditems/pumpkin_house': 'griditem_pumpkin_house',
    'griditems/magic_mirror': 'griditem_magic_mirror',
    'griditems/magic_mirror1': 'griditem_magic_mirror1',
    'griditems/magic_mirror2': 'griditem_magic_mirror2',
    'griditems/magic_mirror3': 'griditem_magic_mirror3',
    'round_icons/Stage_LostVolcano': 'customStagePreset_lostVolcano',
    'round_icons/Stage_TeamBoss': 'musicSuffix_TeamBoss',
    'round_icons/Suffix_TeamBoss': 'musicSuffix_TeamBoss',
    'others/sun_large': 'sun_large',
    'others/plantfood': 'tool_plantfood',
  };
  for (final entry in resources.entries) {
    yield PreviewSticker(
      assetPath: 'assets/images/${entry.key}.webp',
      tag: entry.key.split('/').first,
      resourceNameKey: entry.value,
      searchTerms: [entry.key.split('/').last],
    );
  }
  const labels = <String, String>{
    'others/unknown': 'MainMenu',
    'others/rails': 'Rails',
    'others/railcarts': 'Railcart',
    'others/Pirate_Seas_Planks': 'PiratePlanks',
    'others/kongfu_minecart_tracks': 'KongfuTracks',
    'others/kongfu_minecart_left': 'KongfuCartLeft',
    'others/kongfu_minecart_middle': 'KongfuCartMiddle',
    'others/kongfu_minecart_right': 'KongfuCartRight',
    'tunnels/GULLIVERTUNNEL_ORIENTATION_BIG_ON_LEFT': 'GulliverLeft',
    'tunnels/GULLIVERTUNNEL_ORIENTATION_BIG_ON_RIGHT': 'GulliverRight',
    'tunnels/SouDaCheTunnelRoad': 'ExpeditionRoad',
    'tunnels/SouDaCheTunnelRoadBlocked': 'ExpeditionRoadBlocked',
  };
  for (final entry in labels.entries) {
    yield PreviewSticker(
      assetPath: 'assets/images/${entry.key}.webp',
      tag: entry.key.startsWith('tunnels/') ? 'griditems' : 'others',
      labelKey: entry.value == 'MainMenu'
          ? 'previewGenUnknownBanner'
          : 'previewStickerName${entry.value}',
      searchTerms: [entry.key.split('/').last],
    );
  }
  yield PreviewSticker(
    assetPath: 'assets/images/others/to_be_continued.webp',
    tag: 'others',
    nameResolver: (context) =>
        AppLocalizations.of(context)!.comingSoonPlantBlockedLabel,
  );
  // Same component order as the Underground Palace module's image picker.
  const directions = {
    'DOWN': [1, 2, 3],
    'DOWN_LEFT': [1, 2, 3],
    'LEFT': [1, 2, 3, 4, 5, 6, 7],
    'UP': [1, 2, 3],
    'UP_LEFT': [1, 2, 3],
    'UP_DOWN': [1, 2],
    'UP_DOWN_LEFT': [1, 2],
  };
  for (final direction in directions.entries) {
    for (final variant in direction.value) {
      final suffix = variant == 1 ? '' : '_$variant';
      yield PreviewSticker(
        assetPath:
            'assets/images/tunnels/IMAGE_UI_MAUSOLEUM_TUNNEL_${direction.key}$suffix.webp',
        tag: 'griditems',
        labelKey:
            'previewStickerNameTunnel${direction.key.replaceAll('_', '')}$variant',
      );
    }
  }
}
