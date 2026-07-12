import 'package:c_editor/data/pvz_models.dart';

/// Stable sort for row-based zombie spawn lists: rows 1..[maxRow], then random row.
/// Preserves existing relative order within each row.
void sortZombieSpawnListByRow(List<ZombieSpawnData> zombies, {required int maxRow}) {
  if (zombies.isEmpty) return;

  final buckets = <int, List<ZombieSpawnData>>{};
  for (final zombie in zombies) {
    final key = _rowSortKey(zombie.row, maxRow);
    buckets.putIfAbsent(key, () => []).add(zombie);
  }

  zombies.clear();
  for (var row = 1; row <= maxRow; row++) {
    zombies.addAll(buckets[row] ?? const []);
  }
  zombies.addAll(buckets[maxRow + 1] ?? const []);
}

int _rowSortKey(int? row, int maxRow) => (row == null || row == 0) ? maxRow + 1 : row;

/// Row-local slot move — avoids fragile global [beforeIndex] math with duplicates.
void moveZombieSpawnInListByRowSlot({
  required List<ZombieSpawnData> zombies,
  required int fromIndex,
  required int toRow,
  required int maxRow,
  required int rowInsertIndex,
}) {
  if (fromIndex < 0 || fromIndex >= zombies.length) return;
  final moved = zombies.removeAt(fromIndex);
  moved.row = toRow == 0 ? null : toRow;

  final targetKey = _rowSortKey(toRow, maxRow);
  final rowPositions = <int>[];
  for (var i = 0; i < zombies.length; i++) {
    if (_rowSortKey(zombies[i].row, maxRow) == targetKey) {
      rowPositions.add(i);
    }
  }

  final int insertAt;
  if (rowPositions.isEmpty) {
    insertAt = _globalInsertAtForRow(zombies, toRow, maxRow);
  } else if (rowInsertIndex >= rowPositions.length) {
    insertAt = rowPositions.last + 1;
  } else {
    insertAt = rowPositions[rowInsertIndex];
  }

  zombies.insert(insertAt.clamp(0, zombies.length), moved);
}

int _globalInsertAtForRow(
  List<ZombieSpawnData> zombies,
  int toRow,
  int maxRow,
) {
  final targetKey = _rowSortKey(toRow, maxRow);
  for (var i = 0; i < zombies.length; i++) {
    if (_rowSortKey(zombies[i].row, maxRow) > targetKey) return i;
  }
  return zombies.length;
}

/// Reorders [zombies] after a drag from [fromIndex] onto row [toRow] before [beforeIndex].
/// Pass [beforeIndex] as null to append within the target row section.
void moveZombieSpawnInList({
  required List<ZombieSpawnData> zombies,
  required int fromIndex,
  required int toRow,
  required int maxRow,
  int? beforeIndex,
}) {
  if (fromIndex < 0 || fromIndex >= zombies.length) return;
  final moved = zombies.removeAt(fromIndex);
  moved.row = toRow == 0 ? null : toRow;

  final adjustedBefore = beforeIndex != null && beforeIndex > fromIndex
      ? beforeIndex - 1
      : beforeIndex;

  if (adjustedBefore == null) {
    var insertAt = zombies.length;
    for (var i = zombies.length - 1; i >= 0; i--) {
      final row = zombies[i].row ?? 0;
      final sortKey = _rowSortKey(row, maxRow);
      if (sortKey <= _rowSortKey(toRow, maxRow)) {
        insertAt = i + 1;
        break;
      }
      if (i == 0) insertAt = 0;
    }
    zombies.insert(insertAt, moved);
  } else {
    final safe = adjustedBefore.clamp(0, zombies.length);
    zombies.insert(safe, moved);
  }
}

/// Reorders a flat zombie list after a drag onto [beforeIndex] (null = append).
void reorderZombieFlatList<T>({
  required List<T> list,
  required int fromIndex,
  int? beforeIndex,
}) {
  if (fromIndex < 0 || fromIndex >= list.length) return;
  final item = list.removeAt(fromIndex);
  if (beforeIndex == null) {
    list.add(item);
    return;
  }
  final insertAt = beforeIndex > fromIndex ? beforeIndex - 1 : beforeIndex;
  list.insert(insertAt.clamp(0, list.length), item);
}

int _waveGenRowSortKey(String? row, int maxRow) {
  if (row == null || row.isEmpty || row == '?') return maxRow + 1;
  return int.tryParse(row) ?? maxRow + 1;
}

/// Stable sort for wave-generator zombie lists: rows 1..[maxRow], then random row.
/// Preserves existing relative order within each row.
void sortWaveGeneratorZombieListByRow(
  List<WaveGeneratorZombieEntryData> zombies, {
  required int maxRow,
  List<int?>? parallelLevels,
}) {
  if (zombies.isEmpty) return;

  final buckets = <int, List<WaveGeneratorZombieEntryData>>{};
  final levelBuckets = parallelLevels != null
      ? <int, List<int?>>{}
      : null;

  for (var i = 0; i < zombies.length; i++) {
    final zombie = zombies[i];
    final key = _waveGenRowSortKey(zombie.row, maxRow);
    buckets.putIfAbsent(key, () => []).add(zombie);
    if (parallelLevels != null) {
      levelBuckets!.putIfAbsent(key, () => []).add(parallelLevels[i]);
    }
  }

  zombies.clear();
  parallelLevels?.clear();
  for (var row = 1; row <= maxRow; row++) {
    zombies.addAll(buckets[row] ?? const []);
    parallelLevels?.addAll(levelBuckets?[row] ?? const []);
  }
  zombies.addAll(buckets[maxRow + 1] ?? const []);
  parallelLevels?.addAll(levelBuckets?[maxRow + 1] ?? const []);
}

/// Reorders wave-generator zombies after a drag onto row [toRow] before [beforeIndex].
void moveWaveGeneratorZombieInList({
  required List<WaveGeneratorZombieEntryData> zombies,
  required int fromIndex,
  required int toRow,
  required int maxRow,
  int? beforeIndex,
  List<int?>? parallelLevels,
}) {
  if (fromIndex < 0 || fromIndex >= zombies.length) return;
  int? movedLevel;
  if (parallelLevels != null) {
    movedLevel = parallelLevels.removeAt(fromIndex);
  }
  final moved = zombies.removeAt(fromIndex);
  moved.row = toRow == 0 ? '?' : '$toRow';

  final adjustedBefore = beforeIndex != null && beforeIndex > fromIndex
      ? beforeIndex - 1
      : beforeIndex;

  if (adjustedBefore == null) {
    var insertAt = zombies.length;
    for (var i = zombies.length - 1; i >= 0; i--) {
      final sortKey = _waveGenRowSortKey(zombies[i].row, maxRow);
      if (sortKey <= _waveGenRowSortKey(toRow == 0 ? '?' : '$toRow', maxRow)) {
        insertAt = i + 1;
        break;
      }
      if (i == 0) insertAt = 0;
    }
    zombies.insert(insertAt, moved);
    parallelLevels?.insert(insertAt, movedLevel);
  } else {
    final safe = adjustedBefore.clamp(0, zombies.length);
    zombies.insert(safe, moved);
    parallelLevels?.insert(safe, movedLevel);
  }
}
