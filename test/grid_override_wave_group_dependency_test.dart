import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/app_localizations_en.dart';
import 'package:c_editor/screens/editor/modules/armrack_module_screen.dart';
import 'package:c_editor/screens/editor/modules/energy_grid_module_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

enum _EditorKind { armrack, energyGrid }

PvzObject _moduleObject(_EditorKind kind) {
  return switch (kind) {
    _EditorKind.armrack => PvzObject(
      aliases: const ['Armrack'],
      objClass: 'ArmrackProperties',
      objData: const <String, dynamic>{
        'Overrides': [
          {'Wave': 1, 'ItemList': <dynamic>[]},
        ],
      },
    ),
    _EditorKind.energyGrid => PvzObject(
      aliases: const ['EnergyGrid'],
      objClass: 'EnergyGridProperties',
      objData: const <String, dynamic>{
        'Overrides': [
          {'Wave': 1, 'ItemList': <dynamic>[]},
        ],
      },
    ),
  };
}

Widget _screen(_EditorKind kind, PvzLevelFile level) {
  return switch (kind) {
    _EditorKind.armrack => ArmrackModuleScreen(
      rtid: 'RTID(Armrack@CurrentLevel)',
      levelFile: level,
      onChanged: () {},
      onBack: () {},
    ),
    _EditorKind.energyGrid => EnergyGridModuleScreen(
      rtid: 'RTID(EnergyGrid@CurrentLevel)',
      levelFile: level,
      onChanged: () {},
      onBack: () {},
    ),
  };
}

Widget _app(Widget home) {
  return MaterialApp(
    locale: const Locale('en'),
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: home,
  );
}

PvzObject _dependency(String objClass) => PvzObject(
  aliases: [objClass],
  objClass: objClass,
  objData: const <String, dynamic>{},
);

void main() {
  final l10n = AppLocalizationsEn();

  for (final kind in _EditorKind.values) {
    group('${kind.name} wave groups', () {
      testWidgets('blocks Group 2 without a Wave Generator', (tester) async {
        final module = _moduleObject(kind);
        final level = PvzLevelFile(objects: [module]);

        await tester.pumpWidget(_app(_screen(kind, level)));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('addGridOverrideWaveGroup')),
        );
        await tester.pumpAndSettle();

        expect(
          find.text(l10n.gridOverrideModuleWaveSpawnTimelineNote),
          findsOneWidget,
        );
        expect(find.text('Group 2'), findsNothing);
        expect((module.objData['Overrides'] as List), hasLength(1));
      });

      testWidgets('shows only the Wave Generator note with that system', (
        tester,
      ) async {
        final module = _moduleObject(kind);
        final level = PvzLevelFile(
          objects: [module, _dependency('WaveGeneratorProperties')],
        );

        await tester.pumpWidget(_app(_screen(kind, level)));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('addGridOverrideWaveGroup')),
        );
        await tester.pumpAndSettle();

        expect(find.text('Group 2'), findsWidgets);
        expect(
          find.text(l10n.gridOverrideModuleWaveSpawnNote(1)),
          findsOneWidget,
        );
        expect(
          find.text(l10n.gridOverrideModuleWaveSpawnTimelineNote),
          findsNothing,
        );
      });

      testWidgets('shows both notes when both wave systems are present', (
        tester,
      ) async {
        final module = _moduleObject(kind);
        final level = PvzLevelFile(
          objects: [
            module,
            _dependency('WaveGeneratorProperties'),
            _dependency('WaveManagerModuleProperties'),
          ],
        );

        await tester.pumpWidget(_app(_screen(kind, level)));
        await tester.pumpAndSettle();
        await tester.tap(
          find.byKey(const ValueKey('addGridOverrideWaveGroup')),
        );
        await tester.pumpAndSettle();

        expect(
          find.text(l10n.gridOverrideModuleWaveSpawnNote(1)),
          findsOneWidget,
        );
        expect(
          find.text(l10n.gridOverrideModuleWaveSpawnTimelineNote),
          findsOneWidget,
        );
      });
    });
  }
}
