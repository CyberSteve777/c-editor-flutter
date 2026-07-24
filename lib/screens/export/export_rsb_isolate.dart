import 'dart:io';

import 'package:c_editor/utils/3rdParty/sen/sen_rsb_pack.dart';
import 'package:c_editor/utils/3rdParty/sen/sen_rsb_unpack.dart';
import 'package:c_editor/utils/3rdParty/sen/sen_rsg_pack.dart';
import 'package:c_editor/utils/3rdParty/sen/sen_rsg_unpack.dart';

/// Input/output paths for RSB unpack (must be sendable for isolates).
typedef ExportRsbPaths = (String input, String output);

/// Top-level isolate workers — no Flutter / widget context.
void exportIsolateUnpackRsb(ExportRsbPaths paths) {
  Directory(paths.$2).createSync(recursive: true);
  RsbUnpack.process(paths.$1, paths.$2, null);
}

void exportIsolateUnpackRsg(ExportRsbPaths paths) {
  Directory(paths.$2).createSync(recursive: true);
  RsgUnpack.process(paths.$1, paths.$2, null);
}

void exportIsolatePackRsg(ExportRsbPaths paths) {
  RsgPack.process(paths.$1, paths.$2, null);
}

void exportIsolatePackRsb(ExportRsbPaths paths) {
  RsbPack.process(paths.$1, paths.$2, null);
}
