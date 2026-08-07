// ignore_for_file: file_names

import 'package:c_editor/data/pvz_models/PvzModel.dart';

class BoardGridMapPropsData extends PvzModel {
  BoardGridMapPropsData({required this.values});

  List<List<int>> values;

  factory BoardGridMapPropsData.empty({int rows = 5, int columns = 9}) {
    return BoardGridMapPropsData(
      values: List.generate(rows, (_) => List.filled(columns, 0)),
    );
  }

  factory BoardGridMapPropsData.fromJson(Map<String, dynamic> json) {
    final rawValues = json['Values'];
    if (rawValues is! List) return BoardGridMapPropsData(values: []);
    return BoardGridMapPropsData(
      values: rawValues.map<List<int>>((rawRow) {
        if (rawRow is! List) return <int>[];
        return rawRow.map<int>((value) {
          if (value is num) return value.toInt() == 0 ? 0 : 1;
          return 0;
        }).toList();
      }).toList(),
    );
  }

  BoardGridMapPropsData normalized({required int rows, required int columns}) {
    return BoardGridMapPropsData(
      values: List.generate(rows, (row) {
        return List.generate(columns, (column) {
          if (row >= values.length || column >= values[row].length) return 0;
          return values[row][column] == 0 ? 0 : 1;
        });
      }),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    'Values': values.map((row) => List<int>.from(row)).toList(),
  };
}
