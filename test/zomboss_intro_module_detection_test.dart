import 'package:c_editor/data/grid_override_module_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/editor/tabs/zomboss_mech_battle_tab.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

PvzObject _levelDefinition(String introAlias) {
  return PvzObject(
    aliases: const ['LevelDefinition'],
    objClass: 'LevelDefinition',
    objData: LevelDefinitionData(
      modules: ['RTID($introAlias@LevelModules)'],
    ).toJson(),
  );
}

PvzObject _battleModule() {
  return PvzObject(
    aliases: const ['ZombossBattle'],
    objClass: 'ZombossBattleModuleProperties',
    objData: ZombossMechBattleModuleData(
      zombossMechType: 'zombossmech_iceage',
    ).toJson(),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await ReferenceRepository.init();
    ZombossMechRepository.resetForTest();
    await ZombossMechRepository.init();
    await ResourceNames.ensureLoaded();
  });

  for (final alias in const [
    'ZombossIntro',
    'ZombossIntro5',
    'ZombossDangerRoomRenaiIntro',
    'EightiesZombossIntro',
  ]) {
    test('$alias is detected by its Zomboss battle intro objclass', () {
      final level = PvzLevelFile(objects: [_levelDefinition(alias)]);

      expect(levelHasModule(level, 'ZombossBattleIntroProperties'), isTrue);
    });
  }

  testWidgets('built-in ZombossIntro does not show the missing intro warning', (
    tester,
  ) async {
    final level = PvzLevelFile(
      objects: [_levelDefinition('ZombossIntro'), _battleModule()],
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(
          body: ZombossMechBattleTab(levelFile: level, onChanged: () {}),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('模块缺失警告'), findsNothing);
  });
}
