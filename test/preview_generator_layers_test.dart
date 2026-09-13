import 'dart:convert';
import 'dart:io';

import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_fonts.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_generator_screen.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_toolbar_action.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

late Map<String, Map<String, dynamic>> _copies;

class _Host extends Fake implements CPluginHost {
  _Host(this.locale);

  final String locale;

  @override
  String localize(
    BuildContext context,
    String key, [
    String? fallback,
    Map<String, Object?>? args,
  ]) {
    var text = _copies[locale]![key] as String? ?? fallback ?? key;
    for (final entry in (args ?? const <String, Object?>{}).entries) {
      text = text.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return text;
  }
}

PreviewCanvas _canvas(WidgetTester tester) =>
    tester.widget<PreviewCanvas>(find.byType(PreviewCanvas));

List<String> _order(WidgetTester tester) => [
  for (final entry in _canvas(tester).document.orderedLayerEntries) entry.id,
];

Finder _action(String key) => find.byKey(ValueKey('previewToolbarAction-$key'));
Finder _tool(String name) => find.byKey(ValueKey('previewToolbarTool-$name'));
Finder _option(String id) => find.byKey(ValueKey('previewLayerOption-$id'));
Finder _handle(String id) => find.byKey(ValueKey('previewLayerDragHandle-$id'));

Future<void> _waitFor(WidgetTester tester, Finder finder) async {
  for (var i = 0; i < 200 && finder.evaluate().isEmpty; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 25)),
    );
    await tester.pump(const Duration(milliseconds: 25));
  }
  expect(finder, findsOneWidget);
  await tester.pumpAndSettle();
}

Future<void> _open(WidgetTester tester, {String locale = 'en'}) async {
  SharedPreferences.setMockInitialValues({});
  rootBundle.clear();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(1400, 1100);
  addTearDown(tester.view.reset);
  final bank = PvzObject(
    aliases: ['SeedBank'],
    objClass: 'SeedBankProperties',
    objData: {
      'PresetPlantList': ['peashooter'],
    },
  );
  await tester.pumpWidget(
    MaterialApp(
      locale: Locale(locale),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: PreviewGeneratorScreen(
        host: _Host(locale),
        levelFile: PvzLevelFile(objects: [bank]),
        parsed: ParsedLevelData(objectMap: {'SeedBank': bank}),
        fileName: 'layers-test.json',
        initialStyle: PreviewAutoStyle.normal,
      ),
    ),
  );
  await _waitFor(tester, find.byType(PreviewCanvas));
  expect(tester.takeException(), isNull);
}

