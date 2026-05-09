import 'package:z_editor/data/pvz_models/PvzModel.dart';

import 'package:z_editor/data/pvz_models/MinMaxRange.dart';

class DropShipAppearWaveData extends PvzModel {
  DropShipAppearWaveData({
    this.wave = 0,
    this.imp = 0,
    this.impLv = 1,
    MinMaxRange? rowRange,
    MinMaxRange? colRange,
  }) : rowRange = rowRange ?? MinMaxRange(),
       colRange = colRange ?? MinMaxRange();

  /// 0-based wave index.
  int wave;

  /// Extra imp count (at least one imp is always dropped).
  int imp;
  int impLv;
  MinMaxRange rowRange;
  MinMaxRange colRange;

  factory DropShipAppearWaveData.fromJson(Map<String, dynamic> json) {
    final row = json['RowRange'] as Map<String, dynamic>?;
    final col = json['ColRange'] as Map<String, dynamic>?;
    final rawWave = (json['Wave'] as num?)?.toInt() ?? 0;
    return DropShipAppearWaveData(
      wave: rawWave < 0 ? 0 : rawWave,
      imp: (json['Imp'] as num?)?.toInt() ?? 0,
      impLv: (json['ImpLv'] as num?)?.toInt() ?? 1,
      rowRange: row != null ? MinMaxRange.fromJson(row) : MinMaxRange(),
      colRange: col != null ? MinMaxRange.fromJson(col) : MinMaxRange(),
    );
  }

  Map<String, dynamic> toJson() => {
    'Wave': wave,
    'Imp': imp,
    'ImpLv': impLv,
    'RowRange': rowRange.toJson(),
    'ColRange': colRange.toJson(),
  };
}

