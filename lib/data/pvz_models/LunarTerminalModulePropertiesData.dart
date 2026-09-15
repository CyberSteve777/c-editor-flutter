import 'package:c_editor/data/pvz_models/PvzModel.dart';

class LunarTerminalModulePropertiesData extends PvzModel {
  LunarTerminalModulePropertiesData({this.collectorCooldown = 20.0});

  double collectorCooldown;

  factory LunarTerminalModulePropertiesData.fromJson(
    Map<String, dynamic> json,
  ) {
    return LunarTerminalModulePropertiesData(
      collectorCooldown:
          (json['CollectorCooldown'] as num?)?.toDouble() ?? 20.0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {'CollectorCooldown': collectorCooldown};
}
