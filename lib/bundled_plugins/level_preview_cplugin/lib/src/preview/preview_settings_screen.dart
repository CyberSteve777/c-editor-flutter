import 'package:flutter/material.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_export_prefs.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'preview_export_folder_picker.dart';
import 'preview_toolbar_prefs.dart';

/// Preview export destination and generator toolbar presentation.
class PreviewSettingsScreen extends StatefulWidget {
  const PreviewSettingsScreen({super.key, required this.host});

  final CPluginHost host;

  @override
  State<PreviewSettingsScreen> createState() => _PreviewSettingsScreenState();
}

class _PreviewSettingsScreenState extends State<PreviewSettingsScreen> {
  String _folder = kDefaultPreviewExportFolder;
  PreviewToolbarStyle _toolbarStyle = PreviewToolbarStyle.full;
  bool _loading = true;
  bool _saving = false;

  String _t(String key, [String? fallback]) =>
      widget.host.localize(context, key, fallback ?? key);

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final name = await PreviewExportPrefs.getFolderName();
    final toolbarStyle = await PreviewToolbarPrefs.getStyle();
    if (!mounted) return;
    setState(() {
      _folder = name;
      _toolbarStyle = toolbarStyle;
      _loading = false;
    });
  }

  Future<void> _chooseFolder() async {
    final workspace = await LevelRepository.getSavedFolderPath();
    if (!mounted) return;
    if (workspace == null || workspace.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t(
              'previewSettingsWorkspaceRequired',
              'Choose a workspace before selecting an export folder.',
            ),
          ),
        ),
      );
      return;
    }
    final folder = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => PreviewExportFolderPicker(
          workspacePath: workspace,
          initialFolder: _folder,
          t: _t,
        ),
      ),
    );
    if (folder != null && mounted) setState(() => _folder = folder);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    try {
      await PreviewExportPrefs.setFolderPath(_folder);
      await PreviewToolbarPrefs.setStyle(_toolbarStyle);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_t('previewSettingsSaved', 'Settings saved'))),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                'previewSettingsSaveFailed',
                'Unable to save settings. Please try again.',
              ),
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_t('previewSettings', 'Level Overview settings')),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                OutlinedButton.icon(
                  key: const ValueKey('previewSettingsChooseExportFolder'),
                  onPressed: _saving ? null : _chooseFolder,
                  icon: const Icon(Icons.folder_open),
                  label: Text(
                    '${_t('previewSettingsChooseFolder', 'Choose export folder')}: ${_folder == '.' ? _t('previewSettingsWorkspaceRoot', 'Workspace') : _folder}',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  key: const ValueKey('previewSettingsFolderHint'),
                  _t(
                    'previewSettingsFolderHint',
                    'PNG previews are written under this folder inside your level library.',
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  _t('previewSettingsToolbarStyle', 'Toolbar style'),
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                RadioGroup<PreviewToolbarStyle>(
                  groupValue: _toolbarStyle,
                  onChanged: (value) {
                    if (value != null && !_saving) {
                      setState(() => _toolbarStyle = value);
                    }
                  },
                  child: Column(
                    children: [
                      RadioListTile<PreviewToolbarStyle>(
                        key: const ValueKey('previewToolbarStyleCompact'),
                        value: PreviewToolbarStyle.compact,
                        title: Text(
                          _t('previewSettingsToolbarCompact', 'Compact'),
                        ),
                        subtitle: Text(
                          _t(
                            'previewSettingsToolbarCompactHint',
                            'Icon-only controls with tooltips; tool and add-element controls share one row.',
                          ),
                        ),
                      ),
                      RadioListTile<PreviewToolbarStyle>(
                        key: const ValueKey('previewToolbarStyleFull'),
                        value: PreviewToolbarStyle.full,
                        title: Text(_t('previewSettingsToolbarFull', 'Full')),
                        subtitle: Text(
                          _t(
                            'previewSettingsToolbarFullHint',
                            'Show button labels and explanations below each function.',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save),
                  label: Text(_t('previewSettingsSave', 'Save')),
                ),
              ],
            ),
    );
  }
}
