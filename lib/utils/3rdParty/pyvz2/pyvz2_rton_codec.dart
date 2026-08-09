import 'dart:convert';
import 'dart:typed_data';

import 'package:rijndael/rijndael.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/utils/3rdParty/sen/sen_buffer.dart';
import 'package:c_editor/utils/pvz2c_crypto.dart';

/// Categorises RTON (de)serialisation failures so the UI can localise them.
enum RtonErrorKind {
  invalidMagic,
  invalidVersion,
  invalidEnd,
  invalidArrayEnd,
  invalidRtid,
  invalidValueType,
}

/// A structural RTON error that maps to a localisable message. UI layers can
/// switch on [kind] to surface a friendly notification instead of crashing.
class RtonFormatException extends FormatException {
  RtonFormatException(this.kind, [String? message])
      : super(message ?? _defaultMessage(kind));

  final RtonErrorKind kind;

  static String _defaultMessage(RtonErrorKind kind) {
    switch (kind) {
      case RtonErrorKind.invalidMagic:
        return 'Invalid RTON file: magic must be "RTON".';
      case RtonErrorKind.invalidVersion:
        return 'Invalid RTON version (expected 1).';
      case RtonErrorKind.invalidEnd:
        return 'Invalid RTON file: must end with "DONE".';
      case RtonErrorKind.invalidArrayEnd:
        return 'Invalid RTON array delimiter.';
      case RtonErrorKind.invalidRtid:
        return 'Invalid RTID value.';
      case RtonErrorKind.invalidValueType:
        return 'Invalid value type for RTON.';
    }
  }
}

class Pyvz2RtonCodec {
  const Pyvz2RtonCodec();

  static final BigInt _int64Min = BigInt.parse('-9223372036854775808');
  static final BigInt _int32Min = BigInt.parse('-2147483648');
  static final BigInt _int32Max = BigInt.parse('2147483647');
  static final BigInt _uint32Max = BigInt.parse('4294967295');
  static final BigInt _int32VarMax = BigInt.parse('2097151');
  static final BigInt _int32VarMin = BigInt.parse('-1048576');
  static final BigInt _int64VarMax = BigInt.parse('562949953421311');
  static final BigInt _int64VarMin = BigInt.parse('-281474976710656');
  static final BigInt _int64Max = BigInt.parse('9223372036854775807');
  static final BigInt _uint64Max = BigInt.parse('18446744073709551615');

  Uint8List decryptRton(Uint8List raw, RijndaelC cfg) {
    final cipherBytes = raw.length >= 2 && raw[0] == 0x10 && raw[1] == 0x00
        ? raw.sublist(2)
        : raw;
    final cbc = RijndaelCbc(
      cfg.keyBytes,
      cfg.ivBytes,
      ZeroPadding(PvZ2Crypto.blockSize),
      blockSize: PvZ2Crypto.blockSize,
    );
    return Uint8List.fromList(cbc.decrypt(cipherBytes));
  }

  Uint8List encryptRton(Uint8List raw, RijndaelC cfg) {
    final cbc = RijndaelCbc(
      cfg.keyBytes,
      cfg.ivBytes,
      ZeroPadding(PvZ2Crypto.blockSize),
      blockSize: PvZ2Crypto.blockSize,
    );
    final encrypted = cbc.encrypt(raw);
    return Uint8List.fromList([0x10, 0x00, ...encrypted]);
  }

  PvzLevelFile decode(
    Uint8List bytes, {
    bool decrypt = false,
    RijndaelC? rijndael,
  }) {
    final raw = decrypt
        ? decryptRton(bytes, rijndael ?? RijndaelC.defaultValue())
        : bytes;
    final reader = SenBuffer.fromBytes(raw);
    final magic = reader.readString(4);
    if (magic != 'RTON') {
      throw RtonFormatException(RtonErrorKind.invalidMagic);
    }

    final version = reader.readUint32LE();
    if (version != 1) {
      throw RtonFormatException(
        RtonErrorKind.invalidVersion,
        'Invalid RTON version: $version (expected 1).',
      );
    }

    final cachedStrings = <String>[];
    final cachedPrintableStrings = <String>[];
    final root = _decodeObject(reader, cachedStrings, cachedPrintableStrings);

    final done = reader.readString(4);
    if (done != 'DONE') {
      throw RtonFormatException(RtonErrorKind.invalidEnd);
    }

    return PvzLevelFile.fromJson(Map<String, dynamic>.from(root));
  }

