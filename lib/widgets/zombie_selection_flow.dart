import 'package:flutter/material.dart';

import 'package:c_editor/bloc/editor/editor_cubit.dart';

import 'package:c_editor/screens/select/zombie_selection_screen.dart';



/// Pushes zombie selection and returns the chosen zombie id, or null if cancelled.

Future<String?> pushZombieSelection(

  BuildContext context, {

  EditorCubit? editorCubit,

}) {

  return Navigator.of(context, rootNavigator: true).push<String>(

    MaterialPageRoute(

      builder: (ctx) => ZombieSelectionScreen(

        editorCubit: editorCubit,

        multiSelect: false,

        onZombieSelected: (id) => Navigator.pop(ctx, id),

        onMultiZombieSelected: (_) {},

        onBack: () => Navigator.pop(ctx),

      ),

    ),

  );

}


