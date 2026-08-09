export 'export_engine_base.dart';

import 'export_engine_base.dart';
import 'export_engine_native.dart'
    if (dart.library.js_interop) 'export_engine_web.dart' as impl;

/// Creates the platform-appropriate [ExportEngine]: `dart:io` on native,
/// OPFS + in-memory sen pipeline on the web.
ExportEngine createExportEngine() => impl.createExportEngine();
