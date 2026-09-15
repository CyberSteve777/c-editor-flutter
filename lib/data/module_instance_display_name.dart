const repeatableBossModuleObjClasses = <String>{
  'ZombossBattleModuleProperties',
  'ZombossLastStandMinigameProperties',
};

/// Adds a one-based UI-only suffix when a repeatable Boss module has siblings.
///
/// The internal alias and RTID are deliberately not involved so reordering or
/// deleting instances never renames saved level objects.
String moduleInstanceDisplayName({
  required String baseName,
  required String objClass,
  required int instanceCount,
  required int instanceIndex,
}) {
  if (!repeatableBossModuleObjClasses.contains(objClass) || instanceCount < 2) {
    return baseName;
  }
  return '$baseName ${instanceIndex + 1}';
}
