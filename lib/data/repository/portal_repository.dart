import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';

/// Portal world definition. Ported from Z-Editor-master PortalRepository.kt
class PortalWorldDef {
  const PortalWorldDef({
    required this.typeCode,
    required this.name,
    required this.representativeZombies,
    this.isCustom = false,
    this.customIndex,
  });

  final String typeCode;
  final String name;
  final List<String> representativeZombies;
  final bool isCustom;
  final int? customIndex;
}

class PortalTemplate {
  const PortalTemplate({
    required this.typeCode,
    required this.gridItemType,
    required this.properties,
  });

  final String typeCode;
  final PvzObject gridItemType;
  final PvzObject properties;
}

/// Portal repository. Ported from Z-Editor-master PortalRepository.kt
class PortalRepository {
  PortalRepository._();

  static final Map<String, PortalTemplate> _templates = {};
  static bool _isLoaded = false;

  static const List<String> worldCodes = [
    'egypt',
    'pirate',
    'west',
    'future',
    'dark',
    'beach',
    'iceage',
    'lostcity',
    'eighties',
    'dino',
    'kongfu',
    'steam',
    'renai',
    'heian',
    'twister',
  ];

  static const List<String> popAnimCodes = [
    'POPANIM_EFFECTS_MODERN_PORTAL',
    'POPANIM_EFFECTS_MODERN_PORTAL_PVZ1',
  ];

  static const List<String> spawnMethodCodes = [
    'NonRandomShuffled',
    'NonRandomInOrder',
  ];

  static Future<void> init() async {
    if (_isLoaded) return;
    try {
      final results = await Future.wait([
        rootBundle.loadString('assets/reference/GridItemTypes.json'),
        rootBundle.loadString('assets/reference/PropertySheets.json'),
      ]);
      final gridItems = _decodeObjects(results[0]);
      final propertySheets = _decodeObjects(results[1]);
      final propertiesByAlias = <String, PvzObject>{};
      for (final object in propertySheets) {
        if (object.objClass != 'GridItemZombiePortalProps') continue;
        for (final alias in object.aliases ?? const <String>[]) {
          propertiesByAlias.putIfAbsent(alias, () => object);
        }
      }

      _templates.clear();
      for (final object in gridItems) {
        final data = object.objData;
        if (object.objClass != 'GridItemType' || data is! Map) continue;
        if (data['GridItemClass'] != 'GridItemZombiePortal') continue;
        final alias = object.aliases?.firstOrNull;
        if (alias == null || !alias.startsWith('zombieportal_')) continue;
        final propertyInfo = RtidParser.parse(
          data['Properties']?.toString() ?? '',
        );
        final properties = propertyInfo == null
            ? null
            : propertiesByAlias[propertyInfo.alias];
        if (properties == null) continue;
        final typeCode = alias.substring('zombieportal_'.length);
        _templates.putIfAbsent(
          typeCode,
          () => PortalTemplate(
            typeCode: typeCode,
            gridItemType: object,
            properties: properties,
          ),
        );
      }
    } finally {
      _isLoaded = true;
    }
  }

  static PortalTemplate? templateForType(String typeCode) =>
      _templates[typeCode];

  static Map<String, dynamic> blankPropertiesData() => {
    'PopAnimRigClass': 'GridItemZombiePortal_AnimRig',
    'Hitpoints': 600,
    'Height': 'ground',
    'PopAnim': 'POPANIM_EFFECTS_MODERN_PORTAL',
    'PopAnimRenderOffset': {'x': 96, 'y': 125},
    'SpawnAnimation': 'spawn',
    'CloseAnimation': 'end',
    'CanBeMowed': false,
    'World': 'egypt',
    'ZombieTypesToSpawn': <Map<String, dynamic>>[],
    'ZombieSpawnMethod': 'NonRandomShuffled',
    'ZombieSpawnPointOffset': -20,
  };

  static Map<String, dynamic> clonePropertiesData(String? typeCode) {
    final raw = typeCode == null
        ? null
        : _templates[typeCode]?.properties.objData;
    if (raw is Map) return cloneMap(Map<String, dynamic>.from(raw));
    return blankPropertiesData();
  }

  static Map<String, dynamic> cloneMap(Map<String, dynamic> value) =>
      Map<String, dynamic>.from(jsonDecode(jsonEncode(value)) as Map);

