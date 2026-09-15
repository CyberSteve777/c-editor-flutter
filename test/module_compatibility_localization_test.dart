import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _appLocale(String locale) =>
    jsonDecode(File('assets/l10n/app_$locale.arb').readAsStringSync())
        as Map<String, dynamic>;

void main() {
  const locales = ['zh', 'en', 'ru'];
  const removedKeys = [
    'conflictDesc_WaveGeneratorRenai',
    'conflictDesc_WaveGeneratorWitch',
    'lifeSupportLastStandConflictWarning',
  ];

  test('removes disproven compatibility warnings in every app locale', () {
    for (final locale in locales) {
      final arb = _appLocale(locale);
      for (final key in removedKeys) {
        expect(arb, isNot(contains(key)), reason: '$locale: $key');
        expect(arb, isNot(contains('@$key')), reason: '$locale: @$key');
      }
    }
  });

  test('wave generator help uses the requested general caution', () {
    const expectedBodies = {
      'zh': '可能与部分模块不兼容，造成关卡闪退，请谨慎使用。',
      'en':
          'May be incompatible with some modules and cause the level '
          'to crash. Use with caution.',
      'ru':
          'Может быть несовместим с некоторыми модулями и вызывать '
          'сбой уровня. Используйте с осторожностью.',
    };
    for (final entry in expectedBodies.entries) {
      final arb = _appLocale(entry.key);
      expect(
        arb['waveGeneratorModuleHelpIncompatBody'],
        entry.value,
        reason: entry.key,
      );
      expect(arb['waveGeneratorModuleHelpIncompat'], isNotEmpty);
    }
  });

  test('retains actual wave system conflicts and unrelated module help', () {
    for (final locale in locales) {
      final arb = _appLocale(locale);
      for (final key in const [
        'conflictDesc_WaveGeneratorWaveManagerModule',
        'conflictDesc_WaveGeneratorWaveManager',
        'conflictDesc_SeedBankConveyor',
        'moonLifeSupportHelpOverview',
        'lastStandHelpNotesBody',
        'witchModuleHelpIntro',
        'renaiModuleHelpOverviewBody',
      ]) {
        expect(arb[key], isNotEmpty, reason: '$locale: $key');
      }
    }
  });
}
