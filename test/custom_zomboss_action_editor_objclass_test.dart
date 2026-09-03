import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/others/custom_zomboss_mech_action_editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _catalog = ZombossMechCatalogEntry(
  id: 'EditPropsMech',
  icon: 'unknown.webp',
  defaultPhaseCount: 1,
  variations: [],
  editableInstance: 'edit_props_mech',
  editableInstancePropsName: 'EditPropsMechProps',
  actions: [
    ZombossMechObjclassGroup(
      objclass: 'FirstActionDefinition',
      tag: 'attack',
      fields: [
        ZombossMechFieldSpec(
          name: 'FirstOnlyField',
          type: 'int',
          defaultValue: 1,
        ),
      ],
      implementations: {
        'FirstAction': {'FirstOnlyField': 1, 'Weight': 10},
      },
    ),
    ZombossMechObjclassGroup(
      objclass: 'SecondActionDefinition',
      tag: 'spawn',
      fields: [
        ZombossMechFieldSpec(
          name: 'SecondOnlyField',
          type: 'int',
          defaultValue: 2,
        ),
      ],
      implementations: {
        'SecondAction': {'SecondOnlyField': 42, 'Weight': 5},
      },
    ),
  ],
  properties: [],
);

void main() {
  testWidgets(
    'editing a custom action shows fields for its level objclass, not the first catalog action',
    (tester) async {
      final action = PvzObject(
        aliases: const ['MySecondCustom'],
        objClass: 'SecondActionDefinition',
        objData: const <String, dynamic>{'SecondOnlyField': 99, 'Weight': 7},
      );
      final level = PvzLevelFile(objects: [action]);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push<void>(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomZombossMechActionEditorScreen(
                    catalog: _catalog,
                    levelFile: level,
                    existingRtid: 'RTID(MySecondCustom@CurrentLevel)',
                  ),
                ),
              ),
              child: const Text('Open existing editor'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open existing editor'));
      await tester.pumpAndSettle();

      // Locked type section shows the level object's objclass (title + raw id).
      expect(find.text('SecondActionDefinition'), findsWidgets);
      expect(find.text('FirstActionDefinition'), findsNothing);
      // Edit mode must not use the create-time "Base Action" picker fallback.
      expect(find.text('Base Action'), findsNothing);
      expect(find.text('Recreate from template'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'creating a custom action seeds from the selected base-action template',
    (tester) async {
      final level = PvzLevelFile(objects: []);

      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push<String?>(
                context,
                MaterialPageRoute(
                  builder: (_) => CustomZombossMechActionEditorScreen(
                    catalog: _catalog,
                    levelFile: level,
                  ),
                ),
              ),
              child: const Text('Open create editor'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open create editor'));
      await tester.pumpAndSettle();

      expect(find.text('Base Action'), findsOneWidget);
      expect(find.text('Recreate from template'), findsNothing);

      await tester.tap(find.text('Base Action'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('SecondAction').last);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.save));
      await tester.pumpAndSettle();

      expect(level.objects, hasLength(1));
      expect(level.objects.single.objClass, 'SecondActionDefinition');
      expect(
        level.objects.single.objData,
        containsPair('SecondOnlyField', 42),
      );
      expect(level.objects.single.objData, isNot(contains('FirstOnlyField')));
      expect(tester.takeException(), isNull);
    },
  );
}
