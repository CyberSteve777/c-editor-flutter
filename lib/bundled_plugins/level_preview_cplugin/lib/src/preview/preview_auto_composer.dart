import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_feature_groups.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_zomboss_extras.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/stage_banner_resolver.dart';
import 'package:c_editor/data/armrack_type_catalog.dart';
import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/level_module_order_utils.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/data/zombie_discovery.dart';
import 'package:c_editor/screens/common/level_preview_grid_helpers.dart';

/// Builds a [PreviewDocument] from the open level.
class PreviewAutoComposer {
  PreviewAutoComposer({
    required this.levelFile,
    required this.parsed,
    required this.fileName,
    required this.banners,
    required this.featureGroups,
    this.style = PreviewAutoStyle.normal,
    this.localize,
    this.moduleTitle,
    this.plantsSourceLabel = 'Plants',
    this.zombiesSourceLabel = 'Zombies',
    this.gridItemsSourceLabel = 'Initial grid items',
    this.seedBankLabel = 'Seed Bank',
    this.conveyorLabel = 'Conveyor',
    this.prePlacedLabel = 'Pre-placed',
    this.protectLabel = 'Protect',
    this.challengeLabel = 'Challenge',
    this.wavesLabel = 'Waves',
    this.initialZombiesLabel = 'Initial',
    this.vasebreakerLabel = 'Vasebreaker',
    this.zombotPrefix = 'Zombot: ',
    this.zombossPrefix = 'Zomboss: ',
    this.spawnedZombiesLabel = 'Spawned zombies: ',
    this.resourceName,
  });

  final PvzLevelFile levelFile;
  final ParsedLevelData parsed;
  final String fileName;
  final StageBannerResolver banners;
  final PreviewFeatureGroups featureGroups;
  final PreviewAutoStyle style;
  final PreviewLabelLookup? localize;
  final PreviewModuleTitleLookup? moduleTitle;
  final String Function(String id)? resourceName;

  final String plantsSourceLabel;
  final String zombiesSourceLabel;
  final String gridItemsSourceLabel;
  final String seedBankLabel;
  final String conveyorLabel;
  final String prePlacedLabel;
  final String protectLabel;
  final String challengeLabel;
  final String wavesLabel;
  final String initialZombiesLabel;
  final String vasebreakerLabel;
  final String zombotPrefix;
  final String zombossPrefix;
  final String spawnedZombiesLabel;

  Future<PreviewDocument> compose() async {
    await PlantRepository().init();
    await ZombieRepository().init();
    await GridItemRepository.init();
    await ReferenceRepository.init();

    final levelDef = parsed.levelDef;
    final stageAlias = RtidParser.parse(levelDef?.stageModule ?? '')?.alias;
    final stem = banners.resolveStem(stageAlias);
    final banner = PreviewBannerRef(
      kind: PreviewBannerSourceKind.stageMapped,
      stem: stem,
      assetPath: banners.assetPathForStem(stem),
    );

    final plantItems = _collectPlants();
    final extras = await PreviewZombossExtras.collect(levelFile);
    final bossExclude = {
      ...extras.bossItems.map((e) => e.id),
      if (style == PreviewAutoStyle.normal) ...extras.spawnItems.map((e) => e.id),
    };
    final seedBankZombies = _collectSeedBankZombies(excludeIds: bossExclude);
    final vaseZombies = _collectVasebreakerZombies(
      excludeIds: {...bossExclude, ...seedBankZombies.map((e) => e.id)},
    );
    final waveZombies = _collectWaveZombies(
      excludeIds: {
        ...bossExclude,
        ...seedBankZombies.map((e) => e.id),
        ...vaseZombies.map((e) => e.id),
      },
    );
    final zombieItems = [...seedBankZombies, ...vaseZombies, ...waveZombies];
    final layers = style == PreviewAutoStyle.simple
        ? _composeSimple(levelDef, plantItems, extras, zombieItems)
        : _composeNormal(levelDef, plantItems, extras, zombieItems);

    return PreviewDocument(
      banner: banner,
      layers: layers,
      levelFileName: fileName,
      autoStyle: style,
    );
  }

