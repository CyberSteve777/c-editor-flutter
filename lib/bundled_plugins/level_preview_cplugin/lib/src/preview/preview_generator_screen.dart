import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/gif_first_frame.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_auto_composer.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_editor_workspace.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_feature_groups.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_fonts.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_module_info.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_pickers.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_png_exporter.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_rich_text_controller.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/stage_banner_resolver.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'dart:ui' as ui;

/// Minimum horizontal space needed to keep the preview canvas and its editing
/// controls practical to use.
const double kPreviewGeneratorMinimumWidth = 600;

@visibleForTesting
bool isPreviewGeneratorWidthAvailable(double availableWidth) =>
    availableWidth >= kPreviewGeneratorMinimumWidth;

@visibleForTesting
bool useMobilePreviewGeneratorNarrowPrompt({
  required TargetPlatform platform,
  bool isWeb = kIsWeb,
}) {
  if (isWeb) return false;
  return platform == TargetPlatform.android || platform == TargetPlatform.iOS;
}

/// Asks for Normal / Simple starting layout. Cancel returns null.
/// [Simple] is the recommended (primary) action.
Future<PreviewAutoStyle?> showPreviewLayoutStyleDialog({
  required BuildContext context,
  required String Function(String key, [String? fallback]) t,
  bool recreate = false,
  bool barrierDismissible = false,
}) {
  return showDialog<PreviewAutoStyle>(
    context: context,
    barrierDismissible: barrierDismissible,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return AlertDialog(
        title: Text(
          t(
            recreate ? 'previewGenRecreate' : 'previewGenStartTitle',
            recreate ? 'Recreate again' : 'Choose starting layout',
          ),
        ),
        content: Text(
          t(
            recreate ? 'previewGenRecreateHint' : 'previewGenStartHint',
            recreate
                ? 'Replace the current preview with a fresh layout? You can undo afterwards.'
                : 'Simple is recommended for most levels. You can edit freely after generating.',
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('previewGenCancel', 'Cancel')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, PreviewAutoStyle.normal),
            child: Text(
              t(
                recreate ? 'previewGenRecreateFromNormal' : 'previewGenNormal',
                recreate ? 'From normal' : 'Normal',
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, PreviewAutoStyle.simple),
            child: Text(
              t(
                recreate ? 'previewGenRecreateFromSimple' : 'previewGenSimple',
                recreate ? 'From simple' : 'Simple',
              ),
            ),
          ),
        ],
      );
    },
  );
}

class PreviewGeneratorScreen extends StatefulWidget {
  const PreviewGeneratorScreen({
    super.key,
    required this.host,
    required this.levelFile,
    required this.parsed,
    required this.fileName,
    this.initialStyle = PreviewAutoStyle.simple,
  });

  final CPluginHost host;
  final PvzLevelFile levelFile;
  final ParsedLevelData parsed;
  final String fileName;
  final PreviewAutoStyle initialStyle;

  @override
  State<PreviewGeneratorScreen> createState() => _PreviewGeneratorScreenState();
}

class _PreviewGeneratorScreenState extends State<PreviewGeneratorScreen> {
  final _boundaryKey = GlobalKey();
  final _textController = PreviewRichTextController();
  final _focusNode = FocusNode();
  final _textFocusNode = FocusNode();
  String _lastControllerText = '';

  /// Snapshot taken on toolbar pointer-down so range styles survive focus theft.
  TextSelection? _toolbarSelectionSnapshot;
  final List<_TextEditCheckpoint> _textUndoStack = [];
  final List<_TextEditCheckpoint> _textRedoStack = [];

  PreviewDocument? _document;
  StageBannerResolver? _banners;
  late PreviewAutoStyle _autoStyle = widget.initialStyle;
  PreviewEditTool _tool = PreviewEditTool.select;
  PreviewShapeKind _figureKind = PreviewShapeKind.rect;
  bool _figureFilled = false;
  String? _selectedLayerId;
  String? _editingTextLayerId;
  int? _selectedIconSectionIndex;
  PreviewTextPartSelection? _selectedTextPart;
  String? _activeStrokeId;
  String? _draftShapeId;
  Color _drawColor = Colors.white;
  final double _drawStrokeWidth = 4;
  int _idSeq = 0;
  bool _loading = true;
  bool _exporting = false;
  String? _error;

  PreviewDocument? _undoSnapshot;
  PreviewDocument? _redoSnapshot;

  static const _palette = <Color>[
    Colors.white,
    Colors.black,
    Color(0xFFFFE082),
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.purple,
    Colors.orange,
  ];

