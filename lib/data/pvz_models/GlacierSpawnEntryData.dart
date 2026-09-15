import 'package:c_editor/data/pvz_models/PvzModel.dart';

/// One weighted zombie entry inside a glacier column (`Entries` item).
class GlacierSpawnEntryData extends PvzModel {
  GlacierSpawnEntryData({this.typeName = '', this.weight = 1, this.level = 0});

  String typeName;
  num weight;
  int level;

  factory GlacierSpawnEntryData.fromJson(Map<String, dynamic> json) {
    return GlacierSpawnEntryData(
      typeName: json['TypeName'] as String? ?? '',
      weight: json['Weight'] as num? ?? 1,
      level: json['Level'] as int? ?? 0,
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'TypeName': typeName,
    'Weight': weight,
    'Level': level,
  };
}
