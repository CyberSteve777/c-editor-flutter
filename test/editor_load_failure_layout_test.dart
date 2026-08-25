import 'package:c_editor/bloc/editor/editor_cubit.dart';
import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/editor_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _FailureEditorCubit extends EditorCubit {
  _FailureEditorCubit()
    : super(fileName: 'egypt1.json', filePath: 'egypt1.json');

  void showLoadFailure() {
    emit(const EditorState(isLoading: false));
  }
}

void main() {
  testWidgets('load failure message stays centered on a narrow screen', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(360, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    SharedPreferences.setMockInitialValues({
      'locale': 'en',
      'theme_mode': 'light',
    });
    final prefs = await SharedPreferences.getInstance();
    final editorCubit = _FailureEditorCubit()..showLoadFailure();
    addTearDown(editorCubit.close);

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<EditorCubit>.value(value: editorCubit),
          BlocProvider(create: (_) => SettingsCubit(prefs)),
        ],
        child: MaterialApp(
          locale: const Locale('en'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: EditorScreen(
            onBack: () {},
            onRegisterBackHandler: (_) {},
            onLanguageTap: (_) {},
          ),
        ),
      ),
    );
    await tester.pump();

    final messageFinder = find.byKey(
      const ValueKey('level-load-failure-message'),
    );
    expect(messageFinder, findsOneWidget);

    final message = tester.widget<Text>(messageFinder);
    expect(message.textAlign, TextAlign.center);

    final messageRect = tester.getRect(messageFinder);
    expect(messageRect.left, greaterThanOrEqualTo(24));
    expect(messageRect.right, lessThanOrEqualTo(336));
    expect(messageRect.center.dx, closeTo(180, 0.5));
  });
}
