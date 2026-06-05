import 'package:c_editor/data/pvz_models/PvzModel.dart';

class EnergyGridOverrideItemData extends PvzModel {
  EnergyGridOverrideItemData({
    this.mX = 0,
    this.mY = 0,
  });

  int mX;
  int mY;

  factory EnergyGridOverrideItemData.fromJson(Map<String, dynamic> json) {
    return EnergyGridOverrideItemData(
      mX: (json['mX'] as num?)?.toInt() ?? 0,
      mY: (json['mY'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
    'mX': mX,
    'mY': mY,
  };
}
