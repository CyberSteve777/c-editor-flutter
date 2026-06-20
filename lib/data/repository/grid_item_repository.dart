import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:c_editor/data/asset_loader.dart';
import 'package:c_editor/data/pvz_models/PvzLevelFile.dart';
import 'package:c_editor/data/pvz_models/PvzObject.dart';
import 'package:c_editor/data/repository/reference_repository.dart';
import 'package:c_editor/data/rtid_parser.dart';

/// Grid item info. Ported from Z-Editor-master GridItemRepository.kt
/// For display use ResourceNames.lookup(context, 'griditem_$typeName').
enum GridItemFilterMode { all, restricted, renaiStatues }

enum GridItemTag { normal, special }

enum GridItemSource { defaultSource, custom }

class GridItemInfo {
  const GridItemInfo({
    required this.typeName,
    required this.category,
    this.icon,
    this.tag = GridItemTag.normal,
    this.source = GridItemSource.defaultSource,
    this.gridItemType,
  });

  final String typeName;
  final GridItemCategory category;

  /// Icon filename in assets/images/griditems/ (e.g. 'gravestone_egypt.webp').
  /// Null = use placeholder icon.
  final String? icon;
  final GridItemTag tag;
  final GridItemSource source;
  final PvzObject? gridItemType;
}

enum GridItemCategory {
  all('All'),
  scene('Scene'),
  trap('Trap'),
  spawnableObjects('Spawnable Objects');

  const GridItemCategory(this.label);
  final String label;
}

/// Grid item repository. Icons from assets/images/griditems/.
/// Items without matching icon use placeholder.
/// For localized display use getLocalizedName(context, typeName) via ResourceNames.
class GridItemRepository {
  GridItemRepository._();

  static const String _resourcePath = 'assets/resources/GridItems.json';
  static final List<GridItemInfo> staticItems = [];
  static bool _isLoaded = false;

  static Future<void> init() async {
    if (_isLoaded) return;
    try {
      final jsonString = await loadJsonString(_resourcePath);
      final List<dynamic> jsonList = json.decode(jsonString) as List<dynamic>;
      staticItems
        ..clear()
        ..addAll(
          jsonList.map((raw) {
            final item = raw as Map<String, dynamic>;
            return GridItemInfo(
              typeName: item['typeName'] as String,
              category: _parseCategory(item['category'] as String?),
              icon: item['icon'] as String?,
              tag: _parseTag(item['tag'] as String?),
              source: _parseSource(item['source'] as String?),
              gridItemType: _parseGridItemType(item['gridItemType']),
            );
          }),
        );
      _isLoaded = true;
    } catch (e) {
      debugPrint('Error loading grid items: $e');
    }
  }

  static List<GridItemInfo> get allItems => staticItems;

  static List<GridItemInfo> getByCategory(GridItemCategory category) {
    if (category == GridItemCategory.all) return allItems;
    return allItems.where((i) => i.category == category).toList();
  }

  static List<GridItemInfo> getAll() => allItems;

  static GridItemInfo? getByTypeName(String typeName) {
    final alias = buildGridAliases(typeName);
    for (final item in allItems) {
      if (item.typeName == typeName ||
          buildGridAliases(item.typeName) == alias) {
        return item;
      }
    }
    return null;
  }

  /// Returns asset path for icon, or unknown placeholder if no icon.
  static String getIconPath(String aliases) {
    final typeName = aliases == 'gravestone' ? 'gravestone_egypt' : aliases;
    try {
      final item = allItems.firstWhere((i) => i.typeName == typeName);
      final icon = item.icon;
      return icon != null
          ? 'assets/images/griditems/$icon'
          : 'assets/images/others/unknown.webp';
    } catch (_) {
      return 'assets/images/others/unknown.webp';
    }
  }

  /// True for any Renai statue type (half or non-half).
  static bool isRenaiStatue(String typeName) =>
      typeName.contains('renai_statue_') ||
      typeName == 'renai_zomboss_statue_zombie1_half';

  /// Renai statue types only (for statue picker in Renai module).
  static List<GridItemInfo> getRenaiStatueItems() =>
      allItems.where((i) => isRenaiStatue(i.typeName)).toList();

  static bool isValid(String typeName) {
    if (allItems.any((i) => i.typeName == typeName)) return true;
    return ReferenceRepository.instance.isValidGridItem(typeName);
  }

  static String buildGridAliases(String id) {
    if (id == 'gravestone_egypt') return 'gravestone';
    return id;
  }

  static String buildGridItemTypeRtid(String typeName, PvzLevelFile levelFile) {
    final alias = buildGridAliases(typeName);
    final item = getByTypeName(typeName);
    if (item?.source == GridItemSource.custom) {
      ensureGridItemTypeInLevel(typeName, levelFile);
      return RtidParser.build(alias, 'CurrentLevel');
    }
    return RtidParser.build(alias, 'GridItemTypes');
  }

