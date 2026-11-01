import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/data/narrative_catalog.dart';
import 'package:c_editor/screens/select/narrative_preview_screen.dart';
import 'package:c_editor/screens/select/narrative_selection_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(NarrativeCatalog.clearCacheForTesting);

  test(
    'three locale catalogues stay structurally aligned and exclude Heroes',
    () async {
      final zh = await NarrativeCatalog.load(const Locale('zh'));
      final en = await NarrativeCatalog.load(const Locale('en'));
      final ru = await NarrativeCatalog.load(const Locale('ru'));

      for (final catalog in [zh, en, ru]) {
        expect(catalog.dialogues, hasLength(669));
        expect(
          catalog.dialogues.where((entry) => entry.selectable),
          hasLength(668),
        );
        expect(
          catalog.dialogues.any(
            (entry) =>
                entry.number.startsWith('4.7.') ||
                entry.groupId.startsWith('HEROES_EVENT_'),
          ),
          isFalse,
        );
        expect(
          catalog.forCategory(NarrativeCategory.mainWorlds),
          hasLength(302),
        );
        expect(
          catalog.forCategory(NarrativeCategory.memoryLane),
          hasLength(96),
        );
        expect(
          catalog.forCategory(NarrativeCategory.otherModes),
          hasLength(141),
        );
        expect(
          catalog.forCategory(NarrativeCategory.systemTutorials),
          hasLength(130),
        );
      }

      List<String> structure(NarrativeCatalog catalog) => catalog.dialogues
          .map(
            (entry) => [
              entry.value.runtimeType,
              entry.value,
              entry.groupId,
              entry.number,
              entry.category.name,
              entry.iconAsset,
              entry.selectable,
              for (final line in entry.lines)
                '${line.key}/${line.kind.name}/${line.npc}',
            ].join('|'),
          )
          .toList(growable: false);

      expect(structure(en), structure(zh));
      expect(structure(ru), structure(zh));
      expect(en.strings.keys, zh.strings.keys);
      expect(ru.strings.keys, zh.strings.keys);
      expect(zh.strings.keys, isNot(contains('peaWarningTitle')));
      expect(zh.strings.keys, isNot(contains('peaWarning')));
      expect(
        zh.dialogues.any((entry) => entry.number.startsWith('3.6.')),
        isTrue,
        reason: 'Memory Lane Season 32 is part of the complete safe catalogue.',
      );
    },
  );

  test('all PvP map and Evil Dave dialogue stays in the PvP block', () async {
    final catalogs = [
      await NarrativeCatalog.load(const Locale('zh')),
      await NarrativeCatalog.load(const Locale('en')),
      await NarrativeCatalog.load(const Locale('ru')),
    ];

    for (final catalog in catalogs) {
      final pvp = catalog.dialogues
          .where((entry) => entry.groupId.startsWith('MAP_PVP'))
          .toList();
      expect(pvp, hasLength(11));
      expect(pvp.map((entry) => entry.number), [
        for (var index = 15; index <= 25; index++) '5.2.$index',
      ]);
      expect(
        pvp.every(
          (entry) =>
              entry.category == NarrativeCategory.otherModes &&
              entry.iconAsset.endsWith('/Mode_PvP.webp'),
        ),
        isTrue,
      );
      final indexes = pvp
          .map((entry) => catalog.dialogues.indexOf(entry))
          .toList();
      expect(indexes, [
        for (var index = indexes.first; index <= indexes.last; index++) index,
      ]);
    }

    expect(
      catalogs[0].dialogues
          .singleWhere(
            (entry) => entry.groupId == 'MAP_PVPEVILDAVID_START_INTRO',
          )
          .title,
      startsWith('对战模式 - '),
    );
  });

  test('related system tutorials remain in gameplay order', () async {
    const powerGestures = ['PINCH', 'FLICK', 'WIZARDFINGER'];
    const plantPuzzle = [
      'ELIMINATE_BLOCK_INTRO',
      'ELIMINATE_COLOR_INTRO',
      'ELIMINATE_INTRO',
      'ZOMBIE_INTRO_ELIMINATE_MISSIONFINISH',
      'ZOMBIE_INTRO_ELIMINATE_FREEZINGWIND',
      'ZOMBIE_INTRO_ELIMINATE_SPAWNSHIELD',
      'ZOMBIE_INTRO_ELIMINATE_STAGE11',
      'ZOMBIE_INTRO_ELIMINATE_STAGE12',
      'ZOMBIE_INTRO_ELIMINATE_STAGE21',
      'ZOMBIE_INTRO_ELIMINATE_STAGE22',
      'ZOMBIE_INTRO_ELIMINATE_STAGE31',
      'ZOMBIE_INTRO_ELIMINATE_STAGE32',
      'ZOMBIE_INTRO_ELIMINATE_STAGE41',
      'ZOMBIE_INTRO_ELIMINATE_STAGE42',
    ];

    for (final locale in const [Locale('zh'), Locale('en'), Locale('ru')]) {
      final catalog = await NarrativeCatalog.load(locale);
      final ids = catalog
          .entriesForSection(NarrativeSectionId.systemTutorials)
          .map((entry) => entry.groupId)
          .toList(growable: false);

      void expectConsecutive(List<String> expected) {
        final start = ids.indexOf(expected.first);
        expect(start, isNonNegative);
        expect(ids.sublist(start, start + expected.length), expected);
      }

      expectConsecutive(powerGestures);
      expectConsecutive(plantPuzzle);
    }
  });

  test('Russian catalogue has no substantive English fallbacks', () async {
    final en = await NarrativeCatalog.load(const Locale('en'));
    final ru = await NarrativeCatalog.load(const Locale('ru'));
    final untranslated = <String>[];

    for (
      var dialogueIndex = 0;
      dialogueIndex < en.dialogues.length;
      dialogueIndex += 1
    ) {
      final enDialogue = en.dialogues[dialogueIndex];
      final ruDialogue = ru.dialogues[dialogueIndex];
      if (enDialogue.title == ruDialogue.title) {
        untranslated.add('${enDialogue.groupId}: ${enDialogue.title}');
      }
      for (
        var lineIndex = 0;
        lineIndex < enDialogue.lines.length;
        lineIndex += 1
      ) {
        final enLine = enDialogue.lines[lineIndex];
        final ruLine = ruDialogue.lines[lineIndex];
        if (RegExp('[A-Za-z]').hasMatch(enLine.text) &&
            enLine.text == ruLine.text) {
          untranslated.add(
            '${enDialogue.groupId}/${enLine.key}: ${enLine.text}',
          );
        }
      }
    }

    expect(untranslated, isEmpty, reason: untranslated.join('\n'));
  });

  test(
    'invocation values retain their JSON types and unsafe start is disabled',
    () async {
      final catalog = await NarrativeCatalog.load(const Locale('en'));

      expect(catalog.findByValue(4000)?.value, isA<int>());
      expect(catalog.findByValue(1000450)?.value, isA<int>());
      expect(
        catalog.findByValue('FRESHINTRO_COLLECT_INTRO')?.value,
        isA<String>(),
      );
      expect(
        catalog.dialogues
            .singleWhere((entry) => entry.groupId == 'EGYPT_STAR_INTRO_OLD')
            .selectable,
        isFalse,
      );
    },
  );

  test('all generated mode and NPC image references exist', () async {
    final catalog = await NarrativeCatalog.load(const Locale('en'));
    final missing = <String>{};
    for (final entry in catalog.dialogues) {
      if (!File(entry.iconAsset).existsSync()) missing.add(entry.iconAsset);
      for (final npc in entry.characters) {
        final path = 'assets/images/npcs/npc_$npc.webp';
        if (!File(path).existsSync()) missing.add(path);
      }
    }
    expect(missing, isEmpty);
  });

  test(
    'manual original-text notes are present in all six English lines',
    () async {
      final catalog = await NarrativeCatalog.load(const Locale('en'));
      final notes = catalog.dialogues
          .expand((entry) => entry.lines)
          .where((line) => line.text.contains('Note: as in the original.'))
          .toList();
      expect(notes, hasLength(6));
      expect(
        notes.every((line) => line.kind == NarrativeLineKind.system),
        isTrue,
      );
    },
  );

  test(
    'search keeps title, content, and character matches separated',
    () async {
      final catalog = await NarrativeCatalog.load(const Locale('zh'));

      final title = searchNarratives(catalog, NarrativeCategory.all, '神秘埃及');
      expect(title.byTitle, isNotEmpty);

      final content = searchNarratives(catalog, NarrativeCategory.all, '脑子');
      expect(content.byContent, isNotEmpty);

      final speaker = searchNarratives(catalog, NarrativeCategory.all, '疯狂戴夫');
      expect(speaker.bySpeaker, isNotEmpty);

      final outlineNumber = searchNarratives(
        catalog,
        NarrativeCategory.all,
        '1.6.9',
      );
      expect(outlineNumber.isEmpty, isTrue);
    },
  );

  test('Penny variants are right-aligned and Dave variants stay left', () {
    expect(NarrativeLineView.isRightAlignedNpc('winnie'), isTrue);
    expect(NarrativeLineView.isRightAlignedNpc('winnieicon'), isTrue);
    expect(NarrativeLineView.isRightAlignedNpc('specialwinnie'), isTrue);
    expect(NarrativeLineView.isRightAlignedNpc('crazydave'), isFalse);
    expect(NarrativeLineView.isRightAlignedNpc('crazydaveicon'), isFalse);
    expect(NarrativeLineView.isRightAlignedNpc('zombossicon'), isFalse);
  });
}
