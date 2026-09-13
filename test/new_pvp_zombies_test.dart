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

int _worldGroupIndex(ZombieInfo zombie) =>
    zombieWorldTagOrder.indexWhere((tag) => zombie.tags.contains(tag));

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
      expect(tags, isNot(contains('Evildave')), reason: pvpId);
      expect(tags, contains('PvP'), reason: pvpId);
      expect(tags, contains('Chinese'), reason: pvpId);
      expect(tags.indexOf('PvP') + 1, tags.indexOf('Chinese'), reason: pvpId);

      final inheritedTags = (base['tags'] as List<dynamic>)
          .cast<String>()
          .where(
            (tag) =>
                tag != 'International' && tag != 'Chinese' && tag != 'Evildave',
          )
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

  test('PvP tag is in Other before Expedition variants', () {
    expect(ZombieTag.pvp.category, ZombieCategory.other);
    expect(
      ZombieTag.values.indexOf(ZombieTag.pvp),
      ZombieTag.values.indexOf(ZombieTag.expedition) - 1,
    );
    expect(lookupAppLocalizations(const Locale('zh')).zombieTagPvp, '双人变体');
    expect(
      lookupAppLocalizations(const Locale('en')).zombieTagPvp,
      'Two-Player Mode Variants',
    );
  });

  test('Roman world group is between underground and Memory Lane', () {
    expect(
      zombieWorldTagOrder.indexOf(ZombieTag.toTheWest),
      zombieWorldTagOrder.indexOf(ZombieTag.parkourSpeed) + 1,
    );
    expect(
      zombieWorldTagOrder.indexOf(ZombieTag.toTheWest),
      zombieWorldTagOrder.indexOf(ZombieTag.roman) - 1,
    );
    expect(
      zombieWorldTagOrder.indexOf(ZombieTag.roman),
      zombieWorldTagOrder.indexOf(ZombieTag.memory) - 1,
    );
  });

  test('all-zombie order follows Zombies.json and keeps stay_tuned last', () {
    final repositoryZombies = ZombieRepository().allZombies;
    final catalogIds = zombies
        .map((zombie) => zombie['id'] as String)
        .toSet()
        .toList();
    expect(repositoryZombies.map((zombie) => zombie.id), catalogIds);
    expect(catalogIds.last, 'stay_tuned');
    expect(catalogIds[catalogIds.length - 2], 'fairy_tale_imp_Elite');
    expect(repositoryZombies.last.id, 'stay_tuned');
    expect(
      ZombieRepository()
          .search('', ZombieTag.all, ZombieCategory.main)
          .map((zombie) => zombie.id),
      catalogIds,
    );
  });

  test('static catalog follows the complete world tag order', () {
    final repositoryZombies = ZombieRepository().allZombies;
    final groups = <ZombieTag>[];
    var previousWorldIndex = -1;
    for (final zombie in repositoryZombies) {
      if (zombie.id == 'stay_tuned') continue;
      final worldIndex = _worldGroupIndex(zombie);
      expect(worldIndex, greaterThanOrEqualTo(0), reason: zombie.id);
      expect(
        worldIndex,
        greaterThanOrEqualTo(previousWorldIndex),
        reason: '${zombie.id} must belong to its earliest assigned world tag',
      );
      if (worldIndex != previousWorldIndex) {
        groups.add(zombieWorldTagOrder[worldIndex]);
      }
      previousWorldIndex = worldIndex;
    }
    expect(groups, zombieWorldTagOrder);

    final swimmingRing = ZombieRepository().getZombieById('SwimmingRing')!;
    expect(
      swimmingRing.tags,
      containsAll([
        ZombieTag.modernPvz1,
        ZombieTag.darkBeach,
        ZombieTag.memory,
      ]),
    );
    expect(
      _worldGroupIndex(swimmingRing),
      zombieWorldTagOrder.indexOf(ZombieTag.darkBeach),
    );
    final snowPea = ZombieRepository().getZombieById('zombie_snowpea')!;
    expect(snowPea.tags, containsAll([ZombieTag.modernPvz1, ZombieTag.memory]));
    expect(
      _worldGroupIndex(snowPea),
      zombieWorldTagOrder.indexOf(ZombieTag.modernPvz1),
    );
  });

  test('western and Roman catalog groups precede the Memory Lane block', () {
    final repositoryZombies = ZombieRepository().allZombies;
    final catalogIds = zombies.map((zombie) => zombie['id'] as String).toList();
    final westIds = zombies
        .where((zombie) => (zombie['tags'] as List).contains('Tothewest'))
        .map((zombie) => zombie['id'] as String)
        .toList();
    final romanIds = zombies
        .where((zombie) => (zombie['tags'] as List).contains('Roman'))
        .map((zombie) => zombie['id'] as String)
        .toList();
    expect(westIds, hasLength(51));
    expect(romanIds, hasLength(33));
    final firstWest = catalogIds.indexOf(westIds.first);
    final firstRoman = catalogIds.indexOf(romanIds.first);
    final firstMemory = repositoryZombies.indexWhere(
      (zombie) =>
          _worldGroupIndex(zombie) ==
          zombieWorldTagOrder.indexOf(ZombieTag.memory),
    );
    expect(catalogIds[firstWest - 1], 'zombie_van');
    expect(catalogIds.sublist(firstWest, firstRoman), westIds);
    expect(catalogIds.sublist(firstRoman, firstMemory), romanIds);
    final lastMemory = repositoryZombies.lastIndexWhere(
      (zombie) =>
          _worldGroupIndex(zombie) ==
          zombieWorldTagOrder.indexOf(ZombieTag.memory),
    );
    expect(catalogIds[lastMemory], 'carnie_dove');

    // Memo variants retain their explicit Roman placement even without a
    // Memory tag; actual dual-world variants are also kept in the Roman block.
    for (final id in const ['roman_ballista_memo', 'roman_ballista_memo2']) {
      final zombie = ZombieRepository().getZombieById(id)!;
      expect(zombie.tags, contains(ZombieTag.roman));
      expect(
        catalogIds.indexOf(id),
        inInclusiveRange(firstRoman, firstMemory - 1),
      );
    }
    for (final id in const ['elite_roman_healer', 'elite_roman_ballista']) {
      final zombie = ZombieRepository().getZombieById(id)!;
      expect(zombie.tags, containsAll([ZombieTag.roman, ZombieTag.memory]));
      expect(
        catalogIds.indexOf(id),
        inInclusiveRange(firstRoman, firstMemory - 1),
      );
    }
    expect(
      ZombieRepository()
          .search('', ZombieTag.roman, ZombieCategory.main)
          .map((zombie) => zombie.id),
      romanIds,
    );
  });

  testWidgets('zombie picker shows PvP before Expedition in Other', (
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
    expect(tester.getCenter(pvp).dx, lessThan(tester.getCenter(expedition).dx));
  });
}
