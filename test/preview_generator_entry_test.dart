import 'dart:io';

import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_generator_screen.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/registration.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/plugin_arb.dart';
import 'package:c_editor/plugins/plugin_host_hooks.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Host extends Fake implements CPluginHost {
  final _sources = {
    for (final locale in ['zh', 'en'])
      'l10n/$locale.arb': File(
        'lib/bundled_plugins/preview_img_cplugin/assets/l10n/$locale.arb',
      ).readAsStringSync(),
  };

  @override
  String localize(
    BuildContext context,
    String key, [
    String? fallback,
    Map<String, Object?>? args,
  ]) {
    final locale = Localizations.localeOf(context).languageCode;
    final entry = lookupPluginArbEntry((path) => _sources[path], locale, key);
    if (entry == null) return fallback ?? key;
    return formatPluginArbMessage(
      entry.pattern,
      locale: locale,
      args: args ?? const {},
      placeholders: entry.placeholders,
    );
  }
}

class _Entry {
  final seedBank = PvzObject(
    aliases: const ['SeedBank'],
    objClass: 'SeedBankProperties',
    objData: {
      'PresetPlantList': ['peashooter'],
    },
  );
  late final level = PvzLevelFile(objects: [seedBank]);
  late final parsed = ParsedLevelData(objectMap: {'SeedBank': seedBank});
  bool returned = false;

  Future<void> open(BuildContext context) async {
    await PluginHostHooks.openPreviewImageGenerator!(
      context,
      levelFile: level,
      parsed: parsed,
      fileName: 'entry.json',
    );
    returned = true;
  }
}

Future<_Entry> _open(WidgetTester tester, Size size) async {
  final entry = _Entry();
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    MaterialApp(
      locale: const Locale('zh'),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        platform: size.width < 600
            ? TargetPlatform.iOS
            : TargetPlatform.windows,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: FilledButton(
              onPressed: () => entry.open(context),
              child: const Text('Open generator'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('Open generator'));
  await tester.pumpAndSettle();
  expect(find.text('选择布局'), findsOneWidget);
  for (final label in ['简单布局', '详细布局', '取消']) {
    expect(find.text(label).hitTestable(), findsOneWidget);
  }
  expect(find.byType(PreviewGeneratorScreen), findsNothing);
  expect(entry.returned, isFalse);
  expect(tester.takeException(), isNull);
  return entry;
}

Future<PreviewCanvas> _waitForCanvas(WidgetTester tester) async {
  await tester.pump();
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
  return tester.widget<PreviewCanvas>(find.byType(PreviewCanvas));
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() {
    rootBundle.clear();
    SharedPreferences.setMockInitialValues({});
    final previous = PluginHostHooks.openPreviewImageGenerator;
    addTearDown(() => PluginHostHooks.openPreviewImageGenerator = previous);
    installLevelPreviewHostHooks(_Host());
  });

  for (final size in [const Size(390, 844), const Size(1200, 900)]) {
    for (final style in PreviewAutoStyle.values) {
      testWidgets('$size entry composes the selected $style layout', (
        tester,
      ) async {
        final entry = await _open(tester, size);
        await tester.tap(
          find.text(style == PreviewAutoStyle.simple ? '简单布局' : '详细布局'),
        );
        final canvas = await _waitForCanvas(tester);
        final screen = tester.widget<PreviewGeneratorScreen>(
          find.byType(PreviewGeneratorScreen),
        );
        expect(find.byType(AlertDialog), findsNothing);
        expect(screen.levelFile, same(entry.level));
        expect(screen.parsed, same(entry.parsed));
        expect(canvas.document.levelFileName, 'entry.json');
        expect(canvas.document.autoStyle, style);
        final plants = canvas.document.layers.singleWhere(
          (layer) => layer.id == 'plants',
        );
        expect(plants.showChrome, style == PreviewAutoStyle.normal);
        expect(plants.items.single.sourceLabel, '卡槽植物');
        if (style == PreviewAutoStyle.normal) {
          expect(plants.sourceLabel, '卡槽植物');
        }
      });
    }
  }

  testWidgets('cancel leaves the caller open without creating a preview', (
    tester,
  ) async {
    final entry = await _open(tester, const Size(390, 844));
    // The initial choice requires a button or back action to dismiss it.
    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.text('选择布局'), findsOneWidget);
    await tester.tap(find.text('取消'));
    await tester.pumpAndSettle();
    expect(entry.returned, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(PreviewGeneratorScreen), findsNothing);
    expect(find.text('Open generator').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('system back cancels the initial layout choice', (tester) async {
    final entry = await _open(tester, const Size(390, 844));
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(entry.returned, isTrue);
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.byType(PreviewGeneratorScreen), findsNothing);
    expect(find.text('Open generator').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
