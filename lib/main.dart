import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/app.dart';
import 'package:c_editor/bloc/app_navigation/app_navigation_cubit.dart';
import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/ambient_audio_catalog.dart';
import 'package:c_editor/data/music_suffix_catalog.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/l10n/resource_names.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final previousOnError = FlutterError.onError;
  FlutterError.onError = (details) {
    final message = details.exceptionAsString();
    final isKnownHardwareKeyboardAssertion =
        (message.contains('A KeyDownEvent is dispatched') &&
            message.contains('physical key is already pressed')) ||
        (message.contains('Attempted to send a key down event') &&
            message.contains('no keys are in keysPressed'));
    if (isKnownHardwareKeyboardAssertion) {
      debugPrint('Ignored known Flutter keyboard assertion: $message');
      return;
    }
    if (previousOnError != null) {
      previousOnError(details);
    } else {
      FlutterError.presentError(details);
    }
  };

  await ResourceNames.ensureLoaded();
  await StageRepository.init();
  await CustomStagePresetRepository.init();
  await MusicSuffixCatalog.init();
  await AmbientAudioCatalog.init();
  await GridItemRepository.init();
  await ZombossMechRepository.init();
  await ZombossBattleRepository.init();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(prefs)),
        BlocProvider(create: (_) => AppNavigationCubit()),
      ],
      child: const ZEditorApp(),
    ),
  );
}
