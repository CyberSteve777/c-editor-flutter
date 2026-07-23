import 'package:flutter/material.dart';
import 'package:c_editor/plugin_api.dart';

/// C-Editor plugin entrypoint. Compiled to EVC and packaged as `.cplugin`.
///
/// Prefer non-`const` constructors — dart_eval support for const is limited.
void initialize(CPluginHost host) {
  host.registerScreen('hello', 'Hello Plugin', (context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Hello Plugin'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            editorWarningBanner(
              title: 'Plugin loaded',
              message:
                  'This screen was registered by a .cplugin via flutter_eval.',
            ),
            SizedBox(height: 16),
            Text('Plugin id: ' + host.pluginId),
            SizedBox(height: 16),
            hostAssetImage(
              assetPath: 'images/round_icons/Stage_Modern.png',
              width: 64,
              height: 64,
            ),
            SizedBox(height: 16),
            pvzAddButton(
              onPressed: () {},
              label: 'Host PvzAddButton',
            ),
          ],
        ),
      ),
    );
  });
}
