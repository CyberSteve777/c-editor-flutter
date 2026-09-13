import 'dart:ui' as ui;

import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_generator_screen.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_png_exporter.dart';
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

Future<void> _openGenerator(
  WidgetTester tester, {
  Future<PreviewExportResult> Function(ui.Image, String)? exporter,
}) async {
  SharedPreferences.setMockInitialValues({});
  await tester.binding.setSurfaceSize(const Size(1200, 900));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  final seedBank = PvzObject(
    aliases: const ['SeedBank'],
    objClass: 'SeedBankProperties',
    objData: {
      'PresetPlantList': [for (var i = 0; i < 30; i++) 'test_plant_$i'],
    },
  );
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => PreviewGeneratorScreen(
                    host: _Host(),
                    levelFile: PvzLevelFile(objects: [seedBank]),
                    parsed: ParsedLevelData(objectMap: {'SeedBank': seedBank}),
                    fileName: 'keyboard-exit.json',
                    imageExporter: exporter,
                  ),
                ),
              ),
              child: const Text('Open generator'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open generator'));
  await _waitForCanvas(tester);
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
}

Future<void> _shortcut(
  WidgetTester tester,
  LogicalKeyboardKey key, {
  bool shift = false,
  bool command = false,
}) async {
  final modifier = command
      ? LogicalKeyboardKey.metaLeft
      : LogicalKeyboardKey.controlLeft;
  await tester.sendKeyDownEvent(modifier);
  if (shift) await tester.sendKeyDownEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyEvent(key);
  if (shift) await tester.sendKeyUpEvent(LogicalKeyboardKey.shiftLeft);
  await tester.sendKeyUpEvent(modifier);
  await tester.pumpAndSettle();
}

