import 'package:c_editor/data/pvz_models/PvzModel.dart';

class CamelMinigamePropertiesData extends PvzModel {
  CamelMinigamePropertiesData({
    this.additionalXBufferBetweenChains = 1.0,
    this.riseStaggerBetweenCamels = 0.5,
    this.cardMatchTime = 0.5,
    this.cardMatchingTime = 1.0,
    this.cardNoMatchTime = 1.0,
    List<int>? cardTypesUsed,
    this.tutorialZombieRiseDelay = 1.0,
    this.maxSpawnX = 8,
    this.minSpawnXStart = 0,
    this.minSpawnXEnd = 2,
    this.showTutorial = false,
  }) : cardTypesUsed = List<int>.from(cardTypesUsed ?? const [1, 2, 3]);

  double additionalXBufferBetweenChains;
  double riseStaggerBetweenCamels;
  double cardMatchTime;
  double cardMatchingTime;
  double cardNoMatchTime;
  List<int> cardTypesUsed;
  double tutorialZombieRiseDelay;
  double maxSpawnX;
  double minSpawnXStart;
  double minSpawnXEnd;
  bool showTutorial;

  factory CamelMinigamePropertiesData.fromJson(Map<String, dynamic> json) {
    final rawTypes = json['CardTypesUsed'];
    final types = <int>[];
    if (rawTypes is List) {
      for (final e in rawTypes) {
        if (e is num) types.add(e.toInt());
      }
    }
    return CamelMinigamePropertiesData(
      additionalXBufferBetweenChains:
          (json['AdditionalXBufferBetweenChains'] as num?)?.toDouble() ?? 1.0,
      riseStaggerBetweenCamels:
          (json['RiseStaggerBetweenCamels'] as num?)?.toDouble() ?? 0.5,
      cardMatchTime: (json['CardMatchTime'] as num?)?.toDouble() ?? 0.5,
      cardMatchingTime: (json['CardMatchingTime'] as num?)?.toDouble() ?? 1.0,
      cardNoMatchTime: (json['CardNoMatchTime'] as num?)?.toDouble() ?? 1.0,
      cardTypesUsed: types.isEmpty ? null : types,
      tutorialZombieRiseDelay:
          (json['TutorialZombieRiseDelay'] as num?)?.toDouble() ?? 1.0,
      maxSpawnX: (json['MaxSpawnX'] as num?)?.toDouble() ?? 8,
      minSpawnXStart: (json['MinSpawnXStart'] as num?)?.toDouble() ?? 0,
      minSpawnXEnd: (json['MinSpawnXEnd'] as num?)?.toDouble() ?? 2,
      showTutorial: json['ShowTutorial'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'AdditionalXBufferBetweenChains': additionalXBufferBetweenChains,
    'RiseStaggerBetweenCamels': riseStaggerBetweenCamels,
    'CardMatchTime': cardMatchTime,
    'CardMatchingTime': cardMatchingTime,
    'CardNoMatchTime': cardNoMatchTime,
    'CardTypesUsed': List<int>.from(cardTypesUsed),
    'TutorialZombieRiseDelay': tutorialZombieRiseDelay,
    'MaxSpawnX': maxSpawnX,
    'MinSpawnXStart': minSpawnXStart,
    'MinSpawnXEnd': minSpawnXEnd,
    if (showTutorial) 'ShowTutorial': true,
  };
}
