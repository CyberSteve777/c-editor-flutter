import 'package:c_editor/data/pvz_models/PvzModel.dart';

class PickupCollectableTutorialData extends PvzModel {
  PickupCollectableTutorialData({
    this.dropperZombieType = 'mummy',
    this.lootType = 'GoldCoin',
    this.pickupAdvice = '',
    this.postPickupAdvice = '',
  });

  String dropperZombieType;
  String lootType;
  String pickupAdvice;
  String postPickupAdvice;

  factory PickupCollectableTutorialData.fromJson(Map<String, dynamic> json) {
    return PickupCollectableTutorialData(
      dropperZombieType: json['DropperZombieType'] as String? ?? 'mummy',
      lootType: json['LootType'] as String? ?? 'GoldCoin',
      pickupAdvice: json['PickupAdvice'] as String? ?? '',
      postPickupAdvice: json['PostPickupAdvice'] as String? ?? '',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'DropperZombieType': dropperZombieType,
    'LootType': lootType,
    'PickupAdvice': pickupAdvice,
    'PostPickupAdvice': postPickupAdvice,
  };
}
