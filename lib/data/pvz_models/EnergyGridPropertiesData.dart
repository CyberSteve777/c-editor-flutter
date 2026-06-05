import 'package:c_editor/data/pvz_models/PvzModel.dart';

import 'package:c_editor/data/pvz_models/EnergyGridOverrideWaveData.dart';

class EnergyGridPropertiesData extends PvzModel {
  EnergyGridPropertiesData({List<EnergyGridOverrideWaveData>? overrides})
    : overrides = overrides ?? [];

  List<EnergyGridOverrideWaveData> overrides;

  factory EnergyGridPropertiesData.fromJson(Map<String, dynamic> json) {
    final list = json['Overrides'] as List<dynamic>?;
    return EnergyGridPropertiesData(
      overrides:
          list
              ?.map(
                (e) => EnergyGridOverrideWaveData.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'Overrides': overrides.map((e) => e.toJson()).toList(),
  };
}
