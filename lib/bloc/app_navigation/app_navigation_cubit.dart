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
      ),
    );
  }

  void openAbout() {
    emit(state.copyWith(screen: AppScreen.about));
  }

  void openPlugins() {
    emit(state.copyWith(screen: AppScreen.plugins));
  }

  void backToLevelList() {
    emit(
      state.copyWith(
        screen: AppScreen.levelList,
        editorFileName: '',
        editorFilePath: '',
      ),
    );
  }
}
