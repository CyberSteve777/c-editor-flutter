import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_fonts.dart';

/// Styled [TextEditingController] that owns per-run preview text styles and
/// paints them via [buildTextSpan] (single edit/display path — no overlay).
class PreviewRichTextController extends TextEditingController {
  PreviewRichTextController() {
    _runs = [PreviewTextRun(text: '', style: PreviewTextStyleData())];
  }

  List<PreviewTextRun> _runs = [];
  bool _mutatingValue = false;

  /// True while [loadFromLayer] / programmatic value writes are in progress.
  bool get isApplyingProgrammaticValue => _mutatingValue;

  /// Next inserted characters use this style when set (toolbar / caret typing).
  PreviewTextStyleData? typingStyle;

  List<PreviewTextRun> get runs =>
      List<PreviewTextRun>.unmodifiable(_runs.map((r) => r.copy()));

  String get plainText => _runs.map((r) => r.text).join();

  /// Replace controller contents from a layer without treating it as a user edit.
  void loadFromLayer(PreviewLayer layer) {
    layer.ensureTextRuns();
    _runs = [for (final r in layer.textRuns) r.copy()];
    if (_runs.isEmpty) {
      _runs = [
        PreviewTextRun(
          text: '',
          style: (layer.textStyle ?? PreviewTextStyleData()).copy(),
        ),
      ];
    }
    typingStyle = null;
    final next = plainText;
    final sel = selection;
    final offset = sel.isValid
        ? sel.baseOffset.clamp(0, next.length)
        : next.length;
    _mutatingValue = true;
    value = TextEditingValue(
      text: next,
      selection: TextSelection.collapsed(offset: offset),
    );
    _mutatingValue = false;
  }

  /// Push current runs back onto the layer.
  void applyToLayer(PreviewLayer layer) {
    layer.textRuns = [for (final r in _runs) r.copy()];
    layer.text = plainText;
    layer.textStyle = _runs.isEmpty
        ? (layer.textStyle ?? PreviewTextStyleData()).copy()
        : _runs.first.style.copy();
  }

  /// Refresh span styles from [layer] without moving the caret (toolbar edits).
  void reloadStylesFromLayer(
    PreviewLayer layer, {
    TextSelection? keepSelection,
  }) {
    layer.ensureTextRuns();
    final sel = keepSelection ?? selection;
    _runs = [for (final r in layer.textRuns) r.copy()];
    if (_runs.isEmpty) {
      _runs = [
        PreviewTextRun(
          text: layer.plainText,
          style: (layer.textStyle ?? PreviewTextStyleData()).copy(),
        ),
      ];
    }
    final next = plainText;
    _mutatingValue = true;
    value = TextEditingValue(
      text: next,
      selection: sel.isValid
          ? TextSelection(
              baseOffset: sel.baseOffset.clamp(0, next.length),
              extentOffset: sel.extentOffset.clamp(0, next.length),
            )
          : TextSelection.collapsed(offset: next.length),
    );
    _mutatingValue = false;
  }

  PreviewTextStyleData styleAtCaret() {
    if (typingStyle != null) return typingStyle!.copy();
    final plain = plainText;
    if (plain.isEmpty) {
      return (_runs.isNotEmpty ? _runs.first.style : PreviewTextStyleData())
          .copy();
    }
    final sel = selection;
    if (sel.isValid && !sel.isCollapsed) {
      return _styleAtIndex(sel.start);
    }
    final caret = sel.isValid
        ? sel.baseOffset.clamp(0, plain.length)
        : plain.length;
    if (caret <= 0) return _styleAtIndex(0);
    return _styleAtIndex(caret - 1);
  }

  PreviewTextStyleData _styleAtIndex(int index) {
    final plain = plainText;
    if (plain.isEmpty || _runs.isEmpty) {
      return PreviewTextStyleData();
    }
    final i = index.clamp(0, plain.length - 1);
    var cursor = 0;
    for (final run in _runs) {
      final end = cursor + run.text.length;
      if (i < end) return run.style.copy();
      cursor = end;
    }
    return _runs.last.style.copy();
  }

  /// Apply [mutate] to the selected range, or set [typingStyle] when collapsed.
  void mutateActiveStyle(void Function(PreviewTextStyleData style) mutate) {
    final sel = selection;
    if (sel.isValid && !sel.isCollapsed) {
      typingStyle = null;
      _applyStyleToRange(sel.start, sel.end, mutate);
      notifyListeners();
      return;
    }
    final next = styleAtCaret();
    mutate(next);
    typingStyle = next;
    notifyListeners();
  }

