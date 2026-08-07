import 'package:c_editor/data/pvz_models/PvzObject.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legacy editor aliases are removed while reading and writing JSON', () {
    final object = PvzObject.fromJson({
      'aliases': [
        'PlayableAlias',
        '__c_editor_zomboss_action_preset__presetTemplate__sport_tank_spawn',
      ],
      'objclass': 'ZombieDropActionDefinition',
      'objdata': <String, dynamic>{},
    });

    expect(object.aliases, ['PlayableAlias']);

    object.aliases!.add('__c_editor_custom_stage_preset__roman_empire');
    expect(object.toJson()['aliases'], ['PlayableAlias']);
  });
}
