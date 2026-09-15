abstract final class LevelTemplateUtils {
  static final RegExp _templateIdPattern = RegExp(r'^(\d+)(?:_|\.|$)');
  static final RegExp _jsonExtensionPattern = RegExp(
    r'\.json$',
    caseSensitive: false,
  );
  static const templateAssetDirectory = 'assets/reference/template/';

  /// Returns the numeric identity at the start of a template asset name.
  ///
  /// Everything after the number is descriptive and may be renamed without
  /// changing which template it is.
  static int? idOf(String assetName) {
    final name = _baseName(assetName.trim());
    final match = _templateIdPattern.firstMatch(name);
    return match == null ? null : int.tryParse(match.group(1)!);
  }

  /// Uses the complete template filename as the suggested level name.
  ///
  /// Only the `.json` extension is removed. For example,
  /// `12_custom_lawn_example.json` becomes `12_custom_lawn_example`.
  static String defaultLevelName(String assetName) {
    final name = _baseName(
      assetName.trim(),
    ).replaceFirst(_jsonExtensionPattern, '');
    return name;
  }

  /// Discovers templates directly from Flutter's bundled asset paths.
  ///
  /// This makes the asset filename the single source of truth: renaming a
  /// numbered template automatically changes the filename shown by the app.
  static List<String> fromBundledAssetPaths(Iterable<String> assetPaths) {
    final names = <String>[];
    for (final path in assetPaths) {
      if (!path.startsWith(templateAssetDirectory)) continue;
      final name = path.substring(templateAssetDirectory.length);
      if (name.contains('/') || name.contains(r'\')) continue;
      if (!_jsonExtensionPattern.hasMatch(name) || idOf(name) == null) continue;
      names.add(name);
    }
    names.sort(_compareByIdThenName);
    return normalizeById(names);
  }

  /// Keeps one entry per numeric template identity while preserving order.
  static List<String> normalizeById(Iterable<String> assetNames) {
    final seenIds = <int>{};
    final seenUnnumberedNames = <String>{};
    final normalized = <String>[];

    for (final rawName in assetNames) {
      final name = rawName.trim();
      if (name.isEmpty) continue;
      final id = idOf(name);
      final isNew = id == null
          ? seenUnnumberedNames.add(name.toLowerCase())
          : seenIds.add(id);
      if (isNew) normalized.add(name);
    }
    return normalized;
  }

  static int _compareByIdThenName(String a, String b) {
    final idComparison = idOf(a)!.compareTo(idOf(b)!);
    return idComparison != 0 ? idComparison : a.compareTo(b);
  }

  static String _baseName(String path) => path.split(RegExp(r'[/\\]')).last;
}
