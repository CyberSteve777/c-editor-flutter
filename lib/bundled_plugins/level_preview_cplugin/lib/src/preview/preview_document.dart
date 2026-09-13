import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/data/repository/tool_repository.dart';

/// Design size of pre-made stage banners.
const Size kPreviewCanvasSize = Size(1144, 439);

/// Icon path for seed-bank / conveyor entries (plants, tools, plant food…).
String previewPlantLikeAssetPath(String id) {
  final plant = PlantRepository().getPlantInfoById(id);
  if (plant?.iconAssetPath != null) return plant!.iconAssetPath!;

  if (id == 'plantfood' || id == 'tool_plantfood') {
    return 'assets/images/others/plantfood.png';
  }
  if (id == 'sun' || id == 'sun_large') {
    return 'assets/images/others/sun_large.webp';
  }

  ToolCardInfo? tool = ToolRepository.get(id);
  if (tool == null && !id.startsWith('tool_')) {
    tool = ToolRepository.get('tool_$id');
  }
  final icon = tool?.icon;
  if (icon != null && icon.isNotEmpty) {
    if (icon.startsWith('assets/')) return icon;
    return 'assets/images/tools/$icon';
  }

  return 'assets/images/others/unknown.webp';
}

/// Family registered from plugin `assets/fonts/`.
const kPreviewCustomFontFamily = 'PvZPreview';

enum PreviewBannerSourceKind { stageMapped, assetStem, userFile }

enum PreviewAutoStyle { normal, simple }

enum PreviewLayerKind { text, iconGrid, image, shape, stroke }

enum PreviewIconGridKind { plants, zombies, gridItems, custom }

enum PreviewShapeKind { rect, oval, line, star }

enum PreviewEditTool { select, pen, eraser, figures }

enum PreviewBossKind { zombot, zomboss }

enum PreviewTextPartKind { gridTitle, sourceLabel, sectionTitle, contained }

@immutable
class PreviewTextPartSelection {
  const PreviewTextPartSelection({
    required this.layerId,
    required this.kind,
    this.sectionIndex,
    this.containedTextId,
  });

  final String layerId;
  final PreviewTextPartKind kind;
  final int? sectionIndex;
  final String? containedTextId;

  @override
  bool operator ==(Object other) =>
      other is PreviewTextPartSelection &&
      other.layerId == layerId &&
      other.kind == kind &&
      other.sectionIndex == sectionIndex &&
      other.containedTextId == containedTextId;

  @override
  int get hashCode => Object.hash(layerId, kind, sectionIndex, containedTextId);
}

/// One titled block inside an icon-grid layer (boss, spawned, waves, …).
class PreviewIconSection {
  PreviewIconSection({this.title, List<PreviewItem>? items, this.iconSize = 36})
    : items = items ?? <PreviewItem>[];

  String? title;
  List<PreviewItem> items;
  double iconSize;

  PreviewIconSection copy() => PreviewIconSection(
    title: title,
    items: items.map((e) => e.copy()).toList(),
    iconSize: iconSize,
  );
}

