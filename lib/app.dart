import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:c_editor/escape_override.dart';
import 'package:path/path.dart' as p;
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/bloc/app_navigation/app_navigation_cubit.dart';
import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/bloc/editor/editor_cubit.dart';
import 'package:c_editor/screens/about_screen.dart';
import 'package:c_editor/screens/editor_screen.dart';
import 'package:c_editor/screens/level_list_screen.dart';
import 'package:c_editor/theme/app_theme.dart';

/// Wraps child and handles Escape key on desktop to trigger back/pop.
/// Uses HardwareKeyboard.addHandler for immediate, global Escape handling.
class _DesktopEscapeHandler extends StatefulWidget {
  const _DesktopEscapeHandler({
    required this.child,
    required this.onEscapeNoRouteToPop,
  });

  final Widget child;
  final VoidCallback? onEscapeNoRouteToPop;

  @override
  State<_DesktopEscapeHandler> createState() => _DesktopEscapeHandlerState();
}

class _DesktopEscapeHandlerState extends State<_DesktopEscapeHandler> {
  late final KeyEventCallback _keyHandler;

  @override
  void initState() {
    super.initState();
    _keyHandler = _handleKeyEvent;
    HardwareKeyboard.instance.addHandler(_keyHandler);
  }

  @override
  void dispose() {
    HardwareKeyboard.instance.removeHandler(_keyHandler);
    super.dispose();
  }

  bool _handleKeyEvent(KeyEvent event) {
    if (event is KeyRepeatEvent) return false;
    if (event is! KeyDownEvent) return false;
    if (event.logicalKey != LogicalKeyboardKey.escape) return false;
    if (!mounted) return false;

    final platform = Theme.of(context).platform;
    if (platform != TargetPlatform.windows &&
        platform != TargetPlatform.macOS &&
        platform != TargetPlatform.linux) {
      return false;
    }

    final nav = Navigator.maybeOf(context);
    if (nav != null && nav.canPop()) {
      if (EscapeOverride.tryHandle?.call() == true) return true;
      nav.pop();
      return true;
    }

    widget.onEscapeNoRouteToPop?.call();
    return true;
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class ZEditorApp extends StatefulWidget {
  const ZEditorApp({super.key});

  @override
  State<ZEditorApp> createState() => _ZEditorAppState();
}

class _ZEditorAppState extends State<ZEditorApp> {
  Future<bool> Function()? _editorBackHandler;

  void _backToLevelList(BuildContext context) {
    context.read<AppNavigationCubit>().backToLevelList();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settings) {
        return MaterialApp(
          title: 'C-Editor',
          debugShowCheckedModeBanner: false,
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: settings.themeMode,
          locale: settings.locale,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          builder: (context, child) {
            var scale = settings.uiScale;
            final mediaQuery = MediaQuery.of(context);
            final viewportSize = mediaQuery.size;
            if (mediaQuery.size.shortestSide < 600) {
              scale *= 0.85;
            }
            final scaledSize = Size(
              viewportSize.width / scale,
              viewportSize.height / scale,
            );
            EdgeInsets scaleInsets(EdgeInsets e) => EdgeInsets.fromLTRB(
              e.left / scale,
              e.top / scale,
              e.right / scale,
              e.bottom / scale,
            );
            return MediaQuery(
              data: mediaQuery.copyWith(
                size: scaledSize,
                padding: scaleInsets(mediaQuery.padding),
                viewPadding: scaleInsets(mediaQuery.viewPadding),
                viewInsets: scaleInsets(mediaQuery.viewInsets),
                textScaler: TextScaler.linear(1.0),
              ),
              child: FittedBox(
                fit: BoxFit.contain,
                alignment: Alignment.topLeft,
                child: SizedBox(
                  width: scaledSize.width,
                  height: scaledSize.height,
                  child: child,
                ),
              ),
            );
          },
          home: BlocBuilder<AppNavigationCubit, AppNavigationState>(
            builder: (context, nav) {
              final appNav = context.read<AppNavigationCubit>();
              return _DesktopEscapeHandler(
                onEscapeNoRouteToPop: () {
                  if (nav.screen == AppScreen.levelList) {
                    SystemNavigator.pop();
                  } else if (nav.screen == AppScreen.editor &&
                      _editorBackHandler != null) {
                    _editorBackHandler!().then((leave) {
                      if (leave && mounted) {
                        appNav.backToLevelList();
                      }
                    });
                  } else if (mounted) {
                    appNav.backToLevelList();
                  }
                },
                child: PopScope(
                  canPop: false,
                  onPopInvokedWithResult: (didPop, _) async {
                    if (didPop) return;
                    if (nav.screen == AppScreen.levelList) {
                      SystemNavigator.pop();
                    } else if (nav.screen == AppScreen.editor &&
                        _editorBackHandler != null) {
                      final shouldLeave = await _editorBackHandler!();
                      if (shouldLeave && mounted) {
                        appNav.backToLevelList();
                      }
                    } else if (mounted) {
                      appNav.backToLevelList();
                    }
                  },
                  child: _buildCurrentScreen(context, nav),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildCurrentScreen(BuildContext context, AppNavigationState nav) {
    switch (nav.screen) {
      case AppScreen.levelList:
        return LevelListScreen(
          onLevelClick: (fileName, filePath) {
            LevelRepository.setLastOpenedLevelDirectory(p.dirname(filePath));
            context.read<AppNavigationCubit>().openLevel(fileName, filePath);
          },
          onAboutClick: () => context.read<AppNavigationCubit>().openAbout(),
          onLanguageTap: _showLanguageSelector,
        );
      case AppScreen.editor:
        return BlocProvider(
          key: ValueKey(nav.editorFilePath),
          create: (_) => EditorCubit(
            fileName: nav.editorFileName,
            filePath: nav.editorFilePath,
          )..loadLevel(),
          child: EditorScreen(
            onBack: () => _backToLevelList(context),
            onRegisterBackHandler: (handler) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() => _editorBackHandler = handler);
              });
            },
            onLanguageTap: _showLanguageSelector,
          ),
        );
      case AppScreen.about:
        return AboutScreen(onBack: () => _backToLevelList(context));
    }
  }

  void _showLanguageSelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final languageTitle = l10n?.language ?? 'Language';
    final languageEnglish = l10n?.languageEnglish ?? 'English';
    final languageChinese = l10n?.languageChinese ?? '中文';
    final languageRussian = l10n?.languageRussian ?? 'Русский';
    showModalBottomSheet<void>(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(languageTitle, style: Theme.of(ctx).textTheme.titleLarge),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(languageEnglish),
              onTap: () {
                context.read<SettingsCubit>().setLocale(const Locale('en'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.translate),
              title: Text(languageChinese),
              onTap: () {
                context.read<SettingsCubit>().setLocale(const Locale('zh'));
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.translate),
              title: Text(languageRussian),
              onTap: () {
                context.read<SettingsCubit>().setLocale(const Locale('ru'));
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
