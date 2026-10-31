import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:c_editor/data/asset_loader.dart';

/// The four concrete narrative categories shown by the picker. [all] is a
/// virtual aggregate and is never written to the generated catalogue.
enum NarrativeCategory {
  all,
  mainWorlds,
  memoryLane,
  otherModes,
  systemTutorials;

  static NarrativeCategory fromJson(Object? value) {
    return NarrativeCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => NarrativeCategory.systemTutorials,
    );
  }
}

enum NarrativeLineKind {
  speech,
  stage,
  system;

  static NarrativeLineKind fromJson(Object? value) {
    return NarrativeLineKind.values.firstWhere(
      (kind) => kind.name == value,
      orElse: () => NarrativeLineKind.system,
    );
  }
}

class NarrativeLine {
  const NarrativeLine({
    required this.key,
    required this.kind,
    required this.text,
    this.speaker,
    this.emotion,
    this.npc,
  });

  factory NarrativeLine.fromJson(Map<String, dynamic> json) {
    return NarrativeLine(
      key: json['key']?.toString() ?? '',
      kind: NarrativeLineKind.fromJson(json['kind']),
      text: json['text']?.toString() ?? '',
      speaker: _nonEmptyString(json['speaker']),
      emotion: _nonEmptyString(json['emotion']),
      npc: _nonEmptyString(json['npc']),
    );
  }

  final String key;
  final NarrativeLineKind kind;
  final String text;
  final String? speaker;
  final String? emotion;
  final String? npc;

  String get speakerWithEmotion {
    final name = speaker ?? '';
    final mood = emotion;
    return mood == null || mood.isEmpty ? name : '$name（$mood）';
  }
}

class NarrativeEntry {
  const NarrativeEntry({
    required this.value,
    required this.id,
    required this.groupId,
    required this.number,
    required this.category,
    required this.iconAsset,
    required this.title,
    required this.characters,
    required this.lines,
    required this.selectable,
  });

  factory NarrativeEntry.fromJson(Map<String, dynamic> json) {
    final rawValue = json['value'];
    if (rawValue is! String && rawValue is! int) {
      throw const FormatException(
        'Narrative invocation values must be strings or integers.',
      );
    }
    return NarrativeEntry(
      value: rawValue,
      id: json['id']?.toString() ?? rawValue.toString(),
      groupId: json['groupId']?.toString() ?? '',
      number: json['number']?.toString() ?? '',
      category: NarrativeCategory.fromJson(json['tag']),
      iconAsset: json['icon']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      characters: (json['characters'] as List<dynamic>? ?? const [])
          .map((value) => value.toString())
          .where((value) => value.isNotEmpty)
          .toList(growable: false),
      lines: (json['lines'] as List<dynamic>? ?? const [])
          .whereType<Map>()
          .map(
            (value) => NarrativeLine.fromJson(Map<String, dynamic>.from(value)),
          )
          .toList(growable: false),
      selectable: json['selectable'] as bool? ?? true,
    );
  }

  /// The value written verbatim to FirstIntroNarrative/FirstOutroNarrative.
  /// Its String/int type is intentionally preserved.
  final Object value;
  final String id;
  final String groupId;
  final String number;
  final NarrativeCategory category;
  final String iconAsset;
  final String title;
  final List<String> characters;
  final List<NarrativeLine> lines;
  final bool selectable;

  String get valueKey => value.toString();

  Iterable<String> get dialogueText => lines.map((line) => line.text);

  Iterable<String> get speakerNames => lines
      .map((line) => line.speaker)
      .whereType<String>()
      .where((name) => name.isNotEmpty);
}

class NarrativeStrings {
  NarrativeStrings(Map<String, dynamic> values)
    : _values = Map.unmodifiable(
        values.map((key, value) => MapEntry(key, value.toString())),
      );

  final Map<String, String> _values;

  Set<String> get keys => Set.unmodifiable(_values.keys);

