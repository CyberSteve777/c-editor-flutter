/// Parses wave targets: singles, inclusive ranges, optional steps, and
/// comma-separated lists.
///
/// * `3` — one wave
/// * `1, 3, 8` — several waves
/// * `1-5` — inclusive range, step 1
/// * `5-1` — inclusive reversed range, step -1
/// * `1-10:2` — every second wave from 1 through 10
/// * `10-1:-2` — same direction, explicit negative step
///
/// A missing step is 1 when start <= end, otherwise -1. An explicit step must
/// be non-zero and share that direction. Duplicate waves are kept once, in
/// first-seen order.
List<int>? parseWaveTargetSpec(String input, int waveCount) {
  if (waveCount < 1) return null;
  final text = input.trim();
  if (text.isEmpty) return null;

  final parts = text.split(RegExp(r'[,，]'));
  final result = <int>[];
  final seen = <int>{};
  for (final raw in parts) {
    final expanded = _parseWaveTargetEntry(raw.trim(), waveCount);
    if (expanded == null) return null;
    for (final wave in expanded) {
      if (seen.add(wave)) result.add(wave);
    }
  }
  return result;
}

final _waveTargetEntry = RegExp(
  r'^(\d+)(?:\s*[-–—]\s*(\d+)(?:\s*:\s*(-?\d+))?)?$',
);

List<int>? _parseWaveTargetEntry(String text, int waveCount) {
  if (text.isEmpty) return null;
  final match = _waveTargetEntry.firstMatch(text);
  if (match == null) return null;

  final start = int.parse(match.group(1)!);
  if (start < 1 || start > waveCount) return null;

  final endText = match.group(2);
  if (endText == null) return [start];

  final end = int.parse(endText);
  if (end < 1 || end > waveCount) return null;

  final stepText = match.group(3);
  final int step;
  if (stepText == null) {
    step = start <= end ? 1 : -1;
  } else {
    step = int.parse(stepText);
    if (step == 0) return null;
    if (start < end && step < 0) return null;
    if (start > end && step > 0) return null;
  }

  if (start == end) return [start];

  final waves = <int>[];
  if (step > 0) {
    for (var i = start; i <= end; i += step) {
      waves.add(i);
    }
  } else {
    for (var i = start; i >= end; i += step) {
      waves.add(i);
    }
  }
  return waves;
}
