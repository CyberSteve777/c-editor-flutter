import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:c_editor/utils/3rdParty/sen/sen_rsg_common.dart';
import 'package:c_editor/utils/3rdParty/sen/sen_rsb_common.dart';

void main() {
  group('RSG Memory Round-trip', () {
    test('Pack and Unpack RSG in memory', () {
      final rsg = ResourceStreamGroup();
      
      final resources = {
        'TEST.TXT': Uint8List.fromList('Hello World'.codeUnits),
      };
      
      final packetInfo = {
        'version': 3,
        'compression_flags': 0,
        'res': [
          {'path': ['TEST.TXT']}
        ],
      };
      
      // Pack
      final senFile = rsg.packRSG(packetInfo, resources, null);
      expect(senFile.length, greaterThan(0));
      
      // Unpack
      senFile.readOffset = 0; // RESET OFFSET
      final unpacked = rsg.unpackRSG(senFile, null);
      
      expect(unpacked['version'], equals(3));
      expect(unpacked['files']['TEST.TXT'], equals(resources['TEST.TXT']));
    });
  });

  group('RSB Memory Round-trip', () {
    test('Pack and Unpack RSB in memory', () {
      final rsb = ResourceStreamBundle();
      final rsg = ResourceStreamGroup();
      
      // Prepare a real RSG first
      final rsgResources = {
        'dummy.txt': Uint8List.fromList('Data'.codeUnits),
      };
      final rsgPacketInfo = {
        'version': 3,
        'compression_flags': 0,
        'res': [
          {'path': ['dummy.txt']}
        ],
      };
      final rsgSenFile = rsg.packRSG(rsgPacketInfo, rsgResources, null);
      final rsgBytes = rsgSenFile.toBytes();
      
      // Prepare RSB manifest
      final manifest = {
        'version': 3,
        'ptx_info_size': 16,
        'description': {
          'groups': {}
        },
        'group': {
          'TestGroup': {
            'is_composite': true,
            'subgroup': {
              'TestPacket': {
                'category': [0, ''],
                'packet_info': {
                  'version': 3,
                  'compression_flags': 0,
                  'res': [
                    {'path': ['dummy.txt']}
                  ]
                }
              }
            }
          }
        }
      };
      
      final rsgFiles = {
        'TestPacket.rsg': rsgBytes,
      };
      
      // Pack RSB
      final rsbSenFile = rsb.packRSB(rsgFiles, manifest, null);
      expect(rsbSenFile.length, greaterThan(0));
      
      // Unpack RSB
      rsbSenFile.readOffset = 0; // RESET OFFSET
      final unpacked = rsb.unpackRSB(rsbSenFile, null);
      
      expect(unpacked['manifest']['version'], equals(3));
      expect(unpacked['rsg_files'].containsKey('TestPacket.rsg'), isTrue);
      
      final extractedRsgBytes = unpacked['rsg_files']['TestPacket.rsg'];
      expect(extractedRsgBytes, equals(rsgBytes));
    });
  });
}
