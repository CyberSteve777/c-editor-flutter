import 'dart:typed_data';

import 'package:dart_eval/dart_eval.dart';
import 'package:flutter_eval/flutter_eval.dart';
import 'package:c_editor/plugin_api/eval/c_editor_plugin_eval_plugin.dart';
import 'package:c_editor/plugin_api/eval/host_wrappers.dart';
import 'package:c_editor/plugins/c_plugin_manifest.dart';
import 'package:c_editor/plugins/plugin_host_impl.dart';
import 'package:c_editor/plugins/plugin_screen_registry.dart';

/// Creates a dart_eval [Runtime] for a plugin EVC blob with host bridges.
Runtime createPluginRuntime(Uint8List evcBytes) {
  // Copy so ByteData is never a view into a larger ZIP/file buffer.
  final copy = Uint8List.fromList(evcBytes);
  final runtime = Runtime(ByteData.sublistView(copy));
  runtime.addPlugin(flutterEvalPlugin);
  runtime.addPlugin(const CEditorPluginEvalPlugin());
  return runtime;
}

/// Runs the plugin entrypoint into [registry] (or a throwaway registry).
///
/// Returns the [Runtime] used. Throws if the EVC cannot resolve
/// [CPluginManifest.entryLibrary] / [CPluginManifest.entryFunction].
Runtime executePluginEntrypoint({
  required Uint8List evcBytes,
  required CPluginManifest manifest,
  required String pluginId,
  Map<String, Uint8List> assets = const {},
  PluginScreenRegistry? registry,
  Runtime? runtime,
}) {
  final rt = runtime ?? createPluginRuntime(evcBytes);
  final targetRegistry = registry ?? PluginScreenRegistry();
  final host = PluginHostImpl(
    pluginId: pluginId,
    assets: MemoryCPluginAssets(assets),
    registry: targetRegistry,
  );

  try {
    rt.executeLib(
      manifest.entryLibrary,
      manifest.entryFunction,
      [$CPluginHost.wrap(host)],
    );
  } on ArgumentError catch (e) {
    throw ArgumentError(
      '${e.message}\n'
      'entry.library=${manifest.entryLibrary}, '
      'entry.function=${manifest.entryFunction}. '
      'Recompile the .cplugin with the same dart_eval version as C-Editor, '
      'and ensure the entry file is listed in compiler.entrypoints '
      '(files named main.dart work by default).',
    );
  }
  return rt;
}
