import 'dart:convert';
import 'dart:typed_data';

import 'package:c_editor/bundled_plugins/dynamic_fetch_cplugin/lib/src/registration.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/bundled_plugins/bundled_plugins.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/level_preview_cplugin.dart';
import 'package:c_editor/l10n/app_localizations.dart';
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
    expect(spec.packageRoot, 'lib/bundled_plugins/level_preview_cplugin');

    final record = bundledPluginRecord(
      manifest: CPluginManifest(
        format: CPluginManifest.expectedFormat,
        formatVersion: CPluginManifest.supportedFormatVersion,
        id: kLevelPreviewPluginId,
        name: 'Level Overview',
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

  test('bundled plugin icons match their editor actions', () {
    expect(bundledPluginIcon(kLevelPreviewPluginId), Icons.remove_red_eye);
    expect(
      bundledPluginIcon(kDynamicFetchPluginId),
      Icons.cloud_download_outlined,
    );
    expect(bundledPluginIcon('example.imported'), isNull);
  });

  testWidgets(
    'data package download exposes the level testing mod as a localized screen',
    (tester) async {
      final registry = PluginScreenRegistry();
      final host = PluginHostImpl(
        pluginId: kDynamicFetchPluginId,
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

      registerDynamicFetch(host);

      final screen = registry.screens.single;
      expect(screen.screenId, 'level_testing_mod');

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
      expect(screen.builder(context), isA<ExportScreen>());
    },
  );
}
