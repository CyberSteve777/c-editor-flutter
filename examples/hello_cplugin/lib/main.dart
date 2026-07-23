import 'package:flutter/material.dart';
import 'package:c_editor/plugin_api.dart';

/// C-Editor plugin entrypoint (`package:hello_cplugin/main.dart`).
///
/// Named `main.dart` so dart_eval's default entrypoint list (`/main.dart`)
/// keeps [initialize] in the bytecode.
///
/// - **Debug:** run `debug_host/` with hot reload (`flutter run`).
/// - **Ship:** compile to EVC and pack as `.cplugin`.
///
/// Prefer non-`const` constructors — dart_eval support for const is limited.
/// Use string slot names (`'editorAppBar'`, …) so dart_eval does not need
/// extra bridges for [CPluginUiSlots].
void initialize(CPluginHost host) {
  host.registerScreen('hello', 'Hello Plugin', (context) {
    return Scaffold(
      appBar: AppBar(title: Text('Hello Plugin')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            editorWarningBanner(
              title: 'Plugin loaded',
              message:
                  'This screen was registered by a .cplugin via flutter_eval.',
            ),
            SizedBox(height: 16.0),
            Text('Plugin id: ' + host.pluginId),
            SizedBox(height: 16.0),
            hostAssetImage(
              assetPath: 'images/round_icons/Stage_Modern.png',
              width: 64.0,
              height: 64.0,
            ),
            SizedBox(height: 16.0),
            pvzAddButton(
              onPressed: () {},
              label: 'Host PvzAddButton',
            ),
          ],
        ),
      ),
    );
  });

  host.registerUiElement(
    'hello_toolbar',
    'Hello tool',
    'editorAppBar',
    (context) {
      final open = host.hasOpenLevel;
      final name = host.openLevelFileName ?? '(none)';
      final path = host.openLevelPath ?? '(none)';
      final json = host.getOpenLevelJson();
      final length = json == null ? 0 : json.length;
      return Scaffold(
        appBar: AppBar(title: Text('Hello tool')),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(open ? 'Level is open' : 'No level open'),
              SizedBox(height: 8.0),
              Text('File: ' + name),
              SizedBox(height: 8.0),
              Text('Path: ' + path),
              SizedBox(height: 8.0),
              Text('JSON length: ' + length.toString()),
            ],
          ),
        ),
      );
    },
  );

  host.registerUiElement(
    'hello_overflow',
    'Hello overflow',
    'editorOverflow',
    (context) {
      return Scaffold(
        appBar: AppBar(title: Text('Hello overflow')),
        body: Center(child: Text('Opened from editor overflow')),
      );
    },
  );
}
