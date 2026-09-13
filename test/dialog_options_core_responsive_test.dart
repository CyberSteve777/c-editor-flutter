import 'package:c_editor/app.dart';
import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/plugin_manager.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';
import 'package:c_editor/plugins/plugin_ui_host.dart';
import 'package:c_editor/screens/common/selection_dialog.dart';
import 'package:c_editor/screens/editor_screen.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' show RenderParagraph;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpCoreApp(
  WidgetTester tester, {
  required Widget home,
  Size size = const Size(285, 650),
  double textScale = 1.3,
  SettingsCubit? settings,
  double keyboardHeight = 0,
}) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = size;
  addTearDown(tester.view.resetDevicePixelRatio);
  addTearDown(tester.view.resetPhysicalSize);
  final app = MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    builder: (context, child) => MediaQuery(
      data: MediaQuery.of(context).copyWith(
        textScaler: TextScaler.linear(textScale),
        viewInsets: EdgeInsets.only(bottom: keyboardHeight),
      ),
      child: child!,
    ),
    home: home,
  );
  await tester.pumpWidget(
    settings == null ? app : BlocProvider.value(value: settings, child: app),
  );
  await tester.pumpAndSettle();
}

Future<SettingsCubit> _settings() async {
  SharedPreferences.setMockInitialValues({'locale': 'en'});
  return SettingsCubit(await SharedPreferences.getInstance());
}