/// Intrinsic pixel size for an icon-grid layer at [maxWidth].
Size previewIconGridIntrinsicSize({
  required double maxWidth,
  required List<PreviewIconSection> sections,
  bool showChrome = true,
  String? gridTitle,
  String? sourceLabel,
  int? lawnRows,
  int? lawnCols,
}) {
  const pad = 8.0;
  const sectionGap = 8.0;
  const iconSpacing = 4.0;
  final innerMax = showChrome
      ? (maxWidth - pad * 2).clamp(8.0, maxWidth)
      : maxWidth.clamp(8.0, double.infinity);

  var contentW = 0.0;
  var contentH = 0.0;

  if (showChrome) {
    // Match TextStyle metrics used in preview_canvas chrome (~1.25 line height).
    if (gridTitle != null && gridTitle.isNotEmpty) contentH += 24;
    if (sourceLabel != null && sourceLabel.isNotEmpty) {
      final lines = sourceLabel.split('\n').where((l) => l.trim().isNotEmpty);
      contentH += lines.length.clamp(1, 6) * 14.0;
    }
    if (contentH > 0) contentH += 4; // SizedBox after headers
  }

  final useLawn =
      lawnRows != null &&
      lawnCols != null &&
      lawnRows > 0 &&
      lawnCols > 0 &&
      sections.any((s) => s.items.any((i) => i.hasCell));

  if (useLawn) {
    final lawnH = innerMax / ((lawnCols / lawnRows) * 1.0);
    for (var i = 0; i < sections.length; i++) {
      final section = sections[i];
      if (section.items.isEmpty) continue;
      if (contentH > 0 && (i > 0 || showChrome)) contentH += sectionGap;
      if (section.title != null && section.title!.isNotEmpty) {
        final titleSize = section.iconSize >= 64 ? 15.0 : 13.0;
        contentH += titleSize * 1.25 * 2 + 4;
      }
      contentH += lawnH;
      contentW = math.max(contentW, innerMax);
    }
    final totalH = contentH + (showChrome ? pad * 2 : 0);
    return Size(maxWidth, totalH.clamp(24.0, 4096.0));
  }

  for (var i = 0; i < sections.length; i++) {
    final section = sections[i];
    if (section.items.isEmpty) continue;
    if (contentH > 0 && (i > 0 || showChrome)) contentH += sectionGap;
    if (section.title != null && section.title!.isNotEmpty) {
      // Title Text maxLines:2 + bottom padding 4.
      final titleSize = section.iconSize >= 64 ? 15.0 : 13.0;
      contentH += titleSize * 1.25 * 2 + 4;
    }
    final icon = section.iconSize;
    final n = section.items.length;
    final perRow = ((innerMax + iconSpacing) / (icon + iconSpacing))
        .floor()
        .clamp(1, 64);
    final rows = (n / perRow).ceil().clamp(1, 64);
    final cols = n < perRow ? n : perRow;
    final rowW = cols * icon + (cols - 1) * iconSpacing;
    if (rowW > contentW) contentW = rowW;
    contentH += rows * icon + (rows - 1) * iconSpacing;
  }

  if (contentW <= 0) contentW = 40;
  if (contentH <= 0) contentH = 40;
  // Slack for strut / rounding so ClipRect never eats the last row.
  contentH += 16;

  if (showChrome) {
    return Size(contentW + pad * 2, contentH + pad * 2);
  }
  return Size(contentW, contentH);
}

List<PreviewIconSection> previewEffectiveSections(PreviewLayer layer) {
  if (layer.sections.isNotEmpty) return layer.sections;
  if (layer.items.isEmpty) return const [];
  return [PreviewIconSection(items: layer.items)];
}

class PreviewBannerRef {
  PreviewBannerRef({
    required this.kind,
    this.stem,
    this.userFilePath,
    this.assetPath,
  });

  PreviewBannerSourceKind kind;
  String? stem;
  String? userFilePath;
  String? assetPath;

  PreviewBannerRef copy() => PreviewBannerRef(
    kind: kind,
    stem: stem,
    userFilePath: userFilePath,
    assetPath: assetPath,
  );
}

class PreviewItem {
  PreviewItem({
    required this.id,
    required this.assetPath,
    this.label,
    this.sourceLabel,
    this.gridX,
    this.gridY,
  });

  final String id;
  final String assetPath;
  final String? label;
  final String? sourceLabel;

  /// Lawn-cell column when this item is placed on a mini lawn grid.
  final int? gridX;

  /// Lawn-cell row when this item is placed on a mini lawn grid.
  final int? gridY;

  bool get hasCell => gridX != null && gridY != null;

  PreviewItem copy() => PreviewItem(
    id: id,
    assetPath: assetPath,
    label: label,
    sourceLabel: sourceLabel,
    gridX: gridX,
    gridY: gridY,
  );
}

class PreviewTextStyleData {
  PreviewTextStyleData({
    this.fontFamily = kPreviewCustomFontFamily,
    this.fontSize = 32,
    this.color = const Color(0xFFFFFFFF),
    this.fontWeight = FontWeight.bold,
    this.italic = false,
    this.underline = false,
    this.outline = true,
    this.outlineColor = const Color(0xFF000000),
    this.outlineWidth = 3,
  });

  /// Defaults to the plugin font (`FBUSV8C5EI.ttf` / [kPreviewCustomFontFamily]).
  String? fontFamily;
  double fontSize;
  Color color;
  FontWeight fontWeight;
  bool italic;
  bool underline;
  bool outline;
  Color outlineColor;
  double outlineWidth;

  PreviewTextStyleData copy() => PreviewTextStyleData(
    fontFamily: fontFamily,
    fontSize: fontSize,
    color: color,
    fontWeight: fontWeight,
    italic: italic,
    underline: underline,
    outline: outline,
    outlineColor: outlineColor,
    outlineWidth: outlineWidth,
  );
}

