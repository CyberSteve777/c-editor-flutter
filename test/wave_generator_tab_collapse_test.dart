import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/tabs/wave_generator_tab.dart';
import 'package:c_editor/widgets/wave_generator_zombie_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    'fixed and random zombie previews collapse to two rows independently',
    (tester) async {
      tester.view.physicalSize = const Size(600, 1100);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final generator = WaveGeneratorPropertiesData(
        waveSpendingPoints: 100,
        addToZombiePool: [
          for (var i = 0; i < 20; i++)
            WaveGeneratorPoolEntryData(type: 'random_$i'),
        ],
        waves: [
          WaveGeneratorWaveData(
            disableRandomSpawns: false,
            zombies: [
              for (var i = 0; i < 20; i++)
                WaveGeneratorZombieEntryData(
                  type: 'fixed_$i',
                  row: '${i % 5 + 1}',
                ),
            ],
          ),
        ],
      );
      final generatorObject = PvzObject(
        aliases: const ['WaveGenerator'],
        objClass: 'WaveGeneratorProperties',
        objData: generator.toJson(),
      );
      final levelFile = PvzLevelFile(objects: [generatorObject]);

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: WaveGeneratorTab(
              levelFile: levelFile,
              parsed: ParsedLevelData(
                objectMap: {'WaveGenerator': generatorObject},
              ),
              onChanged: () {},
              onEditWave: (_) {},
            ),
          ),
        ),
      );
      await tester.pump();

      Finder fixedIcons() => find.byWidgetPredicate(
        (widget) =>
            widget is WaveGeneratorZombieIconChip && widget.rowLabel != null,
      );
      Finder randomIcons() => find.byWidgetPredicate(
        (widget) =>
            widget is WaveGeneratorZombieIconChip && widget.sourceBadge != null,
      );
      int visibleRows(Finder finder) => finder
          .evaluate()
          .map(
            (element) => (element.renderObject! as RenderBox)
                .localToGlobal(Offset.zero)
                .dy
                .round(),
          )
          .toSet()
          .length;

      expect(fixedIcons(), findsWidgets);
      expect(randomIcons(), findsWidgets);
      expect(fixedIcons().evaluate().length, lessThan(20));
      expect(randomIcons().evaluate().length, lessThan(20));
      expect(visibleRows(fixedIcons()), lessThanOrEqualTo(2));
      expect(visibleRows(randomIcons()), lessThanOrEqualTo(2));

      final randomPoolLabel = find.text('Current random-spawn pool');
      final waveCard = find
          .ancestor(of: randomPoolLabel, matching: find.byType(Card))
          .first;
      expect(
        tester.getBottomRight(randomPoolLabel).dy,
        lessThan(tester.getBottomRight(waveCard).dy),
      );

      final expandButtons = find.descendant(
        of: waveCard,
        matching: find.byIcon(Icons.expand_more),
      );
      expect(expandButtons, findsNWidgets(2));
      await tester.tap(expandButtons.first);
      await tester.pump();

      expect(visibleRows(fixedIcons()), greaterThan(2));
      expect(visibleRows(randomIcons()), lessThanOrEqualTo(2));
      expect(
        find.descendant(of: waveCard, matching: find.byIcon(Icons.expand_less)),
        findsOneWidget,
      );
      expect(
        find.descendant(of: waveCard, matching: find.byIcon(Icons.expand_more)),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('zombie pool tile reserves readable name width', (tester) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            final media = MediaQuery.of(context);
            return MediaQuery(
              data: media.copyWith(textScaler: const TextScaler.linear(1.6)),
              child: Scaffold(
                body: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: WaveGeneratorZombieTile(
                      key: const ValueKey('responsiveZombiePoolTile'),
                      style: WaveGeneratorZombieTileStyle.poolCompact,
                      localizedName: '周年庆飞行器僵尸',
                      codename: 'anniversary_flying_zombie',
                      iconPath: null,
                      onDelete: () {},
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tile = find.byKey(const ValueKey('responsiveZombiePoolTile'));
    final name = find.text('周年庆飞行器僵尸');
    expect(tester.getSize(tile).width, greaterThanOrEqualTo(220));
    expect(tester.getSize(name).width, greaterThan(80));
    expect(tester.widget<Text>(name).maxLines, 2);
    expect(tester.takeException(), isNull);
  });

  testWidgets('zombie pool tile keeps delete action at the trailing edge', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Align(
            alignment: Alignment.topLeft,
            child: WaveGeneratorZombieTile(
              key: const ValueKey('shortNameZombiePoolTile'),
              style: WaveGeneratorZombieTileStyle.poolCompact,
              localizedName: 'Future zombie',
              codename: 'future',
              iconPath: null,
              onDelete: () {},
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final tileRect = tester.getRect(
      find.byKey(const ValueKey('shortNameZombiePoolTile')),
    );
    final deleteCenter = tester.getCenter(find.byIcon(Icons.close));
    expect(tileRect.right - deleteCenter.dx, lessThan(28));
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'horizontal zombie tile keeps delete action at the trailing edge',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topLeft,
              child: WaveGeneratorZombieTile(
                key: const ValueKey('horizontalShortNameZombieTile'),
                localizedName: 'Future zombie',
                codename: 'future',
                iconPath: null,
                onDelete: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final tileRect = tester.getRect(
        find.byKey(const ValueKey('horizontalShortNameZombieTile')),
      );
      final deleteCenter = tester.getCenter(find.byIcon(Icons.close));
      expect(tileRect.right - deleteCenter.dx, lessThan(32));
      expect(tester.takeException(), isNull);
    },
  );
}
