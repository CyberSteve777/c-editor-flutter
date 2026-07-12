import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/app.dart';
import 'package:c_editor/bloc/app_navigation/app_navigation_cubit.dart';
import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/data/app_bootstrap.dart';
import 'package:c_editor/screens/startup_loading_screen.dart';

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

  final prefs = await SharedPreferences.getInstance();

  runApp(BootstrapApp(prefs: prefs));
}

class BootstrapApp extends StatefulWidget {
  const BootstrapApp({super.key, required this.prefs});

  final SharedPreferences prefs;

  @override
  State<BootstrapApp> createState() => _BootstrapAppState();
}

class _BootstrapAppState extends State<BootstrapApp> {
  double _progress = 0;
  String? _statusLabel;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    await AppBootstrap.load(
      onProgress: (progress, label) {
        if (!mounted) return;
        setState(() {
          _progress = progress;
          _statusLabel = label;
        });
      },
    );
    if (!mounted) return;
    setState(() => _ready = true);
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return StartupLoadingScreen(
        progress: _progress,
        statusLabel: _statusLabel,
      );
    }

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => SettingsCubit(widget.prefs)),
        BlocProvider(create: (_) => AppNavigationCubit()),
      ],
      child: const ZEditorApp(),
    );
  }
}
