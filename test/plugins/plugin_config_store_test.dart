import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/plugins/c_plugin_manifest.dart';
import 'package:c_editor/plugins/plugin_config_store.dart';
import 'package:c_editor/plugins/plugin_constants.dart';
import 'package:c_editor/plugins/plugin_settings_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('CPluginManifest.configurable', () {
    test('defaults to false when omitted', () {
      final manifest = CPluginManifest.fromJson({
        'format': 'cplugin',
        'formatVersion': 1,
        'id': 'com.example.plain',
        'version': '1.0.0',
        'entry': {
          'library': 'package:plain/main.dart',
          'function': 'initialize',
        },
      });
      expect(manifest.configurable, isFalse);
      expect(manifest.toJson().containsKey('configurable'), isFalse);
    });

    test('parses and serializes true', () {
      final manifest = CPluginManifest.fromJson({
        'format': 'cplugin',
        'formatVersion': 1,
        'id': 'com.example.cfg',
        'version': '1.0.0',
        'configurable': true,
        'entry': {
          'library': 'package:cfg/main.dart',
          'function': 'initialize',
        },
      });
      expect(manifest.configurable, isTrue);
      expect(manifest.toJson()['configurable'], isTrue);
    });
  });

  group('PluginConfigStore', () {
    test('round-trips Unicode values via SharedPreferences fallback', () async {
      const id = 'com.example.unicode';
      await PluginConfigStore.instance.writeMap(id, {
        'folder': '截图/превью',
        'note': 'Привет · 你好 · Hello',
      });
      final raw = await PluginConfigStore.instance.readJson(id);
      final map = jsonDecode(raw) as Map<String, dynamic>;
      expect(map['folder'], '截图/превью');
      expect(map['note'], 'Привет · 你好 · Hello');
      expect(raw, contains('截图'));
      expect(raw, contains('Привет'));
    });

    test('writes UTF-8 config.json under library when available', () async {
      final dir = await Directory.systemTemp.createTemp('plugin_config_');
      addTearDown(() => dir.delete(recursive: true));
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('folder_path', dir.path);

      const id = 'com.example.filecfg';
      await PluginConfigStore.instance.writeMap(id, {
        'exportFolder': '关卡/превью',
      });

      final file = File(
        p.join(dir.path, kPluginConfigFolderName, id, kPluginConfigFileName),
      );
      expect(await file.exists(), isTrue);
      final text = await file.readAsString(encoding: utf8);
      expect(text, contains('关卡/превью'));
      expect(await PluginConfigStore.instance.readMap(id), {
        'exportFolder': '关卡/превью',
      });
    });

    test('rejects non-object JSON', () async {
      expect(
        () => PluginConfigStore.instance.writeJson('com.example.bad', '[]'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('plugin settings screen helpers', () {
    test('recognizes settings ids', () {
      expect(isPluginSettingsScreenId('settings'), isTrue);
      expect(isPluginSettingsScreenId('config'), isTrue);
      expect(isPluginSettingsScreenId('preview_settings'), isTrue);
      expect(isPluginSettingsScreenId('foo_settings'), isTrue);
      expect(isPluginSettingsScreenId('preview_generator'), isFalse);
    });
  });

  group('reserved folders', () {
    test('includes plugin_config', () {
      expect(isReservedLibraryFolderName('.plugins'), isTrue);
      expect(isReservedLibraryFolderName('.plugin_config'), isTrue);
      expect(isReservedLibraryFolderName('levels'), isFalse);
    });
  });
}
