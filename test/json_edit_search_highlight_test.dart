import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/json_viewer_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

PvzLevelFile _longLevel() {
  return PvzLevelFile(
    objects: List.generate(
      120,
      (index) => PvzObject(
        aliases: ['TestObject$index'],
        objClass: 'TestClass',
        objData: {
          'Index': index,
          'Value': 'A sufficiently long JSON value for scrolling $index',
        },
      ),
    ),
  );
}

Widget _jsonViewer(PvzLevelFile level) {
  return MaterialApp(
    theme: ThemeData(platform: TargetPlatform.windows),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: JsonViewerScreen(
      fileName: 'test.json',
      filePath: 'test.json',
      levelFile: level,
      onBack: () {},
      saveLevel: (_, _) async {},
    ),
  );
}

void main() {
  testWidgets('edit-mode search paints a visible match highlight', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['TestObject'],
          objClass: 'TestClass',
          objData: {'Value': 'before'},
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: JsonViewerScreen(
          fileName: 'test.json',
          filePath: 'test.json',
          levelFile: level,
          onBack: () {},
          saveLevel: (_, _) async {},
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.hintText == 'Search',
    );
    await tester.enterText(searchField, 'before');
    await tester.pump();

    final editorFinder = find.byWidgetPredicate(
      (widget) =>
          widget is TextField &&
          widget.controller?.text.contains('"before"') == true,
    );
    final editor = tester.widget<TextField>(editorFinder);
    final span = editor.controller!.buildTextSpan(
      context: tester.element(editorFinder),
      style: editor.style,
      withComposing: true,
    );
    final highlightedMatch = span.children!.whereType<TextSpan>().firstWhere(
      (child) => child.text == 'before',
    );

    expect(highlightedMatch.style?.backgroundColor, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('replacing a match does not append a trailing newline', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final level = PvzLevelFile(
      objects: [
        PvzObject(
          aliases: ['TestObject'],
          objClass: 'TestClass',
          objData: {'Value': 'before'},
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: JsonViewerScreen(
          fileName: 'test.json',
          filePath: 'test.json',
          levelFile: level,
          onBack: () {},
          saveLevel: (_, _) async {},
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    final searchField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.hintText == 'Search',
    );
    final replaceField = find.byWidgetPredicate(
      (widget) =>
          widget is TextField && widget.decoration?.hintText == 'Replace',
    );
    final originalEditor = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.controller?.text.contains('"before"') == true,
      ),
    );
    final originalNewlineCount = '\n'
        .allMatches(originalEditor.controller!.text)
        .length;

    await tester.enterText(searchField, 'before');
    await tester.enterText(replaceField, 'after');
    await tester.tap(find.byIcon(Icons.find_replace));
    await tester.pump();

    final updatedEditor = tester.widget<TextField>(
      find.byWidgetPredicate(
        (widget) =>
            widget is TextField &&
            widget.controller?.text.contains('"after"') == true,
      ),
    );
    final updatedText = updatedEditor.controller!.text;
    expect(updatedText.endsWith('\n'), isFalse);
    expect('\n'.allMatches(updatedText).length, originalNewlineCount);
    expect(tester.takeException(), isNull);
  });

  testWidgets('mouse clicks keep JSON scroll position with full Select all', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_jsonViewer(_longLevel()));
    await tester.pump();

    final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar).last);
    final scrollController = scrollbar.controller!;
    scrollController.jumpTo(900);
    await tester.pump();
    final beforePrimaryClick = scrollController.offset;
    final selectionArea = find.byType(SelectionArea).first;
    final selectionRect = tester.getRect(selectionArea);
    final viewportRect = tester.getRect(
      find.byType(SingleChildScrollView).last,
    );
    final visibleSelectionRect = selectionRect.intersect(viewportRect);
    final visiblePoint = visibleSelectionRect.topLeft + const Offset(80, 18);

    await tester.tapAt(visiblePoint);
    await tester.pumpAndSettle();

    expect(scrollController.offset, closeTo(beforePrimaryClick, 0.5));

    scrollController.jumpTo(1100);
    await tester.pump();
    final beforeSecondaryClick = scrollController.offset;
    await tester.tapAt(
      visiblePoint,
      kind: PointerDeviceKind.mouse,
      buttons: kSecondaryButton,
    );
    await tester.pumpAndSettle();

    expect(scrollController.offset, closeTo(beforeSecondaryClick, 0.5));
    expect(selectionArea, findsOneWidget);
    final selectAll = find.textContaining(
      RegExp('select all', caseSensitive: false),
    );
    expect(selectAll, findsOneWidget);

    await tester.tap(selectAll);
    await tester.pumpAndSettle();

    expect(scrollController.offset, closeTo(beforeSecondaryClick, 0.5));
    expect(tester.takeException(), isNull);
  });

  testWidgets('entering JSON edit mode keeps the reading scroll position', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(_jsonViewer(_longLevel()));
    await tester.pump();

    final scrollbar = tester.widget<Scrollbar>(find.byType(Scrollbar).last);
    final scrollController = scrollbar.controller!;
    scrollController.jumpTo(900);
    await tester.pump();
    final before = scrollController.offset;

    await tester.tap(find.byIcon(Icons.more_vert));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Edit'));
    await tester.pumpAndSettle();

    expect(scrollController.offset, closeTo(before, 0.5));
    expect(tester.takeException(), isNull);
  });
}
