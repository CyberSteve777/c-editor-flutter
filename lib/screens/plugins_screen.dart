import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/launch_external_url.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugins/c_plugin_validator.dart';
import 'package:c_editor/plugins/plugin_file_read_stub.dart'
    if (dart.library.io) 'package:c_editor/plugins/plugin_file_read_io.dart'
    as file_read;
import 'package:c_editor/plugins/plugin_manager.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';
import 'package:c_editor/plugins/plugin_storage.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/widgets/app_message.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Plugin manager — master/detail layout inspired by Minecraft's mod menu.
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
  String _searchQuery = '';
  String? _selectedPluginId;

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

  Future<void> _installFromFolder() async {
    final path = await FilePicker.getDirectoryPath();
    if (path == null || path.isEmpty) return;
    await _runInstall(() => _manager.installFromSourceDirectory(path));
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
      setState(() => _selectedPluginId = record.id);
      AppMessage.show(
        context,
        l10n.pluginInstallSuccess(record.localizedName(
          Localizations.localeOf(context).languageCode,
        )),
        icon: Icons.check_circle,
      );
    } on CPluginValidationException catch (e) {
      _showError(l10n.pluginInvalidFile(e.message));
    } on StateError catch (e) {
      final msg = e.message;
      if (msg.toString().contains('level library')) {
        _showError(l10n.pluginNoLibraryForInstall);
      } else {
        _showError(l10n.pluginInstallFailed(e.toString()));
      }
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
    AppMessage.show(context, message, icon: Icons.error_outline);
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
        content: Text(l10n.pluginUninstallConfirm(plugin.localizedName(
          Localizations.localeOf(context).languageCode,
        ))),
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
      if (_selectedPluginId == plugin.id) {
        _selectedPluginId = null;
      }
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

  List<InstalledPluginRecord> _filtered(List<InstalledPluginRecord> plugins) {
    final lang = Localizations.localeOf(context).languageCode;
    return plugins.where((p) {
      final m = p.manifest;
      return matchesSelectionSearch(_searchQuery, [
        p.localizedName(lang),
        m.id,
        p.localizedDescription(lang),
        m.authorsDisplay,
        ...m.contributors,
        m.version,
      ]);
    }).toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ListenableBuilder(
      listenable: Listenable.merge([_manager, _manager.screenRegistry]),
      builder: (context, _) {
        final plugins = _filtered(_manager.installed);
        if (_selectedPluginId != null &&
            !_manager.installed.any((p) => p.id == _selectedPluginId)) {
          _selectedPluginId = null;
        }
        final selected = _selectedPluginId == null
            ? null
            : _manager.installed
                .where((p) => p.id == _selectedPluginId)
                .firstOrNull;

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
          body: LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 840;
              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                      child: EditorWarningBanner(
                        title: l10n.pluginTrustWarningTitle,
                        message: l10n.pluginTrustWarningBody,
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppBarSearchField(
                            hintText: l10n.pluginSearchHint,
                            query: _searchQuery,
                            onChanged: (v) =>
                                setState(() => _searchQuery = v),
                            onClear: () => setState(() => _searchQuery = ''),
                            foregroundColor:
                                Theme.of(context).colorScheme.onSurface,
                          ),
                          const SizedBox(height: 8),
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
                              if (!kIsWeb)
                                OutlinedButton.icon(
                                  onPressed:
                                      _busy ? null : _installFromFolder,
                                  icon: const Icon(
                                    Icons.folder_special_outlined,
                                  ),
                                  label: Text(l10n.pluginInstallFromFolder),
                                ),
                            ],
                          ),
                          if (!kIsWeb) ...[
                            const SizedBox(height: 6),
                            Text(
                              l10n.pluginFolderHint,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  if (_busy)
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_downloadProgress != null)
                              LinearProgressIndicator(value: _downloadProgress)
                            else
                              const LinearProgressIndicator(),
                            if (_statusMessage != null) ...[
                              const SizedBox(height: 6),
                              Text(_statusMessage!),
                            ],
                          ],
                        ),
                      ),
                    ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          plugins.isEmpty
                              ? l10n.pluginEmpty
                              : l10n.pluginShowingCount(plugins.length),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ),
                  ),
                  SliverFillRemaining(
                    hasScrollBody: true,
                    child: wide
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              SizedBox(
                                width: 340,
                                child: _PluginListPane(
                                  plugins: plugins,
                                  selectedId: _selectedPluginId,
                                  busy: _busy,
                                  onSelect: (id) => setState(
                                    () => _selectedPluginId = id,
                                  ),
                                ),
                              ),
                              const VerticalDivider(width: 1),
                              Expanded(
                                child: selected == null
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(32),
                                          child: Text(
                                            l10n.pluginSelectHint,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .onSurfaceVariant,
                                                ),
                                          ),
                                        ),
                                      )
                                    : _PluginDetailPane(
                                        plugin: selected,
                                        busy: _busy,
                                        screens: _manager
                                            .screenRegistry.screens
                                            .where(
                                              (s) =>
                                                  s.pluginId == selected.id,
                                            )
                                            .toList(growable: false),
                                        onToggle: (v) =>
                                            _toggleEnabled(selected, v),
                                        onUninstall: () =>
                                            _uninstall(selected),
                                        onOpenScreen: _openScreen,
                                      ),
                              ),
                            ],
                          )
                        : _PluginListPane(
                            plugins: plugins,
                            selectedId: _selectedPluginId,
                            busy: _busy,
                            onSelect: (id) {
                              final plugin = _manager.installed
                                  .where((p) => p.id == id)
                                  .firstOrNull;
                              if (plugin == null) return;
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => _PluginDetailPage(
                                    plugin: plugin,
                                    busy: _busy,
                                    screens: _manager.screenRegistry.screens
                                        .where((s) => s.pluginId == plugin.id)
                                        .toList(growable: false),
                                    onToggle: (v) =>
                                        _toggleEnabled(plugin, v),
                                    onUninstall: () => _uninstall(plugin),
                                    onOpenScreen: _openScreen,
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            },
          ),
          bottomNavigationBar: Material(
            elevation: 1,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: Text(
                  l10n.pluginDropHint,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
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

class _PluginListPane extends StatelessWidget {
  const _PluginListPane({
    required this.plugins,
    required this.selectedId,
    required this.busy,
    required this.onSelect,
  });

  final List<InstalledPluginRecord> plugins;
  final String? selectedId;
  final bool busy;
  final ValueChanged<String> onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (plugins.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.pluginEmpty, textAlign: TextAlign.center),
        ),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: plugins.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final plugin = plugins[index];
        final selected = plugin.id == selectedId;
        return _PluginListTile(
          plugin: plugin,
          selected: selected,
          onTap: busy ? null : () => onSelect(plugin.id),
        );
      },
    );
  }
}

