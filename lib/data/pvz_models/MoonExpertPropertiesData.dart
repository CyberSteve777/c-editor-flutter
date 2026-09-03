import 'package:c_editor/data/pvz_models/PvzModel.dart';

class MoonExpertPropertiesData extends PvzModel {
  MoonExpertPropertiesData({this.zombieLevel = 2});

  int zombieLevel;

  factory MoonExpertPropertiesData.fromJson(Map<String, dynamic> json) {
    final raw = json['ZombieLevel'];
    final parsed = raw is int
        ? raw
        : raw is num
        ? raw.toInt()
        : 2;
    return MoonExpertPropertiesData(zombieLevel: parsed.clamp(0, 10));
  }

  @override
  Map<String, dynamic> toJson() => {'ZombieLevel': zombieLevel};
}
