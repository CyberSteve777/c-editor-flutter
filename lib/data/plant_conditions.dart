/// Plant special-state ids (e.g. frozen preset plants).
abstract class PlantConditions {
  PlantConditions._();

  /// Only condition supported on preset plants today.
  static const ids = ['icecubed'];

  static String resourceKey(String id) => 'plantCondition_$id';
}
