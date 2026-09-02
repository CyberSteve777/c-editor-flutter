import 'package:c_editor/data/pvz_models/PvzModel.dart';

class IntroSingleHandedPropertiesData extends PvzModel {
  IntroSingleHandedPropertiesData({
    this.waveForStartRocket = 1,
    Map<String, dynamic>? extraFields,
  }) : extraFields = extraFields ?? <String, dynamic>{};

  int waveForStartRocket;
  final Map<String, dynamic> extraFields;

  factory IntroSingleHandedPropertiesData.fromJson(
    Map<String, dynamic> json,
  ) {
    return IntroSingleHandedPropertiesData(
      waveForStartRocket: (json['WaveForStartRocket'] as num?)?.toInt() ?? 1,
      extraFields: Map<String, dynamic>.from(json)
        ..remove('WaveForStartRocket'),
    );
  }

  @override
  Map<String, dynamic> toJson() => {
    ...extraFields,
    'WaveForStartRocket': waveForStartRocket,
  };
}
