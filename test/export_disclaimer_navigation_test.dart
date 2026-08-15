import 'dart:typed_data';

import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/export/export_screen.dart';
import 'package:c_editor/screens/export/export_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FakeExportEngine implements ExportEngine {
  @override
  Future<bool> hasEligibleArchive(String rootPath) async => true;

  @override
  Future<List<ExportEntry>> listDirectory(
    String path, {
    required bool archiveStep,
  }) async => [
    const ExportEntry(
      name: 'dynamic.rsb.smf',
      path: 'library/dynamic.rsb.smf',
      isDirectory: false,
    ),
  ];

  @override
  String parentDirectory(String path) => 'library';

  @override
  Future<void> performExport({
    required String archivePath,
    required Map<String, Uint8List> rtonLevels,
    required void Function(double progress, ExportPhase phase) onProgress,
  }) => throw UnimplementedError();

  @override
  void cancelExport() {}
}

void main() {
  Future<void> pumpAsyncFrames(WidgetTester tester) async {
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }
  }

  testWidgets(
    'back exits export after choosing not to show the disclaimer again',
    (tester) async {
      SharedPreferences.setMockInitialValues({'folder_path': 'library'});
      await tester.binding.setSurfaceSize(const Size(1000, 1000));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('en'),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => ExportScreen(engine: _FakeExportEngine()),
                  ),
                ),
                child: const Text('Open export'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open export'));
      await pumpAsyncFrames(tester);
      expect(find.text('Risk Warning & Disclaimer'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('exportDisclaimerInfoButton')),
        findsNothing,
      );

      await tester.tap(find.text('Do not show by default'));
      await tester.pump();
      expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isTrue);
      await tester.tap(find.text('Proceed'));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(seconds: 1)),
      );
      await pumpAsyncFrames(tester);
      final prefsAfterProceed = await SharedPreferences.getInstance();
      expect(prefsAfterProceed.getBool('export_disclaimer_skip'), isTrue);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Risk Warning & Disclaimer'), findsNothing);

      await tester.tap(
        find.byKey(const ValueKey('exportDisclaimerInfoButton')),
      );
      await tester.pumpAndSettle();
      expect(
        find.byKey(const ValueKey('exportDisclaimerDialog')),
        findsOneWidget,
      );
      expect(find.text('Risk Warning & Disclaimer'), findsOneWidget);
      expect(find.textContaining('at their own risk'), findsOneWidget);
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await pumpAsyncFrames(tester);
      expect(find.text('Open export'), findsOneWidget);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getBool('export_disclaimer_skip'), isTrue);
    },
  );
}
