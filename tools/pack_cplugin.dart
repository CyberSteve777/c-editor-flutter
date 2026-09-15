// Packs a plugin directory into a `.cplugin` ZIP.
//
// Usage:
//   dart run tools/pack_cplugin.dart <plugin_dir> [output.cplugin]
//
// Required in <plugin_dir>:
//   manifest.json
//   plugin.evc
// Optional:
//   assets/**

import 'dart:convert';
import 'dart:io';

import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;

void main(List<String> args) {
  if (args.isEmpty) {
    stderr.writeln(
      'Usage: dart run tools/pack_cplugin.dart <plugin_dir> [output.cplugin]',
    );
    exit(64);
  }

  final dir = Directory(args[0]);
  if (!dir.existsSync()) {
    stderr.writeln('Directory not found: ${dir.path}');
    exit(1);
  }

  final manifestFile = File(p.join(dir.path, 'manifest.json'));
  final evcFile = File(p.join(dir.path, 'plugin.evc'));
  if (!manifestFile.existsSync()) {
    stderr.writeln('Missing manifest.json in ${dir.path}');
    exit(1);
  }
  if (!evcFile.existsSync()) {
    stderr.writeln('Missing plugin.evc in ${dir.path}');
    exit(1);
  }

  // Light validation of manifest shape.
  final manifestJson =
      jsonDecode(manifestFile.readAsStringSync()) as Map<String, dynamic>;
  if (manifestJson['format'] != 'cplugin') {
    stderr.writeln('manifest.json format must be "cplugin"');
    exit(1);
  }
  final id = manifestJson['id'] as String? ?? 'plugin';

  final outPath = args.length > 1
      ? args[1]
      : p.join(dir.path, '$id.cplugin');

  final archive = Archive();
  archive.addFile(
    ArchiveFile(
      'manifest.json',
      manifestFile.lengthSync(),
      manifestFile.readAsBytesSync(),
    ),
  );
  archive.addFile(
    ArchiveFile(
      'plugin.evc',
      evcFile.lengthSync(),
      evcFile.readAsBytesSync(),
    ),
  );

  final assetsDir = Directory(p.join(dir.path, 'assets'));
  if (assetsDir.existsSync()) {
    for (final entity in assetsDir.listSync(recursive: true)) {
      if (entity is! File) continue;
      final rel = p
          .relative(entity.path, from: assetsDir.path)
          .replaceAll('\\', '/');
      final bytes = entity.readAsBytesSync();
      archive.addFile(ArchiveFile('assets/$rel', bytes.length, bytes));
    }
  }

  final encoded = ZipEncoder().encode(archive);
  final outFile = File(outPath);
  outFile.parent.createSync(recursive: true);
  outFile.writeAsBytesSync(encoded);
  stdout.writeln('Wrote ${outFile.path} (${encoded.length} bytes)');
}
