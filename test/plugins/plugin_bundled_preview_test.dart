import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/bundled_plugins/bundled_plugins.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/level_preview_cplugin.dart';
import 'package:c_editor/plugins/plugin_constants.dart';
import 'package:c_editor/plugins/plugin_kind.dart';
import 'package:c_editor/plugins/bundled_plugin.dart';

void main() {
  test('`.plugins` folder name is reserved', () {
    expect(isReservedLibraryFolderName('.plugins'), isTrue);
    expect(isReservedLibraryFolderName(' .plugins '), isTrue);
    expect(isReservedLibraryFolderName('plugins'), isFalse);
    expect(isReservedLibraryFolderName('.plugin'), isFalse);
    expect(kPluginsFolderName, '.plugins');
  });

  test('level preview is registered as a bundled plugin', () {
    final plugin = LevelPreviewBundledPlugin();
    expect(plugin.id, LevelPreviewBundledPlugin.pluginId);
    expect(bundledPlugins.map((p) => p.id), contains(plugin.id));

    final record = bundledPluginRecord(plugin, enabled: true);
    expect(record.kind, PluginKind.bundled);
    expect(record.canUninstall, isFalse);
    expect(record.isBundled, isTrue);
  });
}
