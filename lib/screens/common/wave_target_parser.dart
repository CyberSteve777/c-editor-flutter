/// Parses a single wave index or an inclusive `"start-stop"` range.
List<int>? parseWaveTargetSpec(String input, int waveCount) {
  if (waveCount < 1) return null;
  final text = input.trim();
  if (text.isEmpty) return null;

  final rangeMatch = RegExp(r'^(\d+)\s*[-–—]\s*(\d+)$').firstMatch(text);
  if (rangeMatch != null) {
    var start = int.parse(rangeMatch.group(1)!);
    var end = int.parse(rangeMatch.group(2)!);
    if (start > end) {
      final swap = start;
      start = end;
      end = swap;
    }
    if (start < 1 || end > waveCount) return null;
    return [for (var i = start; i <= end; i++) i];
  }

  final single = int.tryParse(text);
  if (single == null || single < 1 || single > waveCount) return null;
  return [single];
}
