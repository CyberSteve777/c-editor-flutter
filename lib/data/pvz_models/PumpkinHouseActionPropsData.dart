import 'package:z_editor/data/pvz_models/AtlantisShellTileData.dart';
import 'package:z_editor/data/pvz_models/PvzModel.dart';

class PumpkinHouseActionPropsData extends PvzModel {
  PumpkinHouseActionPropsData({this.tiles = const []});

  List<AtlantisShellTileData> tiles;

  factory PumpkinHouseActionPropsData.fromJson(Map<String, dynamic> json) {
    return PumpkinHouseActionPropsData(
      tiles:
          (json['Tiles'] as List<dynamic>?)
              ?.map(
                (e) =>
                    AtlantisShellTileData.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'Tiles': tiles.map((e) => e.toJson()).toList(),
  };
}
