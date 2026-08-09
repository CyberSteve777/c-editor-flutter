import 'dart:js_interop';

/// Message contract shared between the main isolate ([ExportEngineWeb]) and the
/// dedicated Web Worker entrypoint (`web/rsb_worker.dart`).
///
/// Kept in one place so both sides agree on property names for structured-clone
/// messages. Only used on the web (imports `dart:js_interop`).
class RsbWorkerKind {
  RsbWorkerKind._();

  static const String progress = 'progress';
  static const String done = 'done';
  static const String error = 'error';
}

/// Request posted from the main isolate to the worker: the source archive plus
/// the RTON levels to inject (parallel path/buffer arrays keep the payload flat
/// and easy to build).
extension type PackRequest._(JSObject _) implements JSObject {
  external factory PackRequest({
    JSUint8Array archive,
    JSArray<JSString> levelPaths,
    JSArray<JSUint8Array> levelBuffers,
  });

  external JSUint8Array get archive;
  external JSArray<JSString> get levelPaths;
  external JSArray<JSUint8Array> get levelBuffers;
}

/// A message posted back from the worker. [kind] selects which fields are valid:
///  * `progress` -> [value] (0..1) and [phase] (an [ExportPhase] index)
///  * `done`     -> [result] (the packed archive bytes)
///  * `error`    -> [message]
extension type WorkerMessage._(JSObject _) implements JSObject {
  external String get kind;
  external double get value;
  external int get phase;
  external JSUint8Array? get result;
  external String? get message;
}

extension type ProgressMessage._(JSObject _) implements JSObject {
  external factory ProgressMessage({
    String kind,
    double value,
    int phase,
  });
}

extension type DoneMessage._(JSObject _) implements JSObject {
  external factory DoneMessage({
    String kind,
    JSUint8Array result,
  });
}

extension type ErrorMessage._(JSObject _) implements JSObject {
  external factory ErrorMessage({
    String kind,
    String message,
  });
}
