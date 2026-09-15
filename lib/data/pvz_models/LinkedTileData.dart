import 'package:c_editor/data/pvz_models/PvzModel.dart';

import 'package:c_editor/data/pvz_models/TileLocationData.dart';

class LinkedTileData extends PvzModel {
  LinkedTileData({
    this.group = 'alpha',
    this.propagationDelay = 1.5,
    TileLocationData? location,
  }) : location = location ?? TileLocationData();

  String group;
  double propagationDelay;
  TileLocationData location;

  factory LinkedTileData.fromJson(Map<String, dynamic> json) {
    return LinkedTileData(
      group: json['Group'] as String? ?? 'alpha',
      propagationDelay: (json['PropagationDelay'] as num?)?.toDouble() ?? 1.5,
      location: TileLocationData.fromJson(
        json['Location'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'Group': group,
    'PropagationDelay': propagationDelay,
    'Location': location.toJson(),
  };
}