Future<void> _tap(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> _openLayers(WidgetTester tester) async {
  final button = _action('previewTool_layers');
  await tester.ensureVisible(button);
  await tester.pumpAndSettle();
  await tester.tap(button);
  await _waitFor(tester, find.byKey(const ValueKey('previewLayersDialog')));
}

Future<void> _selectInLayers(WidgetTester tester, String id) async {
  await _openLayers(tester);
  await _tap(tester, _option(id));
  await _tap(tester, find.byKey(const ValueKey('previewLayersClose')));
  expect(_canvas(tester).selectedLayerId, id);
}

bool _enabled(WidgetTester tester, String key) =>
    tester.widget<PreviewToolbarAction>(_action(key)).onPressed != null;

Future<void> _font(WidgetTester tester, String label) async {
  await _tap(tester, find.byKey(const ValueKey('previewTextFontPicker')));
  await _tap(tester, find.text(label).last);
}

Future<void> _draw(
  WidgetTester tester, {
  Offset from = const Offset(0.12, 0.15),
  Offset to = const Offset(0.28, 0.4),
}) async {
  final boundary =
      _canvas(tester).boundaryKey!.currentContext!.findRenderObject()!
          as RenderBox;
  final start = boundary.localToGlobal(
    Offset(
      kPreviewCanvasSize.width * from.dx,
      kPreviewCanvasSize.height * from.dy,
    ),
  );
  final finish = boundary.localToGlobal(
    Offset(kPreviewCanvasSize.width * to.dx, kPreviewCanvasSize.height * to.dy),
  );
  final gesture = await tester.startGesture(start);
  await tester.pump();
  await gesture.moveTo(Offset.lerp(start, finish, 0.5)!);
  await tester.pump(const Duration(milliseconds: 16));
  await gesture.moveTo(finish);
  await tester.pump(const Duration(milliseconds: 16));
  await gesture.up();
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() {
    _copies = {
      for (final locale in ['en', 'zh'])
        locale:
            jsonDecode(
                  File(
                    'lib/bundled_plugins/level_preview_cplugin/assets/l10n/$locale.arb',
                  ).readAsStringSync(),
                )
                as Map<String, dynamic>,
    };
  });

  for (final locale in ['en', 'zh']) {
    testWidgets('layers placement and font controls use real $locale copy', (
      tester,
    ) async {
      await _open(tester, locale: locale);
      final figures = _action('previewTool_figures');
      final layers = _action('previewTool_layers');
      expect(tester.getTopLeft(figures).dy, tester.getTopLeft(layers).dy);
      expect(
        tester.getTopLeft(figures).dx,
        lessThan(tester.getTopLeft(layers).dx),
      );
      expect(
        tester.widget<PreviewToolbarAction>(layers).label,
        _copies[locale]!['previewTool_layers'],
      );
      expect(
        tester.widget<PreviewToolbarAction>(_action('previewGenAddImage')).icon,
        Icons.sticky_note_2_outlined,
      );
      expect(
        tester
            .widget<PreviewToolbarAction>(_action('previewGenChooseBanner'))
            .icon,
        Icons.wallpaper,
      );

      await _selectInLayers(tester, 'title');
      final boldPvZ = _copies[locale]!['previewGenBoldPvZ'] as String;
      expect(find.byTooltip(boldPvZ), findsOneWidget);
      final systemDefault =
          _copies[locale]!['previewGenFontSystemDefault'] as String;
      await _font(tester, systemDefault);
      expect(
        _canvas(tester).document
            .layerById('title')!
            .effectiveTextRuns()
            .every((run) => run.style.fontFamily == null),
        isTrue,
      );
      final picker = tester.widget<DropdownButton<String>>(
        find.byKey(const ValueKey('previewTextFontPicker')),
      );
      final systemItem = picker.items!.singleWhere((item) => item.value == '');
      expect((systemItem.child as Text).data, systemDefault);
      if (locale == 'zh') {
        expect(systemDefault, isNot('System default'));
        expect(
          find.byTooltip(_copies['en']!['previewGenBoldPvZ'] as String),
          findsNothing,
        );
      }
      await _font(tester, 'PvZ Preview');
      expect(
        _canvas(tester).document
            .layerById('title')!
            .effectiveTextRuns()
            .every((run) => run.style.fontFamily == PreviewFonts.familyPvZ),
        isTrue,
      );
      expect(find.byTooltip(boldPvZ), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'dragging the real layer handle changes canvas order and undo redo',
    (tester) async {
      await _open(tester);
      final before = _order(tester);
      await _openLayers(tester);
      final top = _option(before.last);
      final start = tester.getCenter(_handle(kPreviewBackgroundLayerId));
      final firstRect = tester.getRect(top);
      final dragOffsetY =
          start.dy - tester.getTopLeft(_option(kPreviewBackgroundLayerId)).dy;
      // ReorderableListView compares the proxy card's start, not its handle.
      final targetY = firstRect.top + firstRect.height * 0.25 + dragOffsetY;
      final drag = await tester.startGesture(start);
      await tester.pump();
      await drag.moveBy(const Offset(0, -24));
      await tester.pump(const Duration(milliseconds: 100));
      for (final id in before.where((id) => id != kPreviewBackgroundLayerId)) {
        await drag.moveTo(Offset(start.dx, tester.getCenter(_option(id)).dy));
        await tester.pump(const Duration(milliseconds: 300));
      }
      await drag.moveTo(Offset(start.dx, targetY));
      await tester.pump(const Duration(milliseconds: 300));
      await drag.up();
      await tester.pumpAndSettle();
      final after = [
        ...before.where((id) => id != kPreviewBackgroundLayerId),
        kPreviewBackgroundLayerId,
      ];
      expect(_order(tester), after);
      await _tap(tester, find.byKey(const ValueKey('previewLayersClose')));
      await _tap(tester, find.byIcon(Icons.undo));
      expect(_order(tester), before);
      await _tap(tester, find.byIcon(Icons.redo));
      expect(_order(tester), after);
      expect(tester.takeException(), isNull);
    },
  );

  for (final tool in ['select', 'pen']) {
    testWidgets(
      'all four layer commands work in $tool and respect boundaries',
      (tester) async {
        await _open(tester);
        await _tap(tester, _tool(tool));
        final before = _order(tester);
        expect(before.length, greaterThanOrEqualTo(3));
        final id = before[1];
        await _selectInLayers(tester, id);
        expect(_canvas(tester).tool.name, tool);
        for (final key in [
          'previewGenLayerToFront',
          'previewGenLayerForward',
          'previewGenLayerBackward',
          'previewGenLayerToBack',
        ]) {
          expect(_enabled(tester, key), isTrue);
        }
        await _tap(tester, _action('previewGenLayerForward'));
        expect(_order(tester).indexOf(id), 2);
        await _tap(tester, _action('previewGenLayerBackward'));
        expect(_order(tester).indexOf(id), 1);
        await _tap(tester, _action('previewGenLayerToBack'));
        expect(_order(tester).first, id);
        expect(_enabled(tester, 'previewGenLayerBackward'), isFalse);
        expect(_enabled(tester, 'previewGenLayerToBack'), isFalse);
        expect(_enabled(tester, 'previewGenLayerForward'), isTrue);
        expect(_enabled(tester, 'previewGenLayerToFront'), isTrue);
        await _tap(tester, _action('previewGenLayerToFront'));
        expect(_order(tester).last, id);
        expect(_enabled(tester, 'previewGenLayerForward'), isFalse);
        expect(_enabled(tester, 'previewGenLayerToFront'), isFalse);
        expect(_enabled(tester, 'previewGenLayerBackward'), isTrue);
        expect(_enabled(tester, 'previewGenLayerToBack'), isTrue);
        expect(_canvas(tester).tool.name, tool);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'background layer commands and new text shape stroke stay in front',
    (tester) async {
      await _open(tester);
      await _selectInLayers(tester, kPreviewBackgroundLayerId);
      expect(_enabled(tester, 'previewGenLayerBackward'), isFalse);
      expect(_enabled(tester, 'previewGenLayerToBack'), isFalse);
      await _tap(tester, _action('previewGenLayerToFront'));
      expect(_order(tester).last, kPreviewBackgroundLayerId);
      expect(_enabled(tester, 'previewGenLayerToFront'), isFalse);

      final initialCount = _canvas(tester).document.layers.length;
      await _tap(tester, _action('previewGenAddText'));
      await _tap(tester, _tool('select'));
      expect(_canvas(tester).document.layers.length, initialCount + 1);
      expect(
        _canvas(tester).document.orderedLayerEntries.last.layer!.kind,
        PreviewLayerKind.text,
      );
      expect(
        _order(tester).indexOf(kPreviewBackgroundLayerId),
        _order(tester).length - 2,
      );

      await _tap(tester, _action('previewTool_figures'));
      await _tap(
        tester,
        find.byKey(const ValueKey('previewFigure-rect-false')),
      );
      await _draw(tester);
      expect(_canvas(tester).document.layers.length, initialCount + 2);
      expect(
        _canvas(tester).document.orderedLayerEntries.last.layer!.kind,
        PreviewLayerKind.shape,
      );
      await _tap(tester, _tool('pen'));
      await _draw(
        tester,
        from: const Offset(0.55, 0.65),
        to: const Offset(0.75, 0.78),
      );
      expect(_canvas(tester).document.layers.length, initialCount + 3);
      expect(
        _canvas(tester).document.orderedLayerEntries.last.layer!.kind,
        PreviewLayerKind.stroke,
      );
      expect(
        _order(tester).indexOf(kPreviewBackgroundLayerId),
        _order(tester).length - 4,
      );
      expect(tester.takeException(), isNull);
    },
  );
}
