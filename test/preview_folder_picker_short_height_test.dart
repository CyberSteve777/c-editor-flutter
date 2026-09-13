import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_export_folder_picker.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_settings_screen.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_toolbar_prefs.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

String _t(String key, [String? fallback]) => fallback ?? key;

class _Host extends Fake implements CPluginHost {
  @override
  String localize(
    BuildContext context,
    String key, [
    String? fallback,
    Map<String, Object?>? args,
  ]) => _t(key, fallback);
}

FileItem _folder(String name) => FileItem(
  name: name,
  path: 'web://$name',
  isDirectory: true,
  lastModified: 0,
  size: 0,
);

Widget _app(Widget home, double textScale) => MaterialApp(
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(
      context,
    ).copyWith(textScaler: TextScaler.linear(textScale)),
    child: child!,
  ),
  home: home,
);

Future<void> _scrollAndTap(
  WidgetTester tester,
  Finder target,
  Finder scrollable, {
  Alignment alignment = Alignment.center,
}) async {
  for (var attempt = 0; attempt < 40; attempt++) {
    await tester.pumpAndSettle();
    final visible = target.hitTestable(at: alignment);
    if (visible.evaluate().isNotEmpty) {
      await tester.tapAt(alignment.withinRect(tester.getRect(visible)));
      await tester.pumpAndSettle();
      return;
    }
    await tester.drag(scrollable, const Offset(0, -60));
  }
  fail('Control cannot be reached by scrolling: $target');
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets(
    'folder location is a Move-style information banner, not a choice',
    (tester) async {
      final reads = <String>[];
      final colors = ColorScheme.fromSeed(seedColor: Colors.green).copyWith(
        secondaryContainer: Colors.blue,
        onSecondaryContainer: Colors.black,
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(colorScheme: colors),
          home: PreviewExportFolderPicker(
            workspacePath: 'web://',
            initialFolder: 'previews',
            t: _t,
            listFolders: (path) async {
              reads.add(path);
              return path == 'web://' ? [_folder('previews')] : [];
            },
          ),
        ),
      );
      await tester.pumpAndSettle();
      final banner = find.byKey(const ValueKey('previewExportLocationBanner'));
      expect(tester.widget<Container>(banner).color, Colors.blue);
      expect(find.text('Currently in: previews'), findsOneWidget);
      expect(find.text('Go to parent folder'), findsOneWidget);
      expect(
        find.descendant(of: banner, matching: find.byType(ListTile)),
        findsNothing,
      );
      expect(
        find.descendant(of: banner, matching: find.byType(InkWell)),
        findsNothing,
      );
      final readCount = reads.length;
      await tester.tap(banner);
      await tester.pumpAndSettle();
      expect(reads.length, readCount);
      expect(find.text('Currently in: previews'), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('previewExportParentFolder')));
      await tester.pumpAndSettle();
      expect(find.text('Currently in: Workspace'), findsOneWidget);
      expect(
        find.byKey(const ValueKey('previewExportParentFolder')),
        findsNothing,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'localized location keeps long paths readable on a narrow screen',
    (tester) async {
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 700);
      addTearDown(tester.view.reset);
      const folder = '关卡预览截图导出文件夹';
      String localized(String key, [String? fallback]) => switch (key) {
        'previewSettingsCurrentFolder' => '当前位于：{folder}',
        'previewSettingsParentFolder' => '返回上级文件夹',
        'previewSettingsFolderPickerHint' =>
          '打开下方的文件夹或新建文件夹，再点击“选择此文件夹”，将当前所在文件夹设为导出位置。',
        _ => fallback ?? key,
      };
      await tester.pumpWidget(
        _app(
          PreviewExportFolderPicker(
            workspacePath: 'web://',
            initialFolder: folder,
            t: localized,
            listFolders: (path) async =>
                path == 'web://' ? [_folder(folder)] : [],
          ),
          1.8,
        ),
      );
      await tester.pumpAndSettle();
      final current = find.byKey(const ValueKey('previewExportCurrentFolder'));
      expect(tester.widget<Text>(current).data, '当前位于：$folder');
      expect(tester.widget<Text>(current).maxLines, isNull);
      expect(tester.getRect(current).right, lessThanOrEqualTo(320));
      expect(tester.takeException(), isNull);
    },
  );

  for (final textScale in [1.0, 2.0]) {
    testWidgets(
      'short landscape folder picker scrolls its header and folders at $textScale',
      (tester) async {
        await tester.binding.setSurfaceSize(const Size(640, 240));
        addTearDown(() => tester.binding.setSurfaceSize(null));
        final folders = [
          for (var index = 0; index < 16; index++) _folder('截图 $index'),
        ];
        String? result;
        await tester.pumpWidget(
          _app(
            Builder(
              builder: (context) => Scaffold(
                body: TextButton(
                  onPressed: () async {
                    result = await Navigator.push<String>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => PreviewExportFolderPicker(
                          workspacePath: 'web://',
                          initialFolder: '.',
                          t: _t,
                          listFolders: (path) async =>
                              path == 'web://' ? folders : [],
                        ),
                      ),
                    );
                  },
                  child: const Text('Open'),
                ),
              ),
            ),
            textScale,
          ),
        );
        await tester.tap(find.text('Open'));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
        final list = find.byKey(const ValueKey('previewExportFoldersScroll'));
        expect(
          find.descendant(
            of: list,
            matching: find.byKey(const ValueKey('previewExportCurrentFolder')),
          ),
          findsOneWidget,
        );
        final scrollable = find.descendant(
          of: list,
          matching: find.byType(Scrollable),
        );
        final lastFolder = find.byKey(
          const ValueKey('previewExportFolder-截图 15'),
        );
        await _scrollAndTap(tester, lastFolder, scrollable);
        final select = find.byKey(const ValueKey('previewExportSelectFolder'));
        expect(tester.getRect(select).bottom, lessThanOrEqualTo(240));
        await tester.tap(select.hitTestable());
        await tester.pumpAndSettle();
        expect(result, '截图 15');
        expect(tester.takeException(), isNull);
      },
    );
  }

  testWidgets(
    'short landscape settings can scroll to style and save controls',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(640, 240));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      await tester.pumpWidget(_app(PreviewSettingsScreen(host: _Host()), 2));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      final scrollable = find.byType(Scrollable);
      final compact = find.byKey(const ValueKey('previewToolbarStyleCompact'));
      await _scrollAndTap(
        tester,
        compact,
        scrollable,
        // A multi-line radio tile can be taller than the short viewport. Its
        // visible upper portion is still a usable part of the same control.
        alignment: const Alignment(0, -0.6),
      );
      final save = find.widgetWithText(FilledButton, 'Save');
      await _scrollAndTap(tester, save, scrollable);
      expect(await PreviewToolbarPrefs.getStyle(), PreviewToolbarStyle.compact);
      expect(tester.takeException(), isNull);
    },
  );
}
