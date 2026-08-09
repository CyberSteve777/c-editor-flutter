import 'dart:typed_data';

import 'package:c_editor/utils/3rdParty/sen/sen_file_system.dart';
import 'package:path/path.dart' as p;

/// Injects [rtonLevels] into an unpacked `Packages.packet` folder, matching the
/// existing `packet.json` `res` entries by case-insensitive basename.
///
/// Reads/writes go through the active sen filesystem backend ([senIo]), so this
/// works on native `dart:io` temp dirs and on the web in-memory workspace alike.
///
/// PopCap stores RSG paths in upper case (e.g. `LEVELS/EGYPT1.RTON`). On a
/// case-sensitive filesystem a naive lower-case write creates an unreferenced
/// file that the repack ignores, so matching by lower-cased basename and
/// reusing the existing casing is essential.
void injectRtonLevelsIntoPacket(
  String rsgUnpackDir,
  Map<String, Uint8List> rtonLevels,
) {
  final packetJsonPath = p.join(rsgUnpackDir, 'packet.json');
  final packet = FileSystem.readJson(packetJsonPath) as Map<String, dynamic>;
  final resList = packet['res'] as List;

  final Map<String, List> levelEntryByLowerName = {};
  List? sampleLevelsSegments;
  for (final res in resList) {
    final segs = res['path'] as List;
    if (segs.isEmpty) continue;
    final inLevels = segs.any((s) => s.toString().toLowerCase() == 'levels');
    if (!inLevels) continue;
    sampleLevelsSegments ??= segs;
    levelEntryByLowerName[segs.last.toString().toLowerCase()] = segs;
  }

  if (levelEntryByLowerName.isEmpty) {
    throw Exception(
      'No LEVELS entries found in Packages.rsg (res count: ${resList.length}).',
    );
  }

  var packetChanged = false;
  for (final entry in rtonLevels.entries) {
    final fileName = entry.key; // e.g. egypt1.rton
    final data = entry.value;

    List targetSegments;
    final match = levelEntryByLowerName[fileName.toLowerCase()];
    if (match != null) {
      targetSegments = match; // overwrite existing, preserving casing
    } else {
      final prefix =
          sampleLevelsSegments!.sublist(0, sampleLevelsSegments.length - 1);
      targetSegments = [...prefix, fileName];
      resList.add({'path': targetSegments});
      packetChanged = true;
    }

    final relPath = targetSegments.map((e) => e.toString()).join('/');
    FileSystem.writeBuffer(p.join(rsgUnpackDir, 'res', relPath), data);
  }

  if (packetChanged) {
    FileSystem.writeJson(packetJsonPath, packet, '\t');
  }
}