  String _t(String key, [String? fallback, Map<String, Object?>? args]) =>
      widget.host.localize(context, key, fallback ?? key, args);

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextControllerTick);
    _textFocusNode.addListener(_onTextFocusChanged);
    _compose();
  }

  void _onTextControllerTick() {
    if (!mounted) return;
    if (_textController.isApplyingProgrammaticValue) {
      _lastControllerText = _textController.text;
      return;
    }
    final textChanged = _textController.text != _lastControllerText;
    _lastControllerText = _textController.text;
    // Caret moves clear typingStyle inside the controller; rebuild toolbar.
    if (!textChanged) {
      setState(() {});
      return;
    }
    final layer = _selectedTextLayer();
    if (layer != null && _editingTextLayerId == layer.id) {
      // Checkpoint the pre-edit layer before applying the controller's new runs.
      _pushTextCheckpoint(layer);
      if (_undoSnapshot == null) _pushHistory(force: true);
      _textController.applyToLayer(layer);
    }
    setState(() {});
    _ensureTextFocus();
  }

  void _onTextFocusChanged() {
    if (!mounted) return;
    setState(() {});
    if (_textFocusNode.hasFocus || _editingTextLayerId == null) return;
    // Focus left the field while still in edit mode (e.g. parent Focus stole
    // it on rebuild). Restore unless another control intentionally took it.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _editingTextLayerId == null) return;
      if (_textFocusNode.hasFocus) return;
      final primary = FocusManager.instance.primaryFocus;
      if (primary == null || primary == _focusNode) {
        _textFocusNode.requestFocus();
      }
    });
  }

  void _ensureTextFocus() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _editingTextLayerId == null) return;
      if (!_textFocusNode.hasFocus) {
        _textFocusNode.requestFocus();
      }
    });
  }

  void _runTextToolbarAction(VoidCallback action) {
    final snap = _toolbarSelectionSnapshot;
    if (snap != null &&
        snap.isValid &&
        !snap.isCollapsed &&
        _editingTextLayerId != null) {
      // Restore range before mutating — InkWell focus clears TextField selection.
      _textController.selection = TextSelection(
        baseOffset: snap.baseOffset.clamp(0, _textController.text.length),
        extentOffset: snap.extentOffset.clamp(0, _textController.text.length),
      );
    }
    action();
    _toolbarSelectionSnapshot = null;
    _ensureTextFocus();
  }

  void _snapshotTextSelectionForToolbar() {
    if (_editingTextLayerId == null) return;
    final sel = _textController.selection;
    if (sel.isValid) {
      _toolbarSelectionSnapshot = sel;
    }
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextControllerTick);
    _textFocusNode.removeListener(_onTextFocusChanged);
    _textController.dispose();
    _textFocusNode.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _nextId(String prefix) => '${prefix}_${_idSeq++}';

  void _clearTextHistory() {
    _textUndoStack.clear();
    _textRedoStack.clear();
  }

  void _pushTextCheckpoint(PreviewLayer layer) {
    final sel = _textController.selection;
    final len = layer.plainText.length;
    final safeSel = sel.isValid
        ? TextSelection(
            baseOffset: sel.baseOffset.clamp(0, len),
            extentOffset: sel.extentOffset.clamp(0, len),
          )
        : TextSelection.collapsed(offset: len);
    _textUndoStack.add(_TextEditCheckpoint.capture(layer, safeSel));
    if (_textUndoStack.length > 80) {
      _textUndoStack.removeAt(0);
    }
    _textRedoStack.clear();
  }

  bool get _canUndoText =>
      _editingTextLayerId != null && _textUndoStack.isNotEmpty;

  bool get _canRedoText =>
      _editingTextLayerId != null && _textRedoStack.isNotEmpty;

  void _undoTextEdit() {
    final layer = _selectedTextLayer();
    if (layer == null || _textUndoStack.isEmpty) return;
    _textRedoStack.add(
      _TextEditCheckpoint.capture(layer, _textController.selection),
    );
    final past = _textUndoStack.removeLast();
    past.applyTo(layer);
    _textController.loadFromLayer(layer);
    final len = _textController.text.length;
    _textController.selection = TextSelection(
      baseOffset: past.selection.baseOffset.clamp(0, len),
      extentOffset: past.selection.extentOffset.clamp(0, len),
    );
    _lastControllerText = _textController.text;
    setState(() {});
    _ensureTextFocus();
  }

  void _redoTextEdit() {
    final layer = _selectedTextLayer();
    if (layer == null || _textRedoStack.isEmpty) return;
    _textUndoStack.add(
      _TextEditCheckpoint.capture(layer, _textController.selection),
    );
    final next = _textRedoStack.removeLast();
    next.applyTo(layer);
    _textController.loadFromLayer(layer);
    final len = _textController.text.length;
    _textController.selection = TextSelection(
      baseOffset: next.selection.baseOffset.clamp(0, len),
      extentOffset: next.selection.extentOffset.clamp(0, len),
    );
    _lastControllerText = _textController.text;
    setState(() {});
    _ensureTextFocus();
  }

  void _clearHistory() {
    _undoSnapshot = null;
    _redoSnapshot = null;
    _clearTextHistory();
  }

  void _pushHistory({bool force = false}) {
    // While editing text, incremental checkpoints live on _textUndoStack.
    if (!force && _editingTextLayerId != null) return;
    final doc = _document;
    if (doc == null) return;
    _undoSnapshot = doc.copy();
    _redoSnapshot = null;
  }

  void _undo() {
    if (_canUndoText) {
      _undoTextEdit();
      return;
    }
    final doc = _document;
    final past = _undoSnapshot;
    if (doc == null || past == null) return;
    setState(() {
      _redoSnapshot = doc.copy();
      _document = past;
      _undoSnapshot = null;
      _selectedLayerId = null;
      _editingTextLayerId = null;
      _selectedIconSectionIndex = null;
      _selectedTextPart = null;
      _activeStrokeId = null;
      _draftShapeId = null;
      _clearTextHistory();
      _syncTextController();
    });
  }

  void _redo() {
    if (_canRedoText) {
      _redoTextEdit();
      return;
    }
    final doc = _document;
    final future = _redoSnapshot;
    if (doc == null || future == null) return;
    setState(() {
      _undoSnapshot = doc.copy();
      _document = future;
      _redoSnapshot = null;
      _selectedLayerId = null;
      _editingTextLayerId = null;
      _selectedIconSectionIndex = null;
      _selectedTextPart = null;
      _activeStrokeId = null;
      _draftShapeId = null;
      _clearTextHistory();
      _syncTextController();
    });
  }

  Future<void> _compose({bool clearHistory = true}) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final banners = await StageBannerResolver.load();
      PreviewFeatureGroups.resetForTest();
      final groups = await PreviewFeatureGroups.load();
      final doc = await PreviewAutoComposer(
        levelFile: widget.levelFile,
        parsed: widget.parsed,
        fileName: widget.fileName,
        banners: banners,
        featureGroups: groups,
        style: _autoStyle,
        localize: (key, fallback) => _t(key, fallback),
        moduleTitle: (objClass) =>
            ModuleRegistry.getMetadata(objClass).getTitle(context),
        plantsSourceLabel: _t('previewGenPlants', 'Plants'),
        zombiesSourceLabel: _t('previewGenZombies', 'Zombies'),
        gridItemsSourceLabel: _t('previewGenGridItems', 'Initial grid items'),
        seedBankLabel: _t('previewSeedBank', 'Seed Bank'),
        zombieSeedBankLabel: _t(
          'previewIZombieSeedBank',
          'Seed Bank (I, Zombie)',
        ),
        vasebreakerLabel: _t('previewFeature_vasebreaker', 'Vasebreaker'),
        conveyorLabel: _t('previewGenConveyor', 'Conveyor'),
        prePlacedLabel: _t('previewPrePlaced', 'Placement'),
        protectLabel: _t('previewGenProtect', 'Protect'),
        challengeLabel: _t('previewGenChallenge', 'Challenge'),
        wavesLabel: _t('previewGenWaves', 'Waves'),
        initialZombiesLabel: _t('previewGenInitial', 'Initial'),
        zombotPrefix: _t('previewGenZombotPrefix', 'Zombot: '),
        zombossPrefix: _t('previewGenZombossPrefix', 'Zomboss: '),
        spawnedZombiesLabel: _t(
          'previewGenSpawnedZombies',
          'Spawned zombies: ',
        ),
        resourceName: (id) => ResourceNames.lookup(context, id),
      ).compose();
      if (!mounted) return;
      setState(() {
        _banners = banners;
        _document = doc;
        _loading = false;
        _selectedLayerId = null;
        _editingTextLayerId = null;
        _selectedIconSectionIndex = null;
        _selectedTextPart = null;
        _activeStrokeId = null;
        _draftShapeId = null;
        if (clearHistory) {
          _clearHistory();
        } else {
          _redoSnapshot = null;
        }
        _syncTextController();
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _recreateFromAuto() async {
    _endTextEdit();
    final choice = await showPreviewLayoutStyleDialog(
      context: context,
      t: _t,
      recreate: true,
      barrierDismissible: true,
    );
    if (choice == null || !mounted) return;
    _pushHistory();
    setState(() => _autoStyle = choice);
    await _compose(clearHistory: false);
  }

  void _syncTextController() {
    final layer = _selectedTextLayer();
    if (layer != null) {
      _textController.loadFromLayer(layer);
    } else {
      // Use the rich controller's programmatic path for panel/shape text too,
      // so selection changes are not mistaken for edits of the previous layer.
      _textController.loadFromLayer(
        PreviewLayer(
          id: 'selected_text_part',
          kind: PreviewLayerKind.text,
          bounds: const Rect.fromLTWH(0, 0, 1, 1),
          text: _selectedTextValue() ?? '',
          textStyle: _selectedContainedText()?.style.copy(),
        ),
      );
    }
    _lastControllerText = _textController.text;
  }

  static const _fontSizeChoices = <double>[
    12,
    14,
    16,
    18,
    20,
    24,
    28,
    32,
    36,
    42,
    48,
    56,
    64,
    72,
    84,
    96,
  ];

  double _snapFontSize(double size) {
    var best = _fontSizeChoices.first;
    var bestDist = (best - size).abs();
    for (final candidate in _fontSizeChoices) {
      final dist = (candidate - size).abs();
      if (dist < bestDist) {
        best = candidate;
        bestDist = dist;
      }
    }
    return best;
  }

  PreviewTextStyleData _activeTextStyle(PreviewLayer layer) {
    if (_editingTextLayerId == layer.id) {
      return _textController.styleAtCaret();
    }
    layer.ensureTextRuns();
    return (layer.textStyle ??
            (layer.textRuns.isNotEmpty
                ? layer.textRuns.first.style
                : PreviewTextStyleData()))
        .copy();
  }

  void _mutateSelectedTextStyle(
    PreviewLayer layer,
    void Function(PreviewTextStyleData style) mutate,
  ) {
    if (_editingTextLayerId == layer.id) {
      _pushTextCheckpoint(layer);
      _textController.mutateActiveStyle(mutate);
      _textController.applyToLayer(layer);
      return;
    }
    layer.ensureTextRuns();
    final sel = _textController.selection;
    if (sel.isValid && !sel.isCollapsed) {
      layer.applyStyleToRange(sel.start, sel.end, mutate);
    } else {
      layer.applyStyleToRange(0, layer.plainText.length, mutate);
    }
    _textController.loadFromLayer(layer);
  }

  Widget _toolbarToggleShell({
    required String tooltip,
    required bool selected,
    required VoidCallback onTap,
    required Widget child,
  }) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected
                ? theme.colorScheme.primary.withValues(alpha: 0.18)
                : theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: selected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.outlineVariant,
            ),
          ),
          child: child,
        ),
      ),
    );
  }

  Widget _styleToggle({
    required String label,
    required String tooltip,
    required bool selected,
    required TextStyle style,
    required VoidCallback onTap,
  }) {
    return _toolbarToggleShell(
      tooltip: tooltip,
      selected: selected,
      onTap: onTap,
      child: Text(label, style: style),
    );
  }

  Widget _alignToggle({
    required IconData icon,
    required String tooltip,
    required TextAlign align,
    PreviewLayer? layer,
    bool forIcons = false,
    TextAlign? currentAlign,
  }) {
    final selected = forIcons
        ? layer?.iconAlign == align
        : currentAlign == align;
    return _toolbarToggleShell(
      tooltip: tooltip,
      selected: forIcons ? selected : currentAlign == align,
      onTap: () {
        _runTextToolbarAction(() {
          _pushHistory();
          setState(() {
            if (forIcons) {
              layer!.iconAlign = align;
            } else {
              _setSelectedTextAlign(align);
            }
          });
        });
      },
      child: Icon(icon, size: 18),
    );
  }

  Widget _labeledSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String valueLabel,
    required ValueChanged<double> onChanged,
  }) {
    return SizedBox(
      width: 260,
      child: Row(
        children: [
          Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(width: 6),
          Expanded(
            child: Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: valueLabel,
              onChangeStart: (_) => _pushHistory(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  PreviewLayer? _selectedLayer() {
    final id = _selectedLayerId;
    if (id == null) return null;
    return _document?.layerById(id);
  }

  PreviewLayer? _selectedTextLayer() {
    final layer = _selectedLayer();
    if (layer == null || layer.kind != PreviewLayerKind.text) return null;
    return layer;
  }

  PreviewLayer? _selectedIconGridLayer() {
    final layer = _selectedLayer();
    if (layer == null || layer.kind != PreviewLayerKind.iconGrid) return null;
    return layer;
  }

  void _beginTextEdit(String id) {
    if (_document?.layerById(id)?.kind != PreviewLayerKind.text) return;
    setState(() {
      _selectedLayerId = id;
      _selectedIconSectionIndex = null;
      _selectedTextPart = null;
      _editingTextLayerId = id;
      _draftShapeId = null;
      _clearTextHistory();
      _syncTextController();
    });
    _ensureTextFocus();
  }

  void _endTextEdit() {
    if (_editingTextLayerId == null && !_textFocusNode.hasFocus) return;
    final layer = _selectedTextLayer();
    if (layer != null) {
      _textController.applyToLayer(layer);
    }
    setState(() {
      _editingTextLayerId = null;
      _textController.typingStyle = null;
      _clearTextHistory();
    });
    if (_textFocusNode.hasFocus) {
      _textFocusNode.unfocus();
      _focusNode.requestFocus();
    }
  }

  PreviewContainedText? _selectedContainedText() {
    final selection = _selectedTextPart;
    if (selection == null || selection.kind != PreviewTextPartKind.contained) {
      return null;
    }
    final layer = _document?.layerById(selection.layerId);
    if (layer == null) return null;
    for (final text in layer.containedTexts) {
      if (text.id == selection.containedTextId) return text;
    }
    return null;
  }

  String? _selectedTextValue() {
    final textLayer = _selectedTextLayer();
    if (textLayer != null) return textLayer.plainText;

    final selection = _selectedTextPart;
    if (selection == null) return null;
    final layer = _document?.layerById(selection.layerId);
    if (layer == null) return null;
    return switch (selection.kind) {
      PreviewTextPartKind.gridTitle => layer.gridTitle,
      PreviewTextPartKind.sourceLabel => layer.sourceLabel,
      PreviewTextPartKind.sectionTitle =>
        selection.sectionIndex != null &&
                selection.sectionIndex! >= 0 &&
                selection.sectionIndex! < layer.sections.length
            ? layer.sections[selection.sectionIndex!].title
            : null,
      PreviewTextPartKind.contained => _selectedContainedText()?.text,
    };
  }

  void _setSelectedText(String value) {
    final textLayer = _selectedTextLayer();
    if (textLayer != null) {
      textLayer.setPlainText(value);
      return;
    }

    final selection = _selectedTextPart;
    if (selection == null) return;
    final layer = _document?.layerById(selection.layerId);
    if (layer == null) return;
    switch (selection.kind) {
      case PreviewTextPartKind.gridTitle:
        layer.gridTitle = value;
      case PreviewTextPartKind.sourceLabel:
        layer.sourceLabel = value;
      case PreviewTextPartKind.sectionTitle:
        final index = selection.sectionIndex;
        if (index != null && index >= 0 && index < layer.sections.length) {
          layer.sections[index].title = value;
        }
      case PreviewTextPartKind.contained:
        final contained = _selectedContainedText();
        if (contained != null) contained.text = value;
    }
    _resizeIconGridToContent(layer);
  }

  PreviewTextStyleData? _activeSelectedTextStyle() {
    final textLayer = _selectedTextLayer();
    if (textLayer != null) return _activeTextStyle(textLayer);
    return _selectedContainedText()?.style;
  }

  void _mutateActiveTextStyle(
    void Function(PreviewTextStyleData style) mutate,
  ) {
    final textLayer = _selectedTextLayer();
    if (textLayer != null) {
      _mutateSelectedTextStyle(textLayer, mutate);
      return;
    }
    final contained = _selectedContainedText();
    if (contained != null) mutate(contained.style);
  }

  TextAlign? _selectedTextAlign() {
    final textLayer = _selectedTextLayer();
    if (textLayer != null) return textLayer.textAlign;
    return _selectedContainedText()?.textAlign;
  }

  void _setSelectedTextAlign(TextAlign align) {
    final textLayer = _selectedTextLayer();
    if (textLayer != null) {
      textLayer.textAlign = align;
      return;
    }
    final contained = _selectedContainedText();
    if (contained != null) contained.textAlign = align;
  }

  PreviewIconSection? _selectedIconSection() {
    final layer = _selectedLayer();
    final index = _selectedIconSectionIndex;
    if (layer == null ||
        layer.kind != PreviewLayerKind.iconGrid ||
        index == null) {
      return null;
    }
    final sections = previewEffectiveSections(layer);
    if (index < 0 || index >= sections.length) return null;
    return sections[index];
  }

  void _resizeIconGridToContent(PreviewLayer layer) {
    if (layer.kind != PreviewLayerKind.iconGrid) return;
    final size = previewIconGridIntrinsicSize(
      maxWidth: layer.bounds.width * kPreviewCanvasSize.width,
      sections: previewEffectiveSections(layer),
      showChrome: layer.showChrome,
      gridTitle: layer.gridTitle,
      sourceLabel: layer.sourceLabel,
      lawnRows: layer.lawnRows,
      lawnCols: layer.lawnCols,
    );
    final height = (size.height / kPreviewCanvasSize.height).clamp(
      0.04,
      1.0 - layer.bounds.top,
    );
    layer.bounds = Rect.fromLTWH(
      layer.bounds.left,
      layer.bounds.top,
      layer.bounds.width,
      height,
    );
  }

  void _applyColor(Color c) {
    _runTextToolbarAction(() {
      _pushHistory();
      setState(() {
        _drawColor = c;
        final layer = _selectedLayer();
        if (layer == null) return;
        if (layer.kind == PreviewLayerKind.text) {
          _mutateSelectedTextStyle(layer, (s) => s.color = c);
        } else if (_selectedContainedText() != null) {
          _mutateActiveTextStyle((s) => s.color = c);
        } else if (layer.kind == PreviewLayerKind.shape ||
            layer.kind == PreviewLayerKind.stroke) {
          layer.strokeColor = c;
          if (layer.kind == PreviewLayerKind.shape && layer.shapeFilled) {
            layer.fillColor = c.withValues(alpha: 0.35);
          }
        }
      });
    });
  }

  Future<void> _openColorPicker() async {
    var pending = _drawColor;
    final chosen = await showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t('previewGenCustomColor', 'Custom color')),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: pending,
            enableAlpha: true,
            hexInputBar: true,
            labelTypes: const [],
            onColorChanged: (c) => pending = c,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(_t('previewGenCancel', 'Cancel')),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, pending),
            child: Text(_t('previewGenApply', 'Apply')),
          ),
        ],
      ),
    );
    if (chosen == null || !mounted) return;
    _applyColor(chosen);
  }

  Future<void> _pickBannerStem() async {
    _endTextEdit();
    final banners = _banners;
    final doc = _document;
    if (banners == null || doc == null) return;
    final chosen = await showPreviewBannerPicker(
      context: context,
      banners: banners,
      t: _t,
      currentStem: doc.banner.stem,
    );
    if (chosen == null || !mounted) return;
    if (chosen == '__custom__') {
      await _pickCustomBanner();
      return;
    }
    _pushHistory();
    setState(() {
      doc.banner = PreviewBannerRef(
        kind: PreviewBannerSourceKind.assetStem,
        stem: chosen,
        assetPath: banners.assetPathForStem(chosen),
      );
    });
  }

  Future<void> _pickCustomBanner() async {
    final doc = _document;
    if (doc == null) return;
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null || path.isEmpty) return;
    _pushHistory();
    setState(() {
      doc.banner = PreviewBannerRef(
        kind: PreviewBannerSourceKind.userFile,
        userFilePath: path,
      );
    });
  }

  Future<void> _addOverlayImage() async {
    _endTextEdit();
    final doc = _document;
    if (doc == null) return;
    final choice = await showPreviewAssetImagePicker(context: context, t: _t);
    if (choice == null || !mounted) return;

    String? path;
    String? asset;
    if (choice.isCustom) {
      final result = await FilePicker.pickFiles(
        type: FileType.image,
        withData: false,
      );
      path = result?.files.single.path;
      if (path == null || path.isEmpty) return;
    } else {
      asset = choice.assetPath;
      if (asset == null) return;
    }

    var bounds = const Rect.fromLTWH(0.35, 0.25, 0.30, 0.40);
    try {
      ui.Image? decoded;
      if (asset != null) {
        if (asset.toLowerCase().endsWith('.gif')) {
          decoded = await decodeFirstFrameFromAsset(asset);
        } else {
          final data = await rootBundle.load(asset);
          decoded = await decodeImageFromList(data.buffer.asUint8List());
        }
      }
      if (decoded != null) {
        final aspect = decoded.width / decoded.height.clamp(1, 100000);
        const maxW = 0.30;
        var w = maxW;
        var h = maxW / aspect;
        if (h > 0.45) {
          h = 0.45;
          w = h * aspect;
        }
        bounds = Rect.fromLTWH(0.5 - w / 2, 0.5 - h / 2, w, h);
        decoded.dispose();
      }
    } catch (_) {}

    final id = _nextId('image');
    _pushHistory();
    setState(() {
      doc.layers.add(
        PreviewLayer(
          id: id,
          kind: PreviewLayerKind.image,
          bounds: bounds,
          scale: 1,
          zIndex: doc.layers.length + 10,
          imagePath: path,
          imageAsset: asset,
        ),
      );
      _selectedLayerId = id;
      _tool = PreviewEditTool.select;
      _selectedIconSectionIndex = null;
      _selectedTextPart = null;
    });
  }

  Future<void> _openFiguresMenu() async {
    _endTextEdit();
    final choice = await showModalBottomSheet<(PreviewShapeKind, bool)>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(title: Text(_t('previewTool_figures', 'Figures'))),
            for (final e in [
              (PreviewShapeKind.rect, false, Icons.crop_square, 'Rectangle'),
              (PreviewShapeKind.oval, false, Icons.circle_outlined, 'Oval'),
              (PreviewShapeKind.line, false, Icons.show_chart, 'Line'),
              (PreviewShapeKind.star, false, Icons.star_border, 'Star'),
              (PreviewShapeKind.rect, true, Icons.square, 'Filled rectangle'),
              (PreviewShapeKind.oval, true, Icons.circle, 'Filled oval'),
              (PreviewShapeKind.star, true, Icons.star, 'Filled star'),
            ])
              ListTile(
                leading: Icon(e.$3),
                title: Text(
                  _t(
                    'previewFigure_${e.$1.name}${e.$2 ? '_filled' : ''}',
                    e.$4,
                  ),
                ),
                onTap: () => Navigator.pop(ctx, (e.$1, e.$2)),
              ),
          ],
        ),
      ),
    );
    if (choice == null || !mounted) return;
    setState(() {
      _tool = PreviewEditTool.figures;
      _figureKind = choice.$1;
      _figureFilled = choice.$2;
      _draftShapeId = null;
    });
  }

  Future<void> _addModuleInfoElement() async {
    _endTextEdit();
    final doc = _document;
    if (doc == null) return;
    final classes = previewPresentModuleObjClasses(widget.levelFile);
    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _t('previewGenModuleInfoEmpty', 'No modules found on this level'),
          ),
        ),
      );
      return;
    }

    final objClass = await showDialog<String>(
      context: context,
      builder: (ctx) {
        var query = '';
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            final filtered = classes.where((oc) {
              if (query.isEmpty) return true;
              final title = ModuleRegistry.getMetadata(oc).getTitle(ctx);
              return oc.toLowerCase().contains(query.toLowerCase()) ||
                  title.toLowerCase().contains(query.toLowerCase());
            }).toList();
            return AlertDialog(
              title: Text(_t('previewGenModuleInfo', 'Module info')),
              content: SizedBox(
                width: 420,
                height: 400,
                child: Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        isDense: true,
                        prefixIcon: const Icon(Icons.search),
                        hintText: _t('previewGenModuleInfoSearch', 'Search'),
                      ),
                      onChanged: (v) => setLocal(() => query = v),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final oc = filtered[i];
                          final meta = ModuleRegistry.getMetadata(oc);
                          return ListTile(
                            title: Text(meta.getTitle(ctx)),
                            subtitle: Text(
                              oc,
                              style: const TextStyle(fontSize: 11),
                            ),
                            onTap: () => Navigator.pop(ctx, oc),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(_t('previewGenCancel', 'Cancel')),
                ),
              ],
            );
          },
        );
      },
    );
    if (objClass == null || !mounted) return;

    final meta = ModuleRegistry.getMetadata(objClass);
    final title = meta.getTitle(context);
    String l10n(String key, String fallback, [Map<String, Object?>? args]) =>
        _t(key, fallback, args);
    final payload = previewModuleInfoBuild(
      levelFile: widget.levelFile,
      objClass: objClass,
      t: l10n,
    );
    final summary = payload.textBody;
    final bodyText = summary.isEmpty ? title : '$title\n$summary';
    final canGrid = payload.sections.isNotEmpty;

    String? mode;
    if (canGrid) {
      mode = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(title),
          content: Text(
            _t(
              'previewGenModuleInfoKindHint',
              'Add a text label or an icon-grid summary for this module.',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(_t('previewGenCancel', 'Cancel')),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 'text'),
              child: Text(_t('previewGenModuleInfoText', 'Text label')),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, 'grid'),
              child: Text(_t('previewGenModuleInfoGrid', 'Icon grid')),
            ),
          ],
        ),
      );
    } else {
      // No icons for this module — only a text summary makes sense.
      mode = 'text';
    }
    if (mode == null || !mounted) return;

    if (mode == 'text') {
      final id = _nextId('modtext');
      _pushHistory();
      setState(() {
        doc.layers.add(
          PreviewLayer(
            id: id,
            kind: PreviewLayerKind.text,
            bounds: const Rect.fromLTWH(0.12, 0.2, 0.76, 0.45),
            zIndex: doc.layers.length + 10,
            text: bodyText,
            textStyle: PreviewTextStyleData(
              fontFamily: PreviewFonts.familyPvZ,
              fontSize: 22,
              outline: true,
            ),
          ),
        );
        _selectedLayerId = id;
        _tool = PreviewEditTool.select;
        _selectedIconSectionIndex = null;
        _selectedTextPart = null;
        _syncTextController();
      });
      return;
    }

    final sections = payload.sections;
    final chrome = payload.gridChromeBody;
    final id = _nextId('modgrid');
    _pushHistory();
    setState(() {
      doc.layers.add(
        PreviewLayer(
          id: id,
          kind: PreviewLayerKind.iconGrid,
          gridKind: PreviewIconGridKind.custom,
          gridTitle: title,
          // Only non-spatial notes on the grid chrome — cell lists stay in text mode.
          sourceLabel: chrome.isEmpty ? null : chrome,
          showChrome: true,
          lawnRows: payload.lawnRows,
          lawnCols: payload.lawnCols,
          bounds: payload.isLawnGrid
              ? const Rect.fromLTWH(0.04, 0.12, 0.42, 0.72)
              : const Rect.fromLTWH(0.05, 0.2, 0.55, 0.55),
          zIndex: doc.layers.length + 10,
          sections: sections,
          items: [for (final s in sections) ...s.items],
        ),
      );
      _selectedLayerId = id;
      _selectedIconSectionIndex = null;
      _selectedTextPart = null;
      _tool = PreviewEditTool.select;
    });
  }

  void _addTextLayer() {
    _endTextEdit();
    final doc = _document;
    if (doc == null) return;
    final container = _selectedLayer();
    final id = _nextId('text');
    _pushHistory();
    setState(() {
      if (container != null &&
          (container.kind == PreviewLayerKind.iconGrid ||
              container.kind == PreviewLayerKind.shape)) {
        final containedIndex = container.containedTexts.length;
        final top = (0.35 + containedIndex * 0.2).clamp(0.05, 0.77);
        container.containedTexts.add(
          PreviewContainedText(
            id: id,
            text: _t('previewGenNewText', 'New text'),
            bounds: Rect.fromLTWH(0.1, top, 0.8, 0.18),
            style: PreviewTextStyleData(
              fontFamily: PreviewFonts.familyPvZ,
              fontSize: 24,
            ),
          ),
        );
        _selectedTextPart = PreviewTextPartSelection(
          layerId: container.id,
          kind: PreviewTextPartKind.contained,
          containedTextId: id,
        );
        _selectedIconSectionIndex = null;
        _tool = PreviewEditTool.select;
        _syncTextController();
        return;
      }
      doc.layers.add(
        PreviewLayer(
          id: id,
          kind: PreviewLayerKind.text,
          bounds: const Rect.fromLTWH(0.2, 0.4, 0.5, 0.15),
          zIndex: doc.layers.length + 10,
          text: _t('previewGenNewText', 'New text'),
          textStyle: PreviewTextStyleData(
            fontFamily: PreviewFonts.familyPvZ,
            fontSize: 36,
          ),
        ),
      );
      _selectedLayerId = id;
      _selectedIconSectionIndex = null;
      _selectedTextPart = null;
      _tool = PreviewEditTool.select;
      _syncTextController();
    });
  }

  void _deleteSelected() {
    _endTextEdit();
    final doc = _document;
    final id = _selectedLayerId;
    if (doc == null || id == null) return;
    final layer = doc.layerById(id);
    if (layer == null) return;
    _pushHistory();
    setState(() {
      final textPart = _selectedTextPart;
      if (textPart != null) {
        switch (textPart.kind) {
          case PreviewTextPartKind.gridTitle:
            layer.gridTitle = null;
          case PreviewTextPartKind.sourceLabel:
            layer.sourceLabel = null;
          case PreviewTextPartKind.sectionTitle:
            final index = textPart.sectionIndex;
            if (index != null && index >= 0 && index < layer.sections.length) {
              layer.sections[index].title = null;
            }
          case PreviewTextPartKind.contained:
            layer.containedTexts.removeWhere(
              (text) => text.id == textPart.containedTextId,
            );
        }
        _selectedTextPart = null;
        _resizeIconGridToContent(layer);
        _textController.clear();
        return;
      }

      final sectionIndex = _selectedIconSectionIndex;
      if (sectionIndex != null &&
          layer.kind == PreviewLayerKind.iconGrid &&
          layer.sections.isNotEmpty &&
          sectionIndex >= 0 &&
          sectionIndex < layer.sections.length) {
        layer.sections.removeAt(sectionIndex);
        layer.items = [for (final section in layer.sections) ...section.items];
        _selectedIconSectionIndex = null;
        _resizeIconGridToContent(layer);
        return;
      }

      doc.layers.removeWhere((l) => l.id == id);
      _selectedLayerId = null;
      _editingTextLayerId = null;
      _selectedIconSectionIndex = null;
      _selectedTextPart = null;
      _textController.clear();
    });
  }

  Future<void> _export() async {
    _endTextEdit();
    final selectedIconSectionIndex = _selectedIconSectionIndex;
    final selectedTextPart = _selectedTextPart;
    setState(() {
      _exporting = true;
      _selectedIconSectionIndex = null;
      _selectedTextPart = null;
    });
    try {
      await Future<void>.delayed(const Duration(milliseconds: 50));
      final box =
          _boundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (box == null) throw StateError('Preview canvas is not ready');
      final image = await box.toImage(pixelRatio: 2.0);
      try {
        final result = await PreviewPngExporter.export(
          image: image,
          levelFileName: widget.fileName,
        );
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _t(
                'previewGenExportOk',
                'Saved preview to {path}',
              ).replaceAll('{path}', result.path),
            ),
          ),
        );
      } finally {
        image.dispose();
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${_t('previewGenExportFail', 'Export failed')}: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _exporting = false;
          _selectedIconSectionIndex = selectedIconSectionIndex;
          _selectedTextPart = selectedTextPart;
        });
      }
    }
  }

  void _onStrokeStarted(Offset n) {
    final doc = _document;
    if (doc == null) return;
    final id = _nextId('stroke');
    _pushHistory();
    setState(() {
      _activeStrokeId = id;
      doc.layers.add(
        PreviewLayer(
          id: id,
          kind: PreviewLayerKind.stroke,
          bounds: const Rect.fromLTWH(0, 0, 1, 1),
          zIndex: doc.layers.length + 20,
          strokeColor: _drawColor,
          strokeWidth: _drawStrokeWidth,
          points: [n],
        ),
      );
      _selectedLayerId = id;
      _selectedIconSectionIndex = null;
      _selectedTextPart = null;
    });
  }

  void _onStrokeUpdated(Offset n) {
    final doc = _document;
    final id = _activeStrokeId;
    if (doc == null || id == null) return;
    final layer = doc.layerById(id);
    if (layer == null) return;
    setState(() => layer.points.add(n));
  }

  void _onStrokeEnded() {
    _activeStrokeId = null;
  }

  void _onEraseAt(Offset n) {
    final doc = _document;
    if (doc == null) return;
    const radius = 0.025;
    var changed = false;
    if (_undoSnapshot == null) _pushHistory();
    setState(() {
      for (final layer in doc.layers) {
        if (layer.kind != PreviewLayerKind.stroke) continue;
        final before = layer.points.length;
        layer.points.removeWhere((p) => (p - n).distance <= radius);
        if (layer.points.length != before) changed = true;
      }
      doc.layers.removeWhere(
        (l) => l.kind == PreviewLayerKind.stroke && l.points.length < 2,
      );
    });
    if (!changed && _undoSnapshot != null) {
      // no-op erase — drop empty history push
    }
  }

  void _onShapeDraft(Rect bounds) {
    final doc = _document;
    if (doc == null) return;
    final kind = _figureKind;
    final filled = _figureFilled;
    setState(() {
      if (_draftShapeId == null) {
        _pushHistory();
        _draftShapeId = _nextId('shape');
        doc.layers.add(
          PreviewLayer(
            id: _draftShapeId!,
            kind: PreviewLayerKind.shape,
            shapeKind: kind,
            shapeFilled: filled,
            bounds: bounds,
            zIndex: doc.layers.length + 15,
            fillColor: filled ? _drawColor.withValues(alpha: 0.35) : null,
            strokeColor: _drawColor,
            strokeWidth: kind == PreviewShapeKind.rect && filled
                ? 0
                : _drawStrokeWidth,
            cornerRadius: kind == PreviewShapeKind.rect ? 10 : 0,
          ),
        );
        _selectedLayerId = _draftShapeId;
        _selectedIconSectionIndex = null;
        _selectedTextPart = null;
      } else {
        final layer = doc.layerById(_draftShapeId!);
        if (layer != null) {
          layer.bounds = bounds;
          layer.shapeKind = kind;
          layer.shapeFilled = filled;
          layer.fillColor = filled ? _drawColor.withValues(alpha: 0.35) : null;
          layer.strokeColor = _drawColor;
        }
      }
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;

    final key = event.logicalKey;
    if ((key == LogicalKeyboardKey.delete ||
            key == LogicalKeyboardKey.backspace) &&
        !HardwareKeyboard.instance.isControlPressed &&
        !HardwareKeyboard.instance.isMetaPressed &&
        !HardwareKeyboard.instance.isAltPressed) {
      if (_editingTextLayerId != null || _textFocusNode.hasFocus) {
        return KeyEventResult.ignored;
      }
      if (_selectedLayerId == null) return KeyEventResult.ignored;
      _deleteSelected();
      return KeyEventResult.handled;
    }

    final isCtrl =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (!isCtrl) return KeyEventResult.ignored;

    if (key == LogicalKeyboardKey.keyZ &&
        HardwareKeyboard.instance.isShiftPressed) {
      if (_redoSnapshot != null) {
        _redo();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.keyZ) {
      if (_undoSnapshot != null) {
        _undo();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    if (key == LogicalKeyboardKey.keyY) {
      if (_redoSnapshot != null) {
        _redo();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final availableWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width;
        final widthAvailable = isPreviewGeneratorWidthAvailable(availableWidth);
        final useMobilePrompt = useMobilePreviewGeneratorNarrowPrompt(
          platform: theme.platform,
        );

        return CallbackShortcuts(
          bindings: widthAvailable
              ? {
                  const SingleActivator(LogicalKeyboardKey.keyZ, control: true):
                      _undo,
                  const SingleActivator(LogicalKeyboardKey.keyZ, meta: true):
                      _undo,
                  const SingleActivator(
                    LogicalKeyboardKey.keyZ,
                    control: true,
                    shift: true,
                  ): _redo,
                  const SingleActivator(
                    LogicalKeyboardKey.keyZ,
                    meta: true,
                    shift: true,
                  ): _redo,
                  const SingleActivator(LogicalKeyboardKey.keyY, control: true):
                      _redo,
                  const SingleActivator(LogicalKeyboardKey.keyY, meta: true):
                      _redo,
                  if (_editingTextLayerId == null &&
                      !_textFocusNode.hasFocus) ...{
                    const SingleActivator(LogicalKeyboardKey.delete):
                        _deleteSelected,
                    const SingleActivator(LogicalKeyboardKey.backspace):
                        _deleteSelected,
                  },
                }
              : {},
          child: Focus(
            focusNode: _focusNode,
            autofocus: true,
            onKeyEvent: widthAvailable
                ? _onKey
                : (_, _) => KeyEventResult.ignored,
            child: Scaffold(
              appBar: AppBar(
                title: Text(_t('previewGenerator', 'Image Preview Generator')),
                actions: widthAvailable
                    ? [
                        IconButton(
                          tooltip: '${_t('previewGenUndo', 'Undo')} (Ctrl+Z)',
                          onPressed: (_canUndoText || _undoSnapshot != null)
                              ? _undo
                              : null,
                          icon: const Icon(Icons.undo),
                        ),
                        IconButton(
                          tooltip: '${_t('previewGenRedo', 'Redo')} (Ctrl+Y)',
                          onPressed: (_canRedoText || _redoSnapshot != null)
                              ? _redo
                              : null,
                          icon: const Icon(Icons.redo),
                        ),
                        IconButton(
                          tooltip: _t('previewGenExport', 'Export PNG'),
                          onPressed:
                              (_loading || _exporting || _document == null)
                              ? null
                              : _export,
                          icon: _exporting
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.save_alt),
                        ),
                      ]
                    : null,
              ),
              body: widthAvailable
                  ? _buildGeneratorBody(theme)
                  : _buildNarrowWidthNotice(
                      theme,
                      useMobilePrompt: useMobilePrompt,
                    ),
            ),
          ),
        );
      },
    );
  }

  void _finishEditingForTransform() {
    if (_editingTextLayerId != null || _textFocusNode.hasFocus) {
      _endTextEdit();
    }
  }

  Widget _buildGeneratorBody(ThemeData theme) {
    if (_loading) return const Center(child: CircularProgressIndicator());
    if (_error != null) return Center(child: Text(_error!));
    if (_document == null) return const SizedBox.shrink();

    return PreviewEditorWorkspace(
      toolbar: _buildManualToolbar(theme),
      canvasZoomLabel: _t('previewGenCanvasZoom'),
      fitCanvasLabel: _t('previewGenFitCanvas'),
      resizeToolbarLabel: _t('previewGenResizeToolbar'),
      zoomInLabel: _t('previewGenZoomIn'),
      zoomOutLabel: _t('previewGenZoomOut'),
      onToolbarResizeStarted: _endTextEdit,
      canvas: Padding(
        padding: const EdgeInsets.all(12),
        child: Center(
          child: PreviewCanvas(
            document: _document!,
            interactive: true,
            tool: _tool,
            selectedLayerId: _selectedLayerId,
            editingTextLayerId: _editingTextLayerId,
            selectedIconSectionIndex: _selectedIconSectionIndex,
            selectedTextPart: _selectedTextPart,
            drawColor: _drawColor,
            drawStrokeWidth: _drawStrokeWidth,
            boundaryKey: _boundaryKey,
            textEditingController: _textController,
            textFocusNode: _textFocusNode,
            onTextEdited: (_) => _ensureTextFocus(),
            onBeginTextEdit: _beginTextEdit,
            onEndTextEdit: _endTextEdit,
            onSelectLayer: (id) {
              final previousId = _selectedLayerId;
              if (id != previousId || id == null || _selectedTextPart != null) {
                _endTextEdit();
              }
              setState(() {
                _selectedLayerId = id;
                _selectedIconSectionIndex = null;
                _selectedTextPart = null;
                _draftShapeId = null;
                _syncTextController();
              });
            },
            onSelectIconSection: (layerId, index) {
              _endTextEdit();
              setState(() {
                _selectedLayerId = layerId;
                _selectedIconSectionIndex = index;
                _selectedTextPart = null;
                _draftShapeId = null;
                _syncTextController();
              });
            },
            onSelectTextPart: (selection) {
              _endTextEdit();
              setState(() {
                _selectedLayerId = selection.layerId;
                _selectedIconSectionIndex = null;
                _selectedTextPart = selection;
                _draftShapeId = null;
                _syncTextController();
              });
            },
            onIconSectionScaled: (layerId, index, iconSize) {
              final layer = _document?.layerById(layerId);
              if (layer == null) return;
              final sections = previewEffectiveSections(layer);
              if (index < 0 || index >= sections.length) return;
              if (_undoSnapshot == null) _pushHistory();
              setState(() {
                sections[index].iconSize = iconSize;
                _resizeIconGridToContent(layer);
              });
            },
            onLayerMoved: (id, bounds) {
              final layer = _document?.layerById(id);
              if (layer == null) return;
              _finishEditingForTransform();
              if (_undoSnapshot == null) _pushHistory();
              setState(() => layer.bounds = bounds);
            },
            onLayerScaled: (id, scale) {
              final layer = _document?.layerById(id);
              if (layer == null) return;
              _finishEditingForTransform();
              if (_undoSnapshot == null) _pushHistory();
              setState(() => layer.scale = scale);
            },
            onLayerRotated: (id, rotation) {
              final layer = _document?.layerById(id);
              if (layer == null) return;
              _finishEditingForTransform();
              if (_undoSnapshot == null) _pushHistory();
              setState(() => layer.rotation = rotation);
            },
            onStrokeStarted: _onStrokeStarted,
            onStrokeUpdated: _onStrokeUpdated,
            onStrokeEnded: () {
              setState(() {
                _onStrokeEnded();
                _draftShapeId = null;
              });
            },
            onEraseAt: _onEraseAt,
            onShapeDraft: _onShapeDraft,
          ),
        ),
      ),
    );
  }

  Widget _buildNarrowWidthNotice(
    ThemeData theme, {
    required bool useMobilePrompt,
  }) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                useMobilePrompt ? Icons.screen_rotation : Icons.aspect_ratio,
                size: 72,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 24),
              Text(
                _t('previewGenDisplayTooNarrowTitle'),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                _t(
                  useMobilePrompt
                      ? 'previewGenDisplayTooNarrowMobileHint'
                      : 'previewGenDisplayTooNarrowDesktopHint',
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildManualToolbar(ThemeData theme) {
    final selected = _selectedLayer();
    final textLayer = _selectedTextLayer();
    final iconGrid = _selectedIconGridLayer();
    final selectedIconSection = _selectedIconSection();
    final selectedText = _selectedTextValue();
    final activeTextStyle = _activeSelectedTextStyle();
    final selectedTextAlign = _selectedTextAlign();

    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final entry in [
                  (PreviewEditTool.select, Icons.near_me, 'Select'),
                  (PreviewEditTool.pen, Icons.edit, 'Draw'),
                  (PreviewEditTool.eraser, Icons.auto_fix_off, 'Eraser'),
                ])
                  ChoiceChip(
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(entry.$2, size: 18),
                        const SizedBox(width: 6),
                        Text(_t('previewTool_${entry.$1.name}', entry.$3)),
                      ],
                    ),
                    selected: _tool == entry.$1,
                    showCheckmark: false,
                    onSelected: (_) {
                      _endTextEdit();
                      setState(() {
                        _tool = entry.$1;
                        _draftShapeId = null;
                      });
                      if (_textFocusNode.hasFocus) {
                        _textFocusNode.unfocus();
                        _focusNode.requestFocus();
                      }
                    },
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    setState(() => _tool = PreviewEditTool.select);
                    _addTextLayer();
                    final id = _selectedLayerId;
                    if (id != null && _selectedTextLayer() != null) {
                      _beginTextEdit(id);
                    } else {
                      _textFocusNode.requestFocus();
                    }
                  },
                  icon: const Icon(Icons.text_fields),
                  label: Text(_t('previewGenAddText', 'Add text')),
                ),
                OutlinedButton.icon(
                  onPressed: _addOverlayImage,
                  icon: const Icon(Icons.add_photo_alternate_outlined),
                  label: Text(_t('previewGenAddImage', 'Add image')),
                ),
                OutlinedButton.icon(
                  onPressed: _openFiguresMenu,
                  style: _tool == PreviewEditTool.figures
                      ? OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.primary,
                          side: BorderSide(color: theme.colorScheme.primary),
                        )
                      : null,
                  icon: const Icon(Icons.category),
                  label: Text(_t('previewTool_figures', 'Figures')),
                ),
                OutlinedButton.icon(
                  onPressed: _pickBannerStem,
                  icon: const Icon(Icons.wallpaper),
                  label: Text(_t('previewGenChooseBanner', 'Choose banner')),
                ),
                OutlinedButton.icon(
                  onPressed: _addModuleInfoElement,
                  icon: const Icon(Icons.extension),
                  label: Text(_t('previewGenModuleInfo', 'Module info')),
                ),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _recreateFromAuto,
                  icon: const Icon(Icons.restart_alt),
                  label: Text(_t('previewGenRecreate', 'Recreate again')),
                ),
                Text('${_t('previewGenColor', 'Color')}:'),
                for (final c in _palette)
                  Listener(
                    onPointerDown: (_) => _snapshotTextSelectionForToolbar(),
                    child: GestureDetector(
                      onTap: () => _applyColor(c),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _drawColor == c
                                ? theme.colorScheme.primary
                                : Colors.grey,
                            width: _drawColor == c ? 2 : 1,
                          ),
                        ),
                      ),
                    ),
                  ),
                Listener(
                  onPointerDown: (_) => _snapshotTextSelectionForToolbar(),
                  child: IconButton(
                    tooltip: _t('previewGenCustomColor', 'Custom color'),
                    onPressed: _openColorPicker,
                    icon: Icon(Icons.colorize, color: _drawColor),
                  ),
                ),
                if (selected != null) ...[
                  if (selectedIconSection != null)
                    _labeledSlider(
                      label: _t('previewGenIconSize', 'Icon size'),
                      value: selectedIconSection.iconSize.clamp(20, 152),
                      min: 20,
                      max: 152,
                      divisions: 66,
                      valueLabel: selectedIconSection.iconSize
                          .round()
                          .toString(),
                      onChanged: (value) {
                        setState(() {
                          selectedIconSection.iconSize = value;
                          _resizeIconGridToContent(selected);
                        });
                      },
                    )
                  else if (selectedText == null &&
                      selected.kind != PreviewLayerKind.text &&
                      selected.kind != PreviewLayerKind.image)
                    _labeledSlider(
                      label: _t('previewGenScale', 'Scale'),
                      value: selected.scale.clamp(0.25, 4.0),
                      min: 0.25,
                      max: 4.0,
                      divisions: 75,
                      valueLabel: selected.scale.toStringAsFixed(2),
                      onChanged: (value) =>
                          setState(() => selected.scale = value),
                    ),
                  if (selectedText == null &&
                      selected.kind == PreviewLayerKind.shape) ...[
                    if (selected.shapeKind == PreviewShapeKind.rect)
                      _labeledSlider(
                        label: _t('previewGenCornerRadius', 'Corner radius'),
                        value: selected.cornerRadius.clamp(0, 40),
                        min: 0,
                        max: 40,
                        divisions: 20,
                        valueLabel: selected.cornerRadius.round().toString(),
                        onChanged: (value) =>
                            setState(() => selected.cornerRadius = value),
                      ),
                    FilterChip(
                      label: Text(_t('previewGenBorder', 'Border')),
                      selected: selected.strokeWidth > 0,
                      onSelected: (enabled) {
                        _pushHistory();
                        setState(
                          () => selected.strokeWidth = enabled
                              ? _drawStrokeWidth
                              : 0,
                        );
                      },
                    ),
                  ],
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_t('previewGenOpacity', 'Opacity')),
                      SizedBox(
                        width: 140,
                        child: Slider(
                          value: selected.opacity.clamp(0.0, 1.0),
                          min: 0,
                          max: 1,
                          divisions: 20,
                          label: selected.opacity.toStringAsFixed(2),
                          onChangeStart: (_) => _pushHistory(),
                          onChanged: (v) =>
                              setState(() => selected.opacity = v),
                        ),
                      ),
                    ],
                  ),
                  OutlinedButton.icon(
                    onPressed: _deleteSelected,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(
                      '${_t('previewGenDeleteElement', 'Delete element')} (Del)',
                    ),
                  ),
                ],
              ],
            ),
            if (selectedText != null && textLayer == null) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                focusNode: _textFocusNode,
                decoration: InputDecoration(
                  labelText: _t('previewGenTextContent', 'Text'),
                  isDense: true,
                ),
                onChanged: (value) {
                  if (_undoSnapshot == null) _pushHistory();
                  setState(() => _setSelectedText(value));
                },
              ),
            ],
            if (iconGrid != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(_t('previewGenIconAlign', 'Icon align')),
                  _alignToggle(
                    icon: Icons.format_align_left,
                    tooltip: _t('previewGenAlignLeft', 'Align left'),
                    align: TextAlign.left,
                    layer: iconGrid,
                    forIcons: true,
                  ),
                  _alignToggle(
                    icon: Icons.format_align_center,
                    tooltip: _t('previewGenAlignCenter', 'Align center'),
                    align: TextAlign.center,
                    layer: iconGrid,
                    forIcons: true,
                  ),
                  _alignToggle(
                    icon: Icons.format_align_right,
                    tooltip: _t('previewGenAlignRight', 'Align right'),
                    align: TextAlign.right,
                    layer: iconGrid,
                    forIcons: true,
                  ),
                  _alignToggle(
                    icon: Icons.format_align_justify,
                    tooltip: _t('previewGenAlignJustify', 'Justify'),
                    align: TextAlign.justify,
                    layer: iconGrid,
                    forIcons: true,
                  ),
                ],
              ),
            ],
            if (textLayer != null) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(_t('previewGenTextBg', 'Text background')),
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      color:
                          textLayer.textBackgroundColor ?? Colors.transparent,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                  OutlinedButton(
                    onPressed: () async {
                      final chosen = await showDialog<Color>(
                        context: context,
                        builder: (ctx) {
                          var pending =
                              textLayer.textBackgroundColor ?? _drawColor;
                          return AlertDialog(
                            title: Text(
                              _t('previewGenTextBg', 'Text background'),
                            ),
                            content: SingleChildScrollView(
                              child: ColorPicker(
                                pickerColor: pending,
                                onColorChanged: (c) => pending = c,
                                enableAlpha: true,
                                hexInputBar: true,
                                labelTypes: const [],
                              ),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx),
                                child: Text(_t('previewGenCancel', 'Cancel')),
                              ),
                              FilledButton(
                                onPressed: () => Navigator.pop(ctx, pending),
                                child: Text(_t('previewGenApply', 'Apply')),
                              ),
                            ],
                          );
                        },
                      );
                      if (chosen == null) return;
                      _pushHistory();
                      setState(() => textLayer.textBackgroundColor = chosen);
                    },
                    child: Text(_t('previewGenTextBgPick', 'Pick')),
                  ),
                  OutlinedButton(
                    onPressed: () {
                      _pushHistory();
                      setState(() => textLayer.textBackgroundColor = null);
                    },
                    child: Text(_t('previewGenTextBgClear', 'Clear')),
                  ),
                  Text(
                    _t(
                      'previewGenTextStyleHint',
                      'Select text to style only that part',
                    ),
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            if (activeTextStyle != null && selectedTextAlign != null) ...[
              const SizedBox(height: 8),
              Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (_) => _snapshotTextSelectionForToolbar(),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    DropdownButton<String?>(
                      value: activeTextStyle.fontFamily,
                      hint: Text(_t('previewGenFont', 'Font')),
                      items: [
                        for (final c in PreviewFonts.choices)
                          DropdownMenuItem(
                            value: c.family,
                            child: Text(c.label),
                          ),
                      ],
                      onChanged: (v) {
                        _runTextToolbarAction(() {
                          _pushHistory();
                          setState(() {
                            _mutateActiveTextStyle((s) => s.fontFamily = v);
                          });
                        });
                      },
                    ),
                    DropdownButton<double>(
                      value: _snapFontSize(activeTextStyle.fontSize),
                      items: [
                        for (final size in _fontSizeChoices)
                          DropdownMenuItem(
                            value: size,
                            child: Text('${size.toInt()}'),
                          ),
                      ],
                      onChanged: (v) {
                        if (v == null) return;
                        _runTextToolbarAction(() {
                          _pushHistory();
                          setState(() {
                            _mutateActiveTextStyle((s) => s.fontSize = v);
                          });
                        });
                      },
                    ),
                    _styleToggle(
                      label: 'B',
                      tooltip:
                          activeTextStyle.fontFamily == PreviewFonts.familyPvZ
                          ? _t(
                              'previewGenBoldPvZ',
                              'Bold (simulated — PvZ font has one weight)',
                            )
                          : _t('previewGenBold', 'Bold'),
                      selected: activeTextStyle.fontWeight == FontWeight.bold,
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                      ),
                      onTap: () {
                        _runTextToolbarAction(() {
                          _pushHistory();
                          setState(() {
                            final on =
                                activeTextStyle.fontWeight != FontWeight.bold;
                            _mutateActiveTextStyle(
                              (s) => s.fontWeight = on
                                  ? FontWeight.bold
                                  : FontWeight.w400,
                            );
                          });
                        });
                      },
                    ),
                    _styleToggle(
                      label: 'I',
                      tooltip: _t('previewGenItalic', 'Italic'),
                      selected: activeTextStyle.italic,
                      style: const TextStyle(
                        fontStyle: FontStyle.italic,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: () {
                        _runTextToolbarAction(() {
                          _pushHistory();
                          setState(() {
                            _mutateActiveTextStyle((s) => s.italic = !s.italic);
                          });
                        });
                      },
                    ),
                    _styleToggle(
                      label: 'U',
                      tooltip: _t('previewGenUnderline', 'Underline'),
                      selected: activeTextStyle.underline,
                      style: const TextStyle(
                        decoration: TextDecoration.underline,
                        decorationThickness: 2.5,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      onTap: () {
                        _runTextToolbarAction(() {
                          _pushHistory();
                          setState(() {
                            _mutateActiveTextStyle(
                              (s) => s.underline = !s.underline,
                            );
                          });
                        });
                      },
                    ),
                    _styleToggle(
                      label: 'O',
                      tooltip: _t('previewGenOutline', 'Outline'),
                      selected: activeTextStyle.outline,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                      onTap: () {
                        _runTextToolbarAction(() {
                          _pushHistory();
                          setState(() {
                            _mutateActiveTextStyle(
                              (s) => s.outline = !s.outline,
                            );
                          });
                        });
                      },
                    ),
                    const SizedBox(width: 4),
                    _alignToggle(
                      icon: Icons.format_align_left,
                      tooltip: _t('previewGenAlignLeft', 'Align left'),
                      align: TextAlign.left,
                      currentAlign: selectedTextAlign,
                    ),
                    _alignToggle(
                      icon: Icons.format_align_center,
                      tooltip: _t('previewGenAlignCenter', 'Align center'),
                      align: TextAlign.center,
                      currentAlign: selectedTextAlign,
                    ),
                    _alignToggle(
                      icon: Icons.format_align_right,
                      tooltip: _t('previewGenAlignRight', 'Align right'),
                      align: TextAlign.right,
                      currentAlign: selectedTextAlign,
                    ),
                    _alignToggle(
                      icon: Icons.format_align_justify,
                      tooltip: _t('previewGenAlignJustify', 'Justify'),
                      align: TextAlign.justify,
                      currentAlign: selectedTextAlign,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// One undo step for in-place text editing (plain + runs + caret).
class _TextEditCheckpoint {
  _TextEditCheckpoint({
    required this.plain,
    required this.runs,
    required this.textStyle,
    required this.selection,
  });

  final String plain;
  final List<PreviewTextRun> runs;
  final PreviewTextStyleData? textStyle;
  final TextSelection selection;

  factory _TextEditCheckpoint.capture(
    PreviewLayer layer,
    TextSelection selection,
  ) {
    layer.ensureTextRuns();
    return _TextEditCheckpoint(
      plain: layer.plainText,
      runs: [for (final r in layer.textRuns) r.copy()],
      textStyle: layer.textStyle?.copy(),
      selection: selection,
    );
  }

  void applyTo(PreviewLayer layer) {
    layer.textRuns = [for (final r in runs) r.copy()];
    layer.text = plain;
    layer.textStyle = textStyle?.copy();
  }
}
