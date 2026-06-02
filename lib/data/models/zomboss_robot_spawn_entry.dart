/// One zombie entry in PVZ1 robot spawn actions (`SpawnZombieTypes` object list).
class ZombossRobotSpawnEntry {
  ZombossRobotSpawnEntry({
    required this.zombieTypeName,
    this.row = -1,
    this.level = 1,
    this.hasPlantfood = false,
    this.weight = 100,
  });

  String zombieTypeName;
  int row;
  int level;
  bool hasPlantfood;
  int weight;

  static bool isRobotSpawnList(dynamic raw) {
    if (raw is! List || raw.isEmpty) return false;
    final first = raw.first;
    return first is Map && first.containsKey('ZombieTypeName');
  }

  static List<ZombossRobotSpawnEntry> parseList(dynamic raw) {
    if (raw is! List) return [];
    return raw.map((e) {
      if (e is! Map) return null;
      final map = e is Map<String, dynamic>
          ? e
          : Map<String, dynamic>.from(e);
      return ZombossRobotSpawnEntry(
        zombieTypeName: map['ZombieTypeName']?.toString() ?? '',
        row: _asInt(map['Row'], -1),
        level: _asInt(map['Level'], 1),
        hasPlantfood: map['HasPlantfood'] == true,
        weight: _asInt(map['Weight'], 100),
      );
    }).whereType<ZombossRobotSpawnEntry>().toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<ZombossRobotSpawnEntry> entries) {
    return entries
        .map(
          (e) => {
            'ZombieTypeName': e.zombieTypeName,
            'Row': e.row,
            'Level': e.level,
            'HasPlantfood': e.hasPlantfood,
            'Weight': e.weight,
          },
        )
        .toList();
  }

  Map<String, dynamic> toJson() => {
        'ZombieTypeName': zombieTypeName,
        'Row': row,
        'Level': level,
        'HasPlantfood': hasPlantfood,
        'Weight': weight,
      };

  static int _asInt(dynamic value, int fallback) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? fallback;
    return fallback;
  }
}

bool zombossActionUsesRobotSpawnList(String objclass) =>
    objclass.contains('ZombossRobotSpawn');
