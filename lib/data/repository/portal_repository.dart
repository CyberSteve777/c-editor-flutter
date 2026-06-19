/// Portal world definition. Ported from Z-Editor-master PortalRepository.kt
class PortalWorldDef {
  const PortalWorldDef({
    required this.typeCode,
    required this.name,
    required this.representativeZombies,
  });

  final String typeCode;
  final String name;
  final List<String> representativeZombies;
}

/// Portal repository. Ported from Z-Editor-master PortalRepository.kt
class PortalRepository {
  PortalRepository._();

  static const List<PortalWorldDef> portalDefinitions = [
    PortalWorldDef(typeCode: 'egypt', name: 'Egypt', representativeZombies: ['ra', 'tomb_raiser', 'pharaoh']),
    PortalWorldDef(typeCode: 'egypt_2', name: 'Egypt 2', representativeZombies: ['explorer']),
    PortalWorldDef(typeCode: 'pirate', name: 'Pirate', representativeZombies: ['pirate_captain', 'seagull', 'barrelroller']),
    PortalWorldDef(typeCode: 'west', name: 'West', representativeZombies: ['piano', 'prospector', 'poncho_plate']),
    PortalWorldDef(typeCode: 'future', name: 'Future', representativeZombies: ['future_protector', 'mech_cone', 'football_mech']),
    PortalWorldDef(typeCode: 'future_2', name: 'Future 2', representativeZombies: ['future_jetpack', 'mech_cone', 'future_armor1']),
    PortalWorldDef(typeCode: 'dark', name: 'Dark', representativeZombies: ['dark_juggler']),
    PortalWorldDef(typeCode: 'beach', name: 'Beach', representativeZombies: ['beach_octopus', 'beach_surfer']),
    PortalWorldDef(typeCode: 'iceage', name: 'Ice Age', representativeZombies: ['iceage_hunter', 'iceage_weaselhoarder']),
    PortalWorldDef(typeCode: 'lostcity', name: 'Lost City', representativeZombies: ['lostcity_excavator', 'lostcity_jane']),
    PortalWorldDef(typeCode: 'eighties', name: 'Eighties', representativeZombies: ['eighties_breakdancer', 'eighties_mc']),
    PortalWorldDef(typeCode: 'dino', name: 'Dino', representativeZombies: ['dino_imp', 'dino_bully']),
    PortalWorldDef(typeCode: 'dangerroom_egypt', name: 'Endless Egypt', representativeZombies: ['ra', 'explorer', 'pharaoh']),
    PortalWorldDef(typeCode: 'dangerroom_pirate', name: 'Endless Pirate', representativeZombies: ['pirate_captain', 'seagull', 'barrelroller']),
    PortalWorldDef(typeCode: 'dangerroom_west', name: 'Endless West', representativeZombies: ['piano', 'chicken_farmer', 'poncho']),
    PortalWorldDef(typeCode: 'dangerroom_Kongfu', name: 'Endless Kongfu', representativeZombies: ['kongfu_basic', 'kongfu_basic_armor1', 'kongfu_basic_armor2', 'kongfu_basic_armor3', 'kongfu_gong', 'kongfu_qigong', 'kongfu_rocket']),
    PortalWorldDef(typeCode: 'dangerroom_future', name: 'Endless Future', representativeZombies: ['future_jetpack', 'future_protector', 'mech_cone']),
    PortalWorldDef(typeCode: 'dangerroom_dark', name: 'Endless Dark', representativeZombies: ['dark_armor3', 'dark_juggler', 'dark_wizard']),
    PortalWorldDef(typeCode: 'dangerroom_beach', name: 'Endless Beach', representativeZombies: ['beach_surfer', 'beach_snorkel', 'beach_octopus']),
    PortalWorldDef(typeCode: 'dangerroom_iceage', name: 'Endless Ice Age', representativeZombies: ['iceage_dodo', 'iceage_weaselhoarder', 'iceage_armor3']),
    PortalWorldDef(typeCode: 'dangerroom_skycity', name: 'Endless Sky City', representativeZombies: ['skycity', 'skycity_armor1', 'skycity_armor2', 'skycity_armor3', 'skycity_ggtimp', 'skycity_battleplane']),
    PortalWorldDef(typeCode: 'dangerroom_lostcity', name: 'Endless Lost City', representativeZombies: ['lostcity_bug', 'lostcity_excavator', 'lostcity_crystalskull']),
    PortalWorldDef(typeCode: 'dangerroom_eighties', name: 'Endless Eighties', representativeZombies: ['eighties_8bit_armor1', 'eighties_8bit_armor2', 'eighties_boombox']),
    PortalWorldDef(typeCode: 'dangerroom_dino', name: 'Endless Dino', representativeZombies: ['dino_bully', 'dino_imp', 'dino_armor3']),
    PortalWorldDef(typeCode: 'dangerroom_modern', name: 'Endless Modern', representativeZombies: ['modern_superfanimp', 'beghouled_newspaper', 'modern_newspaper', 'newspaper_veteran', 'explosion_proof']),
    PortalWorldDef(typeCode: 'pvz1_A', name: 'Memory Lane 1', representativeZombies: ['ra', 'pirate_captain']),
    PortalWorldDef(typeCode: 'pvz1_B', name: 'Memory Lane 2', representativeZombies: ['lostcity_jane']),
    PortalWorldDef(typeCode: 'pvz1_C', name: 'Memory Lane 3', representativeZombies: ['modern_allstar', 'newspaper_veteran']),
    PortalWorldDef(typeCode: 'protector', name: 'Shield Generator', representativeZombies: ['wave_elecshieldgenerator']),
    PortalWorldDef(typeCode: 'pvz1_Zombotany', name: 'Zombotany', representativeZombies: ['zombie_snowpea', 'zombie_gatlingpea', 'zombie_explodenut', 'zombie_jalapeno']),
    PortalWorldDef(typeCode: 'pvz1_Slime', name: 'Slime zombies', representativeZombies: ['slimes']),
    PortalWorldDef(typeCode: 'pvz1_tutorial2', name: 'Glacial nian skill', representativeZombies: ['lny_armor2', 'zombie_moneytree']),
    PortalWorldDef(typeCode: 'pvz1_Universe', name: 'Universe 42', representativeZombies: ['universe_uncharted_lostcity_jane', 'universe_uncharted_allstar', 'universe_uncharted_lostcity_excavator', 'universe_uncharted_prospector']),
    PortalWorldDef(typeCode: 'pvz1_Uncharted', name: 'Universe 41', representativeZombies: ['uncharted_qigong', 'uncharted_crystalskull', 'uncharted_miner', 'uncharted_gentleman']),
    PortalWorldDef(typeCode: 'pvz1_elite_roman_healer_normal', name: 'Elite healer normal', representativeZombies: ['elite_roman_healer_pvz1_normal']),
    PortalWorldDef(typeCode: 'pvz1_elite_skycity_electric_normal', name: 'Elite electric normal', representativeZombies: ['elite_skycity_electric_pvz1_normal']),
    PortalWorldDef(typeCode: 'pvz1_elite_roman_ballista_normal', name: 'Elite ballista normal', representativeZombies: ['elite_roman_ballista_pvz1_normal']),
    PortalWorldDef(typeCode: 'pvz1_elite_heian_onmyoji_normal', name: 'Elite onmyoji normal', representativeZombies: ['elite_heian_onmyoji_pvz1_normal']),
    PortalWorldDef(typeCode: 'pvz1_elite_roman_healer_hard', name: 'Elite healer hard', representativeZombies: ['elite_roman_healer_pvz1_hard']),
    PortalWorldDef(typeCode: 'pvz1_elite_skycity_electric_hard', name: 'Elite electric hard', representativeZombies: ['elite_skycity_electric_pvz1_hard']),
    PortalWorldDef(typeCode: 'pvz1_elite_roman_ballista_hard', name: 'Elite ballista hard', representativeZombies: ['elite_roman_ballista_pvz1_hard']),
    PortalWorldDef(typeCode: 'pvz1_elite_heian_onmyoji_hard', name: 'Elite onmyoji hard', representativeZombies: ['elite_heian_onmyoji_pvz1_hard']),
    PortalWorldDef(typeCode: 'pvz1_renai_romeo_hard', name: 'Romeo hard', representativeZombies: ['renai_romeo_memo']),
    PortalWorldDef(typeCode: 'pvz1_renai_romeo2_hard', name: 'Romeo hard 2', representativeZombies: ['renai_romeo_memo1']),
    PortalWorldDef(typeCode: 'pvz1_renai_juliet_hard', name: 'Juliet hard', representativeZombies: ['renai_juliet_memo']),
    PortalWorldDef(typeCode: 'pvz1_renai_juliet2_hard', name: 'Juliet hard 2', representativeZombies: ['renai_juliet_memo1']),
    PortalWorldDef(typeCode: 'pvz1_renai_sherlock_hard', name: 'Sherlock hard', representativeZombies: ['renai_sherlock_memo']),
    PortalWorldDef(typeCode: 'plantwars_iceage_hunter_elite', name: 'Elite hunter', representativeZombies: ['plantwars_iceage_hunter_elite']),
    PortalWorldDef(typeCode: 'plantwars_iceage_chief_elite', name: 'Elite chief', representativeZombies: ['plantwars_iceage_chief_elite']),
    PortalWorldDef(typeCode: 'plantwars_iceage_weaselhoarder_elite', name: 'Elite weasel', representativeZombies: ['plantwars_iceage_weaselhoarder_elite']),
    PortalWorldDef(typeCode: 'plantwars_bumpercar_elite', name: 'Elite bumper car', representativeZombies: ['plantwars_bumpercar_elite']),
    PortalWorldDef(typeCode: 'plantwars_IceYearMonster', name: 'Glacial nian', representativeZombies: ['plantwars_IceYearMonster']),
    PortalWorldDef(typeCode: 'dark_wizard_elite', name: 'Elite wizard', representativeZombies: ['dark_wizard_elite']),
    PortalWorldDef(typeCode: 'dark_king_elite', name: 'Elite king', representativeZombies: ['dark_king_elite']),
    PortalWorldDef(typeCode: 'plantwars_mirror_queen_phase3', name: 'Elite mirror queen', representativeZombies: ['plantwars_mirror_queen_phase3']),
  ];
}
