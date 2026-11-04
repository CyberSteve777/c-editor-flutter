import 'dart:ui' as ui;

import 'package:c_editor/data/narrative_catalog.dart';
import 'package:c_editor/screens/select/narrative_preview_screen.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(NarrativeCatalog.clearCacheForTesting);

  testWidgets('the brilliant Dave line strikes only crazy and hides markers', (
    tester,
  ) async {
    final catalog = await NarrativeCatalog.load(const Locale('en'));
    final line = catalog.dialogues
        .expand((entry) => entry.lines)
        .singleWhere(
          (line) =>
              line.key == 'NARRATIVE_TRANS_GENOSIS_OPEN_TUTORIAL_2' &&
              line.kind == NarrativeLineKind.speech,
        );
    expect(line.text, contains('~~crazy~~'));
    await tester.pumpWidget(_lineApp(line, localeCode: 'en'));
    final body = tester.widget<Text>(
      find.text(
        'I, the crazy brilliant Dave, have discovered that you can use the puzzle pieces you already have to obtain new and different ones.',
      ),
    );
    expect(find.text(line.text), findsNothing);
    final struckWords = <String>[];
    body.textSpan!.visitChildren((span) {
      if (span.style?.decoration == TextDecoration.lineThrough) {
        struckWords.add(span.toPlainText());
      }
      return true;
    });
    expect(struckWords, ['crazy']);
    expect(body.style?.decoration, isNot(TextDecoration.lineThrough));
    expect(tester.takeException(), isNull);
  });

  testWidgets('unmatched dialogue tildes remain ordinary punctuation', (
    tester,
  ) async {
    const line = NarrativeLine(
      key: 'FAREWELL',
      kind: NarrativeLineKind.speech,
      text: '僵尸博士迟早会再次出现！再见~~！',
      speaker: '疯狂戴夫',
      npc: 'crazydave',
    );
    await tester.pumpWidget(_lineApp(line, localeCode: 'zh'));
    final text = tester.widget<Text>(find.text(line.text));
    expect(text.data, line.text);
    expect(text.textSpan, isNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('stage directions are italic in both Chinese and English', (
    tester,
  ) async {
    const line = NarrativeLine(
      key: 'STAGE_DIRECTION',
      kind: NarrativeLineKind.stage,
      text: '（疯狂戴夫登场。）',
    );

    await tester.pumpWidget(_lineApp(line, localeCode: 'zh'));
    var text = tester.widget<Text>(find.text('（疯狂戴夫登场。）'));
    expect(text.style?.fontStyle, FontStyle.italic);

    await tester.pumpWidget(_lineApp(line, localeCode: 'en'));
    text = tester.widget<Text>(find.text('（疯狂戴夫登场。）'));
    expect(text.style?.fontStyle, FontStyle.italic);
  });

  testWidgets('literal backslash-n in dialogue renders as a line break', (
    tester,
  ) async {
    const line = NarrativeLine(
      key: 'LINE_BREAK',
      kind: NarrativeLineKind.speech,
      text: r'第一行\n第二行',
      speaker: '疯狂戴夫',
      npc: 'crazydave',
    );

    await tester.pumpWidget(_lineApp(line, localeCode: 'zh'));

    expect(find.text('第一行\n第二行'), findsOneWidget);
    expect(find.text(r'第一行\n第二行'), findsNothing);
  });

  testWidgets(
    'NPC portraits keep their full artwork and existing avatar column',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      for (final npc in ['zombossicon', 'crazydave', 'winnie']) {
        final sourceSize = await tester.runAsync(() async {
          final bytes = await rootBundle.load(
            'assets/images/npcs/npc_$npc.webp',
          );
          final codec = await ui.instantiateImageCodec(
            bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes),
          );
          final frame = await codec.getNextFrame();
          final size = Size(
            frame.image.width.toDouble(),
            frame.image.height.toDouble(),
          );
          frame.image.dispose();
          codec.dispose();
          return size;
        });
        expect(sourceSize!.height, greaterThan(sourceSize.width));

        for (final width in [320.0, 900.0]) {
          tester.view.physicalSize = Size(width, 700);
          final line = NarrativeLine(
            key: 'PORTRAIT_$npc',
            kind: NarrativeLineKind.speech,
            text: 'A dialogue line that can wrap onto multiple lines.',
            speaker: npc,
            npc: npc,
          );
          await tester.pumpWidget(_lineApp(line, localeCode: 'en'));
          await tester.pumpAndSettle();

          final portrait = find.byKey(ValueKey('npc-avatar-$npc'));
          final image = tester.widget<AssetImageWidget>(portrait);
          final imageSize = tester.getSize(portrait);
          expect(imageSize, const Size(72, 72));
          expect(
            applyBoxFit(image.fit, sourceSize, imageSize).source,
            sourceSize,
          );
          expect(
            find.ancestor(of: portrait, matching: find.byType(ClipRRect)),
            findsNothing,
          );
          final text = tester.getRect(find.text(line.text));
          final avatar = tester.getRect(portrait);
          if (npc == 'winnie') {
            expect(text.right, lessThanOrEqualTo(avatar.left - 12));
          } else {
            expect(text.left, greaterThanOrEqualTo(avatar.right + 12));
          }
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets('operation prompts are omitted from the preview', (tester) async {
    final catalog = await NarrativeCatalog.load(const Locale('zh'));
    const dialogue = NarrativeEntry(
      value: 'SYNTHETIC_OPERATION_HINT',
      id: 'SYNTHETIC_OPERATION_HINT',
      groupId: 'SYNTHETIC_OPERATION_HINT',
      number: '',
      category: NarrativeCategory.systemTutorials,
      iconAsset: 'assets/images/round_icons/Mode_Tutorial.webp',
      title: '过滤测试',
      characters: [],
      lines: [
        NarrativeLine(
          key: 'OPERATION_HINT',
          kind: NarrativeLineKind.system,
          text: '【操作提示】把豌豆射手拖至目标地块上',
        ),
        NarrativeLine(
          key: 'VISIBLE_LINE',
          kind: NarrativeLineKind.system,
          text: '这行应该保留。',
        ),
      ],
      selectable: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NarrativePreviewScreen(catalog: catalog, dialogue: dialogue),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('操作提示'), findsNothing);
    expect(find.textContaining('把豌豆射手拖至目标地块上'), findsNothing);
    expect(find.text('这行应该保留。'), findsOneWidget);
  });

  testWidgets('preview header uses the section icon', (tester) async {
    final catalog = await NarrativeCatalog.load(const Locale('zh'));
    final dialogue = catalog.dialogues.singleWhere(
      (entry) => entry.groupId == 'TUTORIAL_CARD_GAME_INTRO',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NarrativePreviewScreen(catalog: catalog, dialogue: dialogue),
      ),
    );
    await tester.pump();

    final headerImage = tester.widget<AssetImageWidget>(
      find.byType(AssetImageWidget).first,
    );
    expect(headerImage.assetPath, catalog.displayIcon(dialogue));
  });

  testWidgets('Memory Lane preview header preserves the full icon bounds', (
    tester,
  ) async {
    final catalog = await NarrativeCatalog.load(const Locale('zh'));
    final dialogue = catalog
        .entriesForSection(NarrativeSectionId.memorySeason27)
        .first;

    await tester.pumpWidget(
      MaterialApp(
        home: NarrativePreviewScreen(catalog: catalog, dialogue: dialogue),
      ),
    );
    await tester.pump();

    final headerFinder = find.byType(AssetImageWidget).first;
    final headerImage = tester.widget<AssetImageWidget>(headerFinder);
    expect(headerImage.fit, BoxFit.contain);
    expect(
      find.ancestor(of: headerFinder, matching: find.byType(ClipRRect)),
      findsNothing,
    );
  });
}

Widget _lineApp(NarrativeLine line, {required String localeCode}) {
  return MaterialApp(
    home: Scaffold(
      body: NarrativeLineView(line: line, localeCode: localeCode),
    ),
  );
}
