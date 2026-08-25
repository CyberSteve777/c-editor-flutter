import 'package:c_editor/data/pvz_alias_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('seed bank modules can be added more than once', () {
    final metadata = ModuleRegistry.getMetadata('SeedBankProperties');

    expect(metadata.allowMultiple, isTrue);
    expect(metadata.defaultAlias, 'SeedBank');
  });

  test('connected minecart duplicates append the number directly', () {
    final level = PvzLevelFile(
      objects: [
        PvzObject(aliases: ['MechanismPlank'], objClass: 'Test', objData: {}),
        PvzObject(aliases: ['MechanismPlank1'], objClass: 'Test', objData: {}),
      ],
    );
    final metadata = ModuleRegistry.getMetadata('MechanismPlankProperties');

    expect(metadata.allowMultiple, isTrue);
    expect(metadata.duplicateAliasNumberSeparator, isEmpty);
    expect(
      PvzAliasUtils.uniqueAlias(
        level,
        metadata.defaultAlias,
        numberSeparator: metadata.duplicateAliasNumberSeparator,
      ),
      'MechanismPlank2',
    );
  });

  test('protect-grid-item module supports compact numbered duplicates', () {
    final metadata = ModuleRegistry.getMetadata(
      'ProtectTheGridItemChallengeProperties',
    );

    expect(metadata.allowMultiple, isTrue);
    expect(metadata.duplicateAliasNumberSeparator, isEmpty);
  });
}
