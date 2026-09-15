import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';

abstract final class PvZ2Crypto {
  static const int blockSize = 24;

  static const String _rawKey = String.fromEnvironment('PVZ2C_ENCRYPTION_KEY');

  // MD5 of the raw ASCII string, then UTF8-encode the hex digest
  static Uint8List get keyBytes {
    if (_rawKey.isEmpty) {
      throw StateError(
        'Missing PVZ2C_ENCRYPTION_KEY. Provide it with '
        '--dart-define=PVZ2C_ENCRYPTION_KEY=... or '
        '--dart-define-from-file=dart_defines.json.',
      );
    }
    final md5Hash = md5.convert(utf8.encode(_rawKey));
    final hexStr = md5Hash.toString();
    return Uint8List.fromList(utf8.encode(hexStr));
  }

  // Skip 4 bytes into key, take remaining bytes zero-padded to blockSize
  static Uint8List get ivBytes {
    final key = keyBytes;
    final iv = Uint8List(blockSize);
    final src = key.sublist(4);
    for (var i = 0; i < src.length && i < blockSize; i++) {
      iv[i] = src[i];
    }
    return iv;
  }
}

class RijndaelC {
  final Uint8List keyBytes;
  final Uint8List ivBytes;

  RijndaelC(this.keyBytes, this.ivBytes);

  factory RijndaelC.defaultValue() =>
      RijndaelC(PvZ2Crypto.keyBytes, PvZ2Crypto.ivBytes);
}
