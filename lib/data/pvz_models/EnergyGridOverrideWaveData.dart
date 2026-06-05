import 'package:c_editor/data/pvz_models/PvzModel.dart';

import 'package:c_editor/data/pvz_models/EnergyGridOverrideItemData.dart';

class EnergyGridOverrideWaveData extends PvzModel {
  EnergyGridOverrideWaveData({
    this.wave = 1,
    List<EnergyGridOverrideItemData>? itemList,
  }) : itemList = itemList ?? [];

  int wave;
  List<EnergyGridOverrideItemData> itemList;

  factory EnergyGridOverrideWaveData.fromJson(Map<String, dynamic> json) {
    final list = json['itemList'] as List<dynamic>?;
    return EnergyGridOverrideWaveData(
      wave: (json['wave'] as num?)?.toInt() ?? 1,
      itemList:
          list
              ?.map(
                (e) => EnergyGridOverrideItemData.fromJson(
                  e as Map<String, dynamic>,
                ),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'wave': wave,
    'itemList': itemList.map((e) => e.toJson()).toList(),
  };
}
