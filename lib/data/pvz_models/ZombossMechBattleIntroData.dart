import 'package:z_editor/data/pvz_models/PvzModel.dart';

class ZombossMechBattleIntroData extends PvzModel {
  ZombossMechBattleIntroData({
    this.panStartOffset = 78,
    this.panEndOffset = 486,
    this.panRightDuration = 1.5,
    this.panLeftDuration = 1.5,
    this.zombossPhaseCount = 3,
    this.skipShowingStreetBossBattle = false,
  });

  int panStartOffset;
  int panEndOffset;
  double panRightDuration;
  double panLeftDuration;
  int zombossPhaseCount;
  bool skipShowingStreetBossBattle;

  factory ZombossMechBattleIntroData.fromJson(Map<String, dynamic> json) {
    return ZombossMechBattleIntroData(
      panStartOffset: json['PanStartOffset'] as int? ?? 78,
      panEndOffset: json['PanEndOffset'] as int? ?? 486,
      panRightDuration: (json['PanRightDuration'] as num?)?.toDouble() ?? 1.5,
      panLeftDuration: (json['PanLeftDuration'] as num?)?.toDouble() ?? 1.5,
      zombossPhaseCount: json['ZombossPhaseCount'] as int? ?? 3,
      skipShowingStreetBossBattle:
          json['SkipShowingStreetBossBattle'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'PanStartOffset': panStartOffset,
    'PanEndOffset': panEndOffset,
    'PanRightDuration': panRightDuration,
    'PanLeftDuration': panLeftDuration,
    'ZombossPhaseCount': zombossPhaseCount,
    'SkipShowingStreetBossBattle': skipShowingStreetBossBattle,
  };
}
