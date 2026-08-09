// Dedicated Web Worker entrypoint for the RSB/RSG export pipeline.
//
// Flutter web has no real background isolates (`compute`/`Isolate.run` run on
// the main isolate), so the CPU-heavy, synchronous sen pack/unpack pipeline —
// dominated by pure-Dart zlib deflate — freezes the tab when run inline. This
// standalone entrypoint is compiled separately to `web/rsb_worker.dart.js` and
// runs the pipeline in a real worker thread, keeping the UI fully interactive.
//
// Build it (from the project root) whenever this file or the sen sources change:
//
//   dart compile js web/rsb_worker.dart -o web/rsb_worker.dart.js -O2
//
// If the compiled script is missing, [ExportEngineWeb] transparently falls back
// to running the same pipeline on the main isolate (functional, but it freezes).

import 'dart:js_interop';
import 'dart:typed_data';

import 'package:web/web.dart' as web;

import 'package:c_editor/screens/export/rsb_pipeline.dart';
import 'package:c_editor/screens/export/rsb_worker_protocol.dart';

void main() {
  final scope = globalContext as web.DedicatedWorkerGlobalScope;
  scope.onmessage = ((web.MessageEvent event) {
    _handleMessage(scope, event);
  }).toJS;
}

void _handleMessage(web.DedicatedWorkerGlobalScope scope, web.MessageEvent event) {
  try {
    final request = event.data as PackRequest;

    final archive = request.archive.toDart;
    final paths = request.levelPaths.toDart;
    final buffers = request.levelBuffers.toDart;

    final levels = <String, Uint8List>{};
    for (var i = 0; i < paths.length; i++) {
      levels[paths[i].toDart] = buffers[i].toDart;
    }

    final output = runRsbInjectPipeline(
      archiveBytes: archive,
      rtonLevels: levels,
      onProgress: (progress, phase) {
        scope.postMessage(ProgressMessage(
          kind: RsbWorkerKind.progress,
          value: progress,
          phase: phase.index,
        ));
      },
    );

    final tight = _tighten(output);
    // Under dart2js a Uint8List is a JS Uint8Array, so `.buffer.toJS` is the
    // same ArrayBuffer backing `.toJS` and can be transferred zero-copy. (Under
    // dart2wasm they differ, in which case the result is simply cloned instead.)
    final resultArray = tight.toJS;
    final resultBuffer = tight.buffer.toJS;
    scope.postMessage(
      DoneMessage(kind: RsbWorkerKind.done, result: resultArray),
      web.StructuredSerializeOptions(transfer: <JSObject>[resultBuffer].toJS),
    );
  } catch (error, stack) {
    scope.postMessage(ErrorMessage(
      kind: RsbWorkerKind.error,
      message: '$error\n$stack',
    ));
  }
}

/// Returns a Uint8List that owns its whole backing buffer, so `.toJS.buffer` is
/// safe to transfer (a view with a non-zero offset would transfer the wrong
/// range).
Uint8List _tighten(Uint8List bytes) {
  if (bytes.offsetInBytes == 0 &&
      bytes.lengthInBytes == bytes.buffer.lengthInBytes) {
    return bytes;
  }
  return Uint8List.fromList(bytes);
}
