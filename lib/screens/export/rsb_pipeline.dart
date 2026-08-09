import 'dart:typed_data';

import 'package:path/path.dart' as p;

import 'package:c_editor/utils/3rdParty/sen/sen_file_system.dart';
import 'package:c_editor/utils/3rdParty/sen/sen_rsb_pack.dart';
import 'package:c_editor/utils/3rdParty/sen/sen_rsb_unpack.dart';
import 'package:c_editor/utils/3rdParty/sen/sen_rsg_pack.dart';
import 'package:c_editor/utils/3rdParty/sen/sen_rsg_unpack.dart';
import 'package:c_editor/utils/app_fs/sen_fs.dart';
import 'package:c_editor/utils/app_fs/sen_fs_memory.dart';

import 'export_engine_base.dart';
import 'export_inject.dart';

/// The full unpack -> inject -> repack pipeline, running entirely on an
/// in-memory [MemorySenIo] workspace with no Flutter, `dart:io`, or OPFS
/// dependency.
///
/// This is deliberately pure Dart so it can run in two places:
///  * the main isolate (fallback when a Web Worker is unavailable), and
///  * a dedicated Web Worker entrypoint (`web/rsb_worker.dart`), where the heavy
///    synchronous zlib work no longer blocks the UI thread.
///
/// It is synchronous by nature (the sen tools are CPU-bound with no await
/// points); callers that need a responsive UI must run it off the main isolate.
Uint8List runRsbInjectPipeline({
  required Uint8List archiveBytes,
  required Map<String, Uint8List> rtonLevels,
  void Function(double progress, ExportPhase phase)? onProgress,
}) {
  final mem = MemorySenIo();
  return runWithSenIo<Uint8List>(mem, () {
    onProgress?.call(0.2, ExportPhase.unpackingRsb);
    mem.writeBuffer('temp.rsb', archiveBytes);
    RsbUnpack.process('temp.rsb', 'rsb.bundle');

    onProgress?.call(0.4, ExportPhase.unpackingRsg);
    if (!FileSystem.directoryExists('rsb.bundle/packet')) {
      throw Exception('Packet directory not found in RSB bundle.');
    }
    String? packagesRsgPath;
    for (final entryPath in FileSystem.readDirectory('rsb.bundle/packet', false)) {
      if (p.basename(entryPath).toLowerCase() == 'packages.rsg') {
        packagesRsgPath = entryPath;
        break;
      }
    }
    if (packagesRsgPath == null) {
      throw Exception('Packages.rsg not found in archive.');
    }
    RsgUnpack.process(packagesRsgPath, 'Packages.packet');

    onProgress?.call(0.6, ExportPhase.injecting);
    injectRtonLevelsIntoPacket('Packages.packet', rtonLevels);

    onProgress?.call(0.7, ExportPhase.repackingRsg);
    RsgPack.process('Packages.packet', packagesRsgPath);

    onProgress?.call(0.8, ExportPhase.repackingRsb);
    RsbPack.process('rsb.bundle', 'temp.rsb');

    onProgress?.call(0.9, ExportPhase.finalizing);
    return mem.readBuffer('temp.rsb');
  });
}