  String get sectionTitle => this['sectionTitle'];
  String get helpBody => this['helpBody'];
  String get firstIntro => this['firstIntro'];
  String get firstOutro => this['firstOutro'];
  String get noDialogue => this['noDialogue'];
  String get selectTitle => this['selectTitle'];
  String get searchHint => this['searchHint'];
  String get noResults => this['noResults'];
  String get detailsTitle => this['detailsTitle'];
  String get rawId => this['rawId'];
  String get selectDialogue => this['selectDialogue'];
  String get clearDialogue => this['clearDialogue'];
  String get unavailableDialogue => this['unavailableDialogue'];
  String get loadError => this['loadError'];

  String operator [](String key) => _values[key] ?? key;

  String categoryLabel(NarrativeCategory category) => switch (category) {
    NarrativeCategory.all => this['tagAll'],
    NarrativeCategory.mainWorlds => this['tagMainWorlds'],
    NarrativeCategory.memoryLane => this['tagMemoryLane'],
    NarrativeCategory.otherModes => this['tagOtherModes'],
    NarrativeCategory.systemTutorials => this['tagSystemTutorials'],
  };

  String searchGroupLabel(String key, int count) {
    return this[key].replaceAll('{count}', '$count');
  }
}

class NarrativeCatalog {
  NarrativeCatalog._({
    required this.localeCode,
    required this.strings,
    required this.dialogues,
  }) : _byValue = {
         for (final dialogue in dialogues) dialogue.valueKey: dialogue,
       };

  factory NarrativeCatalog.fromJson(Map<String, dynamic> json) {
    final dialogues = (json['dialogues'] as List<dynamic>? ?? const [])
        .whereType<Map>()
        .map(
          (value) => NarrativeEntry.fromJson(Map<String, dynamic>.from(value)),
        )
        .toList(growable: false);
    return NarrativeCatalog._(
      localeCode: json['locale']?.toString() ?? 'en',
      strings: NarrativeStrings(
        Map<String, dynamic>.from(json['strings'] as Map? ?? const {}),
      ),
      dialogues: List.unmodifiable(dialogues),
    );
  }

  static const String assetDirectory = 'assets/l10n';
  static final Map<String, NarrativeCatalog> _cache = {};
  static final Map<String, Future<NarrativeCatalog>> _pendingLoads = {};

  final String localeCode;
  final NarrativeStrings strings;
  final List<NarrativeEntry> dialogues;
  final Map<String, NarrativeEntry> _byValue;

  static String localeCodeFor(Locale locale) => switch (locale.languageCode) {
    'zh' => 'zh',
    'ru' => 'ru',
    _ => 'en',
  };

  static Future<NarrativeCatalog> load(Locale locale) {
    final code = localeCodeFor(locale);
    final cached = _cache[code];
    if (cached != null) return Future.value(cached);
    return _pendingLoads.putIfAbsent(code, () => _load(code));
  }

  static Future<NarrativeCatalog> _load(String code) async {
    try {
      final source = await loadJsonString(
        '$assetDirectory/narrative_$code.json',
      );
      final catalog = NarrativeCatalog.fromJson(
        Map<String, dynamic>.from(jsonDecode(source) as Map),
      );
      _cache[code] = catalog;
      return catalog;
    } finally {
      _pendingLoads.remove(code);
    }
  }

  static void clearCacheForTesting() {
    _cache.clear();
    _pendingLoads.clear();
  }

  NarrativeEntry? findByValue(Object? value) {
    if (value == null) return null;
    return _byValue[value.toString()];
  }

  List<NarrativeEntry> forCategory(NarrativeCategory category) {
    if (category == NarrativeCategory.all) return dialogues;
    return dialogues
        .where((dialogue) => dialogue.category == category)
        .toList(growable: false);
  }
}

String? _nonEmptyString(Object? value) {
  final text = value?.toString();
  return text == null || text.isEmpty ? null : text;
}
