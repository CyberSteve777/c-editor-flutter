import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_generator_screen.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_png_exporter.dart';
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

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'generator title scrolls with controls and restores exit/export',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(1000, 700));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final seedBank = PvzObject(
        aliases: const ['SeedBank'],
        objClass: 'SeedBankProperties',
        objData: {
          'PresetPlantList': ['peashooter'],
        },
      );
      var exports = 0;
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
                        parsed: ParsedLevelData(
                          objectMap: {'SeedBank': seedBank},
                        ),
                        fileName: 'scrolling-header.json',
                        imageExporter: (image, fileName) async {
                          expect(fileName, 'scrolling-header.json');
                          expect(image.width, greaterThan(0));
                          expect(image.height, greaterThan(0));
                          exports++;
                          return PreviewExportResult(
                            path: 'previews/scrolling-header.png',
                            bytes: Uint8List(0),
                          );
                        },
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
      final generator = find.byType(PreviewGeneratorScreen);
      expect(
        tester
            .widget<Scaffold>(
              find.descendant(of: generator, matching: find.byType(Scaffold)),
            )
            .appBar,
        isNull,
        reason: 'A fixed scaffold app bar would reserve an extra title row',
      );
      final canvas = tester.widget<PreviewCanvas>(find.byType(PreviewCanvas));
      canvas.onSelectLayer!('theme');
      await tester.pumpAndSettle();
      final header = find.byKey(const ValueKey('previewGeneratorTitleBar'));
      final back = find.byKey(const ValueKey('previewGeneratorBackButton'));
      final viewport = find.byKey(const ValueKey('previewToolbarViewport'));
      final originalCanvasRect = tester.getRect(
        find.byKey(canvas.boundaryKey!),
      );
      final scroll = tester
          .widget<Scrollbar>(
            find.byKey(const ValueKey('previewToolbarScrollbar')),
          )
          .controller!;
      expect(find.ancestor(of: header, matching: viewport), findsOneWidget);
      expect(tester.widget<AppBar>(header).primary, isFalse);
      expect(back.hitTestable(), findsOneWidget);
      expect(scroll.position.maxScrollExtent, greaterThan(kToolbarHeight));

      await tester.dragFrom(tester.getCenter(viewport), const Offset(0, -180));
      await tester.pumpAndSettle();
      expect(back.hitTestable(), findsNothing);
      expect(
        tester.getRect(header).bottom,
        lessThanOrEqualTo(tester.getRect(viewport).top),
      );
      expect(
        tester.getRect(find.byKey(canvas.boundaryKey!)),
        originalCanvasRect,
      );

      await tester.scrollUntilVisible(
        back,
        -160,
        scrollable: find
            .descendant(of: viewport, matching: find.byType(Scrollable))
            .first,
      );
      await tester.pumpAndSettle();
      expect(back.hitTestable(), findsOneWidget);
      await tester.tap(find.byTooltip('Export image'));
      for (var attempt = 0; attempt < 100; attempt++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 20)),
        );
        await tester.pump(const Duration(milliseconds: 20));
        if (find.byType(SnackBar).evaluate().isNotEmpty) break;
      }
      await tester.pumpAndSettle();
      expect(exports, 1);
      expect(generator, findsOneWidget);
      await tester.tap(back);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('previewGeneratorExitDialog')),
        findsOneWidget,
      );
      await tester.tap(
        find.byKey(const ValueKey('previewGeneratorDiscardExitButton')),
      );
      await tester.pumpAndSettle();
      expect(generator, findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
