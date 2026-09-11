import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/stage_banner_resolver.dart';

typedef PreviewLabelLookup = String Function(String key, String fallback);
typedef PreviewModuleTitleLookup = String Function(String objClass);

class PreviewFeatureGroup {
  const PreviewFeatureGroup({
    required this.id,
    required this.nameKey,
    required this.objClasses,
    this.titleObjClass,
    this.fallbackName = '',
  });

  final String id;

  /// Plugin ARB key for the grouped feature label.
  final String nameKey;

  /// When set, prefer the app-localized module title for this objClass.
  final String? titleObjClass;
  final Set<String> objClasses;

  /// English fallback used when localizers are absent (tests).
  final String fallbackName;
}

class PreviewFeatureGroups {
  PreviewFeatureGroups._({
    required this.featuresPrefixKey,
    required this.groups,
    required this.excludeObjClasses,
  });

  final String featuresPrefixKey;
  final List<PreviewFeatureGroup> groups;
  final Set<String> excludeObjClasses;

  /// All objClasses tracked by feature groups (Special Modes + extras like Conveyor).
  Set<String> get trackedObjClasses {
    final out = <String>{};
    for (final g in groups) {
      out.addAll(g.objClasses);
    }
    return out;
  }

  static PreviewFeatureGroups? _instance;

  static Future<PreviewFeatureGroups> load() async {
    if (_instance != null) return _instance!;
    final raw = await rootBundle.loadString(
      '${StageBannerResolver.flutterAssetsRoot}/feature_groups.json',
    );
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final groups = <PreviewFeatureGroup>[];
    final groupsRaw = json['groups'];
    if (groupsRaw is List) {
      for (final g in groupsRaw) {
        if (g is! Map) continue;
        final classes = <String>{};
        final oc = g['objClasses'];
        if (oc is List) {
          for (final c in oc) {
            classes.add(c.toString());
          }
        }
        final id = g['id']?.toString() ?? '';
        final nameKey =
            g['nameKey']?.toString() ??
            (id.isEmpty ? '' : 'previewFeature_$id');
        groups.add(
          PreviewFeatureGroup(
            id: id,
            nameKey: nameKey,
            titleObjClass: g['titleObjClass']?.toString(),
            objClasses: classes,
            fallbackName:
                g['displayName']?.toString() ??
                g['fallbackName']?.toString() ??
                id,
          ),
        );
      }
    }
    final exclude = <String>{};
    final ex = json['excludeObjClasses'];
    if (ex is List) {
      for (final e in ex) {
        exclude.add(e.toString());
      }
    }
    _instance = PreviewFeatureGroups._(
      featuresPrefixKey:
          (json['featuresPrefixKey'] as String?) ?? 'previewFeaturesPrefix',
      groups: groups,
      excludeObjClasses: exclude,
    );
    return _instance!;
  }

  static void resetForTest() => _instance = null;

  static PreviewFeatureGroups forTest({
    String featuresPrefixKey = 'previewFeaturesPrefix',
    List<PreviewFeatureGroup> groups = const [],
    Set<String> excludeObjClasses = const {},
  }) {
    return PreviewFeatureGroups._(
      featuresPrefixKey: featuresPrefixKey,
      groups: groups,
      excludeObjClasses: excludeObjClasses,
    );
  }

  String _groupLabel(
    PreviewFeatureGroup group, {
    PreviewLabelLookup? localize,
    PreviewModuleTitleLookup? moduleTitle,
  }) {
    if (group.titleObjClass != null && moduleTitle != null) {
      final titled = moduleTitle(group.titleObjClass!);
      if (titled.isNotEmpty) return titled;
    }
    final fallback = group.fallbackName.isNotEmpty
        ? group.fallbackName
        : group.id;
    if (localize != null && group.nameKey.isNotEmpty) {
      return localize(group.nameKey, fallback);
    }
    return fallback;
  }

  /// Builds localized `Features: A, B, C` from present theme objClasses.
  String buildSubtitle(
    Iterable<String> presentObjClasses, {
    PreviewLabelLookup? localize,
    PreviewModuleTitleLookup? moduleTitle,
  }) {
    final labels = featureLabels(
      presentObjClasses,
      localize: localize,
      moduleTitle: moduleTitle,
    );
    if (labels.isEmpty) return '';
    final prefix = localize != null
        ? localize(featuresPrefixKey, 'Features: ')
        : 'Features: ';
    return '$prefix${labels.join(', ')}';
  }

  /// Deduped feature labels (no prefix), group-aware.
  List<String> featureLabels(
    Iterable<String> presentObjClasses, {
    PreviewLabelLookup? localize,
    PreviewModuleTitleLookup? moduleTitle,
  }) {
    final present = presentObjClasses.toSet();
    final labels = <String>[];
    final claimed = <String>{};

    for (final group in groups) {
      final hit = group.objClasses.intersection(present);
      if (hit.isEmpty) continue;
      labels.add(
        _groupLabel(group, localize: localize, moduleTitle: moduleTitle),
      );
      claimed.addAll(group.objClasses);
    }

    for (final oc in present) {
      if (excludeObjClasses.contains(oc)) continue;
      if (claimed.contains(oc)) continue;
      if (moduleTitle != null) {
        final titled = moduleTitle(oc);
        labels.add(titled.isNotEmpty ? titled : _fallbackLabel(oc));
      } else {
        labels.add(_fallbackLabel(oc));
      }
    }
    return labels;
  }

  /// First feature from [orderedObjClasses] (level definition order).
  String? firstFeatureLabel(
    Iterable<String> orderedObjClasses, {
    PreviewLabelLookup? localize,
    PreviewModuleTitleLookup? moduleTitle,
  }) {
    final claimed = <String>{};
    for (final oc in orderedObjClasses) {
      if (excludeObjClasses.contains(oc)) continue;
      if (claimed.contains(oc)) continue;
      for (final group in groups) {
        if (group.objClasses.contains(oc)) {
          claimed.addAll(group.objClasses);
          return _groupLabel(
            group,
            localize: localize,
            moduleTitle: moduleTitle,
          );
        }
      }
      claimed.add(oc);
      if (moduleTitle != null) {
        final titled = moduleTitle(oc);
        return titled.isNotEmpty ? titled : _fallbackLabel(oc);
      }
      return _fallbackLabel(oc);
    }
    return null;
  }

  String _fallbackLabel(String objClass) {
    var s = objClass;
    for (final suffix in const [
      'Properties',
      'ModuleProperties',
      'MinigameProperties',
      'ChallengeProperties',
      'Module',
    ]) {
      if (s.endsWith(suffix)) {
        s = s.substring(0, s.length - suffix.length);
        break;
      }
    }
    return s;
  }
}
