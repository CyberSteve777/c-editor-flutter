import 'dart:io';

import 'package:c_editor/data/narrative_catalog.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(NarrativeCatalog.clearCacheForTesting);

  test(
    'every dialogue belongs to exactly one ordered picker section',
    () async {
      const expectedSectionOrder = <NarrativeSectionId>[
        NarrativeSectionId.tutorialYard,
        NarrativeSectionId.ancientEgypt,
        NarrativeSectionId.pirateSeas,
        NarrativeSectionId.wildWest,
        NarrativeSectionId.kongfuWorld,
        NarrativeSectionId.farFuture,
        NarrativeSectionId.darkAges,
        NarrativeSectionId.bigWaveBeach,
        NarrativeSectionId.frostbiteCaves,
        NarrativeSectionId.skyCity,
        NarrativeSectionId.lostCity,
        NarrativeSectionId.neonMixtapeTour,
        NarrativeSectionId.jurassicMarsh,
        NarrativeSectionId.modernDay,
        NarrativeSectionId.steamAges,
        NarrativeSectionId.renaissanceAges,
        NarrativeSectionId.heianAges,
        NarrativeSectionId.underwaterWorld,
        NarrativeSectionId.moonBase,
        NarrativeSectionId.memoryImport,
        NarrativeSectionId.memorySeason27,
        NarrativeSectionId.memorySeason28,
        NarrativeSectionId.memorySeason29,
        NarrativeSectionId.memorySeason30,
        NarrativeSectionId.memorySeason31,
        NarrativeSectionId.memorySeason32,
        NarrativeSectionId.secretRealm,
        NarrativeSectionId.twoPlayerDuel,
        NarrativeSectionId.pennysPursuit,
        NarrativeSectionId.endlessModes,
        NarrativeSectionId.pvpMode,
        NarrativeSectionId.cardClash,
        NarrativeSectionId.plantEncounter,
        NarrativeSectionId.travelLog,
        NarrativeSectionId.zenGarden,
        NarrativeSectionId.pinataParty,
        NarrativeSectionId.systemTutorials,
      ];
      const expectedCounts = <NarrativeSectionId, int>{
        NarrativeSectionId.tutorialYard: 2,
        NarrativeSectionId.ancientEgypt: 46,
        NarrativeSectionId.pirateSeas: 22,
        NarrativeSectionId.wildWest: 24,
        NarrativeSectionId.kongfuWorld: 13,
        NarrativeSectionId.farFuture: 17,
        NarrativeSectionId.darkAges: 13,
        NarrativeSectionId.bigWaveBeach: 13,
        NarrativeSectionId.frostbiteCaves: 15,
        NarrativeSectionId.skyCity: 14,
        NarrativeSectionId.lostCity: 11,
        NarrativeSectionId.neonMixtapeTour: 11,
        NarrativeSectionId.jurassicMarsh: 13,
        NarrativeSectionId.modernDay: 22,
        NarrativeSectionId.steamAges: 8,
        NarrativeSectionId.renaissanceAges: 8,
        NarrativeSectionId.heianAges: 10,
        NarrativeSectionId.underwaterWorld: 20,
        NarrativeSectionId.moonBase: 20,
        NarrativeSectionId.memoryImport: 3,
        NarrativeSectionId.memorySeason27: 16,
        NarrativeSectionId.memorySeason28: 16,
        NarrativeSectionId.memorySeason29: 16,
        NarrativeSectionId.memorySeason30: 15,
        NarrativeSectionId.memorySeason31: 15,
        NarrativeSectionId.memorySeason32: 15,
        NarrativeSectionId.secretRealm: 31,
        NarrativeSectionId.twoPlayerDuel: 3,
        NarrativeSectionId.pennysPursuit: 2,
        NarrativeSectionId.endlessModes: 24,
        NarrativeSectionId.pvpMode: 23,
        NarrativeSectionId.cardClash: 4,
        NarrativeSectionId.plantEncounter: 19,
        NarrativeSectionId.travelLog: 22,
        NarrativeSectionId.zenGarden: 4,
        NarrativeSectionId.pinataParty: 9,
        NarrativeSectionId.systemTutorials: 130,
      };
      const expectedCategoryCounts = <NarrativeCategory, int>{
        NarrativeCategory.mainWorlds: 302,
        NarrativeCategory.memoryLane: 96,
        NarrativeCategory.otherModes: 141,
        NarrativeCategory.systemTutorials: 130,
      };

      for (final locale in const [Locale('zh'), Locale('en'), Locale('ru')]) {
        final catalog = await NarrativeCatalog.load(locale);
        final sections = catalog.sectionsForCategory(NarrativeCategory.all);
        expect(sections.map((section) => section.id), expectedSectionOrder);

        final grouped = <NarrativeEntry>[];
        for (final section in sections) {
          final entries = catalog.entriesForSection(section.id);
          expect(entries, hasLength(expectedCounts[section.id]!));
          expect(File(section.iconAsset).existsSync(), isTrue);
          for (final entry in entries) {
            expect(catalog.sectionForEntry(entry).id, section.id);
            expect(catalog.displayCategory(entry), section.category);
            expect(catalog.displayIcon(entry), section.iconAsset);
          }
          grouped.addAll(entries);
        }

        expect(grouped, hasLength(catalog.dialogues.length));
        expect(grouped.toSet(), hasLength(catalog.dialogues.length));
        expect(grouped.toSet(), containsAll(catalog.dialogues));
        for (final expected in expectedCategoryCounts.entries) {
          final entries = catalog.forCategory(expected.key);
          expect(entries, hasLength(expected.value));
          expect(
            entries.every(
              (entry) => catalog.displayCategory(entry) == expected.key,
            ),
            isTrue,
          );
        }
      }
    },
  );

  test(
    'mode tutorials lead their sections and secret realms use release order',
    () async {
      final catalog = await NarrativeCatalog.load(const Locale('zh'));

      const leadingTutorials = <NarrativeSectionId, String>{
        NarrativeSectionId.ancientEgypt: 'TUTORIAL_EGYPT6_INTRO',
        NarrativeSectionId.memoryImport: 'TUTORIAL_PVZ1_INTRO',
        NarrativeSectionId.secretRealm: 'TUTORIAL_PVZ2_UNCHARTED_MODE_INTRO',
        NarrativeSectionId.pvpMode: 'TUTORIAL_PVP_INTRO',
        NarrativeSectionId.twoPlayerDuel: 'TUTORIAL_NEW_PVP_INTRO',
        NarrativeSectionId.pennysPursuit: 'TUTORIAL_RIFT_INTRO',
        NarrativeSectionId.cardClash: 'TUTORIAL_CARD_GAME_INTRO',
        NarrativeSectionId.travelLog: 'TUTORIAL_TRAVELLOG_INTRO',
      };
      for (final entry in leadingTutorials.entries) {
        expect(catalog.entriesForSection(entry.key).first.groupId, entry.value);
      }

      final secretRealm = catalog.entriesForSection(
        NarrativeSectionId.secretRealm,
      );
      final releaseBuckets = secretRealm
          .map((entry) => _secretRealmReleaseBucket(entry.groupId))
          .toList();
      expect(releaseBuckets, orderedEquals([...releaseBuckets]..sort()));
    },
  );
}

int _secretRealmReleaseBucket(String id) {
  if (id == 'TUTORIAL_PVZ2_UNCHARTED_MODE_INTRO') return 0;
  if (id == 'ANNIVERSARY_UNCHARTED_EVENT_TUTORIAL' ||
      id.startsWith('HALLOWEEN_')) {
    return 2;
  }
  if (id.startsWith('CHILDRENSDAY_')) return 4;
  if (id.startsWith('SPECIAL_UNCHARTED_')) return 5;
  if (id.startsWith('CHRISTMAS_202512_') ||
      id.startsWith('ICEAGE_UNCHARTED_') ||
      id.startsWith('UNCHARTED_ICEAGE_')) {
    return 7;
  }
  if (id.startsWith('SPRING_FESTIVAL_2024_')) return 8;
  if (id.startsWith('ARBORDAY_')) return 9;
  if (id.startsWith('NEEDFORSPEED_')) return 10;
  if (id.startsWith('NO42_') || id.startsWith('UNCHARTED_NO42_')) return 11;
  if (id.startsWith('MAUSOLEUM_')) return 15;
  if (id.startsWith('ARENA_')) return 16;
  return 99;
}
