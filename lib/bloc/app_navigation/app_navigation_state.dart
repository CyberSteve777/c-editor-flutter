part of 'app_navigation_cubit.dart';

enum AppScreen { levelList, editor, about, plugins }

final class AppNavigationState extends Equatable {
  const AppNavigationState({
    this.screen = AppScreen.levelList,
    this.editorFileName = '',
    this.editorFilePath = '',
    this.lastOpenedLevelPath = '',
  });

  final AppScreen screen;
  final String editorFileName;
  final String editorFilePath;
  final String lastOpenedLevelPath;

  AppNavigationState copyWith({
    AppScreen? screen,
    String? editorFileName,
    String? editorFilePath,
    String? lastOpenedLevelPath,
  }) {
    return AppNavigationState(
      screen: screen ?? this.screen,
      editorFileName: editorFileName ?? this.editorFileName,
      editorFilePath: editorFilePath ?? this.editorFilePath,
      lastOpenedLevelPath: lastOpenedLevelPath ?? this.lastOpenedLevelPath,
    );
  }

  @override
  List<Object?> get props => [
    screen,
    editorFileName,
    editorFilePath,
    lastOpenedLevelPath,
  ];
}
