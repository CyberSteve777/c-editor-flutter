import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_generator_pickers.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/src/preview/preview_generator_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

String _t(String key, [String? fallback]) => fallback ?? key;

Future<void> _pumpLandscape(
  WidgetTester tester,
  void Function(BuildContext context) open, {
  double height = 300,
  double scale = 1.6,
}) async {
  tester.view.physicalSize = Size(900, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(platform: TargetPlatform.android),
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Builder(
        builder: (context) => Scaffold(
          body: Center(
            child: TextButton(
              onPressed: () => open(context),
              child: const Text('Open'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('Open'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('figure sheet scrolls to and selects its last landscape item', (
    tester,
  ) async {
    (PreviewShapeKind, bool)? selected;
    await _pumpLandscape(tester, (context) async {
      selected = await showPreviewFiguresPicker(context: context, t: _t);
    });
    expect(tester.takeException(), isNull);
    final lastFigure = find.byKey(const ValueKey('previewFigure-star-true'));
    expect(lastFigure.hitTestable(), findsNothing);
    final scrollable = find.descendant(
      of: find.byKey(const ValueKey('previewFiguresScroll')),
      matching: find.byType(Scrollable),
    );
    await tester.scrollUntilVisible(lastFigure, 140, scrollable: scrollable);
    expect(lastFigure.hitTestable(), findsOneWidget);
    await tester.tap(lastFigure);
    await tester.pumpAndSettle();
    expect(selected, (PreviewShapeKind.star, true));
    expect(tester.takeException(), isNull);
  });

  testWidgets('module picker scrolls through its header to the final module', (
    tester,
  ) async {
    String? selected;
    await _pumpLandscape(tester, (context) async {
      selected = await showPreviewModuleInfoPicker(
        context: context,
        classes: List.generate(14, (index) => 'Module$index'),
        titleForClass: (_, objClass) => 'A long localized title for $objClass',
        t: _t,
      );
    });
    final lastModule = find.byKey(const ValueKey('previewModuleInfo-Module13'));
    expect(lastModule.hitTestable(), findsNothing);
    expect(
      find.byKey(const ValueKey('previewModuleInfoCancel')).hitTestable(),
      findsOneWidget,
    );
    final scrollable = find
        .descendant(
          of: find.byKey(const ValueKey('previewModuleInfoPicker')),
          matching: find.byType(Scrollable),
        )
        .first;
    await tester.scrollUntilVisible(
      lastModule,
      160,
      scrollable: scrollable,
      maxScrolls: 40,
    );
    await tester.tap(lastModule);
    await tester.pumpAndSettle();
    expect(selected, 'Module13');
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'module search preserves its query when keyboard changes height',
    (tester) async {
      await _pumpLandscape(tester, (context) {
        showPreviewModuleInfoPicker(
          context: context,
          classes: const ['ModuleOne', 'ModuleTwo'],
          titleForClass: (_, objClass) => objClass,
          t: _t,
        );
      }, scale: 1);
      await tester.enterText(
        find.byKey(const ValueKey('previewModuleInfoSearch')),
        'Two',
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('previewModuleInfo-ModuleOne')),
        findsNothing,
      );
      tester.view.viewInsets = const FakeViewPadding(bottom: 110);
      addTearDown(tester.view.resetViewInsets);
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('previewModuleInfo-ModuleOne')),
        findsNothing,
      );
      final matchingModule = find.byKey(
        const ValueKey('previewModuleInfo-ModuleTwo'),
      );
      final scrollable = find
          .descendant(
            of: find.byKey(const ValueKey('previewModuleInfoPicker')),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        matchingModule,
        60,
        scrollable: scrollable,
      );
      expect(matchingModule.hitTestable(), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('starting layout text scrolls without obscuring actions', (
    tester,
  ) async {
    await _pumpLandscape(tester, (context) {
      showPreviewLayoutStyleDialog(
        context: context,
        t: (key, [fallback]) => key == 'previewGenStartHint'
            ? List.filled(12, 'A long translated layout explanation.').join(' ')
            : fallback ?? key,
      );
    });
    expect(tester.takeException(), isNull);
    expect(find.text('Simple').hitTestable(), findsOneWidget);
    expect(find.text('Normal').hitTestable(), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);
    await tester.tap(find.text('Simple'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
