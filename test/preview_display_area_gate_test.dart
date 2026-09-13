import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_generator_screen.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Host extends Fake implements CPluginHost {
  @override
  String localize(
    BuildContext context,
    String key, [
    String? fallback,
    Map<String, Object?>? args,
  ]) => fallback ?? key;
}

PreviewCanvas _canvas(WidgetTester tester) =>
    tester.widget<PreviewCanvas>(find.byType(PreviewCanvas));

Future<void> _waitForCanvas(WidgetTester tester) async {
  for (
    var attempt = 0;
    attempt < 200 && find.byType(PreviewCanvas).evaluate().isEmpty;
    attempt++
  ) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 25));
  }
  expect(find.byType(PreviewCanvas), findsOneWidget);
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull);
}

Future<void> _openGenerator(
  WidgetTester tester, {
  required Size size,
  required TargetPlatform platform,
  double? parentWidth,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  final generator = PreviewGeneratorScreen(
    host: _Host(),
    levelFile: PvzLevelFile(objects: []),
    parsed: ParsedLevelData(objectMap: {}),
    fileName: 'display-area.json',
  );
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: platform),
      home: parentWidth == null
          ? generator
          : Center(
              child: SizedBox(width: parentWidth, child: generator),
            ),
    ),
  );
  await tester.pump();
  if (isPreviewGeneratorWidthAvailable(parentWidth ?? size.width)) {
    await _waitForCanvas(tester);
  } else {
    await tester.pumpAndSettle();
  }
}

void _expectBlocked(WidgetTester tester, {required bool mobile}) {
  expect(find.byType(PreviewCanvas), findsNothing);
  expect(find.byKey(const ValueKey('previewToolbarTool-select')), findsNothing);
  expect(find.text('previewGenDisplayTooNarrowTitle'), findsOneWidget);
  expect(
    find.text(
      mobile
          ? 'previewGenDisplayTooNarrowMobileHint'
          : 'previewGenDisplayTooNarrowDesktopHint',
    ),
    findsOneWidget,
  );
  expect(
    find.byIcon(mobile ? Icons.screen_rotation : Icons.aspect_ratio),
    findsOneWidget,
  );
  expect(find.byIcon(Icons.save_alt), findsNothing);
  expect(tester.takeException(), isNull);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    rootBundle.clear();
  });

  testWidgets('wide native Android portrait display allows the generator', (
    tester,
  ) async {
    await _openGenerator(
      tester,
      size: const Size(700, 1000),
      platform: TargetPlatform.android,
    );
    expect(
      MediaQuery.orientationOf(
        tester.element(find.byType(PreviewGeneratorScreen)),
      ),
      Orientation.portrait,
    );
    expect(find.byType(PreviewCanvas), findsOneWidget);
    expect(find.text('previewGenDisplayTooNarrowTitle'), findsNothing);
    expect(find.byIcon(Icons.screen_rotation), findsNothing);
    expect(
      find.byKey(const ValueKey('previewToolbarTool-select')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('unfolding restores the same generator and preserves its edits', (
    tester,
  ) async {
    await _openGenerator(
      tester,
      size: const Size(500, 1000),
      platform: TargetPlatform.android,
    );
    _expectBlocked(tester, mobile: true);
    final generatorState = tester.state(find.byType(PreviewGeneratorScreen));

    tester.view.physicalSize = const Size(700, 1000);
    await tester.pump();
    await _waitForCanvas(tester);
    expect(
      tester.state(find.byType(PreviewGeneratorScreen)),
      same(generatorState),
    );
    final document = _canvas(tester).document;
    final initialLayerCount = document.layers.length;
    await tester.tap(
      find.byKey(const ValueKey('previewToolbarAction-previewGenAddText')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('previewToolbarTool-select')));
    await tester.pumpAndSettle();
    expect(_canvas(tester).document.layers.length, initialLayerCount + 1);
    final editedLayer = document.layers.last;

    tester.view.physicalSize = const Size(500, 1000);
    await tester.pumpAndSettle();
    _expectBlocked(tester, mobile: true);
    expect(
      tester.state(find.byType(PreviewGeneratorScreen)),
      same(generatorState),
    );
    tester.view.physicalSize = const Size(700, 1000);
    await tester.pumpAndSettle();
    expect(
      tester.state(find.byType(PreviewGeneratorScreen)),
      same(generatorState),
    );
    expect(_canvas(tester).document, same(document));
    expect(_canvas(tester).document.layers.length, initialLayerCount + 1);
    expect(
      _canvas(tester).document.layerById(editedLayer.id),
      same(editedLayer),
    );
    expect(find.text('previewGenDisplayTooNarrowTitle'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('narrow desktop window remains blocked independently of device', (
    tester,
  ) async {
    await _openGenerator(
      tester,
      size: const Size(590, 900),
      platform: TargetPlatform.windows,
    );
    _expectBlocked(tester, mobile: false);
  });

  testWidgets('large screen does not bypass a narrow parent display area', (
    tester,
  ) async {
    await _openGenerator(
      tester,
      size: const Size(1200, 900),
      platform: TargetPlatform.windows,
      parentWidth: 550,
    );
    expect(
      MediaQuery.sizeOf(
        tester.element(find.byType(PreviewGeneratorScreen)),
      ).width,
      1200,
    );
    expect(tester.getSize(find.byType(PreviewGeneratorScreen)).width, 550);
    _expectBlocked(tester, mobile: false);
  });
}
