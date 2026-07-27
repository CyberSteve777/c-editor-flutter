part of 'app_navigation_cubit.dart';

enum AppScreen { levelList, editor, about, plugins }

final class AppNavigationState extends Equatable {
  const AppNavigationState({
    this.screen = AppScreen.levelList,
    this.editorFileName = '',
    this.editorFilePath = '',
  });

  final AppScreen screen;
  final String editorFileName;
  final String editorFilePath;

  AppNavigationState copyWith({
    AppScreen? screen,
    String? editorFileName,
    String? editorFilePath,
  }) {
    return AppNavigationState(
      screen: screen ?? this.screen,
      editorFileName: editorFileName ?? this.editorFileName,
      editorFilePath: editorFilePath ?? this.editorFilePath,
    );
  }

  @override
  List<Object?> get props => [screen, editorFileName, editorFilePath];
}
