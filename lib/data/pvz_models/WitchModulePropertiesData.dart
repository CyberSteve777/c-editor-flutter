import 'package:z_editor/data/pvz_models/PvzModel.dart';

class WitchModulePropertiesData extends PvzModel {
  WitchModulePropertiesData({this.witchSpawnInterval = 20.0});

  double witchSpawnInterval;

  factory WitchModulePropertiesData.fromJson(Map<String, dynamic> json) {
    return WitchModulePropertiesData(
      witchSpawnInterval:
          (json['WitchSpawnInterval'] as num?)?.toDouble() ?? 20.0,
    );
  }

  Map<String, dynamic> toJson() => {
    'WitchSpawnInterval': witchSpawnInterval,
  };
}
