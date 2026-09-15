import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/plant_selection_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    SharedPreferences.setMockInitialValues({});
    await Future.wait([ResourceNames.ensureLoaded(), PlantRepository().init()]);
  });

  test('new hidden plant names are localized in every resource locale', () {
    const expected = {
      'en': {
        'plant_carrotmissile': 'Plant Food Carrotillery Missile',
        'plant_smallcactus': 'Mini Cactus Ball',
        'plant_magicbeans': 'Magic Beanstalk',
      },
      'zh': {
        'plant_carrotmissile': '大招胡萝卜导弹',
        'plant_smallcactus': '小仙人球',
        'plant_magicbeans': '魔法豆藤',
      },
      'ru': {
        'plant_carrotmissile': 'Ракета Морковортиллерии с Подкормкой',
        'plant_smallcactus': 'Мини-Шар Кактуса',
        'plant_magicbeans': 'Волшебный Бобовый Стебель',
      },
    };

    for (final locale in expected.entries) {
      for (final name in locale.value.entries) {
        expect(
          ResourceNames.lookupWithLocale(locale.key, name.key),
          name.value,
        );
      }
    }
  });

  testWidgets('tapping an already-selected plant icon deselects it', (
    tester,
  ) async {
    var confirmed = <String>[];
    await tester.pumpWidget(
      _localizedApp(
        PlantSelectionScreen(
          isMultiSelect: true,
          allowDuplicateSelection: true,
          onPlantSelected: (_) {},
          onMultiPlantSelected: (ids) => confirmed = ids,
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'peashooter');
    await tester.pumpAndSettle();
    final icon = find.byKey(const ValueKey('plantSelectionIcon-peashooter'));
    expect(icon, findsOneWidget);

    await tester.tap(icon);
    await tester.pump();
    await tester.tap(find.byType(FloatingActionButton));
    expect(confirmed, ['peashooter']);

    await tester.tap(icon);
    await tester.pump();
    await tester.tap(find.byType(FloatingActionButton));
    expect(confirmed, isEmpty);
  });
}
