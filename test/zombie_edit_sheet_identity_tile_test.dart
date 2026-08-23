import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('zombie edit identity name wraps instead of truncating', (
    tester,
  ) async {
    const longName =
        'Memory-Frenzied Zombotany Commander with an Extremely Long Name';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: SizedBox(
              width: 280,
              child: ZombieEditSheetIdentityTile(
                iconPath: null,
                displayName: longName,
                isCustom: true,
                customLabel: 'Custom',
                onChange: () {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final name = tester.widget<Text>(find.text(longName));
    expect(name.softWrap, isTrue);
    expect(name.maxLines, isNull);
    expect(name.overflow, isNull);
    expect(tester.getSize(find.text(longName)).height, greaterThan(30));
    expect(tester.takeException(), isNull);
  });
}