  void _applyStyleToRange(
    int start,
    int end,
    void Function(PreviewTextStyleData style) mutate,
  ) {
    final plain = plainText;
    final s = start.clamp(0, plain.length);
    final e = end.clamp(0, plain.length);
    if (s >= e) {
      for (final run in _runs) {
        mutate(run.style);
      }
      return;
    }
    final next = <PreviewTextRun>[];
    var cursor = 0;
    for (final run in _runs) {
      final runStart = cursor;
      final runEnd = cursor + run.text.length;
      cursor = runEnd;
      if (runEnd <= s || runStart >= e) {
        next.add(run.copy());
        continue;
      }
      if (runStart < s) {
        next.add(
          PreviewTextRun(
            text: run.text.substring(0, s - runStart),
            style: run.style.copy(),
          ),
        );
      }
      final midStart = math.max(s, runStart) - runStart;
      final midEnd = math.min(e, runEnd) - runStart;
      final midStyle = run.style.copy();
      mutate(midStyle);
      next.add(
        PreviewTextRun(
          text: run.text.substring(midStart, midEnd),
          style: midStyle,
        ),
      );
      if (runEnd > e) {
        next.add(
          PreviewTextRun(
            text: run.text.substring(e - runStart),
            style: run.style.copy(),
          ),
        );
      }
    }
    _runs = _coalesce(next);
  }

  @override
  set value(TextEditingValue newValue) {
    final oldText = text;
    if (_mutatingValue) {
      super.value = newValue;
      return;
    }
    final valueChanged = value != newValue;
    final clearTypingStyle = newValue.text == oldText && typingStyle != null;
    if (newValue.text != oldText) {
      // TextEditingController.value synchronously notifies listeners. Prepare
      // runs first so a listener that applies them to a layer sees this edit,
      // including the final character typed before editing ends.
      _updateRunsPreservingStyles(oldText, newValue.text);
    } else if (clearTypingStyle) {
      // Selection-only change — drop pending typing style so toolbar follows caret.
      typingStyle = null;
    }
    super.value = newValue;
    // Equal values do not notify through ValueNotifier, but the pending style
    // may still have changed and needs a toolbar refresh.
    if (clearTypingStyle && !valueChanged) notifyListeners();
  }

  void _updateRunsPreservingStyles(String oldValue, String newValue) {
    if (_runs.length == 1 && typingStyle == null) {
      _runs.first.text = newValue;
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
    for (final run in _runs) {
      for (var i = 0; i < run.text.length; i++) {
        charStyles.add(run.style);
      }
    }

    final fallback =
        (charStyles.isNotEmpty ? charStyles.first : PreviewTextStyleData())
            .copy();
    final inherited = prefix > 0 && prefix <= charStyles.length
        ? charStyles[prefix - 1].copy()
        : (charStyles.isNotEmpty ? charStyles.first.copy() : fallback);
    final insertStyle = typingStyle?.copy() ?? inherited;
    typingStyle = null;

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
      if (next.isNotEmpty && _sameStyle(next.last.style, style)) {
        next.last.text += ch;
      } else {
        next.add(PreviewTextRun(text: ch, style: style.copy()));
      }
    }
    _runs = next.isEmpty
        ? [PreviewTextRun(text: '', style: fallback)]
        : _coalesce(next);
  }

  static List<PreviewTextRun> _coalesce(List<PreviewTextRun> input) {
    final out = <PreviewTextRun>[];
    for (final run in input) {
      if (run.text.isEmpty) continue;
      if (out.isNotEmpty && _sameStyle(out.last.style, run.style)) {
        out.last.text += run.text;
      } else {
        out.add(run.copy());
      }
    }
    if (out.isEmpty) {
      out.add(PreviewTextRun(text: '', style: PreviewTextStyleData()));
    }
    return out;
  }

  static bool _sameStyle(PreviewTextStyleData a, PreviewTextStyleData b) {
    return a.fontFamily == b.fontFamily &&
        a.fontSize == b.fontSize &&
        a.fontWeight == b.fontWeight &&
        a.italic == b.italic &&
        a.underline == b.underline &&
        a.outline == b.outline &&
        a.color == b.color &&
        a.outlineColor == b.outlineColor &&
        a.outlineWidth == b.outlineWidth;
  }

  @override
  void clear() {
    _runs = [PreviewTextRun(text: '', style: PreviewTextStyleData())];
    typingStyle = null;
    _mutatingValue = true;
    super.clear();
    _mutatingValue = false;
  }

  @override
  TextSpan buildTextSpan({
    required BuildContext context,
    TextStyle? style,
    required bool withComposing,
  }) {
    if (_runs.isEmpty || (plainText.isEmpty && text.isEmpty)) {
      return TextSpan(style: style, text: text);
    }
    // Keep span text identical to [text] so caret offsets stay valid.
    final children = <InlineSpan>[];
    var cursor = 0;
    for (final run in _runs) {
      if (run.text.isEmpty) continue;
      final end = cursor + run.text.length;
      if (end > text.length) break;
      final slice = text.substring(cursor, end);
      children.add(
        TextSpan(
          text: slice,
          style: PreviewFonts.resolveForEditable(run.style),
        ),
      );
      cursor = end;
    }
    if (cursor < text.length) {
      children.add(
        TextSpan(
          text: text.substring(cursor),
          style: PreviewFonts.resolveForEditable(
            _runs.isNotEmpty ? _runs.last.style : PreviewTextStyleData(),
          ),
        ),
      );
    }
    return TextSpan(style: style, children: children);
  }
}
