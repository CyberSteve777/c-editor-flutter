import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _testApp({required List<String> plants}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: SizedBox(
        width: 320,
        child: SingleChildScrollView(
          child: WaveDropConfigCard(
            totalDropCount: plants.isEmpty ? 1 : plants.length,
            plants: plants,
            zombieCount: 3,
            onTotalDropCountChanged: (_) {},
            onRemovePlantAt: (_) {},
            onAddPlant: () {},
          ),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('drop card identifies Plant Food before a seed packet is added', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(plants: const []));
    await tester.pumpAndSettle();

    expect(find.text('Drop configuration (Plant Food)'), findsOneWidget);
    expect(
      find.text('Specified seed packet drops (SpawnPlantName)'),
      findsOneWidget,
    );
    expect(
      tester
          .widget<Icon>(find.byKey(const ValueKey('waveDropConfigTitleIcon')))
          .icon,
      Icons.local_florist,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('drop card switches its title after a seed packet is added', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(plants: const ['peashooter']));
    await tester.pumpAndSettle();

    expect(find.text('Drop configuration (seed packets)'), findsOneWidget);
    expect(find.text('Drop configuration (Plant Food)'), findsNothing);
    expect(
      find.byKey(const ValueKey('waveDropPlantSelectionLabel')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}