void main() {
  testWidgets(
    'generic selection keeps filtering and selecting on a narrow screen',
    (tester) async {
      String? selected;
      final items = List.generate(50, (index) => 'Option $index');
      await _pumpCoreApp(
        tester,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => SelectionDialog<String>(
                  title: 'Select an existing option',
                  items: items,
                  filter: (item, query) => item.toLowerCase().contains(query),
                  onSelected: (value) => selected = value,
                  itemBuilder: (_, item) => EditorOptionTile(
                    leading: const Icon(Icons.description),
                    title: Text(item),
                  ),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      expect(tester.getSize(find.byType(AlertDialog)).width, greaterThan(250));
      await tester.enterText(find.byType(TextField), '49');
      await tester.pumpAndSettle();
      expect(find.text('Option 0'), findsNothing);
      await tester.tap(find.text('Option 49'));
      await tester.pumpAndSettle();
      expect(selected, 'Option 49');
      expect(find.byType(SelectionDialog<String>), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'generic selection remains scrollable with a landscape keyboard',
    (tester) async {
      String? selected;
      await _pumpCoreApp(
        tester,
        size: const Size(640, 320),
        keyboardHeight: 120,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showDialog<void>(
                context: context,
                builder: (_) => SelectionDialog<String>(
                  title: 'Select an existing option',
                  items: const ['First', 'Last'],
                  filter: (item, query) => item.toLowerCase().contains(query),
                  onSelected: (value) => selected = value,
                  itemBuilder: (_, item) => EditorOptionTile(title: Text(item)),
                ),
              ),
              child: const Text('Open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'last');
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Last'));
      await tester.tap(find.text('Last'));
      await tester.pumpAndSettle();
      expect(selected, 'Last');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('UI scale presets wrap without truncating their labels', (
    tester,
  ) async {
    double? selected;
    await _pumpCoreApp(
      tester,
      textScale: 1.5,
      home: Scaffold(
        body: Center(
          child: SizedBox(
            width: 180,
            child: EditorUiScalePresetLabels(
              currentScale: 1,
              smallLabel: 'Small',
              standardLabel: 'Standard',
              largeLabel: 'Large',
              ultraLabel: 'Ultra',
              onPresetSelected: (value) => selected = value,
            ),
          ),
        ),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(
      tester.widget<Text>(find.text('Standard')).overflow,
      isNot(TextOverflow.ellipsis),
    );
    expect(
      tester.getTopLeft(find.text('Large')).dy,
      greaterThan(tester.getTopLeft(find.text('Small')).dy),
    );
    await tester.tap(find.text('Ultra'));
    expect(selected, 1.5);
  });

  testWidgets(
    'language selector scrolls on a short screen and keeps language order',
    (tester) async {
      final settings = await _settings();
      addTearDown(settings.close);
      await _pumpCoreApp(
        tester,
        size: const Size(640, 220),
        textScale: 1.5,
        settings: settings,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showAppLanguageSelector(context),
              child: const Text('Open languages'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open languages'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final en = find.byKey(const ValueKey('appLanguage_en'));
      final zh = find.byKey(const ValueKey('appLanguage_zh'));
      final ru = find.byKey(const ValueKey('appLanguage_ru'));
      expect(tester.getTopLeft(en).dy, lessThan(tester.getTopLeft(zh).dy));
      expect(tester.getTopLeft(zh).dy, lessThan(tester.getTopLeft(ru).dy));
      await tester.scrollUntilVisible(ru, 100);
      await tester.tap(ru);
      await tester.pumpAndSettle();
      expect(settings.state.locale, const Locale('ru'));
      expect((await SharedPreferences.getInstance()).getString('locale'), 'ru');
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'language selector keeps text readable on a narrow large-text screen',
    (tester) async {
      final settings = await _settings();
      addTearDown(settings.close);
      await _pumpCoreApp(
        tester,
        size: const Size(285, 500),
        textScale: 2,
        settings: settings,
        home: Builder(
          builder: (context) => Scaffold(
            body: TextButton(
              onPressed: () => showAppLanguageSelector(context),
              child: const Text('Open languages'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Open languages'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final chinese = find.byKey(const ValueKey('appLanguage_zh'));
      final label = find.descendant(of: chinese, matching: find.byType(Text));
      expect(
        tester.renderObject<RenderParagraph>(label).constraints.maxWidth,
        greaterThan(240),
      );
      await tester.ensureVisible(chinese);
      await tester.tap(chinese);
      await tester.pumpAndSettle();
      expect(settings.state.locale, const Locale('zh'));
      expect(tester.takeException(), isNull);
    },
  );

  Future<PluginScreenRegistry> initializeRegistry(WidgetTester tester) async {
    late PluginScreenRegistry registry;
    await tester.runAsync(() async {
      SharedPreferences.setMockInitialValues({});
      final manager = await PluginManager.init(
        await SharedPreferences.getInstance(),
      );
      registry = manager.screenRegistry;
      registry.clearAll();
    });
    addTearDown(() => registry.clearForPlugin('responsive_test'));
    return registry;
  }

  testWidgets(
    'plugin overflow actions keep order, values and route activation',
    (tester) async {
      final registry = await initializeRegistry(tester);
      var activated = 0;
      const slot = CPluginUiSlots.editorOverflow;
      registry.registerEditorAction(
        PluginEditorAction(
          pluginId: 'responsive_test',
          id: 'action',
          titleBuilder: (_) => 'A long localized editor action title',
          icon: Icons.edit,
          slot: slot,
          onActivate: (_) async {
            activated++;
          },
        ),
      );
      registry.registerUiElement(
        PluginUiElement(
          pluginId: 'responsive_test',
          id: 'screen',
          title: 'A long localized contributed screen title',
          slot: slot,
          builder: (_) => const Scaffold(body: Text('Contributed screen')),
        ),
      );
      String? selected;
      await _pumpCoreApp(
        tester,
        size: const Size(285, 650),
        textScale: 1.5,
        home: Builder(
          builder: (context) => Scaffold(
            body: PopupMenuButton<String>(
              itemBuilder: (_) => pluginOverflowMenuItems(
                context: context,
                slot: slot,
                valuePrefix: 'plugin:',
              ),
              onSelected: (value) {
                selected = value;
                expect(
                  handlePluginOverflowSelection(
                    context,
                    value: value,
                    valuePrefix: 'plugin:',
                    slot: slot,
                  ),
                  isTrue,
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final actionLabel = find.text('A long localized editor action title');
      final screenLabel = find.text(
        'A long localized contributed screen title',
      );
      expect(
        tester.getTopLeft(actionLabel).dy,
        lessThan(tester.getTopLeft(screenLabel).dy),
      );
      expect(tester.getSize(actionLabel).width, greaterThan(200));
      await tester.tap(actionLabel);
      await tester.pumpAndSettle();
      expect(selected, 'plugin:responsive_test::editorAction::$slot::action');
      expect(activated, 1);
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      await tester.tap(screenLabel);
      await tester.pumpAndSettle();
      expect(find.text('Contributed screen'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'plugin level-file action preserves its matched file and callback',
    (tester) async {
      final registry = await initializeRegistry(tester);
      (String, String)? activatedFile;
      registry.registerLevelFileAction(
        PluginLevelFileAction(
          pluginId: 'responsive_test',
          id: 'file',
          titleBuilder: (_) => 'A long localized level file action title',
          icon: Icons.description,
          matchesFileName: (name) => name.endsWith('.json'),
          onActivate: (_, name, path) async {
            activatedFile = (name, path);
          },
        ),
      );
      String? selected;
      await _pumpCoreApp(
        tester,
        textScale: 1.5,
        home: Builder(
          builder: (context) => Scaffold(
            body: PopupMenuButton<String>(
              itemBuilder: (_) => pluginLevelFileMenuItems(
                context: context,
                fileName: 'level.json',
                valuePrefix: 'file:',
              ),
              onSelected: (value) {
                selected = value;
                expect(
                  handlePluginLevelFileSelection(
                    context,
                    value: value,
                    valuePrefix: 'file:',
                    fileName: 'level.json',
                    filePath: 'library/level.json',
                  ),
                  isTrue,
                );
              },
            ),
          ),
        ),
      );
      await tester.tap(find.byType(PopupMenuButton<String>));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      await tester.tap(find.text('A long localized level file action title'));
      await tester.pumpAndSettle();
      expect(selected, 'file:responsive_test::fileAction::file');
      expect(activatedFile, ('level.json', 'library/level.json'));
      expect(tester.takeException(), isNull);
    },
  );
}
