import 'package:c_editor/data/tag_assets.dart';

/// Zombie condition ids for [ApplyZombieConditionsChallengeProps].
abstract class ZombieConditions {
  ZombieConditions._();

  /// Default suggestions (not exhaustive); full list is [allIds].
  static const commonNegativeIds = [
    'chill',
    'freeze',
    'stun',
    'dazeystunned',
    'butter',
    'hypnotized',
    'stalled',
    'shrunken',
    'poisoned',
    'chemist_poison',
    'shadowpoisoned',
    'contagiouspoison',
    'sapped',
    'slowdown',
    'tossed',
  ];

  /// All known conditions (id → default Chinese label from game reference).
  static const Map<String, String> defaultLabelsZh = {
    'chill': '冰减速',
    'freeze': '冰冻',
    'stun': '眩晕',
    'butter': '黄油',
    'butter9': '毛茛5阶黄油',
    'numb': '坚果电卫星的麻痹',
    'stucked': '通用麻痹',
    'bleeding': '临界值垂死状态',
    'lightning': '电流环绕(动画效果)',
    'rush': '冲刺',
    'speedup1': '1.25倍加速',
    'speedup2': '1.5倍加速',
    'speedup3': '2倍加速',
    'speedup4': '2.5倍加速',
    'tossed': '僵尸位移空中状态(小鬼和部分僵尸有动画表现)',
    'potionspeed1': '橙色药水加速1.5倍',
    'potionspeed2': '橙色药水加速2倍',
    'potionspeed3': '橙色药水加速2.5倍',
    'potiontoughness1': '粉色药水15%减伤抗性',
    'potiontoughness2': '粉色药水30%减伤抗性',
    'potiontoughness3': '粉色药水45%减伤抗性',
    'potioninvisible': '药水隐身/盗贼隐身',
    'potionpoison': '药水上毒',
    'potionsuper1': '跑步机强化心脏(能量大脑)15%减伤抗性和1.5倍移速',
    'potionsuper2': '跑步机强化心脏(能量大脑)30%减伤抗性和2倍移速',
    'potionsuper3': '跑步机强化心脏(能量大脑)45%减伤抗性和2.5倍移速',
    'buffattack': '僵博瓷砖1.5倍攻击加成',
    'buffspeed': '僵博瓷砖2倍加速',
    'fogshieldlvl1': '童话森林25%减伤白雾',
    'fogshieldlvl2': '童话森林50%减伤蓝雾',
    'fogshieldlvl3': '童话森林75%减伤紫雾',
    'hypnotized': '魅惑(动画效果)',
    'sunbeaned': '阳光豆阳光环绕(动画效果)',
    'morphedtogargantuar': '巨大化(动画效果)',
    'damageflash': '僵尸受击闪亮(动画效果)',
    'zombossstun': '僵王眩晕',
    'haunted': '幽灵辣椒鬼魂缠绕特效(动画效果)',
    'icecubed': '冰块冻住',
    'present_boxed': '礼盒打包',
    'sapped': '树脂减速',
    'unsuspendable': '未知',
    'stalled': '大丽菊减速',
    'slowdown': '橄榄坑的油减速',
    'invincible': '大姐无敌',
    'warpingIn': '逆时草传送中特效(动画效果)',
    'warpingOut': '逆时草传送完毕特效(动画效果)',
    'poisoned': '毒影菇中毒',
    'shadowpoisoned': '暗影状态下中毒',
    'chemist_poison': '药师中毒',
    'contagiouspoison': '传染毒',
    'chemist_contagiouspoison': '药师传染毒',
    'lotus_poison': '莲藕废水中毒',
    'venom': '药师遗留毒液中毒',
    'eagleclawLock': '鹰爪花电球锁定',
    'shrinking': '紫罗兰缩小中',
    'shrunken': '紫罗兰缩小完毕',
    'onfire': '灼烧',
    'bloomingheartdebuff': '铃儿草爱心特效',
    'ghostlantern': '杰克南瓜灯5阶幽灵附身',
    'negative': '闪电枪神器负电荷',
    'positive': '闪电枪神器正电荷',
    'dripwater': '水枪神器润湿',
    'water': '海豌豆buff',
    'hasplantfood': '携带能量豆',
    'gummed': '桉果黏住',
    'stackableslow': '持续减速',
    'cardgame_shield': '精英治愈者无敌护盾/牌面纷争无敌护盾',
    'icebound': '白毛丹冰砖状态',
    'dazeystunned': '眩晕',
  };

  static List<String> get allIds => defaultLabelsZh.keys.toList()..sort();

  static String resourceKey(String id) => 'zombieCondition_$id';
}

/// Plant profession ids for [StarChallengeDisablePlantProps].
abstract class StarChallengeProfessions {
  StarChallengeProfessions._();

  static const ids = [
    'warrior',
    'shooter',
    'specialist',
    'supporter',
    'protector',
    'sunmaker',
  ];

  static String iconAsset(String id) =>
      TagAssets.plantRole('Plant_${_iconSuffix[id] ?? id}.webp');

  static const _iconSuffix = {
    'warrior': 'Vanguard',
    'shooter': 'Remote',
    'specialist': 'Trapper',
    'supporter': 'Assist',
    'protector': 'Defence',
    'sunmaker': 'Productor',
  };

  static String resourceKey(String id) => 'starChallengeProfession_$id';
}