  Uint8List encode(
    PvzLevelFile data, {
    bool encrypt = false,
    RijndaelC? rijndael,
  }) {
    final map = Map<String, Object?>.from(data.toJson());
    final writer = BytesBuilder(copy: false)
      ..add(ascii.encode('RTON'))
      ..add(_packUnsignedBigIntLE(BigInt.one, 4));

    final cachedStrings = <String, int>{};
    _encodeRootObject(writer, map, cachedStrings);

    writer.addByte(0xFF);
    writer.add(ascii.encode('DONE'));
    final raw = writer.toBytes();
    if (!encrypt) {
      return raw;
    }
    return encryptRton(raw, rijndael ?? RijndaelC.defaultValue());
  }

  PvzLevelFile decodeJson(String jsonText) {
    final decoded = jsonDecode(jsonText);
    if (decoded is! Map) {
      throw const FormatException('Top-level JSON value must be an object.');
    }
    return PvzLevelFile.fromJson(Map<String, dynamic>.from(decoded));
  }

  Uint8List encodeJson(
    String jsonText, {
    bool encrypt = false,
    RijndaelC? rijndael,
  }) {
    return encode(decodeJson(jsonText), encrypt: encrypt, rijndael: rijndael);
  }

  Map<String, Object?> _decodeObject(
    SenBuffer reader,
    List<String> cachedStrings,
    List<String> cachedPrintableStrings,
  ) {
    final result = <String, Object?>{};

    while (true) {
      final keyTag = reader.readByte();
      if (keyTag == 0xFF) {
        break;
      }

      final key = _decodeKey(
        keyTag,
        reader,
        cachedStrings,
        cachedPrintableStrings,
      );

      final valueTag = reader.readByte();
      final value = _decodeValue(
        valueTag,
        reader,
        cachedStrings,
        cachedPrintableStrings,
      );
      result[key] = value;
    }

    return result;
  }

  List<Object?> _decodeArray(
    SenBuffer reader,
    List<String> cachedStrings,
    List<String> cachedPrintableStrings,
  ) {
    final listType = reader.readByte();
    if (listType != 0xFD) {
      throw RtonFormatException(
        RtonErrorKind.invalidArrayEnd,
        'Unsupported list subtype: 0x${listType.toRadixString(16)}',
      );
    }

    final expectedLength = _readVarUint(reader);
    final items = <Object?>[];

    while (true) {
      final tag = reader.readByte();
      if (tag == 0xFE) {
        break;
      }
      items.add(
        _decodeValue(tag, reader, cachedStrings, cachedPrintableStrings),
      );
    }

    if (items.length != expectedLength) {
      // Keep Python behavior lenient: parsed values are returned even if count mismatched.
    }
    return items;
  }

  String _decodeKey(
    int tag,
    SenBuffer reader,
    List<String> cachedStrings,
    List<String> cachedPrintableStrings,
  ) {
    switch (tag) {
      case 0x81:
        return _readText(reader);
      case 0x82:
        return _readUtf8Text(reader);
      case 0x90:
        final value = _readText(reader);
        cachedStrings.add(value);
        return value;
      case 0x91:
        final idx = _readVarUint(reader);
        if (idx < 0 || idx >= cachedStrings.length) {
          throw FormatException('Cached string index out of range: $idx');
        }
        return cachedStrings[idx];
      case 0x92:
        final value = _readUtf8Text(reader);
        cachedPrintableStrings.add(value);
        return value;
      case 0x93:
        final idx = _readVarUint(reader);
        if (idx < 0 || idx >= cachedPrintableStrings.length) {
          throw FormatException(
            'Cached printable string index out of range: $idx',
          );
        }
        return cachedPrintableStrings[idx];
      default:
        throw RtonFormatException(
          RtonErrorKind.invalidValueType,
          'Unknown key tag: 0x${tag.toRadixString(16)}',
        );
    }
  }

