// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'sen_buffer.dart';
import "sen_rsb_common.dart";
import 'sen_file_system.dart';
import "package:path/path.dart" as path;
import 'package:c_editor/l10n/app_localizations.dart';

/// [RsbUnpack] is a utility for unpacking Resource Stream Bundle (RSB) files.
/// NOTE: This utility uses `dart:io` and is not supported on the Web platform.
class RsbUnpack {
  static void process(
    String inFile,
    String outFolder,
    AppLocalizations? localizations,
  ) {
    final senFile = FileSystem.openSenBuffer(inFile);
    process_package(
      senFile,
      outFolder,
      localizations,
    );
    return;
  }

  static void process_package(
    SenBuffer senFile,
    String outFolder,
    AppLocalizations? localizations,
  ) {
    final rsb = ResourceStreamBundle();
    final result = rsb.unpackRSB(senFile, localizations);
    final manifest = result["manifest"];
    final rsgFiles = result["rsg_files"] as Map<String, Uint8List>;

    FileSystem.writeJson(path.join(outFolder, "manifest.json"), manifest, "\t");
    if (manifest["description"] != null) {
      FileSystem.writeJson(path.join(outFolder, "description.json"), manifest["description"], "\t");
    }

    rsgFiles.forEach((fileName, data) {
      FileSystem.writeBuffer(path.join(outFolder, "packet", fileName), data);
    });
    return;
  }
}