  Rect _iconGridBounds({
    required double left,
    required double top,
    required double maxWidthNorm,
    required List<PreviewIconSection> sections,
    required bool showChrome,
    String? gridTitle,
    String? sourceLabel,
  }) {
    // Chrome panels keep the full allocated width so Wrap row counts match
    // the real layout. Shrinking to content width made more rows → clipped.
    double w = maxWidthNorm.clamp(0.04, 1.0);
    if (!showChrome) {
      final probe = previewIconGridIntrinsicSize(
        maxWidth: maxWidthNorm * kPreviewCanvasSize.width,
        sections: sections,
        showChrome: false,
      );
      w = (probe.width / kPreviewCanvasSize.width).clamp(0.04, maxWidthNorm);
    }
    final size = previewIconGridIntrinsicSize(
      maxWidth: w * kPreviewCanvasSize.width,
      sections: sections,
      showChrome: showChrome,
      gridTitle: gridTitle,
      sourceLabel: sourceLabel,
    );
    final maxH = (1.0 - top).clamp(0.04, 1.0);
    final h = (size.height / kPreviewCanvasSize.height).clamp(0.04, maxH);
    return Rect.fromLTWH(left, top, w, h);
  }

  List<PreviewIconSection> _zombieSections({
    required PreviewZombossExtras extras,
    required List<PreviewItem> waveZombies,
    required bool normal,
  }) {
    final sections = <PreviewIconSection>[];
    for (final boss in extras.bosses) {
      final name = resourceName?.call(boss.item.id) ?? boss.item.id;
      final title = normal
          ? '${boss.kind == PreviewBossKind.zombot ? zombotPrefix : zombossPrefix}$name'
          : null;
      sections.add(
        PreviewIconSection(
          title: title,
          items: [boss.item],
          iconSize: normal ? 72 : 64,
        ),
      );
    }
    if (normal && extras.spawnItems.isNotEmpty) {
      sections.add(
        PreviewIconSection(
          title: spawnedZombiesLabel,
          items: extras.spawnItems,
          iconSize: 36,
        ),
      );
    }
    if (waveZombies.isNotEmpty) {
      sections.add(PreviewIconSection(items: waveZombies, iconSize: 36));
    }
    return sections;
  }

  List<PreviewLayer> _composeNormal(
    LevelDefinitionData? levelDef,
    List<PreviewItem> plantItems,
    PreviewZombossExtras extras,
    List<PreviewItem> waveZombies,
  ) {
    final layers = <PreviewLayer>[];
    var z = 0;

    layers.add(
      PreviewLayer(
        id: 'title',
        kind: PreviewLayerKind.text,
        bounds: const Rect.fromLTWH(0.025, 0.04, 0.70, 0.16),
        zIndex: z++,
        text: _levelTitle(levelDef),
        textStyle: PreviewTextStyleData(
          fontFamily: kPreviewCustomFontFamily,
          fontSize: 42,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFFFFFF),
          outline: true,
          outlineWidth: 4,
        ),
      ),
    );

    final subtitle = featureGroups.buildSubtitle(
      _themeObjClassesOrdered(),
      localize: localize,
      moduleTitle: moduleTitle,
    );
    if (subtitle.isNotEmpty) {
      layers.add(
        PreviewLayer(
          id: 'subtitle',
          kind: PreviewLayerKind.text,
          bounds: const Rect.fromLTWH(0.025, 0.18, 0.70, 0.12),
          zIndex: z++,
          text: subtitle,
          textStyle: PreviewTextStyleData(
            fontFamily: kPreviewCustomFontFamily,
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: const Color(0xFFFFE082),
            outline: true,
            outlineWidth: 2.5,
          ),
        ),
      );
    }

    final gridItems = _collectGridItems();
    final zombieSections = _zombieSections(
      extras: extras,
      waveZombies: waveZombies,
      normal: true,
    );
    final hasPlants = plantItems.isNotEmpty;
    final hasZombies = zombieSections.isNotEmpty;
    final hasGrid = gridItems.isNotEmpty && hasPlants && hasZombies;

    var cursorY = 0.34;