  Object? _decodeValue(
    int tag,
    SenBuffer reader,
    List<String> cachedStrings,
    List<String> cachedPrintableStrings,
  ) {
    switch (tag) {
      case 0x00:
        return false;
      case 0x01:
        return true;

      case 0x08:
        return reader.readInt8();
      case 0x09:
      case 0x0B:
      case 0x11:
      case 0x13:
      case 0x21:
      case 0x27:
      case 0x41:
      case 0x47:
        return 0;
      case 0x0A:
        return reader.readByte();

      case 0x10:
        return reader.readInt16LE();
      case 0x12:
        return reader.readUint16LE();

      case 0x20:
        return reader.readInt32LE();
      case 0x22:
        return reader.readFloat32LE();
      case 0x23:
      case 0x43:
        return 0.0;
      case 0x24:
      case 0x28:
      case 0x44:
      case 0x48:
        return _readVarUint(reader);
      case 0x25:
      case 0x29:
      case 0x45:
      case 0x49:
        return _readVarInt(reader);
      case 0x26:
        return reader.readUint32LE();

      case 0x40:
        return reader.readInt64LE();
      case 0x42:
        return reader.readFloat64LE();
      case 0x46:
        return reader.readUint64LE();

      case 0x81:
        return _readText(reader);
      case 0x82:
        return _readUtf8Text(reader);
      case 0x83:
        return _readRtid(reader);
      case 0x84:
        return 'RTID(0)';
      case 0x85:
        return _decodeObject(reader, cachedStrings, cachedPrintableStrings);
      case 0x86:
        return _decodeArray(reader, cachedStrings, cachedPrintableStrings);

      case 0x90:
        final value = _readText(reader);
        cachedStrings.add(value);
        return value;
      case 0x91:
        final idx = _readVarUint(reader);
        if (idx < 0 || idx >= cachedStrings.length) {
          throw FormatException('Cached string index out of range: $idx');
        }
        return cachedStrings[idx];
      case 0x92:
        final value = _readUtf8Text(reader);
        cachedPrintableStrings.add(value);
        return value;
      case 0x93:
        final idx = _readVarUint(reader);
        if (idx < 0 || idx >= cachedPrintableStrings.length) {
          throw FormatException(
            'Cached printable string index out of range: $idx',
          );
        }
        return cachedPrintableStrings[idx];

      default:
        throw RtonFormatException(
          RtonErrorKind.invalidValueType,
          'Unknown value tag: 0x${tag.toRadixString(16)}',
        );
    }
  }

  String _readText(SenBuffer reader) {
    final len = _readVarUint(reader);
    final bytes = reader.readBytes(len);
    try {
      return utf8.decode(bytes);
    } catch (_) {
      return latin1.decode(bytes);
    }
  }

  String _readUtf8Text(SenBuffer reader) {
    final expectedChars = _readVarUint(reader);
    final byteLen = _readVarUint(reader);
    final decoded = utf8.decode(reader.readBytes(byteLen));
    if (decoded.runes.length != expectedChars) {
      // Match Python behavior: no hard failure, just continue.
    }
    return decoded;
  }

  String _readRtid(SenBuffer reader) {
    final subtype = reader.readByte();
    switch (subtype) {
      case 0x00:
        return 'RTID(0)';
      case 0x02:
        final type = _readUtf8Text(reader);
        final i2 = _readVarUint(reader);
        final i1 = _readVarUint(reader);
        final raw = reader.readBytes(4).reversed.toList(growable: false);
        final hex = raw.map((v) => v.toRadixString(16).padLeft(2, '0')).join();
        return 'RTID($i1.$i2.$hex@$type)';
      case 0x03:
        final type = _readUtf8Text(reader);
        final name = _readUtf8Text(reader);
        return 'RTID($name@$type)';
      default:
        throw RtonFormatException(
          RtonErrorKind.invalidRtid,
          'Unknown RTID subtype: 0x${subtype.toRadixString(16)}',
        );
    }
  }

  void _encodeRootObject(
    BytesBuilder writer,
    Map<String, Object?> map,
    Map<String, int> cachedStrings,
  ) {
    for (final entry in map.entries) {
      writer.add(_encodeCachedString(entry.key, cachedStrings));
      writer.add(_encodeValue(entry.value, cachedStrings));
    }
  }

  Uint8List _encodeObject(
    Map<String, Object?> map,
    Map<String, int> cachedStrings,
  ) {
    final writer = BytesBuilder(copy: false)..addByte(0x85);
    for (final entry in map.entries) {
      writer.add(_encodeCachedString(entry.key, cachedStrings));
      writer.add(_encodeValue(entry.value, cachedStrings));
    }
    writer.addByte(0xFF);
    return writer.toBytes();
  }