  static List<PvzObject> _decodeObjects(String source) {
    final decoded = jsonDecode(source);
    final raw = decoded is Map ? decoded['objects'] : decoded;
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((item) => PvzObject.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static const List<PortalWorldDef> portalDefinitions = [
    PortalWorldDef(
      typeCode: 'egypt',
      name: 'Egypt',
      representativeZombies: ['ra', 'tomb_raiser', 'pharaoh'],
    ),
    PortalWorldDef(
      typeCode: 'egypt_2',
      name: 'Egypt 2',
      representativeZombies: ['explorer'],
    ),
    PortalWorldDef(
      typeCode: 'pirate',
      name: 'Pirate',
      representativeZombies: ['pirate_captain', 'seagull', 'barrelroller'],
    ),
    PortalWorldDef(
      typeCode: 'west',
      name: 'West',
      representativeZombies: ['piano', 'prospector', 'poncho_plate'],
    ),
    PortalWorldDef(
      typeCode: 'future',
      name: 'Future',
      representativeZombies: ['future_protector', 'mech_cone', 'football_mech'],
    ),
    PortalWorldDef(
      typeCode: 'future_2',
      name: 'Future 2',
      representativeZombies: ['future_jetpack', 'mech_cone', 'future_armor1'],
    ),
    PortalWorldDef(
      typeCode: 'dark',
      name: 'Dark',
      representativeZombies: ['dark_juggler'],
    ),
    PortalWorldDef(
      typeCode: 'beach',
      name: 'Beach',
      representativeZombies: ['beach_octopus', 'beach_surfer'],
    ),
    PortalWorldDef(
      typeCode: 'iceage',
      name: 'Ice Age',
      representativeZombies: ['iceage_hunter', 'iceage_weaselhoarder'],
    ),
    PortalWorldDef(
      typeCode: 'lostcity',
      name: 'Lost City',
      representativeZombies: ['lostcity_excavator', 'lostcity_jane'],
    ),
    PortalWorldDef(
      typeCode: 'eighties',
      name: 'Eighties',
      representativeZombies: ['eighties_breakdancer', 'eighties_mc'],
    ),
    PortalWorldDef(
      typeCode: 'dino',
      name: 'Dino',
      representativeZombies: ['dino_imp', 'dino_bully'],
    ),
    PortalWorldDef(
      typeCode: 'dangerroom_egypt',
      name: 'Endless Egypt',
      representativeZombies: ['ra', 'explorer', 'pharaoh'],
    ),
    PortalWorldDef(
      typeCode: 'dangerroom_pirate',
      name: 'Endless Pirate',
      representativeZombies: ['pirate_captain', 'seagull', 'barrelroller'],
    ),
    PortalWorldDef(
      typeCode: 'dangerroom_west',
      name: 'Endless West',
      representativeZombies: ['piano', 'chicken_farmer', 'poncho'],
    ),
    PortalWorldDef(
      typeCode: 'dangerroom_Kongfu',
      name: 'Endless Kongfu',
      representativeZombies: [
        'kongfu_basic',
        'kongfu_basic_armor1',
        'kongfu_basic_armor2',
        'kongfu_basic_armor3',
        'kongfu_gong',
        'kongfu_qigong',
        'kongfu_rocket',
      ],
    ),
    PortalWorldDef(
      typeCode: 'dangerroom_future',
      name: 'Endless Future',
      representativeZombies: [
        'future_jetpack',
        'future_protector',
        'mech_cone',
      ],
    ),
    PortalWorldDef(
      typeCode: 'dangerroom_dark',
      name: 'Endless Dark',
      representativeZombies: ['dark_armor3', 'dark_juggler', 'dark_wizard'],
    ),
    PortalWorldDef(
      typeCode: 'dangerroom_beach',
      name: 'Endless Beach',
      representativeZombies: ['beach_surfer', 'beach_snorkel', 'beach_octopus'],
    ),
    PortalWorldDef(
      typeCode: 'dangerroom_iceage',
      name: 'Endless Ice Age',
      representativeZombies: [
        'iceage_dodo',
        'iceage_weaselhoarder',
        'iceage_armor3',
      ],
    ),
    PortalWorldDef(
      typeCode: 'dangerroom_skycity',
      name: 'Endless Sky City',
      representativeZombies: [
        'skycity',
        'skycity_armor1',
        'skycity_armor2',
        'skycity_armor3',
        'skycity_ggtimp',
        'skycity_battleplane',
      ],
    ),
    PortalWorldDef(
      typeCode: 'dangerroom_lostcity',
      name: 'Endless Lost City',
      representativeZombies: [
        'lostcity_bug',
        'lostcity_excavator',
        'lostcity_crystalskull',
      ],
    ),
    PortalWorldDef(
      typeCode: 'dangerroom_eighties',
      name: 'Endless Eighties',
      representativeZombies: [
        'eighties_8bit_armor1',
        'eighties_8bit_armor2',
        'eighties_boombox',
      ],
    ),
    PortalWorldDef(
      typeCode: 'dangerroom_dino',
      name: 'Endless Dino',
      representativeZombies: ['dino_bully', 'dino_imp', 'dino_armor3'],
    ),
    PortalWorldDef(
      typeCode: 'dangerroom_modern',
      name: 'Endless Modern',
      representativeZombies: [
        'modern_superfanimp',
        'beghouled_newspaper',
        'modern_newspaper',
        'newspaper_veteran',
        'explosion_proof',
      ],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_A',
      name: 'Memory Lane 1',
      representativeZombies: ['ra', 'pirate_captain'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_B',
      name: 'Memory Lane 2',
      representativeZombies: ['lostcity_jane'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_C',
      name: 'Memory Lane 3',
      representativeZombies: ['modern_allstar', 'newspaper_veteran'],
    ),
    PortalWorldDef(
      typeCode: 'protector',
      name: 'Shield Generator',
      representativeZombies: ['wave_elecshieldgenerator'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_Zombotany',
      name: 'Zombotany',
      representativeZombies: [
        'zombie_snowpea',
        'zombie_gatlingpea',
        'zombie_explodenut',
        'zombie_jalapeno',
      ],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_Slime',
      name: 'Slime zombies',
      representativeZombies: ['slimes'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_tutorial2',
      name: 'Glacial nian skill',
      representativeZombies: ['lny_armor2', 'zombie_moneytree'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_Universe',
      name: 'Universe 42',
      representativeZombies: [
        'universe_uncharted_lostcity_jane',
        'universe_uncharted_allstar',
        'universe_uncharted_lostcity_excavator',
        'universe_uncharted_prospector',
      ],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_Uncharted',
      name: 'Universe 41',
      representativeZombies: [
        'uncharted_qigong',
        'uncharted_crystalskull',
        'uncharted_miner',
        'uncharted_gentleman',
      ],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_elite_roman_healer_normal',
      name: 'Elite healer normal',
      representativeZombies: ['elite_roman_healer_pvz1_normal'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_elite_skycity_electric_normal',
      name: 'Elite electric normal',
      representativeZombies: ['elite_skycity_electric_pvz1_normal'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_elite_roman_ballista_normal',
      name: 'Elite ballista normal',
      representativeZombies: ['elite_roman_ballista_pvz1_normal'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_elite_heian_onmyoji_normal',
      name: 'Elite onmyoji normal',
      representativeZombies: ['elite_heian_onmyoji_pvz1_normal'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_elite_roman_healer_hard',
      name: 'Elite healer hard',
      representativeZombies: ['elite_roman_healer_pvz1_hard'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_elite_skycity_electric_hard',
      name: 'Elite electric hard',
      representativeZombies: ['elite_skycity_electric_pvz1_hard'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_elite_roman_ballista_hard',
      name: 'Elite ballista hard',
      representativeZombies: ['elite_roman_ballista_pvz1_hard'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_elite_heian_onmyoji_hard',
      name: 'Elite onmyoji hard',
      representativeZombies: ['elite_heian_onmyoji_pvz1_hard'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_renai_romeo_hard',
      name: 'Romeo hard',
      representativeZombies: ['renai_romeo_memo'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_renai_romeo2_hard',
      name: 'Romeo hard 2',
      representativeZombies: ['renai_romeo_memo1'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_renai_juliet_hard',
      name: 'Juliet hard',
      representativeZombies: ['renai_juliet_memo'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_renai_juliet2_hard',
      name: 'Juliet hard 2',
      representativeZombies: ['renai_juliet_memo1'],
    ),
    PortalWorldDef(
      typeCode: 'pvz1_renai_sherlock_hard',
      name: 'Sherlock hard',
      representativeZombies: ['renai_sherlock_memo'],
    ),
    PortalWorldDef(
      typeCode: 'plantwars_iceage_hunter_elite',
      name: 'Elite hunter',
      representativeZombies: ['plantwars_iceage_hunter_elite'],
    ),
    PortalWorldDef(
      typeCode: 'plantwars_iceage_chief_elite',
      name: 'Elite chief',
      representativeZombies: ['plantwars_iceage_chief_elite'],
    ),
    PortalWorldDef(
      typeCode: 'plantwars_iceage_weaselhoarder_elite',
      name: 'Elite weasel',
      representativeZombies: ['plantwars_iceage_weaselhoarder_elite'],
    ),
    PortalWorldDef(
      typeCode: 'plantwars_bumpercar_elite',
      name: 'Elite bumper car',
      representativeZombies: ['plantwars_bumpercar_elite'],
    ),
    PortalWorldDef(
      typeCode: 'plantwars_IceYearMonster',
      name: 'Glacial nian',
      representativeZombies: ['plantwars_IceYearMonster'],
    ),
    PortalWorldDef(
      typeCode: 'dark_wizard_elite',
      name: 'Elite wizard',
      representativeZombies: ['dark_wizard_elite'],
    ),
    PortalWorldDef(
      typeCode: 'dark_king_elite',
      name: 'Elite king',
      representativeZombies: ['dark_king_elite'],
    ),
    PortalWorldDef(
      typeCode: 'plantwars_mirror_queen_phase3',
      name: 'Elite mirror queen',
      representativeZombies: ['plantwars_mirror_queen_phase3'],
    ),
  ];
}
