import 'package:c_editor/bloc/editor/editor_cubit.dart';

/// Tracks the [EditorCubit] for the currently open level editor, if any.
///
/// Plugin hosts read/write level JSON through this session because plugin
/// routes are pushed above the editor and cannot `context.read<EditorCubit>()`.
class ActiveEditorSession {
  ActiveEditorSession._();

  static final ActiveEditorSession instance = ActiveEditorSession._();

  EditorCubit? _cubit;

  EditorCubit? get cubit {
    final c = _cubit;
    if (c == null || c.isClosed) return null;
    return c;
  }

  bool get hasOpenLevel {
    final c = cubit;
    return c != null && c.state.levelFile != null;
  }

  String? get openLevelPath => cubit?.filePath;

  String? get openLevelFileName => cubit?.fileName;

  void bind(EditorCubit cubit) {
    _cubit = cubit;
  }

  void clear() {
    _cubit = null;
  }

  /// Clears only if [cubit] is still the bound instance.
  void clearIf(EditorCubit cubit) {
    if (_cubit == cubit) {
      _cubit = null;
    }
  }
}
