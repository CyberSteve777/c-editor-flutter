part of 'app_navigation_cubit.dart';

enum AppScreen { levelList, editor, about, plugins }

final class AppNavigationState extends Equatable {
  const AppNavigationState({
    this.screen = AppScreen.levelList,
    this.editorFileName = '',
    this.editorFilePath = '',
    this.lastOpenedLevelPath = '',
    this.levelListScrollOffset = 0,
    this.levelListFavoritesView = false,
    this.levelListSearchQuery = '',
    this.showUploadAfterLevelReturn = false,
  });

  final AppScreen screen;
  final String editorFileName;
  final String editorFilePath;
  final String lastOpenedLevelPath;
  final double levelListScrollOffset;
  final bool levelListFavoritesView;
  final String levelListSearchQuery;
  final bool showUploadAfterLevelReturn;

  AppNavigationState copyWith({
    AppScreen? screen,
    String? editorFileName,
    String? editorFilePath,
    String? lastOpenedLevelPath,
    double? levelListScrollOffset,
    bool? levelListFavoritesView,
    String? levelListSearchQuery,
    bool? showUploadAfterLevelReturn,
  }) {
    return AppNavigationState(
      screen: screen ?? this.screen,
      editorFileName: editorFileName ?? this.editorFileName,
      editorFilePath: editorFilePath ?? this.editorFilePath,
      lastOpenedLevelPath: lastOpenedLevelPath ?? this.lastOpenedLevelPath,
      levelListScrollOffset:
          levelListScrollOffset ?? this.levelListScrollOffset,
      levelListFavoritesView:
          levelListFavoritesView ?? this.levelListFavoritesView,
      levelListSearchQuery: levelListSearchQuery ?? this.levelListSearchQuery,
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
    levelListScrollOffset,
    levelListFavoritesView,
    levelListSearchQuery,
    showUploadAfterLevelReturn,
  ];
}
