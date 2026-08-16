import 'package:c_editor/data/models/zomboss_mech_catalog.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/others/custom_zomboss_mech_properties_screen.dart';
import 'package:c_editor/screens/editor/others/zomboss_battle_base_selection_screen.dart';
import 'package:c_editor/screens/editor/others/zomboss_mech_base_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _localizedApp(Widget home) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: home,
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    ZombossMechRepository.resetForTest();
    await ZombossMechRepository.init();
    await ZombossBattleRepository.init();
  });

  testWidgets('base mech selection help uses zombossMechBaseHint', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        ZombossMechBaseSelectionScreen(
          selectedBaseId: ZombossMechRepository.allZombossMechs.first.id,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    expect(
      find.descendant(
        of: dialog,
        matching: find.textContaining(
          'Zombots built and piloted by Dr. Zomboss himself',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('base Zomboss selection help uses zombossBattleBaseHint', (
    tester,
  ) async {
    await tester.pumpWidget(
      _localizedApp(
        ZombossBattleBaseSelectionScreen(
          selectedBaseId: ZombossBattleRepository.allZombosses.first.id,
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(dialog, findsOneWidget);
    expect(
      find.descendant(
        of: dialog,
        matching: find.textContaining(
          'Zombie bosses who hold sway in a world or realm',
        ),
      ),
      findsOneWidget,
    );
  });

  testWidgets('custom mech help gives phases its own section title', (
    tester,
  ) async {
    const catalog = ZombossMechCatalogEntry(
      id: 'HelpTestMech',
      icon: 'unknown.webp',
      defaultPhaseCount: 1,
      variations: [],
      editableInstance: 'help_test_mech',
      editableInstancePropsName: 'HelpTestProps',
      actions: [],
      properties: [
        ZombossMechObjclassGroup(
          objclass: 'HelpTestProperties',
          fields: [],
          implementations: {
            'HelpTestProps': {
              'Stages': [
                {'Actions': <String>[], 'HitPoints': 1000},
              ],
            },
          },
        ),
      ],
    );

    await tester.pumpWidget(
      _localizedApp(
        CustomZombossMechPropertiesScreen(
          catalog: catalog,
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pump();
    await tester.tap(find.byIcon(Icons.help_outline));
    await tester.pumpAndSettle();

    final dialog = find.byType(AlertDialog);
    expect(
      find.descendant(of: dialog, matching: find.text('• Phase contents')),
      findsOneWidget,
    );
    expect(
      find.descendant(of: dialog, matching: find.text('Battle phases')),
      findsNothing,
    );
  });
}
