import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/tabs/level_settings_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('only parameter modules with editors respond to taps', (
    tester,
  ) async {
    const scoringRtid = 'RTID(LevelScoring@CurrentLevel)';
    const zombossRtid = 'RTID(ZombossBattle@CurrentLevel)';
    final edited = <String>[];
    final levelDef = LevelDefinitionData(
      modules: const [scoringRtid, zombossRtid],
    );
    final objects = <String, PvzObject>{
      'LevelScoring': PvzObject(
        aliases: ['LevelScoring'],
        objClass: 'LevelScoringModuleProperties',
        objData: <String, dynamic>{},
      ),
      'ZombossBattle': PvzObject(
        aliases: ['ZombossBattle'],
        objClass: 'ZombossBattleModuleProperties',
        objData: <String, dynamic>{},
      ),
    };

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: LevelSettingsTab(
            levelDef: levelDef,
            objectMap: objects,
            missingModules: const [],
            onEditBasicInfo: () {},
            onEditModule: edited.add,
            onRemoveModule: (_) {},
            onReorderModules:
                ({
                  required isCoreSection,
                  required oldIndex,
                  required newIndex,
                }) {},
            onNavigateToAddModule: () {},
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Scoring Module (LevelScoring)'));
    await tester.pump();
    expect(edited, isEmpty);

    await tester.tap(find.text('Zomboss Mech Battle (ZombossBattle)'));
    await tester.pump();
    expect(edited, [zombossRtid]);
    expect(find.byIcon(Icons.smart_toy_outlined), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
