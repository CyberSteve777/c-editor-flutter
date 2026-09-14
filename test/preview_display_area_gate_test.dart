import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_generator_screen.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/widgets/app_ui_scale.dart';
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

Future<void> _tapToolbarControl(WidgetTester tester, String key) async {
  final control = find.byKey(ValueKey(key));
  await tester.ensureVisible(control);
  await tester.pumpAndSettle();
  expect(control.hitTestable(), findsOneWidget);
  await tester.tap(control);
  await tester.pumpAndSettle();
}

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
  double? appUiScale,
  double devicePixelRatio = 1,
}) async {
  tester.view.devicePixelRatio = devicePixelRatio;
  tester.view.physicalSize = size * devicePixelRatio;
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
      builder: appUiScale == null
          ? null
          : (context, child) {
              final media = MediaQuery.of(context);
              final scale =
                  appUiScale * (media.size.shortestSide < 600 ? 0.85 : 1);
              final scaledSize = media.size / scale;
              return MediaQuery(
                data: media.copyWith(size: scaledSize),
                child: FittedBox(
                  fit: BoxFit.contain,
                  alignment: Alignment.topLeft,
                  child: SizedBox(
                    width: scaledSize.width,
                    height: scaledSize.height,
                    child: AppUiScale(scale: scale, child: child!),
                  ),
                ),
              );
            },
      home: parentWidth == null
          ? generator
          : Center(
              child: SizedBox(width: parentWidth, child: generator),
            ),
    ),
  );
  await tester.pump();
  final scale = appUiScale == null
      ? 1.0
      : appUiScale * (size.shortestSide < 600 ? 0.85 : 1);
  if (isPreviewGeneratorDisplayAreaAvailable(
    availableSize: Size(parentWidth ?? size.width / scale, size.height / scale),
    uiScale: scale,
    platform: platform,
  )) {
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
      size: const Size(400, 1000),
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
    await _tapToolbarControl(tester, 'previewToolbarAction-previewGenAddText');
    await _tapToolbarControl(tester, 'previewToolbarTool-select');
    expect(_canvas(tester).document.layers.length, initialLayerCount + 1);
    final editedLayer = document.layers.last;

    tester.view.physicalSize = const Size(400, 1000);
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

  for (final scenario in [
    (size: const Size(480, 240), platform: TargetPlatform.android, scale: 1.5),
    (size: const Size(430, 260), platform: TargetPlatform.iOS, scale: 1.0),
    (size: const Size(560, 620), platform: TargetPlatform.android, scale: 1.5),
    (size: const Size(700, 760), platform: TargetPlatform.android, scale: 1.5),
    (size: const Size(620, 800), platform: TargetPlatform.windows, scale: 1.5),
  ]) {
    testWidgets('scaled ${scenario.platform} ${scenario.size} remains usable', (
      tester,
    ) async {
      await _openGenerator(
        tester,
        size: scenario.size,
        platform: scenario.platform,
        appUiScale: scenario.scale,
        devicePixelRatio: 3,
      );
      expect(find.byType(PreviewCanvas), findsOneWidget);
      expect(find.text('previewGenDisplayTooNarrowTitle'), findsNothing);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('zooming UI out does not exempt a genuinely narrow desktop', (
    tester,
  ) async {
    await _openGenerator(
      tester,
      size: const Size(590, 800),
      platform: TargetPlatform.windows,
      appUiScale: 0.75,
    );
    _expectBlocked(tester, mobile: false);
  });

  testWidgets(
    'a narrow mobile split screen is blocked even when wide in shape',
    (tester) async {
      await _openGenerator(
        tester,
        size: const Size(350, 250),
        platform: TargetPlatform.android,
        appUiScale: 0.75,
      );
      _expectBlocked(tester, mobile: true);
    },
  );

  testWidgets(
    'unfolding across the app scale breakpoint keeps the same edits',
    (tester) async {
      await _openGenerator(
        tester,
        size: const Size(560, 620),
        platform: TargetPlatform.android,
        appUiScale: 1.5,
        devicePixelRatio: 3,
      );
      final state = tester.state(find.byType(PreviewGeneratorScreen));
      final document = _canvas(tester).document;
      final initialLayerCount = document.layers.length;
      await _tapToolbarControl(
        tester,
        'previewToolbarAction-previewGenAddText',
      );
      expect(document.layers.length, initialLayerCount + 1);
      final editedLayer = document.layers.last;
      tester.view.physicalSize = const Size(700, 760) * 3;
      await tester.pumpAndSettle();
      expect(find.byType(PreviewCanvas), findsOneWidget);
      expect(tester.state(find.byType(PreviewGeneratorScreen)), same(state));
      expect(_canvas(tester).document, same(document));
      expect(document.layerById(editedLayer.id), same(editedLayer));
      expect(tester.takeException(), isNull);
    },
  );

  test('web narrow windows do not receive a phone landscape exemption', () {
    expect(
      isPreviewGeneratorDisplayAreaAvailable(
        availableSize: const Size(500, 260),
        platform: TargetPlatform.android,
        isWeb: true,
      ),
      isFalse,
    );
  });

  test(
    'mobile budgets and minimum layout dimensions have explicit boundaries',
    () {
      for (final scenario in [
        (size: const Size(399.9, 200), allowed: false),
        (size: const Size(400, 200), allowed: true),
        (size: const Size(479.9, 900), allowed: false),
        (size: const Size(480, 900), allowed: true),
        (size: const Size(319.9, 200), allowed: false),
        (size: const Size(600, 159.9), allowed: false),
        (size: const Size(600, 160), allowed: true),
      ]) {
        expect(
          isPreviewGeneratorDisplayAreaAvailable(
            availableSize: scenario.size,
            platform: TargetPlatform.android,
          ),
          scenario.allowed,
          reason: '${scenario.size}',
        );
      }
      expect(
        isPreviewGeneratorDisplayAreaAvailable(
          availableSize: const Size(320, 160),
          platform: TargetPlatform.android,
          uiScale: 1.5,
        ),
        isTrue,
      );
    },
  );

  test('invalid dimensions or UI scales do not bypass the display guard', () {
    for (final scale in [0.0, -1.0, double.nan, double.infinity]) {
      expect(
        isPreviewGeneratorDisplayAreaAvailable(
          availableSize: const Size(1200, 900),
          platform: TargetPlatform.android,
          uiScale: scale,
        ),
        isFalse,
      );
    }
    for (final size in [
      const Size(double.nan, 900),
      const Size(double.infinity, 900),
      const Size(1200, double.infinity),
    ]) {
      expect(
        isPreviewGeneratorDisplayAreaAvailable(
          availableSize: size,
          platform: TargetPlatform.android,
        ),
        isFalse,
      );
    }
  });
}
