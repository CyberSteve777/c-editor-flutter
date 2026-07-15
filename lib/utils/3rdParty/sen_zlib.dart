import 'dart:typed_data';
import 'package:archive/archive.dart';
import 'sen_buffer.dart';
import 'sen_file_system.dart';

class Zlib {
  static Uint8List uncompress(Uint8List dataStream) {
    return Uint8List.fromList(ZLibDecoder().decodeBytes(dataStream));
  }

  static Uint8List compress(Uint8List dataStream, int compressionLevel) {
    return Uint8List.fromList(ZLibEncoder().encodeBytes(dataStream, level: compressionLevel));
  }

  static void compressFile(
    String inFile,
    String outFile,
    int level,
  ) {
    var inFs = FileSystem.openSenBuffer(inFile);
    var outFs = SenBuffer.fromBytes(
      Zlib.compress(
        inFs.toBytes(),
        level,
      ),
    );
    FileSystem.saveSenBuffer(outFile, outFs);
  }

  static void uncompressFile(
    String inFile,
    String outFile,
  ) {
    var inFs = FileSystem.openSenBuffer(inFile);
    var outFs = SenBuffer.fromBytes(
      Zlib.uncompress(
        inFs.toBytes(),
      ),
    );
    FileSystem.saveSenBuffer(outFile, outFs);
  }
}
