import 'package:c_editor/screens/common/wave_target_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parseWaveTargetSpec', () {
    test('parses a single wave', () {
      expect(parseWaveTargetSpec('3', 10), [3]);
      expect(parseWaveTargetSpec(' 1 ', 5), [1]);
      expect(parseWaveTargetSpec('5', 5), [5]);
    });

    test('parses inclusive ranges and implied reverse step', () {
      expect(parseWaveTargetSpec('1-5', 10), [1, 2, 3, 4, 5]);
      expect(parseWaveTargetSpec('2 - 4', 10), [2, 3, 4]);
      expect(parseWaveTargetSpec('5-3', 10), [5, 4, 3]);
      expect(parseWaveTargetSpec('1–3', 10), [1, 2, 3]);
      expect(parseWaveTargetSpec('3-3', 10), [3]);
    });

    test('parses explicit steps in both directions', () {
      expect(parseWaveTargetSpec('1-10:2', 10), [1, 3, 5, 7, 9]);
      expect(parseWaveTargetSpec('1-10:3', 10), [1, 4, 7, 10]);
      expect(parseWaveTargetSpec('10-1:-2', 10), [10, 8, 6, 4, 2]);
      expect(parseWaveTargetSpec('5-1:-1', 5), [5, 4, 3, 2, 1]);
    });

    test('parses comma-separated waves and ranges, keeping first order', () {
      expect(parseWaveTargetSpec('1, 3, 5', 10), [1, 3, 5]);
      expect(parseWaveTargetSpec('1,5-3,8', 10), [1, 5, 4, 3, 8]);
      expect(parseWaveTargetSpec('1-5,3,7,1-3:2', 10), [1, 2, 3, 4, 5, 7]);
      expect(parseWaveTargetSpec('2-8:2, 10-6:-2', 10), [2, 4, 6, 8, 10]);
    });

    test('rejects empty, non-numeric, out-of-range, and bad steps', () {
      expect(parseWaveTargetSpec('', 10), isNull);
      expect(parseWaveTargetSpec('abc', 10), isNull);
      expect(parseWaveTargetSpec('0', 10), isNull);
      expect(parseWaveTargetSpec('11', 10), isNull);
      expect(parseWaveTargetSpec('1-11', 10), isNull);
      expect(parseWaveTargetSpec('0-3', 10), isNull);
      expect(parseWaveTargetSpec('1-5', 0), isNull);
      expect(parseWaveTargetSpec('1-10:0', 10), isNull);
      expect(parseWaveTargetSpec('1-10:-2', 10), isNull);
      expect(parseWaveTargetSpec('10-1:2', 10), isNull);
      expect(parseWaveTargetSpec('1,,3', 10), isNull);
      expect(parseWaveTargetSpec('1,', 10), isNull);
      expect(parseWaveTargetSpec('1-5:2:3', 10), isNull);
    });
  });
}
