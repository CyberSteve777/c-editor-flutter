import 'package:c_editor/plugins/debug/plugin_debug_app.dart';
import 'package:flutter/material.dart';
import 'package:hello_cplugin/main.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const PluginDebugApp(
      pluginId: 'com.example.hello',
      title: 'Hello Plugin Debug',
      initialize: initialize,
    ),
  );
}