/// Editable text positioned inside an icon panel, rectangle, or oval.
class PreviewContainedText {
  PreviewContainedText({
    required this.id,
    required this.text,
    this.bounds = const Rect.fromLTWH(0.1, 0.25, 0.8, 0.5),
    PreviewTextStyleData? style,
    this.textAlign = TextAlign.center,
  }) : style = style ?? PreviewTextStyleData(fontSize: 24);

  final String id;
  String text;

  /// Bounds normalized to the containing layer.
  Rect bounds;
  PreviewTextStyleData style;
  TextAlign textAlign;

  PreviewContainedText copy() => PreviewContainedText(
    id: id,
    text: text,
    bounds: bounds,
    style: style.copy(),
    textAlign: textAlign,
  );
}

/// One contiguous styled run inside a text layer.
class PreviewTextRun {
  PreviewTextRun({required this.text, PreviewTextStyleData? style})
    : style = style ?? PreviewTextStyleData();

  String text;
  PreviewTextStyleData style;

  PreviewTextRun copy() => PreviewTextRun(text: text, style: style.copy());
}

/// Unified canvas object — titles, themes, icon grids, overlays, shapes, strokes.
///
/// [bounds] uses normalized coordinates (0–1) relative to [kPreviewCanvasSize].
class PreviewLayer {
  PreviewLayer({
    required this.id,
    required this.kind,
    required this.bounds,
    this.scale = 1.0,
    this.rotation = 0.0,
    this.opacity = 1.0,
    this.visible = true,
    this.zIndex = 0,
    this.text,
    this.textStyle,
    List<PreviewTextRun>? textRuns,
    this.textAlign = TextAlign.left,
    this.textBackgroundColor,
    this.iconAlign = TextAlign.left,
    this.gridKind,
    this.gridTitle,
    this.sourceLabel,
    this.showChrome = true,
    this.lawnRows,
    this.lawnCols,
    List<PreviewItem>? items,
    List<PreviewIconSection>? sections,
    this.imagePath,
    this.imageAsset,
    this.shapeKind,
    this.shapeFilled = false,
    this.fillColor,
    this.strokeColor = const Color(0xFFFFFFFF),
    this.strokeWidth = 3,
    this.cornerRadius = 0,
    List<PreviewContainedText>? containedTexts,
    List<Offset>? points,
  }) : items = items ?? <PreviewItem>[],
       sections = sections ?? <PreviewIconSection>[],
       containedTexts = containedTexts ?? <PreviewContainedText>[],
       points = points ?? <Offset>[],
       textRuns = textRuns ?? <PreviewTextRun>[];

  final String id;
  PreviewLayerKind kind;
  Rect bounds;
  double scale;

  /// Clockwise radians around the layer center.
  double rotation;
  /// 0–1; applied to the whole layer when painting.
  double opacity;
  bool visible;
  int zIndex;

  // text
  String? text;
  PreviewTextStyleData? textStyle;

  /// Styled runs; when empty, [text] + [textStyle] are used as a single run.
  List<PreviewTextRun> textRuns;
  TextAlign textAlign;
  /// Optional solid background behind text (independent of fill text color).
  Color? textBackgroundColor;
  /// Horizontal alignment for icon-grid content (icons / section titles).
  TextAlign iconAlign;

  // icon grid
  PreviewIconGridKind? gridKind;
  String? gridTitle;
  String? sourceLabel;
  bool showChrome;
  /// When set with [lawnCols], icon-grid content is painted as a mini lawn.
  int? lawnRows;
  int? lawnCols;
  List<PreviewItem> items;
  List<PreviewIconSection> sections;

  // image overlay
  String? imagePath;
  String? imageAsset;

  // shape
  PreviewShapeKind? shapeKind;
  bool shapeFilled;
  Color? fillColor;
  Color strokeColor;
  double strokeWidth;
  double cornerRadius;

  // text contained by icon panels and shapes
  List<PreviewContainedText> containedTexts;

  // freehand (normalized canvas coords)
  List<Offset> points;

  String get plainText {
    if (textRuns.isNotEmpty) {
      return textRuns.map((r) => r.text).join();
    }
    return text ?? '';
  }

