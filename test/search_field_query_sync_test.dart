import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('shared search fields display restored query values', (
    tester,
  ) async {
    var query = 'remembered search';
    late StateSetter rebuild;

    await tester.pumpWidget(
      MaterialApp(
        home: StatefulBuilder(
          builder: (context, setState) {
            rebuild = setState;
            return Scaffold(
              appBar: AppBar(
                title: AppBarSearchField(
                  hintText: 'Search',
                  query: query,
                  onChanged: (_) {},
                ),
              ),
              body: SelectionSearchField(
                hintText: 'Search',
                query: query,
                onChanged: (_) {},
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      tester
          .widgetList<EditableText>(find.byType(EditableText))
          .map((editable) => editable.controller.text),
      everyElement('remembered search'),
    );

    rebuild(() => query = 'updated search');
    await tester.pump();

    expect(
      tester
          .widgetList<EditableText>(find.byType(EditableText))
          .map((editable) => editable.controller.text),
      everyElement('updated search'),
    );
  });
}
