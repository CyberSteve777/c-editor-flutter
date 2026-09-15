import 'package:flutter/material.dart';
import 'package:c_editor/plugin_api.dart';

/// C-Editor plugin entrypoint (`package:hello_cplugin/main.dart`).
///
/// Prefer widgets already bridged by flutter_eval. Avoid StatefulWidget,
/// StatefulBuilder, FilledButton, showDialog, and dart:convert where possible.
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

  host.registerScreen('settings', 'helloSettingsTitle', (context) {
    final controller = TextEditingController();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          host.localize(context, 'helloSettingsTitle', 'Hello settings'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(host.localize(context, 'configGreeting', 'Greeting')),
            SizedBox(height: 8.0),
            Text(
              host.localize(
                context,
                'configGreetingDescription',
                'Saved with host.readConfigJson / writeConfigJson.',
              ),
            ),
            SizedBox(height: 12.0),
            TextField(
              controller: controller,
              decoration: InputDecoration(
                hintText: host.localize(
                  context,
                  'configGreetingHint',
                  'e.g. Hello · Привет · 你好',
                ),
              ),
            ),
            SizedBox(height: 12.0),
            ElevatedButton(
              onPressed: () async {
                final raw = await host.readConfigJson();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(raw)),
                );
              },
              child: Text('Load'),
            ),
            SizedBox(height: 8.0),
            ElevatedButton(
              onPressed: () async {
                final text = controller.text;
                final escaped = text
                    .replaceAll('\\', '\\\\')
                    .replaceAll('"', '\\"');
                await host.writeConfigJson(
                  '{"greeting":"' + escaped + '"}',
                );
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      host.localize(
                        context,
                        'helloSettingsSaved',
                        'Settings saved',
                      ),
                    ),
                  ),
                );
              },
              child: Text(
                host.localize(context, 'helloSettingsSave', 'Save'),
              ),
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
