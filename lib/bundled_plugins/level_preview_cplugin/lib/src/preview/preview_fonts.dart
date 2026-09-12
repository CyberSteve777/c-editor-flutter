import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'dart:math' as math;

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
    bool syntheticBold = false,
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
      // Single-cut TTF — FontWeight cannot select another face. Optional
      // faux-bold via horizontal same-color shadows.
      final face = build(familyPvZ).copyWith(fontWeight: FontWeight.w400);
      if (!syntheticBold || color == null || foreground != null) {
        return face;
      }
      return face.copyWith(
        letterSpacing: 0.35,
        shadows: [
          ...?shadows,
          Shadow(offset: const Offset(1.15, 0), color: color, blurRadius: 0),
          Shadow(offset: const Offset(0.55, 0), color: color, blurRadius: 0),
        ],
      );
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

  /// True when [style] requests bold and the family has no real bold cut.
  static bool needsSyntheticBold(PreviewTextStyleData style) {
    if (style.fontFamily != familyPvZ) return false;
    return style.fontWeight.value >= FontWeight.w600.value;
  }

  static TextStyle resolve(PreviewTextStyleData style, {required bool fill}) {
    // Always set an explicit decoration so parent TextField styles cannot
    // leak underline onto every run.
    final decoration =
        style.underline ? TextDecoration.underline : TextDecoration.none;
    final thickness =
        style.underline ? math.max(2.5, style.fontSize * 0.09) : null;
    final fontStyle = style.italic ? FontStyle.italic : FontStyle.normal;
    final fauxBold = needsSyntheticBold(style);
    final outlineWidth =
        style.outlineWidth + (fauxBold && style.outline ? 1.25 : 0);
    if (fill || !style.outline) {
      return textStyle(
        fontFamily: style.fontFamily,
        fontSize: style.fontSize,
        color: style.color,
        fontWeight: style.fontFamily == familyPvZ
            ? FontWeight.w400
            : style.fontWeight,
        syntheticBold: fauxBold && !style.outline,
        shadows: style.outline
            ? null
            : const [
                Shadow(
                  blurRadius: 6,
                  color: Colors.black87,
                  offset: Offset(1, 1),
                ),
              ],
      ).copyWith(
        fontStyle: fontStyle,
        decoration: decoration,
        decorationColor: style.color,
        decorationThickness: thickness,
      );
    }
    return textStyle(
      fontFamily: style.fontFamily,
      fontSize: style.fontSize,
      fontWeight: style.fontFamily == familyPvZ
          ? FontWeight.w400
          : style.fontWeight,
      foreground: Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = outlineWidth
        ..color = style.outlineColor,
    ).copyWith(
      fontStyle: fontStyle,
      decoration: decoration,
      decorationColor: style.outlineColor,
      decorationThickness: thickness,
    );
  }

  /// Fill style safe for [TextField] / [EditableText] (no [Paint.foreground]).
  /// Outline is approximated with hard shadows so edit and display stay close.
  static TextStyle resolveForEditable(PreviewTextStyleData style) {
    final fill = resolve(
      PreviewTextStyleData(
        fontFamily: style.fontFamily,
        fontSize: style.fontSize,
        color: style.color,
        fontWeight: style.fontWeight,
        italic: style.italic,
        underline: style.underline,
        outline: false,
        outlineColor: style.outlineColor,
        outlineWidth: style.outlineWidth,
      ),
      fill: true,
    );
    if (!style.outline) return fill;
    final o = style.outlineColor;
    final w = (style.outlineWidth / 2).clamp(1.0, 4.0);
    return fill.copyWith(
      shadows: [
        for (final dx in <double>[-w, 0, w])
          for (final dy in <double>[-w, 0, w])
            if (dx != 0 || dy != 0) Shadow(offset: Offset(dx, dy), color: o),
      ],
    );
  }

  /// Metrics-only base style for [TextField.style] — never carries underline /
  /// italic so those cannot inherit onto every character via the parent span.
  static TextStyle resolveFieldBase(PreviewTextStyleData style) {
    return resolveForEditable(
      PreviewTextStyleData(
        fontFamily: style.fontFamily,
        fontSize: style.fontSize,
        color: style.color,
        fontWeight: style.fontWeight,
        italic: false,
        underline: false,
        outline: style.outline,
        outlineColor: style.outlineColor,
        outlineWidth: style.outlineWidth,
      ),
    );
  }
}
