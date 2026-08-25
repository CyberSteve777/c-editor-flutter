import 'package:c_editor/data/pvz_models/PvzModel.dart';

class CowboyMinigamePropertiesData extends PvzModel {
  CowboyMinigamePropertiesData({
    this.beginString = defaultBeginString,
    this.showTutorial = false,
  });

  static const String defaultBeginString = '[COWBOY_MINIGAME_TUTORIAL_1]';

  String beginString;
  bool showTutorial;

  factory CowboyMinigamePropertiesData.fromJson(Map<String, dynamic> json) {
    return CowboyMinigamePropertiesData(
      beginString: json['BeginString'] as String? ?? defaultBeginString,
      showTutorial: json['ShowTutorial'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'BeginString': beginString,
    if (showTutorial) 'ShowTutorial': true,
  };
}
