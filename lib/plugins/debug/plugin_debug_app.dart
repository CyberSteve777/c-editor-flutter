import 'package:flutter/material.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/debug/debug_plugin_host.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';
import 'package:c_editor/theme/app_theme.dart';

/// Flutter shell for debugging a C-Editor plugin with hot reload.
///
/// Use from a plugin project's `debug_host` app:
///
/// ```dart
/// void main() {
///   runApp(PluginDebugApp(
///     pluginId: 'com.example.hello',
///     initialize: initialize,
///   ));
/// }
/// ```
class PluginDebugApp extends StatefulWidget {
  const PluginDebugApp({
    super.key,
    required this.initialize,
    this.pluginId = 'debug.plugin',
    this.title = 'C-Editor Plugin Debug',
  });

  final void Function(CPluginHost host) initialize;
  final String pluginId;
  final String title;

  @override
  State<PluginDebugApp> createState() => _PluginDebugAppState();
}

class _PluginDebugAppState extends State<PluginDebugApp> {
  late final DebugPluginHost _host;
  Object? _initError;

  @override
  void initState() {
    super.initState();
    _host = DebugPluginHost(pluginId: widget.pluginId);
    try {
      widget.initialize(_host);
    } catch (e, st) {
      _initError = '$e\n$st';
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: widget.title,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      home: _initError != null
          ? Scaffold(
              appBar: AppBar(title: Text(widget.title)),
              body: Padding(
                padding: const EdgeInsets.all(16),
                child: SelectableText(
                  'Plugin initialize() failed:\n\n$_initError',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            )
          : _PluginDebugHome(
              title: widget.title,
              registry: _host.registry,
            ),
    );
  }
}

class _PluginDebugHome extends StatelessWidget {
  const _PluginDebugHome({
    required this.title,
    required this.registry,
  });

  final String title;
  final PluginScreenRegistry registry;

  void _open(BuildContext context, CPluginScreenBuilder builder) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: builder),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: registry,
      builder: (context, _) {
        final screens = registry.screens;
        final appBar = registry.elementsForSlot(CPluginUiSlots.editorAppBar);
        final editorOverflow =
            registry.elementsForSlot(CPluginUiSlots.editorOverflow);
        final levelOverflow =
            registry.elementsForSlot(CPluginUiSlots.levelListOverflow);

        return Scaffold(
          appBar: AppBar(
            title: Text(title),
            actions: [
              for (final el in appBar)
                IconButton(
                  icon: Icon(el.icon),
                  tooltip: el.title,
                  onPressed: () => _open(context, el.builder),
                ),
              if (editorOverflow.isNotEmpty)
                PopupMenuButton<PluginUiElement>(
                  tooltip: 'Editor overflow (plugin)',
                  itemBuilder: (context) => [
                    for (final el in editorOverflow)
                      PopupMenuItem(
                        value: el,
                        child: ListTile(
                          leading: Icon(el.icon),
                          title: Text(el.title),
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                  ],
                  onSelected: (el) => _open(context, el.builder),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                'Hot-reload this debug host while editing your plugin. '
                'Registered screens and UI slots appear below / in the AppBar.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Text(
                'Screens (registerScreen)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (screens.isEmpty)
                const Text('None registered')
              else
                ...screens.map(
                  (s) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.web_asset),
                      title: Text(s.title),
                      subtitle: Text(s.key),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _open(context, s.builder),
                    ),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'Editor AppBar (editorAppBar)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (appBar.isEmpty)
                const Text('None — icons would show in the AppBar above')
              else
                ...appBar.map(
                  (el) => ListTile(
                    leading: Icon(el.icon),
                    title: Text(el.title),
                    subtitle: Text(el.key),
                    onTap: () => _open(context, el.builder),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'Editor overflow (editorOverflow)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (editorOverflow.isEmpty)
                const Text('None — use the ⋮ menu in the AppBar')
              else
                ...editorOverflow.map(
                  (el) => ListTile(
                    leading: Icon(el.icon),
                    title: Text(el.title),
                    onTap: () => _open(context, el.builder),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                'Level list overflow (levelListOverflow)',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (levelOverflow.isEmpty)
                const Text('None registered')
              else
                ...levelOverflow.map(
                  (el) => ListTile(
                    leading: Icon(el.icon),
                    title: Text(el.title),
                    onTap: () => _open(context, el.builder),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
