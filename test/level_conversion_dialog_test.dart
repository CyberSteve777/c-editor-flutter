import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/level_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<AppLocalizations> _openDialog<T>(
  WidgetTester tester, {
  required Future<T?> Function(BuildContext context) show,
  required ValueChanged<T?> onResult,
  Locale locale = const Locale('en'),
  Size size = const Size(285, 650),
  double textScale = 1,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  late AppLocalizations l10n;
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: Builder(
        builder: (context) {
          l10n = AppLocalizations.of(context)!;
          return Scaffold(
            body: TextButton(
              key: const ValueKey('openConversionDialog'),
              onPressed: () async => onResult(await show(context)),
              child: const Text('Open'),
            ),
          );
        },
      ),
    ),
  );
  await tester.tap(find.byKey(const ValueKey('openConversionDialog')));
  await tester.pumpAndSettle();
  return l10n;
}

void main() {
  for (final locale in const [Locale('en'), Locale('zh'), Locale('ru')]) {
    testWidgets(
      'conversion choices wrap and scroll at narrow ${locale.languageCode}',
      (tester) async {
        String? selected;
        final l10n = await _openDialog<String>(
          tester,
          locale: locale,
          textScale: 1.3,
          show: (context) => showLevelConversionOptionsDialog(
            context,
            sourceName: 'example.JSON',
            includeDebugFormats: false,
          ),
          onResult: (value) => selected = value,
        );
        expect(tester.takeException(), isNull);
        expect(
          tester.getSize(find.byType(AlertDialog)).width,
          greaterThan(250),
        );
        expect(
          tester.getSize(find.text(l10n.convertToHotUpdateJson)).width,
          greaterThan(110),
        );
        expect(find.text(l10n.hujsonFormatDescription), findsOneWidget);
        expect(find.text(l10n.rtonFormatDescription), findsOneWidget);
        final target = find.byKey(const ValueKey('editorChoiceOption_.rton'));
        await tester.scrollUntilVisible(target, 150);
        await tester.tap(target);
        await tester.pumpAndSettle();
        expect(selected, '.rton');
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'conversion choices remain reachable on a short landscape screen',
    (tester) async {
      String? selected;
      final l10n = await _openDialog<String>(
        tester,
        size: const Size(640, 300),
        textScale: 1.3,
        show: (context) => showLevelConversionOptionsDialog(
          context,
          sourceName: 'example.json',
          includeDebugFormats: true,
        ),
        onResult: (value) => selected = value,
      );
      expect(tester.takeException(), isNull);
      final target = find.byKey(const ValueKey('editorChoiceOption_.zlib'));
      await tester.scrollUntilVisible(target, 120);
      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(selected, '.zlib');
      expect(find.text(l10n.convertAction), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'conversion required contains only the necessary conversion message',
    (tester) async {
      bool? selected;
      final l10n = await _openDialog<bool>(
        tester,
        textScale: 1.3,
        show: (context) => showDialog<bool>(
          context: context,
          builder: (_) => const LevelConversionRequiredDialog(),
        ),
        onResult: (value) => selected = value,
      );
      expect(tester.takeException(), isNull);
      expect(find.text(l10n.conversionRequiredMessage), findsOneWidget);
      expect(find.text(l10n.hujsonFormatDescription), findsNothing);
      expect(find.text(l10n.rtonFormatDescription), findsNothing);
      expect(
        tester.getSize(find.text(l10n.conversionRequiredMessage)).width,
        greaterThan(220),
      );
      await tester.tap(find.text(l10n.convertAction));
      await tester.pumpAndSettle();
      expect(selected, isTrue);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'conversion required keeps cancellation accessible on a short screen',
    (tester) async {
      bool? selected;
      final l10n = await _openDialog<bool>(
        tester,
        locale: const Locale('ru'),
        size: const Size(360, 300),
        textScale: 1.3,
        show: (context) => showDialog<bool>(
          context: context,
          builder: (_) => const LevelConversionRequiredDialog(),
        ),
        onResult: (value) => selected = value,
      );
      expect(tester.takeException(), isNull);
      expect(find.text(l10n.conversionRequiredMessage), findsOneWidget);
      await tester.tap(find.text(l10n.cancel));
      await tester.pumpAndSettle();
      expect(selected, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  for (final source in const [
    'example.hujson',
    'example.rton',
    'example.zlib',
  ]) {
    testWidgets('conversion choices preserve the target for $source', (
      tester,
    ) async {
      String? selected;
      await _openDialog<String>(
        tester,
        show: (context) => showLevelConversionOptionsDialog(
          context,
          sourceName: source,
          includeDebugFormats: false,
        ),
        onResult: (value) => selected = value,
      );
      final expected = source.endsWith('.zlib') ? '.bin' : '.json';
      await tester.tap(find.byKey(ValueKey('editorChoiceOption_$expected')));
      await tester.pumpAndSettle();
      expect(selected, expected);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('conversion choices cancellation does not select a target', (
    tester,
  ) async {
    String? selected = 'unchanged';
    final l10n = await _openDialog<String>(
      tester,
      show: (context) => showLevelConversionOptionsDialog(
        context,
        sourceName: 'example.json',
        includeDebugFormats: false,
      ),
      onResult: (value) => selected = value,
    );
    await tester.tap(find.text(l10n.cancel));
    await tester.pumpAndSettle();
    expect(selected, isNull);
    expect(tester.takeException(), isNull);
  });
}
