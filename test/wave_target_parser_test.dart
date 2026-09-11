import 'package:c_editor/screens/common/wave_target_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseWaveTargetSpec', () {
    test('parses a single wave', () {
      expect(parseWaveTargetSpec('3', 10), [3]);
      expect(parseWaveTargetSpec(' 1 ', 5), [1]);
      expect(parseWaveTargetSpec('5', 5), [5]);
    });

    test('parses inclusive ranges and swaps reversed bounds', () {
      expect(parseWaveTargetSpec('1-5', 10), [1, 2, 3, 4, 5]);
      expect(parseWaveTargetSpec('2 - 4', 10), [2, 3, 4]);
      expect(parseWaveTargetSpec('5-3', 10), [3, 4, 5]);
      expect(parseWaveTargetSpec('1–3', 10), [1, 2, 3]);
    });

    test('rejects empty, non-numeric, and out-of-range values', () {
      expect(parseWaveTargetSpec('', 10), isNull);
      expect(parseWaveTargetSpec('abc', 10), isNull);
      expect(parseWaveTargetSpec('0', 10), isNull);
      expect(parseWaveTargetSpec('11', 10), isNull);
      expect(parseWaveTargetSpec('1-11', 10), isNull);
      expect(parseWaveTargetSpec('0-3', 10), isNull);
      expect(parseWaveTargetSpec('1-5', 0), isNull);
    });
  });
}
