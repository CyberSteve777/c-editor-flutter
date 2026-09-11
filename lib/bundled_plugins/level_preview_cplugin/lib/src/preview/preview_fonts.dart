import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';

/// Custom fonts shipped with the Level Overview plugin + popular Google Fonts.
class PreviewFonts {
  static const familyPvZ = kPreviewCustomFontFamily;

  /// Families available in the manual text style picker (PvZ font first).
  static const List<({String? family, String label})> choices = [
    (family: familyPvZ, label: 'PvZ Preview'),
    (family: 'Roboto', label: 'Roboto'),
    (family: 'Open Sans', label: 'Open Sans'),
    (family: 'Lato', label: 'Lato'),
    (family: 'Montserrat', label: 'Montserrat'),
    (family: 'Oswald', label: 'Oswald'),
    (family: 'Nunito', label: 'Nunito'),
    (family: 'Rubik', label: 'Rubik'),
    (family: 'Bebas Neue', label: 'Bebas Neue'),
    (family: 'Poppins', label: 'Poppins'),
    (family: 'Raleway', label: 'Raleway'),
    (family: null, label: 'System default'),
  ];

  static TextStyle textStyle({
    String? fontFamily,
    double fontSize = 32,
    Color? color,
    FontWeight? fontWeight,
    double height = 1.1,
    Paint? foreground,
    List<Shadow>? shadows,
  }) {
    TextStyle build(String? family) => TextStyle(
      fontFamily: family,
      fontSize: fontSize,
      color: foreground == null ? color : null,
      fontWeight: fontWeight,
      height: height,
      foreground: foreground,
      shadows: shadows,
    );

    if (fontFamily == null) {
      return build(null);
    }
    if (fontFamily == familyPvZ) {
      return build(familyPvZ);
    }
    try {
      return GoogleFonts.getFont(
        fontFamily,
        fontSize: fontSize,
        color: foreground == null ? color : null,
        fontWeight: fontWeight,
        height: height,
        foreground: foreground,
        shadows: shadows,
      );
    } catch (_) {
      return build(fontFamily);
    }
  }

  static TextStyle resolve(PreviewTextStyleData style, {required bool fill}) {
    final decoration = style.underline ? TextDecoration.underline : null;
    final fontStyle = style.italic ? FontStyle.italic : FontStyle.normal;
    if (fill || !style.outline) {
      return textStyle(
        fontFamily: style.fontFamily,
        fontSize: style.fontSize,
        color: style.color,
        fontWeight: style.fontWeight,
        shadows: style.outline
            ? null
            : const [
                Shadow(
                  blurRadius: 6,
                  color: Colors.black87,
                  offset: Offset(1, 1),
                ),
              ],
      ).copyWith(fontStyle: fontStyle, decoration: decoration, decorationColor: style.color);
    }
    return textStyle(
      fontFamily: style.fontFamily,
      fontSize: style.fontSize,
      fontWeight: style.fontWeight,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = style.outlineWidth
        ..color = style.outlineColor,
    ).copyWith(fontStyle: fontStyle, decoration: decoration, decorationColor: style.outlineColor);
  }
}
