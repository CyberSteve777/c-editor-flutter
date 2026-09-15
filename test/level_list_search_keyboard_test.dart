import 'dart:io';

import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/level_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('level search keeps focus when the mobile keyboard opens', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(420, 720);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);

    // A missing path is sufficient here: the startup cache renders the
    // header synchronously, while the background load fails quickly without
    // touching the real level library.
    final libraryPath =
        '${Directory.current.path}${Platform.pathSeparator}'
        '__missing_level_search_test__';

    SharedPreferences.setMockInitialValues({
      'folder_path': libraryPath,
      'locale': 'en',
      'theme_mode': 'light',
    });
    final prefs = await SharedPreferences.getInstance();
    await LevelRepository.preloadLibrarySettings(prefs);
    final settings = SettingsCubit(prefs);
    addTearDown(settings.close);

    await tester.pumpWidget(
      BlocProvider.value(
        value: settings,
        child: MaterialApp(
          theme: ThemeData(platform: TargetPlatform.android),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: LevelListScreen(
            onLevelClick: (_, _, _, _, _) {},
            onAboutClick: () {},
            onPluginsClick: () {},
            onLanguageTap: (_) {},
          ),
        ),
      ),
    );
    // The list begins loading asynchronously and shows an indeterminate
    // progress indicator. A bounded pump is enough because the startup cache
    // builds the header synchronously, while pumpAndSettle can wait forever
    // for that indicator's animation.
    await tester.pump(const Duration(milliseconds: 100));

    final search = find.byKey(const ValueKey('levelListSearchField'));
    expect(search, findsOneWidget);
    expect(
      find.ancestor(of: search, matching: find.byType(SingleChildScrollView)),
      findsNothing,
    );
    await tester.tap(search);
    await tester.showKeyboard(search);
    await tester.pump();

    final focusNode = tester
        .widget<EditableText>(
          find.descendant(of: search, matching: find.byType(EditableText)),
        )
        .focusNode;
    expect(focusNode.hasFocus, isTrue);
    expect(tester.testTextInput.isRegistered, isTrue);
    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: 'zhong',
        selection: TextSelection.collapsed(offset: 5),
        composing: TextRange(start: 0, end: 5),
      ),
    );
    await tester.pump();
    expect(
      tester
          .widget<EditableText>(
            find.descendant(of: search, matching: find.byType(EditableText)),
          )
          .controller
          .value
          .composing,
      const TextRange(start: 0, end: 5),
    );

    // Opening a mobile IME reduces the Scaffold body below the old 300px
    // layout breakpoint. The search field must remain the same focused
    // element while that inset animates in.
    tester.view.viewInsets = const FakeViewPadding(bottom: 440);
    // A focused EditableText keeps scheduling cursor-blink frames, so waiting
    // for the entire tree to settle would never finish. One bounded frame is
    // sufficient for Scaffold and LayoutBuilder to apply the new inset.
    await tester.pump(const Duration(milliseconds: 100));

    final resizedEditable = tester.widget<EditableText>(
      find.descendant(of: search, matching: find.byType(EditableText)),
    );
    expect(
      find.ancestor(of: search, matching: find.byType(SingleChildScrollView)),
      findsOneWidget,
    );
    expect(resizedEditable.focusNode, same(focusNode));
    expect(focusNode.hasFocus, isTrue);
    expect(tester.testTextInput.isRegistered, isTrue);
    expect(resizedEditable.controller.text, 'zhong');
    expect(
      resizedEditable.controller.value.composing,
      const TextRange(start: 0, end: 5),
    );

    tester.testTextInput.updateEditingValue(
      const TextEditingValue(
        text: '中',
        selection: TextSelection.collapsed(offset: 1),
      ),
    );
    await tester.pump();
    expect(resizedEditable.controller.text, '中');
    expect(tester.takeException(), isNull);
  });
}