    var plantBottom = cursorY;
    if (hasPlants) {
      final plantSections = [
        PreviewIconSection(items: plantItems, iconSize: 36),
      ];
      final source = _combinedSources(plantItems);
      final bounds = _iconGridBounds(
        left: 0.03,
        top: cursorY,
        maxWidthNorm: hasZombies ? 0.42 : 0.94,
        sections: plantSections,
        showChrome: true,
        gridTitle: plantsSourceLabel,
        sourceLabel: source,
      );
      layers.add(
        PreviewLayer(
          id: 'plants',
          kind: PreviewLayerKind.iconGrid,
          gridKind: PreviewIconGridKind.plants,
          gridTitle: plantsSourceLabel,
          sourceLabel: source,
          showChrome: true,
          bounds: bounds,
          zIndex: z++,
          items: plantItems,
          sections: plantSections,
        ),
      );
      plantBottom = bounds.bottom;
    }
    if (hasZombies) {
      final source = _combinedSources(waveZombies);
      final bounds = _iconGridBounds(
        left: hasPlants ? 0.48 : 0.03,
        top: cursorY,
        maxWidthNorm: hasPlants ? 0.49 : 0.94,
        sections: zombieSections,
        showChrome: true,
        gridTitle: zombiesSourceLabel,
        sourceLabel: source.isEmpty ? null : source,
      );
      layers.add(
        PreviewLayer(
          id: 'zombies',
          kind: PreviewLayerKind.iconGrid,
          gridKind: PreviewIconGridKind.zombies,
          gridTitle: zombiesSourceLabel,
          sourceLabel: source.isEmpty ? null : source,
          showChrome: true,
          bounds: bounds,
          zIndex: z++,
          items: [
            ...extras.bossItems,
            ...extras.spawnItems,
            ...waveZombies,
          ],
          sections: zombieSections,
        ),
      );
      cursorY = (plantBottom > bounds.bottom ? plantBottom : bounds.bottom) + 0.02;
    } else if (hasPlants) {
      cursorY = plantBottom + 0.02;
    }
    if (gridItems.isNotEmpty) {
      final gridSections = [
        PreviewIconSection(items: gridItems, iconSize: 36),
      ];
      final source = _combinedSources(gridItems);
      final top = hasGrid ? cursorY.clamp(0.55, 0.85) : (hasPlants || hasZombies ? cursorY : 0.40);
      final bounds = _iconGridBounds(
        left: 0.03,
        top: top,
        maxWidthNorm: 0.94,
        sections: gridSections,
        showChrome: true,
        gridTitle: gridItemsSourceLabel,
        sourceLabel: source,
      );
      layers.add(
        PreviewLayer(
          id: 'grid_items',
          kind: PreviewLayerKind.iconGrid,
          gridKind: PreviewIconGridKind.gridItems,
          gridTitle: gridItemsSourceLabel,
          sourceLabel: source,
          showChrome: true,
          bounds: bounds,
          zIndex: z++,
          items: gridItems,
          sections: gridSections,
        ),
      );
    }
    return layers;
  }

  List<PreviewLayer> _composeSimple(
    LevelDefinitionData? levelDef,
    List<PreviewItem> plantItems,
    PreviewZombossExtras extras,
    List<PreviewItem> waveZombies,
  ) {
    final layers = <PreviewLayer>[];
    var z = 0;

    final theme =
        featureGroups.firstFeatureLabel(
          _themeObjClassesOrdered(),
          localize: localize,
          moduleTitle: moduleTitle,
        ) ??
        _levelTitle(levelDef);

    final zombieSections = _zombieSections(
      extras: extras,
      waveZombies: waveZombies,
      normal: false,
    );

    if (plantItems.isNotEmpty) {
      final plantSections = [
        PreviewIconSection(items: plantItems, iconSize: 36),
      ];
      layers.add(
        PreviewLayer(
          id: 'plants',
          kind: PreviewLayerKind.iconGrid,
          gridKind: PreviewIconGridKind.plants,
          showChrome: false,
          bounds: _iconGridBounds(
            left: 0.04,
            top: 0.08,
            maxWidthNorm: zombieSections.isNotEmpty ? 0.40 : 0.90,
            sections: plantSections,
            showChrome: false,
          ),
          zIndex: z++,
          items: plantItems,
          sections: plantSections,
        ),
      );
    }
    if (zombieSections.isNotEmpty) {
      layers.add(
        PreviewLayer(
          id: 'zombies',
          kind: PreviewLayerKind.iconGrid,
          gridKind: PreviewIconGridKind.zombies,
          showChrome: false,
          bounds: _iconGridBounds(
            left: plantItems.isNotEmpty ? 0.48 : 0.04,
            top: 0.06,
            maxWidthNorm: plantItems.isNotEmpty ? 0.48 : 0.90,
            sections: zombieSections,
            showChrome: false,
          ),
          zIndex: z++,
          items: [...extras.bossItems, ...waveZombies],
          sections: zombieSections,
        ),
      );
    }

    layers.add(
      PreviewLayer(
        id: 'theme',
        kind: PreviewLayerKind.text,
        bounds: const Rect.fromLTWH(0.04, 0.72, 0.55, 0.22),
        zIndex: z++,
        text: theme,
        textStyle: PreviewTextStyleData(
          fontFamily: kPreviewCustomFontFamily,
          fontSize: 56,
          fontWeight: FontWeight.bold,
          color: const Color(0xFFFFFFFF),
          outline: true,
          outlineWidth: 5,
        ),
      ),
    );
    return layers;
  }

  String _levelTitle(LevelDefinitionData? def) {
    final name = def?.name.trim() ?? '';
    if (name.isNotEmpty) return name;
    final base = fileName.replaceAll(
      RegExp(r'\.(json|hujson|rton)$', caseSensitive: false),
      '',
    );
    return base.isEmpty ? 'Level' : base;
  }

  /// Theme modules in level-definition order (Special Modes + tracked extras).
  ///
  /// Resolves `@LevelModules` RTIDs via [ReferenceRepository] so Zomboss intro
  /// (and similar shared modules) are not skipped.
  List<String> _themeObjClassesOrdered() {
    final out = <String>[];
    final seen = <String>{};
    final tracked = featureGroups.trackedObjClasses;

    bool isThemeCandidate(String objClass) {
      if (featureGroups.excludeObjClasses.contains(objClass)) return false;
      if (tracked.contains(objClass)) return true;
      final meta = ModuleRegistry.registry[objClass];
      return meta != null && meta.category == ModuleCategory.mode;
    }

    void add(String? objClass) {
      if (objClass == null || objClass.isEmpty) return;
      if (!isThemeCandidate(objClass)) return;
      if (seen.add(objClass)) out.add(objClass);
    }

    final def = parsed.levelDef;
    if (def != null) {
      for (final rtid in def.modules) {
        add(_resolveModuleObjClass(rtid));
      }
    }
    for (final obj in levelFile.objects) {
      add(obj.objClass);
    }
    return PreviewFeatureGroups.sortObjClassesByCategory(out);
  }

  String? _resolveModuleObjClass(String rtid) {
    final resolved = LevelModuleOrderUtils.resolveModuleObjClass(
      rtid,
      parsed.objectMap,
    );
    if (resolved != null && resolved.isNotEmpty) return resolved;

    final info = RtidParser.parse(rtid);
    if (info == null) return null;

    // CurrentLevel object indexed under a secondary alias.
    final local = levelFile.objects.firstWhereOrNull(
      (o) => o.aliases?.contains(info.alias) == true,
    );
    if (local?.objClass != null && local!.objClass.isNotEmpty) {
      return local.objClass;
    }

    // allowMultiple aliases: ZombossBattle2 → ZombossBattleModuleProperties
    for (final entry in ModuleRegistry.registry.entries) {
      final meta = entry.value;
      final alias = meta.defaultAlias;
      if (alias == info.alias) return entry.key;
      if (meta.allowMultiple &&
          info.alias.startsWith(alias) &&
          info.alias.length > alias.length) {
        return entry.key;
      }
    }
    return null;
  }

  bool _isIZombieSeedBank(Map data) {
    return data['ZombieMode'] == true ||
        '${data['SeedPacketType'] ?? ''}'.contains('UIIZombieSeedPacket');
  }

  List<PreviewItem> _collectPlants() {
    final seen = <String>{};
    final items = <PreviewItem>[];

    void addPlant(String rawId, String source) {
      final id = _cleanId(rawId);
      if (id.isEmpty || !seen.add('$source::$id')) return;
      // Deduplicate by id across sources for display uniqueness, but keep first source.
      if (items.any((e) => e.id == id)) return;
      final path = previewPlantLikeAssetPath(id);
      items.add(PreviewItem(id: id, assetPath: path, sourceLabel: source));
    }

    void addFromList(dynamic raw, String source) {
      if (raw is! List) return;
      for (final e in raw) {
        if (e is String) {
          addPlant(e, source);
        } else if (e is Map) {
          final types = e['PlantTypes'];
          if (types is List) {
            for (final t in types) {
              if (t is String) addPlant(t, source);
            }
          }
          final id =
              e['ToolType'] ??
              e['PlantType'] ??
              e['PlantTypeName'] ??
              e['TypeName'] ??
              e['Type'];
          if (id is String) addPlant(id, source);
        }
      }
    }

    final sb = levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'SeedBankProperties',
    );
    if (sb?.objData is Map) {
      final data = sb!.objData as Map;
      // I-zombie seed packets are zombies — collected separately.
      if (!_isIZombieSeedBank(data)) {
        addFromList(data['PresetPlantList'], seedBankLabel);
        addFromList(data['PlantWhiteList'] ?? data['WhiteList'], seedBankLabel);
      }
    }

    final conv = levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'ConveyorSeedBankProperties',
    );
    if (conv?.objData is Map) {
      final data = conv!.objData as Map;
      addFromList(data['Plants'] ?? data['InitialPlantList'], conveyorLabel);
    }

    for (final obj in levelFile.objects) {
      if (obj.objClass == 'InitialPlantEntryProperties' ||
          obj.objClass == 'InitialPlantProperties' ||
          obj.objClass == 'FrozenPlantPlacement') {
        final data = obj.objData;
        if (data is Map) {
          addFromList(
            data['InitialPlantPlacements'] ??
                data['Plants'] ??
                data['PlantPlacements'] ??
                data['InitialPlantList'],
            prePlacedLabel,
          );
          final single = data['PlantType'] ?? data['PlantTypeName'];
          if (single is String) addPlant(single, prePlacedLabel);
          // Nested plant type fields.
          _scanPlantFields(data, prePlacedLabel, addPlant);
        }
      }
      if (obj.objClass == 'ProtectThePlantChallengeProperties') {
        final data = obj.objData;
        if (data is Map) {
          addFromList(data['Plants'], protectLabel);
          _scanPlantFields(data, protectLabel, addPlant);
        }
      }
      if (obj.objClass == 'PlantDefeatZombieChallengeProps') {
        final data = obj.objData;
        if (data is Map) {
          final t = data['PlantTypeName'] ?? data['PlantType'];
          if (t is String) addPlant(t, challengeLabel);
        }
      }
    }

    final vaseData = readVaseBreakerData(levelFile);
    if (vaseData != null) {
      for (final v in vaseData.vases) {
        final p = v.plantTypeName;
        if (p != null && p.isNotEmpty) addPlant(p, vasebreakerLabel);
      }
    }

    return items;
  }

  /// I-zombie seed bank presets/whitelist → zombie icons for zombie sections.
  List<PreviewItem> _collectSeedBankZombies({
    Set<String> excludeIds = const {},
  }) {
    final items = <PreviewItem>[];
    final seen = <String>{...excludeIds};

    final sb = levelFile.objects.firstWhereOrNull(
      (o) => o.objClass == 'SeedBankProperties',
    );
    if (sb?.objData is! Map) return items;
    final data = sb!.objData as Map;
    if (!_isIZombieSeedBank(data)) return items;

    void addZombie(String rawId) {
      final id = _cleanId(rawId);
      if (id.isEmpty || !seen.add(id)) return;
      final info = ZombieRepository().getZombieById(id);
      final path = info?.iconAssetPath ?? 'assets/images/others/unknown.webp';
      items.add(
        PreviewItem(id: id, assetPath: path, sourceLabel: seedBankLabel),
      );
    }

    void addFromList(dynamic raw) {
      if (raw is! List) return;
      for (final e in raw) {
        if (e is String) {
          addZombie(e);
        } else if (e is Map) {
          final types = e['PlantTypes'];
          if (types is List) {
            for (final t in types) {
              if (t is String) addZombie(t);
            }
          }
          final id =
              e['PlantType'] ??
              e['PlantTypeName'] ??
              e['TypeName'] ??
              e['Type'] ??
              e['ZombieType'];
          if (id is String) addZombie(id);
        }
      }
    }

    addFromList(data['PresetPlantList']);
    addFromList(data['PlantWhiteList'] ?? data['WhiteList']);
    return items;
  }

  List<PreviewItem> _collectVasebreakerZombies({
    Set<String> excludeIds = const {},
  }) {
    final items = <PreviewItem>[];
    final seen = <String>{...excludeIds};
    final vaseData = readVaseBreakerData(levelFile);
    if (vaseData == null) return items;
    for (final v in vaseData.vases) {
      final z = v.zombieTypeName;
      if (z == null || z.isEmpty) continue;
      final id = _cleanId(z);
      if (id.isEmpty || !seen.add(id)) continue;
      final info = ZombieRepository().getZombieById(id);
      final path = info?.iconAssetPath ?? 'assets/images/others/unknown.webp';
      items.add(
        PreviewItem(id: id, assetPath: path, sourceLabel: vasebreakerLabel),
      );
    }
    return items;
  }

  void _scanPlantFields(
    dynamic node,
    String source,
    void Function(String, String) addPlant,
  ) {
    if (node is Map) {
      for (final e in node.entries) {
        final k = e.key.toString();
        if (k.contains('Plant') && e.value is String) {
          addPlant(e.value as String, source);
        } else {
          _scanPlantFields(e.value, source, addPlant);
        }
      }
    } else if (node is List) {
      for (final e in node) {
        _scanPlantFields(e, source, addPlant);
      }
    }
  }

  List<PreviewItem> _collectWaveZombies({Set<String> excludeIds = const {}}) {
    final items = <PreviewItem>[];
    final seen = <String>{...excludeIds};
    final ids = ZombieDiscovery.discoverZombies(levelFile, parsed);

    final initial = <String>{};
    for (final obj in levelFile.objects) {
      if (obj.objClass != 'InitialZombieProperties') continue;
      final data = obj.objData;
      if (data is! Map) continue;
      final list = data['InitialZombiePlacements'] ?? data['Zombies'];
      if (list is! List) continue;
      for (final e in list) {
        if (e is Map) {
          final type = e['TypeName'] ?? e['ZombieType'];
          if (type is String) initial.add(_cleanId(type));
        }
      }
    }

    for (final id in ids) {
      final clean = _cleanId(id);
      if (clean.isEmpty || !seen.add(clean)) continue;
      final info = ZombieRepository().getZombieById(clean);
      final path = info?.iconAssetPath ?? 'assets/images/others/unknown.webp';
      final source = initial.contains(clean) ? initialZombiesLabel : wavesLabel;
      items.add(PreviewItem(id: clean, assetPath: path, sourceLabel: source));
    }
    return items;
  }

  List<PreviewItem> _collectGridItems() {
    final items = <PreviewItem>[];
    final seen = <String>{};

    void addItem({
      required String id,
      required String assetPath,
      String? source,
    }) {
      final clean = _cleanId(id);
      if (clean.isEmpty || !seen.add(clean)) return;
      items.add(
        PreviewItem(
          id: clean,
          assetPath: assetPath,
          sourceLabel: source ?? gridItemsSourceLabel,
        ),
      );
    }

    void addGridType(String raw) {
      final clean = _cleanId(raw);
      if (clean.isEmpty || clean == 'flowerpot') return;
      final id =
          GridItemRepository.displayTypeNameForLevel(clean, levelFile) ?? clean;
      if (id.isEmpty) return;
      addItem(id: id, assetPath: GridItemRepository.getIconPath(id));
    }

    // True InitialGridItemProperties placements.
    for (final obj in levelFile.objects) {
      if (obj.objClass != 'InitialGridItemProperties') continue;
      final data = obj.objData;
      if (data is! Map) continue;
      final list = data['InitialGridItemPlacements'] ?? data['GridItems'];
      if (list is! List) continue;
      for (final entry in list) {
        if (entry is! Map) continue;
        final raw =
            entry['TypeName'] ??
            entry['GridItemType'] ??
            entry['GridItemTypeName'] ??
            entry['ItemType'];
        if (raw is String && raw.isNotEmpty) addGridType(raw);
      }
    }

    // Renai day statues only (night spawns are wave-timed, not initial).
    final renai = readRenaiModuleData(levelFile);
    if (renai != null) {
      for (final s in renai.statueInfos) {
        if (s.typeName.isNotEmpty) addGridType(s.typeName);
      }
    }

    // Kongfu initial armrack / Taiji (energy grid) wave-1 presets.
    for (final item in initialArmrackItems(readArmrackModuleData(levelFile))) {
      if (item.type.isEmpty) continue;
      addItem(id: item.type, assetPath: armrackIconAsset(item.type));
    }
    if (initialEnergyGridItems(readEnergyGridModuleData(levelFile)).isNotEmpty) {
      addItem(
        id: 'energyGrid',
        assetPath: GridItemRepository.getIconPath('energyGrid'),
      );
    }

    return items;
  }

  String _combinedSources(List<PreviewItem> items) {
    final labels = <String>[];
    for (final i in items) {
      final s = i.sourceLabel;
      if (s == null || s.isEmpty) continue;
      if (!labels.contains(s)) labels.add(s);
    }
    return labels.join(' · ');
  }

  String _cleanId(String raw) {
    var s = raw.trim();
    if (s.startsWith('RTID(')) {
      s = LevelParser.extractAlias(s);
    }
    s = s.replaceAll(RegExp(r'^(Zombie|Plant)'), '');
    return s;
  }
}
