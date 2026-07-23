import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugins/c_plugin_validator.dart';
import 'package:c_editor/plugins/plugin_file_read_stub.dart'
    if (dart.library.io) 'package:c_editor/plugins/plugin_file_read_io.dart'
    as file_read;
import 'package:c_editor/plugins/plugin_manager.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';
import 'package:c_editor/plugins/plugin_storage.dart';
import 'package:c_editor/widgets/editor_components.dart';

class PluginsScreen extends StatefulWidget {
  const PluginsScreen({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  State<PluginsScreen> createState() => _PluginsScreenState();
}

class _PluginsScreenState extends State<PluginsScreen> {
  PluginManager get _manager => PluginManager.instance;

  bool _busy = false;
  double? _downloadProgress;
  String? _statusMessage;

  Future<void> _refresh() async {
    await _manager.reload();
    if (mounted) setState(() {});
  }

  Future<void> _installLocal() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['cplugin'],
      withData: true,
    );
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    Uint8List? bytes = file.bytes;
    if (bytes == null && file.path != null) {
      try {
        bytes = await file_read.readPluginFileBytes(file.path!);
      } catch (_) {
        bytes = null;
      }
    }
    if (bytes == null) {
      _showError(l10n.pluginReadFailed);
      return;
    }

    await _runInstall(() => _manager.installBytes(bytes!));
  }

  Future<void> _installFromUrl() async {
    final l10n = AppLocalizations.of(context)!;
    final controller = TextEditingController();
    final url = await showDialog<String>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(l10n.pluginInstallFromUrl),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: l10n.pluginUrlHint,
              labelText: 'URL',
            ),
            keyboardType: TextInputType.url,
            autofocus: true,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: Text(l10n.pluginDownload),
            ),
          ],
        );
      },
    );
    controller.dispose();
    if (url == null || url.isEmpty) return;

    final uri = Uri.tryParse(url);
    if (uri == null || !(uri.isScheme('http') || uri.isScheme('https'))) {
      _showError(l10n.pluginInvalidUrl);
      return;
    }

    await _runInstall(
      () => _manager.installFromUrl(
        uri,
        onProgress: (received, total) {
          if (!mounted) return;
          setState(() {
            _downloadProgress =
                total != null && total > 0 ? received / total : null;
            _statusMessage = total != null && total > 0
                ? l10n.pluginDownloadProgress(
                    _formatBytes(received),
                    _formatBytes(total),
                  )
                : l10n.pluginDownloadProgressUnknown(_formatBytes(received));
          });
        },
      ),
    );
  }

  Future<void> _runInstall(
    Future<InstalledPluginRecord> Function() action,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    setState(() {
      _busy = true;
      _downloadProgress = 0;
      _statusMessage = l10n.pluginInstalling;
    });
    try {
      final record = await action();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pluginInstallSuccess(record.manifest.name)),
        ),
      );
    } on CPluginValidationException catch (e) {
      _showError(l10n.pluginInvalidFile(e.message));
    } catch (e) {
      _showError(l10n.pluginInstallFailed(e.toString()));
    } finally {
      if (mounted) {
        setState(() {
          _busy = false;
          _downloadProgress = null;
          _statusMessage = null;
        });
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _toggleEnabled(
    InstalledPluginRecord plugin,
    bool enabled,
  ) async {
    setState(() => _busy = true);
    try {
      await _manager.setEnabled(plugin.id, enabled);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _uninstall(InstalledPluginRecord plugin) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.pluginUninstallTitle),
        content: Text(l10n.pluginUninstallConfirm(plugin.manifest.name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.pluginUninstall),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    setState(() => _busy = true);
    try {
      await _manager.uninstall(plugin.id);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _openScreen(PluginRegisteredScreen screen) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => screen.builder(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: Listenable.merge([_manager, _manager.screenRegistry]),
      builder: (context, _) {
        final plugins = _manager.installed;
        final screens = _manager.screenRegistry.screens;
        return Scaffold(
          appBar: AppBar(
            title: Text(l10n.pluginsTitle),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBack,
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: l10n.refresh,
                onPressed: _busy ? null : _refresh,
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              EditorWarningBanner(
                title: l10n.pluginTrustWarningTitle,
                message: l10n.pluginTrustWarningBody,
              ),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton.icon(
                    onPressed: _busy ? null : _installLocal,
                    icon: const Icon(Icons.folder_open),
                    label: Text(l10n.pluginInstallFromDevice),
                  ),
                  OutlinedButton.icon(
                    onPressed: _busy ? null : _installFromUrl,
                    icon: const Icon(Icons.link),
                    label: Text(l10n.pluginInstallFromUrl),
                  ),
                ],
              ),
              if (_busy) ...[
                const SizedBox(height: 16),
                if (_downloadProgress != null)
                  LinearProgressIndicator(value: _downloadProgress)
                else
                  const LinearProgressIndicator(),
                if (_statusMessage != null) ...[
                  const SizedBox(height: 8),
                  Text(_statusMessage!),
                ],
              ],
              const SizedBox(height: 24),
              Text(
                l10n.pluginInstalledSection,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (plugins.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(l10n.pluginEmpty),
                )
              else
                ...plugins.map(
                  (plugin) => _PluginTile(
                    plugin: plugin,
                    busy: _busy,
                    onToggle: (v) => _toggleEnabled(plugin, v),
                    onUninstall: () => _uninstall(plugin),
                  ),
                ),
              const SizedBox(height: 24),
              Text(
                l10n.pluginScreensSection,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (screens.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Text(l10n.pluginNoScreens),
                )
              else
                ...screens.map(
                  (screen) => Card(
                    child: ListTile(
                      leading: const Icon(Icons.extension),
                      title: Text(screen.title),
                      subtitle: Text(screen.pluginId),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => _openScreen(screen),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  static String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}

class _PluginTile extends StatelessWidget {
  const _PluginTile({
    required this.plugin,
    required this.busy,
    required this.onToggle,
    required this.onUninstall,
  });

  final InstalledPluginRecord plugin;
  final bool busy;
  final ValueChanged<bool> onToggle;
  final VoidCallback onUninstall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final m = plugin.manifest;
    final subtitle = [
      if (m.author.isNotEmpty) m.author,
      'v${m.version}',
      if (plugin.loadError != null) l10n.pluginLoadError,
    ].join(' · ');

    return Card(
      child: ListTile(
        title: Text(m.name),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(subtitle),
            if (m.description.isNotEmpty) Text(m.description),
            if (plugin.loadError != null)
              Text(
                plugin.loadError!,
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
          ],
        ),
        isThreeLine: true,
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: plugin.enabled,
              onChanged: busy ? null : onToggle,
            ),
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: l10n.pluginUninstall,
              onPressed: busy ? null : onUninstall,
            ),
          ],
        ),
      ),
    );
  }
}
