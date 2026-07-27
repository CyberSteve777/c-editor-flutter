import 'dart:convert';

import 'package:intl/intl.dart';
import 'package:intl/message_format.dart';

/// Placeholder metadata from an ARB `@messageKey.placeholders` entry.
class PluginArbPlaceholder {
  const PluginArbPlaceholder({
    this.type,
    this.format,
    this.optionalParameters = const {},
    this.isCustomDateFormat = false,
  });

  final String? type;
  final String? format;
  final Map<String, Object?> optionalParameters;
  final bool isCustomDateFormat;
}

/// One ARB message: ICU pattern plus optional `@key` placeholder metadata.
class PluginArbEntry {
  const PluginArbEntry(this.pattern, {this.placeholders = const {}});

  final String pattern;
  final Map<String, PluginArbPlaceholder> placeholders;
}

/// NumberFormat factory names supported by Flutter gen-l10n.
const _numberFormatsWithNamedParameters = {
  'compact',
  'compactCurrency',
  'compactSimpleCurrency',
  'compactLong',
  'currency',
  'decimalPatternDigits',
  'decimalPercentPattern',
  'simpleCurrency',
};

const _numberFormatsPositional = {
  'decimalPattern',
  'percentPattern',
  'scientificPattern',
};

/// Parses a Flutter-style `.arb` document into message key → [PluginArbEntry].
///
/// Reads `@key` metadata for `placeholders` (type / format /
/// optionalParameters / isCustomDateFormat). Skips `@@…` file-level keys.
/// Invalid JSON returns an empty map.
Map<String, PluginArbEntry> parsePluginArbBundle(String source) {
  Object? decoded;
  try {
    decoded = jsonDecode(source);
  } catch (_) {
    return const {};
  }
  if (decoded is! Map) return const {};

  final messages = <String, String>{};
  final meta = <String, Map>{};

  for (final entry in decoded.entries) {
    final key = entry.key;
    if (key is! String || key.isEmpty) continue;
    if (key.startsWith('@@')) continue;
    if (key.startsWith('@')) {
      final messageKey = key.substring(1);
      if (messageKey.isEmpty) continue;
      final value = entry.value;
      if (value is Map) meta[messageKey] = value;
      continue;
    }
    final value = entry.value;
    if (value is String) {
      messages[key] = value;
    }
  }

  return {
    for (final entry in messages.entries)
      entry.key: PluginArbEntry(
        entry.value,
        placeholders: _parsePlaceholders(meta[entry.key]),
      ),
  };
}

/// Parses a Flutter-style `.arb` document into message key → string value.
///
/// Skips metadata keys (`@@locale`, `@someKey`, …). Prefer
/// [parsePluginArbBundle] when placeholder metadata is needed.
Map<String, String> parsePluginArb(String source) {
  return {
    for (final entry in parsePluginArbBundle(source).entries)
      entry.key: entry.value.pattern,
  };
}

Map<String, PluginArbPlaceholder> _parsePlaceholders(Map? attributes) {
  if (attributes == null) return const {};
  final raw = attributes['placeholders'];
  if (raw is! Map) return const {};

  final out = <String, PluginArbPlaceholder>{};
  for (final entry in raw.entries) {
    final name = entry.key;
    if (name is! String || name.isEmpty) continue;
    final attrs = entry.value;
    if (attrs is! Map) {
      out[name] = const PluginArbPlaceholder();
      continue;
    }
    final optional = attrs['optionalParameters'];
    out[name] = PluginArbPlaceholder(
      type: attrs['type'] is String ? attrs['type'] as String : null,
      format: attrs['format'] is String ? attrs['format'] as String : null,
      optionalParameters: optional is Map
          ? {
              for (final e in optional.entries)
                if (e.key != null) e.key.toString(): e.value,
            }
          : const {},
      isCustomDateFormat: attrs['isCustomDateFormat'] == true,
    );
  }
  return out;
}

