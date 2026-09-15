import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/bloc/editor/editor_cubit.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/plugins/active_editor_session.dart';
import 'package:c_editor/plugins/plugin_host_impl.dart';
import 'package:c_editor/plugins/plugin_level_io.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';

PvzLevelFile _sampleLevel({int version = 1, String alias = 'LevelDefinition'}) {
  return PvzLevelFile(
    version: version,
    objects: [
      PvzObject(
        aliases: [alias],
        objClass: 'LevelDefinition',
        objData: <String, dynamic>{'Description': 'test'},
      ),
    ],
  );
}

void main() {
  tearDown(() {
    ActiveEditorSession.instance.clear();
  });

  test('encode/decode level JSON round-trip', () {
    final level = _sampleLevel(version: 2);
    final json = encodeLevelJson(level);
    final decoded = decodeLevelJson(json);
    expect(decoded.version, 2);
    expect(decoded.objects, hasLength(1));
    expect(decoded.objects.first.aliases, ['LevelDefinition']);
  });

  test('decodeLevelJson rejects non-object JSON', () {
    expect(() => decodeLevelJson('[1,2,3]'), throwsArgumentError);
    expect(() => decodeLevelJson('not-json'), throwsFormatException);
  });

  test('PluginHostImpl open-level get/apply via ActiveEditorSession', () {
    final cubit = EditorCubit(
      fileName: 'demo.json',
      filePath: '/lib/demo.json',
    );
    // Seed in-memory level without repository I/O.
    cubit.applyLevelFile(_sampleLevel(), markDirty: false);
    ActiveEditorSession.instance.bind(cubit);

    final host = PluginHostImpl(
      pluginId: 'test.plugin',
      assets: MemoryCPluginAssets(const {}),
      registry: PluginScreenRegistry(),
    );

    expect(host.hasOpenLevel, isTrue);
    expect(host.openLevelFileName, 'demo.json');
    expect(host.openLevelPath, '/lib/demo.json');

    final json = host.getOpenLevelJson();
    expect(json, isNotNull);
    expect(json!, contains('LevelDefinition'));

    final edited = _sampleLevel(alias: 'LevelDefinition', version: 3);
    edited.objects.first.objData = <String, dynamic>{
      'Description': 'from-plugin',
    };
    host.applyOpenLevelJson(encodeLevelJson(edited));

    expect(cubit.state.hasChanges, isTrue);
    expect(cubit.state.levelFile!.version, 3);
    expect(
      cubit.state.levelFile!.objects.first.objData['Description'],
      'from-plugin',
    );

    ActiveEditorSession.instance.clearIf(cubit);
    expect(host.hasOpenLevel, isFalse);
    expect(host.getOpenLevelJson(), isNull);
    expect(() => host.applyOpenLevelJson(json), throwsStateError);

    cubit.close();
  });

  test('JSON viewer save clears the editor dirty state', () {
    final cubit = EditorCubit(
      fileName: 'demo.json',
      filePath: '/lib/demo.json',
    );
    cubit.applyLevelFile(_sampleLevel(), markDirty: true);
    expect(cubit.state.hasChanges, isTrue);

    cubit.onJsonViewerSaved();

    expect(cubit.state.hasChanges, isFalse);
    expect(cubit.state.parsedData, isNotNull);
    cubit.close();
  });

  test('restoring the saved level clears semantic dirty state', () {
    final cubit = EditorCubit(
      fileName: 'demo.json',
      filePath: '/lib/demo.json',
    );
    cubit.applyLevelFile(_sampleLevel(), markDirty: false);
    final data = cubit.state.levelFile!.objects.first.objData as Map;

    data['Description'] = 'temporarily edited';
    cubit.markDirty();
    expect(cubit.state.hasChanges, isTrue);

    data['Description'] = 'test';
    cubit.markDirty();
    expect(cubit.state.hasChanges, isFalse);

    cubit.close();
  });

  test('applyOpenLevelJson throws when no editor is bound', () {
    final host = PluginHostImpl(
      pluginId: 'test.plugin',
      assets: MemoryCPluginAssets(const {}),
      registry: PluginScreenRegistry(),
    );
    expect(
      () => host.applyOpenLevelJson(encodeLevelJson(_sampleLevel())),
      throwsStateError,
    );
  });
}
