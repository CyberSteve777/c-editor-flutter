import 'dart:convert';
import 'dart:io';

import 'package:c_editor/data/asset_loader.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget _localizedApp(Widget home) => MaterialApp(
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: home,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<String> referencePvpIds;
  late List<Map<String, dynamic>> zombies;
  late Map<String, Map<String, dynamic>> zombiesById;

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Future.wait([
      ResourceNames.ensureLoaded(),
      ZombieRepository().init(),
    ]);

    final zombieTypes =
        jsonDecode(await loadJsonString('assets/reference/ZombieTypes.json'))
            as Map<String, dynamic>;
    referencePvpIds = (zombieTypes['objects'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map((object) => object['objdata'])
        .whereType<Map<String, dynamic>>()
        .map((data) => data['TypeName']?.toString() ?? '')
        .where((id) => id.startsWith('new_pvp_'))
        .toList();

    zombies =
        (jsonDecode(await loadJsonString('assets/resources/Zombies.json'))
                as List<dynamic>)
            .cast<Map<String, dynamic>>();
    zombiesById = {
      for (final zombie in zombies) zombie['id'] as String: zombie,
    };
  });

  test('Zombies.json contains every referenced new_pvp_ ZombieType', () {
    final configuredPvpIds = zombies
        .map((zombie) => zombie['id'] as String)
        .where((id) => id.startsWith('new_pvp_'))
        .toList();

    expect(configuredPvpIds, hasLength(referencePvpIds.length));
    expect(configuredPvpIds.toSet(), referencePvpIds.toSet());
    expect(configuredPvpIds, hasLength(76));
  });

  test('PvP zombies inherit base metadata and use PvP then Chinese tags', () {
    for (final pvpId in referencePvpIds) {
      final baseId = pvpId.substring('new_pvp_'.length);
      final base = zombiesById[baseId];
      final pvp = zombiesById[pvpId];
      expect(base, isNotNull, reason: 'Missing base zombie $baseId');
      expect(pvp, isNotNull, reason: 'Missing PvP zombie $pvpId');
      expect(pvp!['icon'], base!['icon'], reason: pvpId);
      expect(pvp['name'], 'zombie_$pvpId');

      final tags = (pvp['tags'] as List<dynamic>).cast<String>();
      expect(tags, isNot(contains('International')), reason: pvpId);
      expect(tags, contains('PvP'), reason: pvpId);
      expect(tags, contains('Chinese'), reason: pvpId);
      expect(tags.indexOf('PvP') + 1, tags.indexOf('Chinese'), reason: pvpId);

      final inheritedTags = (base['tags'] as List<dynamic>)
          .cast<String>()
          .where((tag) => tag != 'International' && tag != 'Chinese')
          .toList();
      expect(tags.take(tags.length - 2), inheritedTags, reason: pvpId);

      final repositoryEntry = ZombieRepository().getZombieById(pvpId);
      expect(repositoryEntry, isNotNull, reason: pvpId);
      expect(repositoryEntry!.tags, contains(ZombieTag.pvp), reason: pvpId);
      expect(repositoryEntry.tags, contains(ZombieTag.chinese), reason: pvpId);
    }
  });

  test('PvP zombies follow their base variant groups', () {
    final ids = zombies.map((zombie) => zombie['id'] as String).toList();
    for (final pvpId in referencePvpIds) {
      final baseId = pvpId.substring('new_pvp_'.length);
      expect(
        ids.indexOf(pvpId),
        greaterThan(ids.indexOf(baseId)),
        reason: pvpId,
      );
    }

    expect(
      ids.indexOf('new_pvp_roman_ballista'),
      ids.indexOf('roman_ballista_memo2') + 1,
    );
    expect(
      ids.indexOf('new_pvp_zombie_gatlingpea'),
      ids.indexOf('zombie_gatlingpea_ice') + 1,
    );
    expect(
      ids.indexOf('new_pvp_tutorial_gargantuar'),
      ids.indexOf('tutorial_gargantuar_memo') + 1,
    );
  });

  test('PvP names append localized suffixes with ASCII parentheses', () {
    const suffixes = {
      'en': 'Two-Player Mode',
      'zh': '双人对决',
      'ru': 'Режим для двух игроков',
    };
    for (final locale in suffixes.keys) {
      for (final pvpId in referencePvpIds) {
        final baseId = pvpId.substring('new_pvp_'.length);
        final baseKey = zombiesById[baseId]!['name'] as String;
        final pvpKey = zombiesById[pvpId]!['name'] as String;
        final baseName = ResourceNames.lookupWithLocale(locale, baseKey);
        final pvpName = ResourceNames.lookupWithLocale(locale, pvpKey);
        expect(pvpName, '$baseName (${suffixes[locale]})', reason: pvpId);
        expect(pvpName, isNot(contains('（')), reason: pvpId);
        expect(pvpName, isNot(contains('）')), reason: pvpId);
      }
    }
  });

  test('PvP resource name keys form one alphabetical block', () {
    for (final locale in const ['en', 'zh', 'ru']) {
      final resource =
          jsonDecode(
                File('assets/l10n/resource_$locale.json').readAsStringSync(),
              )
              as Map<String, dynamic>;
      final allKeys = resource.keys.toList();
      final pvpKeys = allKeys
          .where((key) => key.startsWith('zombie_new_pvp_'))
          .toList();
      final sortedPvpKeys = pvpKeys.toList()..sort();

      expect(pvpKeys, sortedPvpKeys, reason: locale);
      expect(pvpKeys, hasLength(referencePvpIds.length), reason: locale);

      final firstIndex = allKeys.indexOf(pvpKeys.first);
      expect(
        allKeys.sublist(firstIndex, firstIndex + pvpKeys.length),
        pvpKeys,
        reason: locale,
      );
      expect(
        allKeys[firstIndex - 1].compareTo(pvpKeys.first),
        lessThan(0),
        reason: locale,
      );
      expect(
        pvpKeys.last.compareTo(allKeys[firstIndex + pvpKeys.length]),
        lessThan(0),
        reason: locale,
      );
    }
  });

  test('PvP tag is in Other after Expedition variants', () {
    expect(ZombieTag.pvp.category, ZombieCategory.other);
    expect(
      ZombieTag.values.indexOf(ZombieTag.pvp),
      ZombieTag.values.indexOf(ZombieTag.expedition) + 1,
    );
    expect(lookupAppLocalizations(const Locale('zh')).zombieTagPvp, '双人变体');
    expect(
      lookupAppLocalizations(const Locale('en')).zombieTagPvp,
      'Two-Player Mode Variants',
    );
  });

  testWidgets('zombie picker shows PvP after Expedition in Other', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1400, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      _localizedApp(
        ZombieSelectionScreen(
          stateBucketId: 'pvp-tag-order-test',
          onZombieSelected: (_) {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Other'));
    await tester.pumpAndSettle();

    final expedition = find.text('Expedition Gate Variants');
    final pvp = find.text('Two-Player Mode Variants');
    expect(expedition, findsOneWidget);
    expect(pvp, findsOneWidget);
    expect(tester.getCenter(expedition).dx, lessThan(tester.getCenter(pvp).dx));
  });
}
