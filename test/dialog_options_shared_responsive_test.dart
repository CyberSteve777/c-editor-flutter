import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/level_list_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/separated_option_picker_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _host(
  WidgetTester tester, {
  required Widget Function(BuildContext) build,
  Size size = const Size(285, 650),
  double scale = 1.6,
  Locale locale = const Locale('en'),
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  await tester.pumpWidget(
    MaterialApp(
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
      home: Scaffold(body: Builder(builder: build)),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('long trailing control cannot squeeze the option text', (
    tester,
  ) async {
    await _host(
      tester,
      size: const Size(500, 650),
      build: (_) => SizedBox(
        width: 500,
        child: EditorOptionTile(
          leading: const Icon(Icons.copy),
          title: const Text(
            'A descriptive option with a large trailing action',
          ),
          trailing: SizedBox(
            width: 420,
            height: 48,
            child: TextButton(
              onPressed: () {},
              child: const Text('A wide action'),
            ),
          ),
        ),
      ),
    );
    final text = find.text('A descriptive option with a large trailing action');
    expect(tester.getSize(text).width, greaterThan(450));
    expect(
      tester.getRect(text).top,
      greaterThan(tester.getRect(find.text('A wide action')).bottom),
    );
    expect(tester.takeException(), isNull);
  });
  testWidgets('template choices scroll with their heading on short landscape', (
    tester,
  ) async {
    String? selected;
    var cancelled = false;
    await _host(
      tester,
      size: const Size(640, 260),
      build: (_) => LevelTemplateSelectionDialog(
        title: 'New level - Select a bundled level template',
        cancelLabel: 'Cancel',
        templates: [for (var i = 0; i < 14; i++) 'template$i'],
        displayName: (template) => 'A descriptive localized level $template',
        onSelected: (template) => selected = template,
        onCancel: () => cancelled = true,
      ),
    );
    expect(tester.takeException(), isNull);
    final last = find.text('A descriptive localized level template13');
    await tester.scrollUntilVisible(last, 120);
    await tester.tap(last);
    expect(selected, 'template13');
    await tester.tap(find.text('Cancel'));
    expect(cancelled, isTrue);
    expect(tester.takeException(), isNull);
  });
  for (final locale in const [Locale('en'), Locale('zh'), Locale('ru')]) {
    testWidgets(
      'shared choices give narrow ${locale.languageCode} text full width',
      (tester) async {
        int? result;
        late AppLocalizations l10n;
        await _host(
          tester,
          locale: locale,
          build: (context) {
            l10n = AppLocalizations.of(context)!;
            return TextButton(
              onPressed: () async {
                result = await showEditorChoiceDialog<int>(
                  context,
                  title: l10n.smartUploadTitle,
                  message: l10n.smartUploadFileMessage(
                    'a_long_level_filename.json',
                  ),
                  options: [
                    EditorChoiceDialogOption(
                      value: 0,
                      icon: Icons.skip_next,
                      title: l10n.smartUploadSkip,
                    ),
                    EditorChoiceDialogOption(
                      value: 1,
                      icon: Icons.copy,
                      title: l10n.smartUploadCopyAll,
                    ),
                  ],
                );
              },
              child: const Text('Open'),
            );
          },
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final title = find.text(l10n.smartUploadSkip);
        expect(tester.getSize(title).width, greaterThan(170));
        final icon = find.byIcon(Icons.skip_next);
        expect(
          tester.getRect(title).top,
          greaterThan(tester.getRect(icon).bottom),
        );
        final last = find.byKey(const ValueKey('editorChoiceOption_1'));
        await tester.scrollUntilVisible(last, 120);
        await tester.tap(last);
        await tester.pumpAndSettle();
        expect(result, 1);
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets('shared choices keep six actions reachable on short landscape', (
    tester,
  ) async {
    int? result;
    await _host(
      tester,
      size: const Size(640, 260),
      build: (context) {
        final l10n = AppLocalizations.of(context)!;
        final labels = [
          l10n.smartUploadSkip,
          l10n.smartUploadOverwrite,
          l10n.smartUploadAsCopy,
          l10n.smartUploadSkipAll,
          l10n.smartUploadOverwriteAll,
          l10n.smartUploadCopyAll,
        ];
        return TextButton(
          onPressed: () async => result = await showEditorChoiceDialog<int>(
            context,
            title: l10n.smartUploadTitle,
            message: l10n.smartUploadFileMessage('example.json'),
            options: [
              for (var i = 0; i < labels.length; i++)
                EditorChoiceDialogOption(
                  value: i,
                  icon: Icons.copy,
                  title: labels[i],
                ),
            ],
          ),
          child: const Text('Open'),
        );
      },
    );
    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    final last = find.byKey(const ValueKey('editorChoiceOption_5'));
    await tester.scrollUntilVisible(last, 140);
    await tester.tap(last);
    await tester.pumpAndSettle();
    expect(result, 5);
    expect(tester.takeException(), isNull);
  });

  testWidgets('wide option stays a row and disabled choice does not select', (
    tester,
  ) async {
    var calls = 0;
    await _host(
      tester,
      size: const Size(1000, 700),
      scale: 1,
      build: (_) => SizedBox(
        width: 600,
        child: EditorOptionTile(
          leading: const Icon(Icons.copy),
          title: const Text('A descriptive choice'),
          subtitle: const Text('Additional details'),
          trailing: const Icon(Icons.check),
          enabled: false,
          onTap: () => calls++,
        ),
      ),
    );
    expect(
      tester.getRect(find.text('A descriptive choice')).left,
      greaterThan(tester.getRect(find.byIcon(Icons.copy)).right),
    );
    await tester.tap(find.text('A descriptive choice'));
    expect(calls, 0);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'popup choice wraps at actual menu width and returns original value',
    (tester) async {
      String? result;
      await _host(
        tester,
        build: (_) => PopupMenuButton<String>(
          key: const ValueKey('popup'),
          onSelected: (value) => result = value,
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'original',
              child: EditorPopupMenuTile(
                leading: Icon(Icons.extension),
                title: Text('A long localized plugin action name'),
              ),
            ),
          ],
        ),
      );
      await tester.tap(find.byKey(const ValueKey('popup')));
      await tester.pumpAndSettle();
      final label = find.text('A long localized plugin action name');
      expect(tester.getSize(label).width, greaterThan(170));
      expect(
        tester.getRect(label).top,
        greaterThan(tester.getRect(find.byIcon(Icons.extension)).bottom),
      );
      await tester.tap(label);
      await tester.pumpAndSettle();
      expect(result, 'original');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'separated picker scrolls long header and last choice on short landscape',
    (tester) async {
      int? result;
      await _host(
        tester,
        size: const Size(640, 230),
        build: (_) => SingleChildScrollView(
          child: SeparatedOptionPickerField<int>(
            labelText:
                'A long localized heading describing which animation or appearance to use',
            value: 0,
            items: [
              for (var i = 0; i < 12; i++)
                SeparatedOptionPickerItem(
                  value: i,
                  label: 'Choice $i',
                  subtitle: 'A descriptive localized explanation of choice $i',
                ),
            ],
            onChanged: (value) => result = value,
          ),
        ),
      );
      final arrow = find.byIcon(Icons.arrow_drop_down);
      await tester.ensureVisible(arrow);
      await tester.pumpAndSettle();
      await tester.tap(arrow);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final list = find
          .descendant(
            of: find.byType(BottomSheet),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('Choice 11'),
        100,
        scrollable: list,
      );
      await tester.pumpAndSettle();
      expect(find.text('Choice 11').hitTestable(), findsOneWidget);
      await tester.tap(find.text('Choice 11'));
      await tester.pumpAndSettle();
      expect(result, 11);
      expect(tester.takeException(), isNull);
    },
  );
}
