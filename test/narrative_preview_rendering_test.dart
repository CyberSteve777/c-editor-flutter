import 'package:c_editor/data/narrative_catalog.dart';
import 'package:c_editor/screens/select/narrative_preview_screen.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(NarrativeCatalog.clearCacheForTesting);

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