  Uint8List _encodeArray(List<Object?> list, Map<String, int> cachedStrings) {
    final writer = BytesBuilder(copy: false)
      ..addByte(0x86)
      ..addByte(0xFD)
      ..add(_writeVarUint(list.length));

    for (final value in list) {
      writer.add(_encodeValue(value, cachedStrings));
    }

    writer.addByte(0xFE);
    return writer.toBytes();
  }

  Uint8List _encodeValue(Object? value, Map<String, int> cachedStrings) {
    if (value is String) {
      if (_isRtid(value)) {
        return _encodeRtid(value);
      }
      return _encodeCachedString(value, cachedStrings);
    }

    if (value is bool) {
      return Uint8List.fromList([value ? 0x01 : 0x00]);
    }

    if (value is BigInt) {
      return _encodeInt(value);
    }

    if (value is int) {
      return _encodeInt(BigInt.from(value));
    }

    if (value is double) {
      return _encodeFloat(value);
    }

    if (value is List) {
      return _encodeArray(List<Object?>.from(value), cachedStrings);
    }

    if (value is Map) {
      final typed = <String, Object?>{};
      for (final entry in value.entries) {
        if (entry.key is! String) {
          throw FormatException(
            'Object keys must be strings, got ${entry.key.runtimeType}.',
          );
        }
        typed[entry.key as String] = entry.value;
      }
      return _encodeObject(typed, cachedStrings);
    }

    if (value == null) {
      return Uint8List.fromList([0x84]);
    }

    throw RtonFormatException(
      RtonErrorKind.invalidValueType,
      'Unsupported value type for RTON: ${value.runtimeType}',
    );
  }

  Uint8List _encodeInt(BigInt value) {
    if (value == BigInt.zero) {
      return Uint8List.fromList([0x21]);
    }
    if (value >= BigInt.zero && value <= _int32VarMax) {
      return Uint8List.fromList([0x24, ..._writeVarUint(value.toInt())]);
    }
    if (value >= _int32VarMin && value <= BigInt.zero) {
      final zigZag = (-BigInt.one - (value * BigInt.from(2))).toInt();
      return Uint8List.fromList([0x25, ..._writeVarUint(zigZag)]);
    }
    if (value >= _int32Min && value <= _int32Max) {
      return Uint8List.fromList([0x20, ..._packSignedBigIntLE(value, 4)]);
    }
    if (value >= BigInt.zero && value <= _uint32Max) {
      return Uint8List.fromList([0x26, ..._packUnsignedBigIntLE(value, 4)]);
    }
    if (value >= BigInt.zero && value <= _int64VarMax) {
      return Uint8List.fromList([0x44, ..._writeVarUint(value.toInt())]);
    }
    if (value >= _int64VarMin && value <= BigInt.zero) {
      final zigZag = (-BigInt.one - (value * BigInt.from(2))).toInt();
      return Uint8List.fromList([0x45, ..._writeVarUint(zigZag)]);
    }
    if (value >= _int64Min && value <= _int64Max) {
      return Uint8List.fromList([0x40, ..._packSignedBigIntLE(value, 8)]);
    }
    if (value >= BigInt.zero) {
      // Python prefers fixed uint64 when representable; otherwise uses uvarint tag 0x44.
      if (value <= _uint64Max) {
        return Uint8List.fromList([0x46, ..._packUnsignedBigIntLE(value, 8)]);
      }
      throw FormatException('Integer too large to encode as RTON: $value');
    }
    return Uint8List.fromList([
      0x45,
      ..._writeVarUint((-BigInt.one - (value * BigInt.from(2))).toInt()),
    ]);
  }

  Uint8List _encodeFloat(double value) {
    if (value == 0.0) {
      return Uint8List.fromList([0x23]);
    }

    final f32 = Float32List(1)..[0] = value;
    final roundtrip = f32[0];
    final isFinite32Range = value >= -3.4028235e38 && value <= 3.4028235e38;

    if (value.isNaN ||
        value.isInfinite ||
        (isFinite32Range && roundtrip == value)) {
      return Uint8List.fromList([0x22, ..._packFloat32LE(value)]);
    }

    return Uint8List.fromList([0x42, ..._packFloat64LE(value)]);
  }

