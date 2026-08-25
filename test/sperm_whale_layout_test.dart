import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor/modules/sperm_whale_module_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('whale warning and parameter labels match the actual layout', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(345, 1000);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('zh'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: SpermWhaleModuleScreen(
          rtid: 'RTID(SpermWhaleModule@CurrentLevel)',
          levelFile: PvzLevelFile(objects: []),
          onChanged: () {},
          onBack: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('以下网格'), findsNothing);
    expect(
      find.text(
        '推荐在海底世界地图中使用该模块；在非海底两万里/亚特兰蒂斯地图中使用时，可能会出现不兼容的情况。',
      ),
      findsOneWidget,
    );

    final labels = [
      find.text('吞噬间隔 (SwallowInterval，单位：秒)'),
      find.text('中毒时吞噬间隔 (PoisonSwallowInterval，单位：秒)'),
      find.text('吞噬持续时间 (SwallowDuration，单位：秒)'),
      find.text('中毒触发次数 (PoisonTriggerCount)'),
    ];
    final fontSizes = <double?>{};
    for (final label in labels) {
      expect(label, findsOneWidget);
      fontSizes.add(tester.widget<Text>(label).style?.fontSize);
    }
    expect(fontSizes, hasLength(1));

    final fields = tester
        .widgetList<TextField>(find.byType(TextField))
        .where((field) => field.decoration?.labelText == null);
    expect(fields, hasLength(4));
    expect(tester.takeException(), isNull);
  });
}
