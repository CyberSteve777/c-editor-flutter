part of 'app_navigation_cubit.dart';

enum AppScreen { levelList, editor, about, plugins }

final class AppNavigationState extends Equatable {
  const AppNavigationState({
    this.screen = AppScreen.levelList,
    this.editorFileName = '',
    this.editorFilePath = '',
    this.lastOpenedLevelPath = '',
    this.showUploadAfterLevelReturn = false,
  });

  final AppScreen screen;
  final String editorFileName;
  final String editorFilePath;
  final String lastOpenedLevelPath;
  final bool showUploadAfterLevelReturn;

  AppNavigationState copyWith({
    AppScreen? screen,
    String? editorFileName,
    String? editorFilePath,
    String? lastOpenedLevelPath,
    bool? showUploadAfterLevelReturn,
  }) {
    return AppNavigationState(
      screen: screen ?? this.screen,
      editorFileName: editorFileName ?? this.editorFileName,
      editorFilePath: editorFilePath ?? this.editorFilePath,
      lastOpenedLevelPath: lastOpenedLevelPath ?? this.lastOpenedLevelPath,
      showUploadAfterLevelReturn:
          showUploadAfterLevelReturn ?? this.showUploadAfterLevelReturn,
    );
  }

  @override
  List<Object?> get props => [
    screen,
    editorFileName,
    editorFilePath,
    lastOpenedLevelPath,
    showUploadAfterLevelReturn,
  ];
}
