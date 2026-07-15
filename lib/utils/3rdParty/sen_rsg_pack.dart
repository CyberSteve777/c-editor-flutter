// ignore_for_file: unused_import, non_constant_identifier_names

import 'dart:typed_data';

import 'sen_buffer.dart';
import "sen_rsg_common.dart";
import 'sen_file_system.dart';
import "package:path/path.dart" as path;
import 'package:c_editor/l10n/app_localizations.dart';

/// [RsgPack] is a utility for packing Resource Stream Group (RSG) files.
/// NOTE: This utility uses `dart:io` and is not supported on the Web platform.
class RsgPack {
  static void process(
    String inFolder,
    String outFile,
    AppLocalizations? localizations, [
    bool useResFolder = true,
  ]) {
    final packet = FileSystem.readJson(path.join(inFolder, "packet.json"));
    process_package(
      inFolder,
      outFile,
      packet,
      useResFolder,
      localizations,
    );
    return;
  }

  static void process_package(
    String inFolder,
    String outFile,
    dynamic packet,
    bool useResFolder,
    AppLocalizations? localizations,
  ) {
    final rsg = ResourceStreamGroup();
    final resources = <String, Uint8List>{};
    for (final res in packet["res"]) {
      final resKey = (res["path"] as List).join("/");
      final resPath = path.join(inFolder, useResFolder ? "res" : "", resKey);
      resources[(res["path"] as List).join("\\")] = FileSystem.readBuffer(resPath);
    }
    final senFile = rsg.packRSG(packet, resources, localizations);
    FileSystem.saveSenBuffer(outFile, senFile);
    return;
  }
}
