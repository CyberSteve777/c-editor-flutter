import 'package:c_editor/data/pvz_models/PvzModel.dart';

import 'package:c_editor/data/pvz_models/TunnelRoadData.dart';

class TunnelDefendModuleData extends PvzModel {
  TunnelDefendModuleData({
    List<TunnelRoadData>? roads,
    this.brickMapIndex = 1,
    this.tunnelSequenceInterval = 0.4,
    this.reportError = true,
  }) : roads = roads ?? [];

  List<TunnelRoadData> roads;

  /// Tile style preset in game (`BrickMapIndex`): 1, 2, or SouDaChe's 3.
  int brickMapIndex;

  double tunnelSequenceInterval;

  bool reportError;

  factory TunnelDefendModuleData.fromJson(
    Map<String, dynamic> json, {
    bool defaultReportError = true,
  }) {
    final raw = (json['BrickMapIndex'] as num?)?.toInt() ?? 1;
    return TunnelDefendModuleData(
      roads:
          (json['Roads'] as List<dynamic>?)
              ?.map((e) => TunnelRoadData.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      brickMapIndex: raw == 2 || raw == 3 ? raw : 1,
      tunnelSequenceInterval:
          (json['TunnelSequenceInterval'] as num?)?.toDouble() ?? 0.4,
      reportError: json['reportError'] is bool
          ? json['reportError'] as bool
          : defaultReportError,
    );
  }

  Map<String, dynamic> toJson({bool includeTunnelSequenceInterval = true}) {
    final json = <String, dynamic>{
      'Roads': roads.map((e) => e.toJson()).toList(),
      'BrickMapIndex': brickMapIndex,
      'reportError': reportError,
    };
    if (includeTunnelSequenceInterval) {
      json['TunnelSequenceInterval'] = tunnelSequenceInterval;
    }
    return json;
  }
}