  List<PreviewTextRun> effectiveTextRuns() {
    if (textRuns.isNotEmpty) return textRuns;
    final t = text ?? '';
    if (t.isEmpty) return const [];
    return [
      PreviewTextRun(
        text: t,
        style: (textStyle ?? PreviewTextStyleData()).copy(),
      ),
    ];
  }

  void ensureTextRuns() {
    if (textRuns.isNotEmpty) return;
    final t = text ?? '';
    textRuns = [
      PreviewTextRun(
        text: t,
        style: (textStyle ?? PreviewTextStyleData()).copy(),
      ),
    ];
  }

  void setPlainText(String value) {
    ensureTextRuns();
    if (textRuns.length == 1) {
      textRuns.first.text = value;
    } else {
      final style = textRuns.isNotEmpty
          ? textRuns.first.style.copy()
          : (textStyle ?? PreviewTextStyleData()).copy();
      textRuns = [PreviewTextRun(text: value, style: style)];
    }
    text = value;
    textStyle = textRuns.first.style.copy();
  }

  /// Updates plain text while preserving per-run styles around the edit.
  ///
  /// Inserted characters use [typingStyle] when provided; otherwise they inherit
  /// the style of the character before the caret (or the first character when
  /// inserting at the start).
  void updatePlainTextPreservingStyles(
    String newValue, {
    PreviewTextStyleData? typingStyle,
  }) {
    ensureTextRuns();
    final oldValue = plainText;
    if (newValue == oldValue) {
      text = newValue;
      return;
    }
    if (textRuns.length == 1 && typingStyle == null) {
      textRuns.first.text = newValue;
      text = newValue;
      textStyle = textRuns.first.style.copy();
      return;
    }

    var prefix = 0;
    final maxPrefix = math.min(oldValue.length, newValue.length);
    while (prefix < maxPrefix && oldValue[prefix] == newValue[prefix]) {
      prefix++;
    }
    var oldEnd = oldValue.length;
    var newEnd = newValue.length;
    while (oldEnd > prefix &&
        newEnd > prefix &&
        oldValue[oldEnd - 1] == newValue[newEnd - 1]) {
      oldEnd--;
      newEnd--;
    }

    final charStyles = <PreviewTextStyleData>[];
    for (final run in textRuns) {
      for (var i = 0; i < run.text.length; i++) {
        charStyles.add(run.style);
      }
    }

    final fallback =
        (textStyle ??
                (charStyles.isNotEmpty
                    ? charStyles.first
                    : PreviewTextStyleData()))
            .copy();
    // Inherit previous character; at the start, inherit the first character.
    final inherited = prefix > 0 && prefix <= charStyles.length
        ? charStyles[prefix - 1].copy()
        : (charStyles.isNotEmpty ? charStyles.first.copy() : fallback);
    final insertStyle = typingStyle?.copy() ?? inherited;

    final nextStyles = <PreviewTextStyleData>[];
    for (var i = 0; i < prefix; i++) {
      nextStyles.add(charStyles[i].copy());
    }
    for (var i = prefix; i < newEnd; i++) {
      nextStyles.add(insertStyle.copy());
    }
    for (var i = oldEnd; i < oldValue.length; i++) {
      nextStyles.add(charStyles[i].copy());
    }

    final next = <PreviewTextRun>[];
    for (var i = 0; i < newValue.length; i++) {
      final ch = newValue[i];
      final style = i < nextStyles.length ? nextStyles[i] : fallback;
      if (next.isNotEmpty && _sameTextStyle(next.last.style, style)) {
        next.last.text += ch;
      } else {
        next.add(PreviewTextRun(text: ch, style: style.copy()));
      }
    }
    textRuns = next.isEmpty
        ? [
            PreviewTextRun(text: '', style: fallback),
          ]
        : next;
    text = plainText;
    textStyle = textRuns.first.style.copy();
  }

  static bool _sameTextStyle(PreviewTextStyleData a, PreviewTextStyleData b) {
    return a.fontFamily == b.fontFamily &&
        a.fontSize == b.fontSize &&
        a.fontWeight == b.fontWeight &&
        a.italic == b.italic &&
        a.underline == b.underline &&
        a.outline == b.outline &&
        a.color == b.color;
  }

