import 'package:c_editor/data/pvz_models/PvzModel.dart';

/// Default break-state animation labels used by all [ResilienceConfig.json] presets.
const kDefaultZombieResilienceAnimLabels = [
  'break_enter',
  'break_loop',
  'break_recover',
];

class ZombieResilienceData extends PvzModel {
  ZombieResilienceData({
    this.amount = 300,
    this.weakType = 6,
    this.recoverSpeed = 25,
    this.damageThresholdPerSecond = 1500,
    this.resilienceBaseDamageThreshold = 40,
    this.resilienceExtraDamageThreshold = 60,
    List<String>? animLabels,
  }) : animLabels = List<String>.from(
          animLabels ?? kDefaultZombieResilienceAnimLabels,
        );

  int amount;
  int weakType;
  double recoverSpeed;
  double damageThresholdPerSecond;
  int resilienceBaseDamageThreshold;
  int resilienceExtraDamageThreshold;
  List<String> animLabels;

  factory ZombieResilienceData.fromJson(Map<String, dynamic> json) {
    return ZombieResilienceData(
      amount: (json['Amount'] as num?)?.toInt() ?? 300,
      weakType: (json['WeakType'] as num?)?.toInt() ?? 6,
      recoverSpeed: (json['RecoverSpeed'] as num?)?.toDouble() ?? 25,
      damageThresholdPerSecond:
          (json['DamageThresholdPerSecond'] as num?)?.toDouble() ?? 1500,
      resilienceBaseDamageThreshold:
          (json['ResilienceBaseDamageThreshold'] as num?)?.toInt() ?? 40,
      resilienceExtraDamageThreshold:
          (json['ResilienceExtraDamageThreshold'] as num?)?.toInt() ?? 60,
      animLabels: _parseAnimLabels(json['AnimLabels']),
    );
  }

  static List<String> _parseAnimLabels(dynamic raw) {
    if (raw is List && raw.isNotEmpty) {
      return raw.map((e) => e.toString()).toList();
    }
    return List<String>.from(kDefaultZombieResilienceAnimLabels);
  }

  /// Numeric fields only — used when embedding resilience inline on a property sheet.
  @override
  Map<String, dynamic> toJson() => {
    'Amount': amount,
    'WeakType': weakType,
    'RecoverSpeed': recoverSpeed,
    'DamageThresholdPerSecond': damageThresholdPerSecond,
    'ResilienceBaseDamageThreshold': resilienceBaseDamageThreshold,
    'ResilienceExtraDamageThreshold': resilienceExtraDamageThreshold,
  };

  /// Full level [ZombieResilience] object payload, including required [AnimLabels].
  Map<String, dynamic> toLevelJson() => {
    ...toJson(),
    'AnimLabels': List<String>.from(animLabels),
  };
}