  Uint8List _encodeRtid(String value) {
    if (value == 'RTID(0)') {
      return Uint8List.fromList([0x84]);
    }

    if (!_isRtid(value)) {
      throw RtonFormatException(
        RtonErrorKind.invalidRtid,
        'Invalid RTID string format.',
      );
    }

    final inner = value.substring(5, value.length - 1);
    final at = inner.lastIndexOf('@');
    if (at == -1) {
      return Uint8List.fromList([0x84]);
    }

    final name = inner.substring(0, at);
    final type = inner.substring(at + 1);

    final dotted = name.split('.');
    if (dotted.length == 3) {
      final i2 = int.parse(dotted[0]);
      final i1 = int.parse(dotted[1]);
      final hex = dotted[2];
      if (hex.length != 8) {
        throw RtonFormatException(
          RtonErrorKind.invalidRtid,
          'Invalid RTID hex component: $hex',
        );
      }
      final bytes = Uint8List(4);
      for (var i = 0; i < 4; i++) {
        bytes[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
      }
      final reversed = bytes.reversed.toList(growable: false);

      return Uint8List.fromList([
        0x83,
        0x02,
        ..._writeUtf8Text(type),
        ..._writeVarUint(i1),
        ..._writeVarUint(i2),
        ...reversed,
      ]);
    }

    return Uint8List.fromList([
      0x83,
      0x03,
      ..._writeUtf8Text(type),
      ..._writeUtf8Text(name),
    ]);
  }

  Uint8List _encodeCachedString(String value, Map<String, int> cachedStrings) {
    final existing = cachedStrings[value];
    if (existing != null) {
      return Uint8List.fromList([0x91, ..._writeVarUint(existing)]);
    }

    final bytes = utf8.encode(value);
    cachedStrings[value] = cachedStrings.length;
    return Uint8List.fromList([0x90, ..._writeVarUint(bytes.length), ...bytes]);
  }

  bool _isRtid(String value) {
    return value.length >= 6 &&
        value.startsWith('RTID(') &&
        value.endsWith(')');
  }

  int _readVarUint(SenBuffer reader) {
    var num = reader.readByte();
    var result = num & 0x7F;
    var multiplier = 128;

    while (num > 127) {
      num = reader.readByte();
      result += multiplier * (num & 0x7F);
      multiplier *= 128;
    }
    return result;
  }

  int _readVarInt(SenBuffer reader) {
    var num = _readVarUint(reader);
    if ((num & 1) == 1) {
      num = -num - 1;
    }
    return num ~/ 2;
  }

  Uint8List _writeVarUint(int value) {
    if (value < 0) {
      throw FormatException('VarUint cannot encode negative values: $value');
    }

    var v = value;
    final out = <int>[];
    while (true) {
      var byte = v & 0x7F;
      v ~/= 128;
      if (v != 0) {
        byte |= 0x80;
      }
      out.add(byte);
      if (v == 0) {
        break;
      }
    }
    return Uint8List.fromList(out);
  }

  Uint8List _writeUtf8Text(String value) {
    final bytes = utf8.encode(value);
    final runeLength = value.runes.length;
    return Uint8List.fromList([
      ..._writeVarUint(runeLength),
      ..._writeVarUint(bytes.length),
      ...bytes,
    ]);
  }

  Uint8List _packSignedBigIntLE(BigInt value, int byteCount) {
    final modulus = BigInt.one << (byteCount * 8);
    var current = value;
    if (current.isNegative) {
      current = modulus + current;
    }
    return _packUnsignedBigIntLE(current, byteCount);
  }

  Uint8List _packUnsignedBigIntLE(BigInt value, int byteCount) {
    final bytes = Uint8List(byteCount);
    var current = value;
    for (var i = 0; i < byteCount; i++) {
      bytes[i] = (current & BigInt.from(0xFF)).toInt();
      current >>= 8;
    }
    return bytes;
  }

  Uint8List _packFloat32LE(double value) {
    final data = ByteData(4)..setFloat32(0, value, Endian.little);
    return data.buffer.asUint8List();
  }

  Uint8List _packFloat64LE(double value) {
    final data = ByteData(8)..setFloat64(0, value, Endian.little);
    return data.buffer.asUint8List();
  }
}