Future<void> _finishExport(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 100));
  for (var attempt = 0; attempt < 100; attempt++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 20)),
    );
    await tester.pump(const Duration(milliseconds: 20));
    final screens = find.byType(PreviewGeneratorScreen).evaluate();
    if (screens.isEmpty || find.byType(SnackBar).evaluate().isNotEmpty) break;
  }
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    // CachingAssetBundle stores Futures, whose completion callbacks belong to
    // the test's fake-async zone. Each widget test needs independent futures.
    rootBundle.clear();
  });

  testWidgets(
    'Del and document undo/redo work after canvas or control clicks',
    (tester) async {
      await _openGenerator(tester);
      final initial = _canvas(tester).document.layerById('plants')!;
      final itemCount = initial.sections.single.items.length;
      await tester.tap(
        find.byKey(const ValueKey('preview-icon-item-plants-0-1-0')),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('previewCanvasFitButton')));
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();
      int? count() => _canvas(
        tester,
      ).document.layerById('plants')?.sections.single.items.length;
      // Clicking an icon now selects the whole group, not its visual row.
      expect(count(), isNull);
      await _shortcut(tester, LogicalKeyboardKey.keyZ);
      expect(count(), itemCount);
      await _shortcut(tester, LogicalKeyboardKey.keyY);
      expect(count(), isNull);
      await _shortcut(tester, LogicalKeyboardKey.keyZ);
      expect(count(), itemCount);
      await _shortcut(tester, LogicalKeyboardKey.keyZ, shift: true);
      expect(count(), isNull);
      await _shortcut(tester, LogicalKeyboardKey.keyZ, command: true);
      expect(count(), itemCount);
      await _shortcut(
        tester,
        LogicalKeyboardKey.keyZ,
        command: true,
        shift: true,
      );
      expect(count(), isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('rich text gets text undo/redo and Del never deletes its layer', (
    tester,
  ) async {
    await _openGenerator(tester);
    _canvas(tester).onBeginTextEdit!('theme');
    await tester.pumpAndSettle();
    final field = find.byType(TextField);
    expect(field, findsOneWidget);
    await tester.enterText(field, 'Edited');
    await tester.pump();
    await tester.enterText(field, 'Edited twice');
    await tester.pump();
    await _shortcut(tester, LogicalKeyboardKey.keyZ);
    expect(tester.widget<TextField>(field).controller!.text, 'Edited');
    await _shortcut(tester, LogicalKeyboardKey.keyZ, shift: true);
    expect(tester.widget<TextField>(field).controller!.text, 'Edited twice');
    final controller = tester.widget<TextField>(field).controller!;
    controller.selection = const TextSelection(baseOffset: 0, extentOffset: 6);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pumpAndSettle();
    expect(_canvas(tester).document.layerById('theme'), isNotNull);
    expect(controller.text, ' twice');
    await _shortcut(tester, LogicalKeyboardKey.keyZ);
    expect(controller.text, 'Edited twice');
    expect(tester.takeException(), isNull);
  });

  testWidgets('app-bar back asks before leaving; cancel and discard work', (
    tester,
  ) async {
    await _openGenerator(tester);
    await tester.tap(
      find.byKey(const ValueKey('preview-icon-item-plants-0-1-0')),
    );
    await tester.pumpAndSettle();
    final count = _canvas(tester).document.layerById('plants')!.items.length;
    await tester.tap(find.byKey(const ValueKey('previewGeneratorBackButton')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('previewGeneratorExitDialog')),
      findsOneWidget,
    );
    // Document commands must not modify the canvas behind a modal dialog.
    await tester.sendKeyEvent(LogicalKeyboardKey.delete);
    await tester.pump();
    expect(
      _canvas(tester).document.layerById('plants')!.items,
      hasLength(count),
    );
    await tester.tap(
      find.byKey(const ValueKey('previewGeneratorCancelExitButton')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PreviewGeneratorScreen), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('previewGeneratorBackButton')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('previewGeneratorDiscardExitButton')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PreviewGeneratorScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('system back uses the same confirmation instead of popping', (
    tester,
  ) async {
    await _openGenerator(tester);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('previewGeneratorExitDialog')),
      findsOneWidget,
    );
    expect(find.byType(PreviewGeneratorScreen), findsOneWidget);
    await tester.tap(
      find.byKey(const ValueKey('previewGeneratorDiscardExitButton')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(PreviewGeneratorScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final systemBack in [false, true]) {
    testWidgets(
      'blocked generator exits without saving via ${systemBack ? 'system' : 'app-bar'} back',
      (tester) async {
        var exports = 0;
        await _openGenerator(
          tester,
          exporter: (_, _) async {
            exports++;
            throw StateError('A blocked generator must not export on exit');
          },
        );
        // A composed document must not trigger a save dialog when its editor is
        // hidden by the display-area guard.
        await tester.binding.setSurfaceSize(const Size(400, 800));
        await tester.pumpAndSettle();
        expect(find.text('previewGenDisplayTooNarrowTitle'), findsOneWidget);
        if (systemBack) {
          await tester.binding.handlePopRoute();
        } else {
          await tester.tap(
            find.byKey(const ValueKey('previewGeneratorBackButton')),
          );
        }
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('previewGeneratorExitDialog')),
          findsNothing,
        );
        expect(find.byType(PreviewGeneratorScreen), findsNothing);
        expect(exports, 0);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('save and leave exports before popping', (tester) async {
    var exports = 0;
    await _openGenerator(
      tester,
      exporter: (image, name) async {
        expect(find.byType(PreviewGeneratorScreen), findsOneWidget);
        expect(image.width, greaterThan(0));
        expect(name, 'keyboard-exit.json');
        exports++;
        return PreviewExportResult(
          path: 'previews/keyboard-exit.png',
          bytes: Uint8List(0),
        );
      },
    );
    await tester.tap(find.byKey(const ValueKey('previewGeneratorBackButton')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('previewGeneratorSaveExitButton')),
    );
    await _finishExport(tester);
    expect(exports, 1);
    expect(find.byType(PreviewGeneratorScreen), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed save reports failure and keeps generator open', (
    tester,
  ) async {
    var exports = 0;
    await _openGenerator(
      tester,
      exporter: (image, name) async {
        exports++;
        throw StateError('Test export failure');
      },
    );
    await tester.tap(find.byKey(const ValueKey('previewGeneratorBackButton')));
    await tester.pumpAndSettle();
    await tester.tap(
      find.byKey(const ValueKey('previewGeneratorSaveExitButton')),
    );
    await _finishExport(tester);
    expect(exports, 1);
    expect(find.byType(PreviewGeneratorScreen), findsOneWidget);
    expect(find.text('Export failed'), findsOneWidget);
    expect(find.textContaining('Test export failure'), findsNothing);
    // The failed save must not permanently suppress another leave attempt.
    await tester.tap(find.byKey(const ValueKey('previewGeneratorBackButton')));
    await tester.pumpAndSettle();
    expect(
      find.byKey(const ValueKey('previewGeneratorExitDialog')),
      findsOneWidget,
    );
    await tester.tap(
      find.byKey(const ValueKey('previewGeneratorCancelExitButton')),
    );
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets('one application can enter and leave the generator repeatedly', (
    tester,
  ) async {
    await _openGenerator(tester);
    for (var visit = 0; visit < 3; visit++) {
      if (visit > 0) {
        await tester.tap(find.text('Open generator'));
        await _waitForCanvas(tester);
      }
      final initialCount = _canvas(
        tester,
      ).document.layerById('plants')!.sections.single.items.length;
      await tester.tap(
        find.byKey(const ValueKey('preview-icon-item-plants-0-1-0')),
      );
      await tester.pumpAndSettle();
      await tester.sendKeyEvent(LogicalKeyboardKey.delete);
      await tester.pumpAndSettle();
      expect(_canvas(tester).document.layerById('plants'), isNull);
      await _shortcut(tester, LogicalKeyboardKey.keyZ);
      expect(
        _canvas(tester).document.layerById('plants')!.sections.single.items,
        hasLength(initialCount),
      );
      await tester.tap(
        find.byKey(const ValueKey('previewGeneratorBackButton')),
      );
      await tester.pumpAndSettle();
      await tester.tap(
        find.byKey(const ValueKey('previewGeneratorDiscardExitButton')),
      );
      await tester.pumpAndSettle();
      expect(find.byType(PreviewGeneratorScreen), findsNothing);
    }
    expect(tester.takeException(), isNull);
  });
}
