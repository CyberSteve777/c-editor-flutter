import 'package:flutter/material.dart';

/// Resolves a Material Icons code point to a tree-shaken-safe [IconData].
///
/// Plugins pass `Icons.foo.codePoint` as an `int` (required for EVC). Building
/// `IconData(codePoint, fontFamily: 'MaterialIcons')` alone does **not** keep
/// the glyph in Flutter's icon tree-shaker, so a wrong icon (often a check)
/// can appear. Mapping back to const [Icons] references fixes that.
IconData pluginMaterialIcon(int? codePoint, {IconData fallback = Icons.extension}) {
  if (codePoint == null) return fallback;
  for (final icon in _pluginMaterialIcons) {
    if (icon.codePoint == codePoint) return icon;
  }
  // Fallback for uncommon icons; may still be tree-shaken away in release.
  // ignore: non_const_argument_for_const_parameter
  return IconData(codePoint, fontFamily: 'MaterialIcons');
}

/// Const Material icons that plugins are allowed / expected to use.
/// Keep this list referenced so glyphs ship in release builds.
const List<IconData> _pluginMaterialIcons = <IconData>[
  Icons.extension,
  Icons.settings,
  Icons.remove_red_eye,
  Icons.visibility,
  Icons.visibility_outlined,
  Icons.build,
  Icons.waves,
  Icons.preview,
  Icons.play_arrow,
  Icons.info_outline,
  Icons.star,
  Icons.star_outline,
  Icons.download,
  Icons.cloud_download,
  Icons.folder_open,
  Icons.code,
  Icons.bug_report_outlined,
];
