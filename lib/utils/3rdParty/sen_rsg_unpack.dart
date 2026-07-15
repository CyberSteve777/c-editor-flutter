// ignore_for_file: non_constant_identifier_names

import 'dart:typed_data';

import 'sen_buffer.dart';
import "sen_rsg_common.dart";
import 'sen_file_system.dart';
import "package:path/path.dart" as path;
import 'package:c_editor/l10n/app_localizations.dart';

/// [RsgUnpack] is a utility for unpacking Resource Stream Group (RSG) files.
/// NOTE: This utility uses `dart:io` and is not supported on the Web platform.
class RsgUnpack {
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
    final rsg = ResourceStreamGroup();
    final packet = rsg.unpackRSG(senFile, localizations, extractFiles: true);
    FileSystem.writeJson(path.join(outFolder, "packet.json"), packet, "\t");
    
    final files = packet["files"] as Map<String, Uint8List>?;
    if (files != null && files.isNotEmpty) {
      files.forEach((filePath, data) {
        // Normalize backslashes to forward slashes for cross-platform compatibility
        final normalizedPath = filePath.replaceAll('\\', '/');
        FileSystem.writeBuffer(path.join(outFolder, "res", normalizedPath), data);
      });
    } else {
      throw Exception("No files extracted from RSG. File count: ${packet["res"]?.length ?? 0}");
    }
    return;
  }
}
