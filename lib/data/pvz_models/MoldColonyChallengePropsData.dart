// ignore_for_file: file_names

import 'package:c_editor/data/pvz_models/PvzModel.dart';

class MoldColonyChallengePropsData extends PvzModel {
  MoldColonyChallengePropsData({
    this.description = '',
    this.locations = 'RTID(Mold@CurrentLevel)',
  });

  String description;
  String locations;

  factory MoldColonyChallengePropsData.fromJson(Map<String, dynamic> json) {
    return MoldColonyChallengePropsData(
      description: json['Description'] as String? ?? '',
      locations: json['Locations'] as String? ?? 'RTID(Mold@CurrentLevel)',
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'Description': description,
    'Locations': locations,
  };
}
