import 'dart:convert';
import 'dart:typed_data';

import 'package:c_editor/bundled_plugins/level_test_cplugin/lib/src/registration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/bundled_plugins/bundled_plugins.dart';
import 'package:c_editor/bundled_plugins/preview_img_cplugin/lib/preview_img_cplugin.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/c_plugin_manifest.dart';
import 'package:c_editor/plugins/plugin_constants.dart';
import 'package:c_editor/plugins/plugin_host_hooks.dart';
import 'package:c_editor/plugins/plugin_host_impl.dart';
import 'package:c_editor/plugins/plugin_kind.dart';
import 'package:c_editor/plugins/plugin_package.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';
import 'package:c_editor/screens/export/export_screen.dart';

void main() {
  test('`.plugins` folder name is reserved', () {
    expect(isReservedLibraryFolderName('.plugins'), isTrue);
    expect(isReservedLibraryFolderName(' .plugins '), isTrue);
    expect(isReservedLibraryFolderName('plugins'), isFalse);
    expect(isReservedLibraryFolderName('.plugin'), isFalse);
    expect(kPluginsFolderName, '.plugins');
  });

  test('level preview is registered as a bundled plugin', () {
    expect(bundledPlugins.map((p) => p.id), contains(kLevelPreviewPluginId));

    final spec = bundledPlugins.firstWhere(
      (p) => p.id == kLevelPreviewPluginId,
    );
    expect(spec, isA<CPluginPackageSpec>());
    expect(spec.packageRoot, 'lib/bundled_plugins/preview_img_cplugin');

    final record = bundledPluginRecord(
      manifest: CPluginManifest(
        format: CPluginManifest.expectedFormat,
        formatVersion: CPluginManifest.supportedFormatVersion,
        id: kLevelPreviewPluginId,
        name: 'Level preview image generator',
        version: '1.0.0',
        entryLibrary:
            'package:c_editor/bundled_plugins/preview_img_cplugin/lib/main.dart',
        entryFunction: 'initialize',
      ),
      assets: const <String, Uint8List>{},
      enabled: true,
    );
    expect(record.kind, PluginKind.bundled);
    expect(record.canUninstall, isFalse);
    expect(record.isBundled, isTrue);
  });

  test('bundled plugins use manifest icon images like imported plugins', () {
    final withIcon = bundledPluginRecord(
      manifest: CPluginManifest(
        format: CPluginManifest.expectedFormat,
        formatVersion: CPluginManifest.supportedFormatVersion,
        id: kLevelPreviewPluginId,
        name: 'Level preview image generator',
        version: '1.0.0',
        icon: 'icon.png',
        entryLibrary:
            'package:c_editor/bundled_plugins/preview_img_cplugin/lib/main.dart',
        entryFunction: 'initialize',
      ),
      assets: <String, Uint8List>{
        // Minimal valid 1x1 PNG.
        'icon.png': Uint8List.fromList(<int>[
          0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00,
          0x0D, 0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00,
          0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89,
          0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63,
          0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4,
          0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60,
          0x82,
        ]),
      },
      enabled: true,
    );
    expect(withIcon.isBundled, isTrue);
    expect(withIcon.iconImageProvider(), isA<MemoryImage>());
  });

  testWidgets(
    'level testing mod creator exposes the export screen and level-list overflow',
    (tester) async {
      final registry = PluginScreenRegistry();
      final host = PluginHostImpl(
        pluginId: kLevelTestingModPluginId,
        assets: MemoryCPluginAssets({
          'l10n/en.arb': Uint8List.fromList(
            utf8.encode('{"levelTestingMod":"Level testing mod"}'),
          ),
          'l10n/zh.arb': Uint8List.fromList(
            utf8.encode('{"levelTestingMod":"关卡测试包"}'),
          ),
        }),
        registry: registry,
      );
      addTearDown(() => PluginHostHooks.offerExternalDynamic = null);

      registerLevelTestingMod(host);

      final screen = registry.screens.single;
      expect(screen.screenId, 'level_testing_mod');

      final overflow = registry
          .elementsForSlot(CPluginUiSlots.levelListOverflow)
          .single;
      expect(overflow.id, 'level_testing_mod_overflow');
      expect(overflow.iconCodePoint, Icons.inventory_2.codePoint);

      late BuildContext context;
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('zh'),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (builderContext) {
              context = builderContext;
              return const SizedBox();
            },
          ),
        ),
      );

      expect(screen.resolvedTitle(context), '关卡测试包');
      expect(overflow.resolvedTitle(context), '关卡测试包');
      expect(screen.builder(context), isA<ExportScreen>());
      expect(overflow.builder(context), isA<ExportScreen>());
    },
  );
}
