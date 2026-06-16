/// Optional focus when opening a module editor from a wave preview.
class ModuleOpenHint {
  const ModuleOpenHint({
    this.gridOverrideModuleWave,
    this.dropShipWave,
    this.heianWindWaveNumber,
  });

  /// 1-based wave in [ArmrackPropertiesData] / [EnergyGridPropertiesData].
  final int? gridOverrideModuleWave;

  /// 0-based wave in [DropShipPropertiesData].
  final int? dropShipWave;

  /// 0-based wave number in [HeianWindModulePropertiesData].
  final int? heianWindWaveNumber;
}

typedef OpenModuleCallback = void Function(
  String rtid, {
  ModuleOpenHint? hint,
});
