import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'app_navigation_state.dart';

class AppNavigationCubit extends Cubit<AppNavigationState> {
  AppNavigationCubit() : super(const AppNavigationState());

  void openLevel(String fileName, String filePath) {
    emit(
      state.copyWith(
        screen: AppScreen.editor,
        editorFileName: fileName,
        editorFilePath: filePath,
        lastOpenedLevelPath: filePath,
        showUploadAfterLevelReturn: false,
      ),
    );
  }

  void openAbout() {
    emit(
      state.copyWith(
        screen: AppScreen.about,
        showUploadAfterLevelReturn: false,
      ),
    );
  }

  void openPlugins() {
    emit(
      state.copyWith(
        screen: AppScreen.plugins,
        showUploadAfterLevelReturn: false,
      ),
    );
  }

  void backToLevelList() {
    final returningFromEditor = state.screen == AppScreen.editor;
    emit(
      state.copyWith(
        screen: AppScreen.levelList,
        editorFileName: '',
        editorFilePath: '',
        showUploadAfterLevelReturn: returningFromEditor,
      ),
    );
  }
}