  /// Applies [mutate] to the style of characters in `[start, end)`.
  void applyStyleToRange(
    int start,
    int end,
    void Function(PreviewTextStyleData style) mutate,
  ) {
    ensureTextRuns();
    final plain = plainText;
    final s = start.clamp(0, plain.length);
    final e = end.clamp(0, plain.length);
    if (s >= e) {
      for (final run in textRuns) {
        mutate(run.style);
      }
      textStyle = textRuns.first.style.copy();
      return;
    }

    final next = <PreviewTextRun>[];
    var cursor = 0;
    for (final run in textRuns) {
      final runStart = cursor;
      final runEnd = cursor + run.text.length;
      cursor = runEnd;
      if (runEnd <= s || runStart >= e) {
        next.add(run.copy());
        continue;
      }
      final localStart = (s - runStart).clamp(0, run.text.length);
      final localEnd = (e - runStart).clamp(0, run.text.length);
      if (localStart > 0) {
        next.add(
          PreviewTextRun(
            text: run.text.substring(0, localStart),
            style: run.style.copy(),
          ),
        );
      }
      final mid = PreviewTextRun(
        text: run.text.substring(localStart, localEnd),
        style: run.style.copy(),
      );
      mutate(mid.style);
      if (mid.text.isNotEmpty) next.add(mid);
      if (localEnd < run.text.length) {
        next.add(
          PreviewTextRun(
            text: run.text.substring(localEnd),
            style: run.style.copy(),
          ),
        );
      }
    }
    textRuns = next.where((r) => r.text.isNotEmpty).toList();
    if (textRuns.isEmpty) {
      textRuns = [
        PreviewTextRun(
          text: '',
          style: (textStyle ?? PreviewTextStyleData()).copy(),
        ),
      ];
    }
    text = plainText;
    textStyle = textRuns.first.style.copy();
  }

  PreviewLayer copy() => PreviewLayer(
    id: id,
    kind: kind,
    bounds: bounds,
    scale: scale,
    rotation: rotation,
    opacity: opacity,
    visible: visible,
    zIndex: zIndex,
    text: text,
    textStyle: textStyle?.copy(),
    textRuns: textRuns.map((e) => e.copy()).toList(),
    textAlign: textAlign,
    textBackgroundColor: textBackgroundColor,
    iconAlign: iconAlign,
    gridKind: gridKind,
    gridTitle: gridTitle,
    sourceLabel: sourceLabel,
    showChrome: showChrome,
    lawnRows: lawnRows,
    lawnCols: lawnCols,
    items: items.map((e) => e.copy()).toList(),
    sections: sections.map((e) => e.copy()).toList(),
    imagePath: imagePath,
    imageAsset: imageAsset,
    shapeKind: shapeKind,
    shapeFilled: shapeFilled,
    fillColor: fillColor,
    strokeColor: strokeColor,
    strokeWidth: strokeWidth,
    cornerRadius: cornerRadius,
    containedTexts: containedTexts.map((e) => e.copy()).toList(),
    points: List<Offset>.from(points),
  );
}

class PreviewDocument {
  PreviewDocument({
    required this.banner,
    List<PreviewLayer>? layers,
    this.levelFileName = 'preview',
    this.autoStyle = PreviewAutoStyle.normal,
  }) : layers = layers ?? <PreviewLayer>[];

  PreviewBannerRef banner;
  List<PreviewLayer> layers;
  String levelFileName;
  PreviewAutoStyle autoStyle;

  PreviewLayer? layerById(String id) {
    for (final l in layers) {
      if (l.id == id) return l;
    }
    return null;
  }

  List<PreviewLayer> get sortedLayers {
    final copy = List<PreviewLayer>.from(layers);
    copy.sort((a, b) => a.zIndex.compareTo(b.zIndex));
    return copy;
  }

  /// Convenience for editors that still think in title/subtitle.
  String get titleText =>
      layerById('title')?.text ?? layerById('theme')?.text ?? '';

  set titleText(String v) {
    final t = layerById('title') ?? layerById('theme');
    if (t != null) t.text = v;
  }

  String get subtitleText => layerById('subtitle')?.text ?? '';

  set subtitleText(String v) {
    final s = layerById('subtitle');
    if (s != null) s.text = v;
  }

  PreviewDocument copy() => PreviewDocument(
    banner: banner.copy(),
    layers: layers.map((l) => l.copy()).toList(),
    levelFileName: levelFileName,
    autoStyle: autoStyle,
  );
}

/// @deprecated Prefer [PreviewLayer] with [PreviewLayerKind.iconGrid].
typedef PreviewPresentationModule = PreviewLayer;
