import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/stage_resource_group_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(ResourceNames.ensureLoaded);

  testWidgets(
    'unknown resource group localization keys fall back to codename',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StageResourceGroupListTile(
              group: 'Modern_Gravestone',
              reorderIndex: 0,
              onRemove: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('resourceGroup_Modern_Gravestone'), findsNothing);
      expect(find.text('Modern_Gravestone'), findsNWidgets(2));
    },
  );
}