class _PluginListTile extends StatelessWidget {
  const _PluginListTile({
    required this.plugin,
    required this.selected,
    required this.onTap,
  });

  final InstalledPluginRecord plugin;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final borderColor = selected ? scheme.primary : scheme.outlineVariant;
    final lang = Localizations.localeOf(context).languageCode;
    final name = plugin.localizedName(lang);
    final description = plugin.localizedDescription(lang);

    return Material(
      color: selected
          ? scheme.primaryContainer.withValues(alpha: 0.35)
          : scheme.surfaceContainerHighest.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: borderColor, width: selected ? 2 : 1),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PluginIcon(plugin: plugin, size: 40),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 6,
                      runSpacing: 2,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        _Badge(
                          label: plugin.isBundled
                              ? l10n.pluginBundledBadge
                              : l10n.pluginImportedBadge,
                          color: plugin.isBundled
                              ? scheme.tertiary
                              : scheme.secondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description.isEmpty
                          ? l10n.pluginNoDescription
                          : description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plugin.loadError != null
                          ? l10n.pluginLoadError
                          : (plugin.enabled
                              ? l10n.pluginEnabled
                              : l10n.pluginDisabled),
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: plugin.loadError != null || !plugin.enabled
                            ? scheme.error
                            : scheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PluginDetailPage extends StatelessWidget {
  const _PluginDetailPage({
    required this.plugin,
    required this.busy,
    required this.screens,
    required this.onToggle,
    required this.onUninstall,
    required this.onOpenScreen,
  });

  final InstalledPluginRecord plugin;
  final bool busy;
  final List<PluginRegisteredScreen> screens;
  final ValueChanged<bool> onToggle;
  final VoidCallback onUninstall;
  final ValueChanged<PluginRegisteredScreen> onOpenScreen;

  @override
  Widget build(BuildContext context) {
    final name = plugin.localizedName(
      Localizations.localeOf(context).languageCode,
    );
    return Scaffold(
      appBar: AppBar(title: Text(name)),
      body: _PluginDetailPane(
        plugin: plugin,
        busy: busy,
        screens: screens,
        onToggle: onToggle,
        onUninstall: onUninstall,
        onOpenScreen: onOpenScreen,
      ),
    );
  }
}

class _PluginDetailPane extends StatelessWidget {
  const _PluginDetailPane({
    required this.plugin,
    required this.busy,
    required this.screens,
    required this.onToggle,
    required this.onUninstall,
    required this.onOpenScreen,
  });

  final InstalledPluginRecord plugin;
  final bool busy;
  final List<PluginRegisteredScreen> screens;
  final ValueChanged<bool> onToggle;
  final VoidCallback onUninstall;
  final ValueChanged<PluginRegisteredScreen> onOpenScreen;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final m = plugin.manifest;
    final authors = m.authorsDisplay;
    final lang = Localizations.localeOf(context).languageCode;
    final name = plugin.localizedName(lang);
    final description = plugin.localizedDescription(lang);

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _PluginIcon(plugin: plugin, size: 72),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 6,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        name,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      _Badge(
                        label: plugin.isBundled
                            ? l10n.pluginBundledBadge
                            : l10n.pluginImportedBadge,
                        color: plugin.isBundled
                            ? theme.colorScheme.tertiary
                            : theme.colorScheme.secondary,
                      ),
                      _Badge(
                        label: plugin.enabled
                            ? l10n.pluginEnabled
                            : l10n.pluginDisabled,
                        color: plugin.enabled
                            ? theme.colorScheme.primary
                            : theme.colorScheme.error,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    l10n.pluginVersionLabel(m.version),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (authors.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      l10n.pluginByAuthors(authors),
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            if (m.website != null)
              OutlinedButton.icon(
                onPressed: () => launchExternalUrl(m.website!),
                icon: const Icon(Icons.public),
                label: Text(l10n.pluginLinkWebsite),
              ),
            if (m.issues != null)
              OutlinedButton.icon(
                onPressed: () => launchExternalUrl(m.issues!),
                icon: const Icon(Icons.bug_report_outlined),
                label: Text(l10n.pluginLinkIssues),
              ),
            if (m.source != null)
              OutlinedButton.icon(
                onPressed: () => launchExternalUrl(m.source!),
                icon: const Icon(Icons.code),
                label: Text(l10n.pluginLinkSource),
              ),
            if (m.discord != null)
              OutlinedButton.icon(
                onPressed: () => launchExternalUrl(m.discord!),
                icon: const Icon(Icons.forum_outlined),
                label: Text(l10n.pluginLinkDiscord),
              ),
          ],
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(l10n.pluginEnabled),
          value: plugin.enabled,
          onChanged: busy ? null : onToggle,
        ),
        if (plugin.canUninstall)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: busy ? null : onUninstall,
              icon: const Icon(Icons.delete_outline),
              label: Text(l10n.pluginUninstall),
            ),
          ),
        const SizedBox(height: 8),
        Text(
          description.isEmpty ? l10n.pluginNoDescription : description,
          style: theme.textTheme.bodyLarge,
        ),
        if (plugin.loadError != null) ...[
          const SizedBox(height: 12),
          Text(
            '${l10n.pluginLoadError}: ${plugin.loadError}',
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ],
        const SizedBox(height: 20),
        _MetaRow(label: l10n.pluginIdLabel, value: m.id),
        if (m.license != null)
          _MetaRow(label: l10n.pluginLicense, value: m.license!),
        if (m.resolvedAuthors.isNotEmpty)
          _MetaRow(
            label: l10n.pluginAuthors,
            value: m.resolvedAuthors.join(', '),
          ),
        if (m.contributors.isNotEmpty)
          _MetaRow(
            label: l10n.pluginContributors,
            value: m.contributors.join(', '),
          ),
        if (m.incompatibleWith.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            l10n.pluginIncompatibleWith,
            style: theme.textTheme.titleSmall,
          ),
          const SizedBox(height: 4),
          ...m.incompatibleWith.map(
            (rule) => Text(
              '• ${rule.id}${rule.version == '*' ? '' : ' (${rule.version})'}',
              style: theme.textTheme.bodyMedium,
            ),
          ),
        ],
        const SizedBox(height: 24),
        Text(
          l10n.pluginFeaturesSection,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        if (screens.isEmpty)
          Text(
            l10n.pluginNoScreens,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          ...screens.map(
            (screen) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: const Icon(Icons.extension),
                title: Text(screen.title),
                trailing: TextButton(
                  onPressed: () => onOpenScreen(screen),
                  child: Text(l10n.pluginOpenScreen),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _MetaRow extends StatelessWidget {
  const _MetaRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}

class _PluginIcon extends StatelessWidget {
  const _PluginIcon({required this.plugin, required this.size});

  final InstalledPluginRecord plugin;
  final double size;

  @override
  Widget build(BuildContext context) {
    final image = plugin.iconImageProvider();
    final scheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: size,
        height: size,
        child: image != null
            ? Image(image: image, fit: BoxFit.cover)
            : ColoredBox(
                color: scheme.surfaceContainerHighest,
                child: Icon(
                  Icons.settings,
                  size: size * 0.55,
                  color: scheme.primary,
                ),
              ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Text(
        label,
        maxLines: 1,
        softWrap: false,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
