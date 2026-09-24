import 'package:c_editor/data/pvz_models/PvzModel.dart';

class OakTrainPropertiesData extends PvzModel {
  OakTrainPropertiesData({
    this.totalLife = 100,
    this.arrowScore = 10,
    this.wizardScore = 50,
    this.archmageScore = 100,
    this.bossScore = 200,
    this.healNum = 20,
    this.arrowPowerNum = 1,
    this.arrowMultipleNum = 1,
    List<int>? initArrowsNum,
  }) : initArrowsNum = List<int>.from(
         initArrowsNum ?? const [10, 0, 0, 0],
       );

  int totalLife;
  int arrowScore;
  int wizardScore;
  int archmageScore;
  int bossScore;
  int healNum;
  int arrowPowerNum;
  int arrowMultipleNum;

  /// [Normal, Power, Split, Unused]
  List<int> initArrowsNum;

  int get initArrowNormal => _slot(0);
  set initArrowNormal(int v) => _setSlot(0, v);

  int get initArrowPower => _slot(1);
  set initArrowPower(int v) => _setSlot(1, v);

  int get initArrowSplit => _slot(2);
  set initArrowSplit(int v) => _setSlot(2, v);

  int get initArrowUnused => _slot(3);
  set initArrowUnused(int v) => _setSlot(3, v);

  int _slot(int i) {
    while (initArrowsNum.length <= i) {
      initArrowsNum.add(0);
    }
    return initArrowsNum[i];
  }

  void _setSlot(int i, int v) {
    while (initArrowsNum.length <= i) {
      initArrowsNum.add(0);
    }
    initArrowsNum[i] = v;
  }

  factory OakTrainPropertiesData.fromJson(Map<String, dynamic> json) {
    final raw = json['InitArrowsNum'];
    final arrows = <int>[];
    if (raw is List) {
      for (final e in raw) {
        if (e is num) arrows.add(e.toInt());
      }
    }
    while (arrows.length < 4) {
      arrows.add(0);
    }
    return OakTrainPropertiesData(
      totalLife: (json['TotalLife'] as num?)?.toInt() ?? 100,
      arrowScore: (json['ArrowScore'] as num?)?.toInt() ?? 10,
      wizardScore: (json['WizardScore'] as num?)?.toInt() ?? 50,
      archmageScore: (json['ArchmageScore'] as num?)?.toInt() ?? 100,
      bossScore: (json['BossScore'] as num?)?.toInt() ?? 200,
      healNum: (json['HealNum'] as num?)?.toInt() ?? 20,
      arrowPowerNum: (json['ArrowPowerNum'] as num?)?.toInt() ?? 1,
      arrowMultipleNum: (json['ArrowMultipleNum'] as num?)?.toInt() ?? 1,
      initArrowsNum: arrows.take(4).toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'TotalLife': totalLife,
    'ArrowScore': arrowScore,
    'WizardScore': wizardScore,
    'ArchmageScore': archmageScore,
    'BossScore': bossScore,
    'HealNum': healNum,
    'ArrowPowerNum': arrowPowerNum,
    'ArrowMultipleNum': arrowMultipleNum,
    'InitArrowsNum': List<int>.from(initArrowsNum.take(4)),
  };
}