/// Candidate asset paths for plugin locale messages (ARB only).
///
/// Preferred layout: `assets/l10n/{locale}.arb`.
/// Also accepts Flutter-style `*_{locale}.arb` names.
List<String> pluginArbAssetCandidates(String languageCode) {
  final code = languageCode.trim().toLowerCase();
  if (code.isEmpty) return const [];
  return [
    'l10n/$code.arb',
    'l10n/app_$code.arb',
    'l10n/messages_$code.arb',
    'l10n/plugin_$code.arb',
  ];
}

/// Looks up [key] in plugin ARB assets for [languageCode], then `en`.
PluginArbEntry? lookupPluginArbEntry(
  String? Function(String relativePath) readString,
  String languageCode,
  String key,
) {
  for (final code in [languageCode, 'en']) {
    if (code.isEmpty) continue;
    for (final path in pluginArbAssetCandidates(code)) {
      final raw = readString(path);
      if (raw == null) continue;
      final entry = parsePluginArbBundle(raw)[key];
      if (entry != null) return entry;
    }
  }
  return null;
}

/// Looks up [key] and returns only the message pattern (no metadata).
String? lookupPluginArbMessage(
  String? Function(String relativePath) readString,
  String languageCode,
  String key,
) {
  return lookupPluginArbEntry(readString, languageCode, key)?.pattern;
}

/// Formats an ARB / ICU message pattern the same way Flutter gen-l10n expects
/// at runtime (simple `{name}`, `plural`, `select`, `selectordinal`).
///
/// When [placeholders] metadata is provided (from `@key`), args are coerced
/// to the declared type and numbers/dates are formatted with `intl`
/// [NumberFormat] / [DateFormat] before MessageFormat runs — matching
/// Flutter's ARB `type` / `format` / `optionalParameters` rules.
///
/// Uses [MessageFormat] from `package:intl`. On failure, falls back to plain
/// `{key}` string substitution.
String formatPluginArbMessage(
  String pattern, {
  Map<String, Object?> args = const {},
  String locale = 'en',
  Map<String, PluginArbPlaceholder> placeholders = const {},
}) {
  final named = <String, Object>{};
  for (final entry in args.entries) {
    final value = entry.value;
    if (value == null) continue;
    final meta = placeholders[entry.key];
    named[entry.key] = _prepareArg(
      pattern: pattern,
      name: entry.key,
      value: value,
      meta: meta,
      locale: locale,
    );
  }

  try {
    final formatter = MessageFormat(pattern, locale: locale);
    return formatter.format(named.isEmpty ? null : named);
  } catch (_) {
    if (named.isEmpty) return pattern;
    var out = pattern;
    for (final entry in named.entries) {
      out = out.replaceAll('{${entry.key}}', '${entry.value}');
    }
    return out;
  }
}

Object _prepareArg({
  required String pattern,
  required String name,
  required Object value,
  required PluginArbPlaceholder? meta,
  required String locale,
}) {
  final type = meta?.type;
  final coerced = _coerceType(value, type);

  final format = meta?.format;
  if (format == null || format.isEmpty) {
    return coerced;
  }

  // Plural / selectordinal selectors need a numeric value; do not stringify.
  if (_isPluralOrOrdinalSelector(pattern, name)) {
    return coerced;
  }

  final formatted = _tryFormatValue(
    coerced,
    type: type,
    format: format,
    optionalParameters: meta?.optionalParameters ?? const {},
    isCustomDateFormat: meta?.isCustomDateFormat ?? false,
    locale: locale,
  );
  return formatted ?? coerced;
}

bool _isPluralOrOrdinalSelector(String pattern, String name) {
  return RegExp(
    '\\{${RegExp.escape(name)}\\s*,\\s*(plural|selectordinal)\\b',
  ).hasMatch(pattern);
}

