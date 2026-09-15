import 'package:c_editor/data/pvz_models/PvzModel.dart';
import 'package:c_editor/data/pvz_models/InitialGridItemData.dart';

class InitialGridItemEntryData extends PvzModel {
  InitialGridItemEntryData({
    this.placements = const [],
    this.fieldName = 'InitialGridItemPlacements',
  });

  List<InitialGridItemData> placements;
  String fieldName;

  factory InitialGridItemEntryData.fromJson(Map<String, dynamic> json) {
    String detectedField = 'InitialGridItemPlacements';
    List<dynamic>? rawList;

    if (json.containsKey('InitialGridItemPlacements')) {
      detectedField = 'InitialGridItemPlacements';
      rawList = json['InitialGridItemPlacements'] as List<dynamic>?;
    } else if (json.containsKey('GridItems')) {
      detectedField = 'GridItems';
      rawList = json['GridItems'] as List<dynamic>?;
    }

    return InitialGridItemEntryData(
      fieldName: detectedField,
      placements:
          rawList
              ?.map(
                (e) => InitialGridItemData.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    fieldName: placements.map((e) => e.toJson()).toList(),
  };
}
