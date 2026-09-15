import 'dart:convert';
import 'dart:io';

const _pvpPrefix = 'new_pvp_';
const _zombieTypesPath = 'assets/reference/ZombieTypes.json';
const _zombiesPath = 'assets/resources/Zombies.json';
const _localeSuffixes = <String, String>{
  'en': 'Two-Player Mode',
  'zh': '双人对决',
  'ru': 'Режим для двух игроков',
};

void main(List<String> arguments) {
  final checkOnly = arguments.contains('--check');
  final pvpIds = _loadPvpIds();
  final zombiesFile = File(_zombiesPath);
  final currentZombiesText = zombiesFile.readAsStringSync();
  final currentZombies = (jsonDecode(currentZombiesText) as List)
      .cast<Map<String, dynamic>>();
  final generatedZombies = _buildZombies(currentZombies, pvpIds);
  final zombiesText =
      '${const JsonEncoder.withIndent('  ').convert(generatedZombies)}\n';

  final generatedFiles = <File, String>{zombiesFile: zombiesText};
  for (final entry in _localeSuffixes.entries) {
    final file = File('assets/l10n/resource_${entry.key}.json');
    generatedFiles[file] = _buildLocalizedNames(
      currentText: file.readAsStringSync(),
      zombies: generatedZombies,
      pvpIds: pvpIds,
      suffix: entry.value,
    );
  }

  var hasChanges = false;
  for (final entry in generatedFiles.entries) {
    if (entry.key.readAsStringSync() == entry.value) continue;
    hasChanges = true;
    if (!checkOnly) entry.key.writeAsStringSync(entry.value);
  }

  if (checkOnly && hasChanges) {
    stderr.writeln('PvP zombie resources are out of date.');
    exitCode = 1;
  }
}

List<String> _loadPvpIds() {
  final root = jsonDecode(File(_zombieTypesPath).readAsStringSync()) as Map;
  final ids = <String>[];
  for (final rawObject in root['objects'] as List? ?? const []) {
    if (rawObject is! Map) continue;
    final data = rawObject['objdata'];
    if (data is! Map) continue;
    final id = data['TypeName']?.toString() ?? '';
    if (id.startsWith(_pvpPrefix)) ids.add(id);
  }
  return ids;
}

List<Map<String, dynamic>> _buildZombies(
  List<Map<String, dynamic>> current,
  List<String> pvpIds,
) {
  final pvpIdSet = pvpIds.toSet();
  final baseZombies = current
      .where((zombie) => !pvpIdSet.contains(zombie['id']))
      .map(_cloneMap)
      .toList();
  final byId = <String, Map<String, dynamic>>{
    for (final zombie in baseZombies) zombie['id'] as String: zombie,
  };
  final indexById = <String, int>{
    for (var i = 0; i < baseZombies.length; i++)
      baseZombies[i]['id'] as String: i,
  };
  final insertAfter = <String, List<Map<String, dynamic>>>{};

  for (final pvpId in pvpIds) {
    final baseId = pvpId.substring(_pvpPrefix.length);
    final base = byId[baseId];
    if (base == null) {
      throw StateError('Missing base zombie for $pvpId: $baseId');
    }

    final generated = _cloneMap(base);
    generated['id'] = pvpId;
    generated['name'] = 'zombie_$pvpId';
    generated['tags'] = <String>[
      ...((base['tags'] as List? ?? const [])
          .map((tag) => tag.toString())
          .where(
            (tag) => tag != 'International' && tag != 'Chinese' && tag != 'PvP',
          )),
      'PvP',
      'Chinese',
    ];

    final baseIndex = indexById[baseId]!;
    final icon = base['icon'];
    var anchorIndex = baseIndex;
    while (anchorIndex + 1 < baseZombies.length &&
        baseZombies[anchorIndex + 1]['icon'] == icon) {
      anchorIndex++;
    }
    final anchorId = baseZombies[anchorIndex]['id'] as String;
    insertAfter.putIfAbsent(anchorId, () => []).add(generated);
  }

  final result = <Map<String, dynamic>>[];
  for (final zombie in baseZombies) {
    result.add(zombie);
    result.addAll(insertAfter[zombie['id']] ?? const []);
  }
  return result;
}

String _buildLocalizedNames({
  required String currentText,
  required List<Map<String, dynamic>> zombies,
  required List<String> pvpIds,
  required String suffix,
}) {
  final current = Map<String, dynamic>.from(jsonDecode(currentText) as Map);
  final pvpKeys = pvpIds.map((id) => 'zombie_$id').toSet();
  current.removeWhere((key, _) => pvpKeys.contains(key));
  final byId = <String, Map<String, dynamic>>{
    for (final zombie in zombies) zombie['id'] as String: zombie,
  };
  final localizedPvpNames = <String, String>{};
  final sortedPvpIds = pvpIds.toList()..sort();
  for (final pvpId in sortedPvpIds) {
    final baseId = pvpId.substring(_pvpPrefix.length);
    final baseNameKey = byId[baseId]!['name'] as String;
    final baseName = current[baseNameKey];
    if (baseName == null) {
      throw StateError('Missing localized base name for $pvpId: $baseNameKey');
    }
    localizedPvpNames['zombie_$pvpId'] = '$baseName ($suffix)';
  }

  final result = <String, dynamic>{};
  final firstPvpKey = localizedPvpNames.keys.first;
  var insertedPvpNames = false;
  for (final entry in current.entries) {
    if (!insertedPvpNames &&
        entry.key.startsWith('zombie_') &&
        entry.key.compareTo(firstPvpKey) > 0) {
      result.addAll(localizedPvpNames);
      insertedPvpNames = true;
    }
    result[entry.key] = entry.value;
  }
  if (!insertedPvpNames) result.addAll(localizedPvpNames);
  return '${const JsonEncoder.withIndent('    ').convert(result)}\n';
}

Map<String, dynamic> _cloneMap(Map<String, dynamic> value) =>
    Map<String, dynamic>.from(jsonDecode(jsonEncode(value)) as Map);