Object _coerceType(Object value, String? type) {
  switch (type) {
    case 'int':
      if (value is int) return value;
      if (value is num) return value.toInt();
      return int.tryParse('$value') ?? value;
    case 'double':
      if (value is double) return value;
      if (value is num) return value.toDouble();
      return double.tryParse('$value') ?? value;
    case 'num':
      if (value is num) return value;
      return num.tryParse('$value') ?? value;
    case 'String':
      return '$value';
    case 'DateTime':
      if (value is DateTime) return value;
      return DateTime.tryParse('$value') ?? value;
    default:
      return value;
  }
}

String? _tryFormatValue(
  Object value, {
  required String? type,
  required String format,
  required Map<String, Object?> optionalParameters,
  required bool isCustomDateFormat,
  required String locale,
}) {
  final isDate =
      type == 'DateTime' || value is DateTime || isCustomDateFormat;
  if (isDate) {
    final date = value is DateTime
        ? value
        : DateTime.tryParse('$value');
    if (date == null) return null;
    try {
      if (isCustomDateFormat) {
        return DateFormat(format, locale).format(date);
      }
      // Named DateFormat constructors (yMd, yMMMMd, …) or pattern string.
      return DateFormat(format, locale).format(date);
    } catch (_) {
      return null;
    }
  }

  final number = value is num ? value : num.tryParse('$value');
  if (number == null) return null;

  try {
    final formatter = _numberFormat(format, locale, optionalParameters);
    if (formatter == null) return null;
    return formatter.format(number);
  } catch (_) {
    return null;
  }
}

NumberFormat? _numberFormat(
  String format,
  String locale,
  Map<String, Object?> opts,
) {
  int? asInt(Object? v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v);
    return null;
  }

  String? asString(Object? v) => v?.toString();

  if (_numberFormatsWithNamedParameters.contains(format)) {
    switch (format) {
      case 'compact':
        return NumberFormat.compact(locale: locale);
      case 'compactLong':
        return NumberFormat.compactLong(locale: locale);
      case 'compactCurrency':
        return NumberFormat.compactCurrency(
          locale: locale,
          name: asString(opts['name']),
          decimalDigits: asInt(opts['decimalDigits']),
          symbol: asString(opts['symbol']),
        );
      case 'compactSimpleCurrency':
        return NumberFormat.compactSimpleCurrency(
          locale: locale,
          name: asString(opts['name']),
          decimalDigits: asInt(opts['decimalDigits']),
        );
      case 'currency':
        return NumberFormat.currency(
          locale: locale,
          name: asString(opts['name']),
          decimalDigits: asInt(opts['decimalDigits']),
          symbol: asString(opts['symbol']),
          customPattern: asString(opts['customPattern']),
        );
      case 'decimalPatternDigits':
        return NumberFormat.decimalPatternDigits(
          locale: locale,
          decimalDigits: asInt(opts['decimalDigits']),
        );
      case 'decimalPercentPattern':
        return NumberFormat.decimalPercentPattern(
          locale: locale,
          decimalDigits: asInt(opts['decimalDigits']),
        );
      case 'simpleCurrency':
        return NumberFormat.simpleCurrency(
          locale: locale,
          name: asString(opts['name']),
          decimalDigits: asInt(opts['decimalDigits']),
        );
    }
  }

  if (_numberFormatsPositional.contains(format)) {
    switch (format) {
      case 'decimalPattern':
        return NumberFormat.decimalPattern(locale);
      case 'percentPattern':
        return NumberFormat.percentPattern(locale);
      case 'scientificPattern':
        return NumberFormat.scientificPattern(locale);
    }
  }

  return null;
}

/// Converts a loosely-typed map (e.g. from dart_eval) into localize args.
Map<String, Object?>? coerceLocalizeArgs(Object? raw) {
  if (raw == null) return null;
  if (raw is Map<String, Object?>) return raw;
  if (raw is Map) {
    return {
      for (final entry in raw.entries)
        if (entry.key != null) entry.key.toString(): entry.value,
    };
  }
  return null;
}
