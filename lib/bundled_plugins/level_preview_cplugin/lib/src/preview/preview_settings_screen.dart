import 'package:flutter/material.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_export_prefs.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';

/// Plugin settings: preview PNG export folder name under the level library.
class PreviewSettingsScreen extends StatefulWidget {
  const PreviewSettingsScreen({super.key, required this.host});

  final CPluginHost host;

  @override
  State<PreviewSettingsScreen> createState() => _PreviewSettingsScreenState();
}

class _PreviewSettingsScreenState extends State<PreviewSettingsScreen> {
  final _controller = TextEditingController();
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
    if (!mounted) return;
    setState(() {
      _controller.text = name;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await PreviewExportPrefs.setFolderName(_controller.text);
    final sanitized = await PreviewExportPrefs.getFolderName();
    if (!mounted) return;
    setState(() {
      _controller.text = sanitized;
      _saving = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(_t('previewSettingsSaved', 'Settings saved'))),
    );
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
                Text(
                  _t(
                    'previewSettingsFolderHint',
                    'PNG previews are written under this folder inside your level library.',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    labelText: _t(
                      'previewSettingsFolderLabel',
                      'Preview export folder name',
                    ),
                    hintText: kDefaultPreviewExportFolder,
                    border: const OutlineInputBorder(),
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
