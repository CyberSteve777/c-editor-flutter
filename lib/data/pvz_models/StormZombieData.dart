import 'package:c_editor/data/pvz_models/PvzModel.dart';

class StormZombieData extends PvzModel {
  StormZombieData({this.type = '', this.level = 0});

  String type;

  /// The editor does not expose this value; newly added entries use level 0.
  /// Existing values can still be edited manually in JSON.
  int? level;

  factory StormZombieData.fromJson(Map<String, dynamic> json) {
    return StormZombieData(
      type: json['Type'] as String? ?? '',
      level: json['Level'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {'Type': type, 'Level': level ?? 0};
}
