import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/bundled_plugins/bundled_plugins.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/level_preview_cplugin.dart';
import 'package:c_editor/plugins/c_plugin_manifest.dart';
import 'package:c_editor/plugins/plugin_constants.dart';
import 'package:c_editor/plugins/plugin_kind.dart';
import 'package:c_editor/plugins/plugin_package.dart';

void main() {
  test('`.plugins` folder name is reserved', () {
    expect(isReservedLibraryFolderName('.plugins'), isTrue);
    expect(isReservedLibraryFolderName(' .plugins '), isTrue);
    expect(isReservedLibraryFolderName('plugins'), isFalse);
    expect(isReservedLibraryFolderName('.plugin'), isFalse);
    expect(kPluginsFolderName, '.plugins');
  });

  test('level preview is registered as a bundled plugin', () {
    expect(
      bundledPlugins.map((p) => p.id),
      contains(kLevelPreviewPluginId),
    );

    final spec = bundledPlugins.firstWhere(
      (p) => p.id == kLevelPreviewPluginId,
    );
    expect(spec, isA<CPluginPackageSpec>());
    expect(spec.packageRoot, 'lib/bundled_plugins/level_preview_cplugin');

    final record = bundledPluginRecord(
      manifest: CPluginManifest(
        format: CPluginManifest.expectedFormat,
        formatVersion: CPluginManifest.supportedFormatVersion,
        id: kLevelPreviewPluginId,
        name: 'Level Preview',
        version: '1.0.0',
        entryLibrary:
            'package:c_editor/bundled_plugins/level_preview_cplugin/lib/main.dart',
        entryFunction: 'initialize',
      ),
      assets: const <String, Uint8List>{},
      enabled: true,
    );
    expect(record.kind, PluginKind.bundled);
    expect(record.canUninstall, isFalse);
    expect(record.isBundled, isTrue);
  });
}
