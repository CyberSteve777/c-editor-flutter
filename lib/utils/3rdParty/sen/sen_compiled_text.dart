// ignore_for_file: non_constant_identifier_names

import 'dart:convert';
import 'dart:typed_data';

import 'package:rijndael/rijndael.dart';
import 'package:c_editor/utils/pvz2c_crypto.dart';

import 'sen_buffer.dart';
import 'sen_popcap_zlib.dart';

  /// Hot-update style asset: base64( `[0x10, 0x00]` + Rijndael-CBC(PopCap-zlib(payload)) ).
class CompiledText {
  RijndaelCbc _cipher(RijndaelC cfg) => RijndaelCbc(
    cfg.keyBytes,
    cfg.ivBytes,
    ZeroPadding(PvZ2Crypto.blockSize),
    blockSize: PvZ2Crypto.blockSize,
  );

  SenBuffer decode(SenBuffer raw, RijndaelC rijndael, bool use64BitVariant) {
    final decoded = base64Decode(ascii.decode(raw.toBytes()));
    final buf = SenBuffer.fromBytes(Uint8List.fromList(decoded));
    final cipherBytes = buf.getBytes(buf.length - 2, 2);
    final plain = _cipher(rijndael).decrypt(cipherBytes);
    return PopCapZlib.uncompress(SenBuffer.fromBytes(plain), use64BitVariant);
  }

  SenBuffer encode(SenBuffer raw, RijndaelC rijndael, bool use64BitVariant) {
    final compressedData = PopCapZlib.compress(raw, use64BitVariant);
    final SenBuffer ripe = SenBuffer.fromBytes(
      Uint8List.fromList([0x10, 0x00]),
    );
    ripe.writeBytes(_cipher(rijndael).encrypt(compressedData.toBytes()));
    return SenBuffer.fromBytes(ascii.encode(base64Encode(ripe.toBytes())));
  }

  static void encode_fs(
    String inFile,
    String outFile,
    RijndaelC rijndael,
    bool use64BitVariant,
  ) {
    final compiledText = CompiledText();
    final data = compiledText.encode(
      SenBuffer.OpenFile(inFile),
      rijndael,
      use64BitVariant,
    );
    data.outFile(outFile);
  }

  static void decode_fs(
    String inFile,
    String outFile,
    RijndaelC rijndael,
    bool use64BitVariant,
  ) {
    final compiledText = CompiledText();
    final data = compiledText.decode(
      SenBuffer.OpenFile(inFile),
      rijndael,
      use64BitVariant,
    );
    data.outFile(outFile);
  }
}
