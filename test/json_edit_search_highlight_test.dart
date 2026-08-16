import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/json_viewer_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}