  static PvzObject? ensureGridItemTypeInLevel(
    String typeName,
    PvzLevelFile levelFile,
  ) {
    final item = getByTypeName(typeName);
    if (item == null || item.source != GridItemSource.custom) return null;
    final template = item.gridItemType;
    if (template == null) return null;

    final alias = buildGridAliases(typeName);
    final templateAliases = template.aliases;
    final aliases = templateAliases != null && templateAliases.isNotEmpty
        ? templateAliases
        : <String>[alias];
    final templateTypeName = _gridItemTypeName(template) ?? item.typeName;

    for (final object in levelFile.objects) {
      if (object.objClass != 'GridItemType') continue;
      final objectAliases = object.aliases ?? const <String>[];
      if (aliases.any(objectAliases.contains)) return object;
      if (_gridItemTypeName(object) == templateTypeName) return object;
    }

    final object = _clonePvzObject(template);
    if (object.aliases == null || object.aliases!.isEmpty) {
      object.aliases = List<String>.from(aliases);
    }
    levelFile.objects.add(object);
    return object;
  }

  static int cleanupUnusedCustomGridItemTypes(PvzLevelFile levelFile) {
    var removed = 0;
    for (final item in allItems) {
      if (item.source != GridItemSource.custom) continue;
      if (_cleanupUnusedCustomGridItemType(item, levelFile)) {
        removed++;
      }
    }
    return removed;
  }

  static bool cleanupUnusedCustomGridItemType(
    String typeName,
    PvzLevelFile levelFile,
  ) {
    final item = getByTypeName(typeName);
    if (item == null || item.source != GridItemSource.custom) return false;
    return _cleanupUnusedCustomGridItemType(item, levelFile);
  }

  static List<GridItemInfo> search(String query) {
    if (query.trim().isEmpty) return allItems;
    final lower = query.toLowerCase();
    return allItems
        .where((i) => i.typeName.toLowerCase().contains(lower))
        .toList();
  }

  static GridItemCategory _parseCategory(String? raw) {
    return GridItemCategory.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => GridItemCategory.scene,
    );
  }

  static GridItemTag _parseTag(String? raw) {
    return GridItemTag.values.firstWhere(
      (e) => e.name == raw,
      orElse: () => GridItemTag.normal,
    );
  }

  static GridItemSource _parseSource(String? raw) {
    return raw == 'custom'
        ? GridItemSource.custom
        : GridItemSource.defaultSource;
  }

  static PvzObject? _parseGridItemType(dynamic raw) {
    if (raw is Map<String, dynamic>) return PvzObject.fromJson(raw);
    if (raw is Map) return PvzObject.fromJson(Map<String, dynamic>.from(raw));
    return null;
  }

  static bool _cleanupUnusedCustomGridItemType(
    GridItemInfo item,
    PvzLevelFile levelFile,
  ) {
    final aliases = _gridItemTypeAliases(item);
    final hasReference = aliases.any(
      (alias) => _containsValue(
        levelFile.objects.map((object) => object.toJson()),
        RtidParser.build(alias, 'CurrentLevel'),
      ),
    );
    if (hasReference) return false;

    var removed = false;
    levelFile.objects.removeWhere((object) {
      if (object.objClass != 'GridItemType') return false;
      final objectAliases = object.aliases ?? const <String>[];
      final shouldRemove = objectAliases.any(aliases.contains);
      removed = removed || shouldRemove;
      return shouldRemove;
    });
    return removed;
  }

  static Set<String> _gridItemTypeAliases(GridItemInfo item) {
    final aliases = <String>{buildGridAliases(item.typeName)};
    final templateAliases = item.gridItemType?.aliases;
    if (templateAliases != null) aliases.addAll(templateAliases);
    return aliases;
  }

  static bool _containsValue(dynamic value, String target) {
    if (value is String) return value == target;
    if (value is Iterable) {
      return value.any((entry) => _containsValue(entry, target));
    }
    if (value is Map) {
      return value.values.any((entry) => _containsValue(entry, target));
    }
    return false;
  }

  static String? _gridItemTypeName(PvzObject object) {
    final objData = object.objData;
    if (objData is Map) {
      final typeName = objData['TypeName'];
      if (typeName is String && typeName.isNotEmpty) return typeName;
    }
    return null;
  }

  static PvzObject _clonePvzObject(PvzObject object) {
    final aliases = object.aliases;
    return PvzObject(
      aliases: aliases == null ? null : List<String>.from(aliases),
      objClass: object.objClass,
      objData: jsonDecode(jsonEncode(object.objData)),
    );
  }
}
