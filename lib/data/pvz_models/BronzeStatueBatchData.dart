import 'package:c_editor/data/pvz_models/BronzeStatueItemData.dart';
import 'package:c_editor/data/pvz_models/PvzModel.dart';

class BronzeStatueBatchData extends PvzModel {
  BronzeStatueBatchData({List<BronzeStatueItemData>? itemList})
      : itemList = itemList ?? [];

  List<BronzeStatueItemData> itemList;

  factory BronzeStatueBatchData.fromJson(Map<String, dynamic> json) {
    final list = json['itemList'] as List<dynamic>?;
    return BronzeStatueBatchData(
      itemList:
          list
              ?.map(
                (e) => BronzeStatueItemData.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'itemList': itemList.map((e) => e.toJson()).toList(),
  };
}
