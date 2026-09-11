import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_auto_composer.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_canvas.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_document.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_feature_groups.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_fonts.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/preview_png_exporter.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/stage_banner_resolver.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';

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
                recreate
                    ? 'previewGenRecreateFromNormal'
                    : 'previewGenNormal',
                recreate ? 'From normal' : 'Normal',
              ),
            ),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, PreviewAutoStyle.simple),
            child: Text(
              t(
                recreate
                    ? 'previewGenRecreateFromSimple'
                    : 'previewGenSimple',
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
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  PreviewDocument? _document;
  StageBannerResolver? _banners;
  late PreviewAutoStyle _autoStyle = widget.initialStyle;
  PreviewEditTool _tool = PreviewEditTool.select;
  String? _selectedLayerId;
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

  String _t(String key, [String? fallback]) =>
      widget.host.localize(context, key, fallback ?? key);

  @override
  void initState() {
    super.initState();
    _compose();
  }

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _nextId(String prefix) => '${prefix}_${_idSeq++}';

  void _clearHistory() {
    _undoSnapshot = null;
    _redoSnapshot = null;
  }

  void _pushHistory() {
    final doc = _document;
    if (doc == null) return;
    _undoSnapshot = doc.copy();
    _redoSnapshot = null;
  }

  void _undo() {
    final doc = _document;
    final past = _undoSnapshot;
    if (doc == null || past == null) return;
    setState(() {
      _redoSnapshot = doc.copy();
      _document = past;
      _undoSnapshot = null;
      _selectedLayerId = null;
      _activeStrokeId = null;
      _draftShapeId = null;
      _syncTextController();
    });
  }

  void _redo() {
    final doc = _document;
    final future = _redoSnapshot;
    if (doc == null || future == null) return;
    setState(() {
      _undoSnapshot = doc.copy();
      _document = future;
      _redoSnapshot = null;
      _selectedLayerId = null;
      _activeStrokeId = null;
      _draftShapeId = null;
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
    final next = layer?.plainText ?? '';
    if (_textController.text != next) {
      _textController.value = TextEditingValue(
        text: next,
        selection: TextSelection.collapsed(offset: next.length),
      );
    }
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
    layer.ensureTextRuns();
    final sel = _textController.selection;
    if (sel.isValid && !sel.isCollapsed) {
      final runs = layer.effectiveTextRuns();
      var cursor = 0;
      for (final run in runs) {
        final end = cursor + run.text.length;
        if (sel.start < end && sel.end > cursor) {
          return run.style;
        }
        cursor = end;
      }
    }
    return layer.textStyle ??
        (layer.textRuns.isNotEmpty
            ? layer.textRuns.first.style
            : PreviewTextStyleData());
  }

  void _mutateSelectedTextStyle(
    PreviewLayer layer,
    void Function(PreviewTextStyleData style) mutate,
  ) {
    layer.ensureTextRuns();
    final sel = _textController.selection;
    if (sel.isValid && !sel.isCollapsed) {
      layer.applyStyleToRange(sel.start, sel.end, mutate);
    } else {
      layer.applyStyleToRange(0, layer.plainText.length, mutate);
    }
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
    required PreviewLayer layer,
  }) {
    return _toolbarToggleShell(
      tooltip: tooltip,
      selected: layer.textAlign == align,
      onTap: () {
        _pushHistory();
        setState(() => layer.textAlign = align);
      },
      child: Icon(icon, size: 18),
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

  void _applyColor(Color c) {
    _pushHistory();
    setState(() {
      _drawColor = c;
      final layer = _selectedLayer();
      if (layer == null) return;
      if (layer.kind == PreviewLayerKind.text) {
        _mutateSelectedTextStyle(layer, (s) => s.color = c);
      } else if (layer.kind == PreviewLayerKind.shape ||
          layer.kind == PreviewLayerKind.stroke) {
        layer.strokeColor = c;
        if (layer.kind == PreviewLayerKind.shape) {
          layer.fillColor = c.withValues(alpha: 0.25);
        }
      }
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
    final banners = _banners;
    final doc = _document;
    if (banners == null || doc == null) return;
    final chosen = await showDialog<String>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: Text(_t('previewGenChooseBanner', 'Choose banner')),
        children: [
          for (final stem in banners.allStems)
            SimpleDialogOption(
              onPressed: () => Navigator.pop(ctx, stem),
              child: Text(stem),
            ),
        ],
      ),
    );
    if (chosen == null || !mounted) return;
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
    final doc = _document;
    if (doc == null) return;
    final result = await FilePicker.pickFiles(
      type: FileType.image,
      withData: false,
    );
    final path = result?.files.single.path;
    if (path == null || path.isEmpty) return;
    final id = _nextId('image');
    _pushHistory();
    setState(() {
      doc.layers.add(
        PreviewLayer(
          id: id,
          kind: PreviewLayerKind.image,
          bounds: const Rect.fromLTWH(0.35, 0.25, 0.30, 0.40),
          zIndex: doc.layers.length + 10,
          imagePath: path,
        ),
      );
      _selectedLayerId = id;
      _tool = PreviewEditTool.select;
    });
  }

  void _addTextLayer() {
    final doc = _document;
    if (doc == null) return;
    final id = _nextId('text');
    _pushHistory();
    setState(() {
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
      _tool = PreviewEditTool.select;
      _syncTextController();
    });
  }

  void _deleteSelected() {
    final doc = _document;
    final id = _selectedLayerId;
    if (doc == null || id == null) return;
    _pushHistory();
    setState(() {
      doc.layers.removeWhere((l) => l.id == id);
      _selectedLayerId = null;
      _textController.clear();
    });
  }

  Future<void> _export() async {
    setState(() => _exporting = true);
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
              _t('previewGenExportOk', 'Saved preview to {path}')
                  .replaceAll('{path}', result.path),
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
      if (mounted) setState(() => _exporting = false);
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

  void _onShapeDraft(Rect bounds) {
    final doc = _document;
    if (doc == null) return;
    final kind = _tool == PreviewEditTool.oval
        ? PreviewShapeKind.oval
        : PreviewShapeKind.rect;
    setState(() {
      if (_draftShapeId == null) {
        _pushHistory();
        _draftShapeId = _nextId('shape');
        doc.layers.add(
          PreviewLayer(
            id: _draftShapeId!,
            kind: PreviewLayerKind.shape,
            shapeKind: kind,
            bounds: bounds,
            zIndex: doc.layers.length + 15,
            fillColor: _drawColor.withValues(alpha: 0.25),
            strokeColor: _drawColor,
            strokeWidth: _drawStrokeWidth,
          ),
        );
        _selectedLayerId = _draftShapeId;
      } else {
        final layer = doc.layerById(_draftShapeId!);
        if (layer != null) {
          layer.bounds = bounds;
          layer.shapeKind = kind;
        }
      }
    });
  }

  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final isCtrl =
        HardwareKeyboard.instance.isControlPressed ||
        HardwareKeyboard.instance.isMetaPressed;
    if (!isCtrl) return KeyEventResult.ignored;

    final key = event.logicalKey;
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
    return Focus(
      focusNode: _focusNode,
      autofocus: true,
      onKeyEvent: _onKey,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_t('previewGenerator', 'Image Preview Generator')),
          actions: [
            IconButton(
              tooltip: '${_t('previewGenUndo', 'Undo')} (Ctrl+Z)',
              onPressed: _undoSnapshot == null ? null : _undo,
              icon: const Icon(Icons.undo),
            ),
            IconButton(
              tooltip: '${_t('previewGenRedo', 'Redo')} (Ctrl+Y)',
              onPressed: _redoSnapshot == null ? null : _redo,
              icon: const Icon(Icons.redo),
            ),
            IconButton(
              tooltip: _t('previewGenExport', 'Export PNG'),
              onPressed: (_loading || _exporting || _document == null)
                  ? null
                  : _export,
              icon: _exporting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_alt),
            ),
          ],
        ),
        body: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
            ? Center(child: Text(_error!))
            : _document == null
            ? const SizedBox.shrink()
            : Column(
                children: [
                  _buildManualToolbar(theme),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Center(
                        child: PreviewCanvas(
                          document: _document!,
                          interactive: true,
                          tool: _tool,
                          selectedLayerId: _selectedLayerId,
                          drawColor: _drawColor,
                          drawStrokeWidth: _drawStrokeWidth,
                          boundaryKey: _boundaryKey,
                          onSelectLayer: (id) {
                            setState(() {
                              _selectedLayerId = id;
                              _draftShapeId = null;
                              _syncTextController();
                            });
                          },
                          onLayerMoved: (id, bounds) {
                            final layer = _document?.layerById(id);
                            if (layer == null) return;
                            if (_undoSnapshot == null) _pushHistory();
                            setState(() => layer.bounds = bounds);
                          },
                          onLayerScaled: (id, scale) {
                            final layer = _document?.layerById(id);
                            if (layer == null) return;
                            if (_undoSnapshot == null) _pushHistory();
                            setState(() => layer.scale = scale);
                          },
                          onLayerRotated: (id, rotation) {
                            final layer = _document?.layerById(id);
                            if (layer == null) return;
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
                          onShapeDraft: (bounds) {
                            _onShapeDraft(bounds);
                          },
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildManualToolbar(ThemeData theme) {
    final selected = _selectedLayer();
    final textLayer = _selectedTextLayer();

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
      child: SingleChildScrollView(
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
                  (PreviewEditTool.text, Icons.text_fields, 'Text'),
                  (PreviewEditTool.image, Icons.add_photo_alternate, 'Image'),
                  (PreviewEditTool.pen, Icons.edit, 'Draw'),
                  (PreviewEditTool.rect, Icons.crop_square, 'Rect'),
                  (PreviewEditTool.oval, Icons.circle_outlined, 'Oval'),
                ])
                  ChoiceChip(
                    label: Text(_t('previewTool_${entry.$1.name}', entry.$3)),
                    selected: _tool == entry.$1,
                    avatar: Icon(entry.$2, size: 18),
                    onSelected: (_) {
                      setState(() {
                        _tool = entry.$1;
                        _draftShapeId = null;
                        if (_tool == PreviewEditTool.text) {
                          _addTextLayer();
                        } else if (_tool == PreviewEditTool.image) {
                          _addOverlayImage();
                        }
                      });
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
                  onPressed: _pickBannerStem,
                  icon: const Icon(Icons.wallpaper),
                  label: Text(_t('previewGenChooseBanner', 'Choose banner')),
                ),
                OutlinedButton.icon(
                  onPressed: _pickCustomBanner,
                  icon: const Icon(Icons.folder_open),
                  label: Text(_t('previewGenCustomBanner', 'Custom image')),
                ),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _recreateFromAuto,
                  icon: const Icon(Icons.restart_alt),
                  label: Text(_t('previewGenRecreate', 'Recreate again')),
                ),
                Text('${_t('previewGenColor', 'Color')}:'),
                for (final c in _palette)
                  GestureDetector(
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
                IconButton(
                  tooltip: _t('previewGenCustomColor', 'Custom color'),
                  onPressed: _openColorPicker,
                  icon: Icon(Icons.colorize, color: _drawColor),
                ),
                if (selected != null) ...[
                  if (selected.kind != PreviewLayerKind.text) ...[
                    Text(_t('previewGenScale', 'Scale')),
                    SizedBox(
                      width: 160,
                      child: Slider(
                        value: selected.scale.clamp(0.25, 4.0),
                        min: 0.25,
                        max: 4.0,
                        divisions: 75,
                        label: selected.scale.toStringAsFixed(2),
                        onChangeStart: (_) => _pushHistory(),
                        onChanged: (v) => setState(() => selected.scale = v),
                      ),
                    ),
                  ],
                  OutlinedButton.icon(
                    onPressed: _deleteSelected,
                    icon: const Icon(Icons.delete_outline),
                    label: Text(
                      _t('previewGenDeleteElement', 'Delete element'),
                    ),
                  ),
                ],
              ],
            ),
            if (textLayer != null) ...[
              const SizedBox(height: 8),
              TextField(
                controller: _textController,
                decoration: InputDecoration(
                  labelText: _t('previewGenTextContent', 'Text'),
                  isDense: true,
                  helperText: _t(
                    'previewGenTextStyleHint',
                    'Select text to style only that part',
                  ),
                ),
                onChanged: (v) {
                  if (_undoSnapshot == null) _pushHistory();
                  setState(() => textLayer.setPlainText(v));
                },
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  DropdownButton<String?>(
                    value: _activeTextStyle(textLayer).fontFamily,
                    hint: Text(_t('previewGenFont', 'Font')),
                    items: [
                      for (final c in PreviewFonts.choices)
                        DropdownMenuItem(
                          value: c.family,
                          child: Text(c.label),
                        ),
                    ],
                    onChanged: (v) {
                      _pushHistory();
                      setState(() {
                        _mutateSelectedTextStyle(
                          textLayer,
                          (s) => s.fontFamily = v,
                        );
                      });
                    },
                  ),
                  DropdownButton<double>(
                    value: _snapFontSize(_activeTextStyle(textLayer).fontSize),
                    items: [
                      for (final size in _fontSizeChoices)
                        DropdownMenuItem(
                          value: size,
                          child: Text('${size.toInt()}'),
                        ),
                    ],
                    onChanged: (v) {
                      if (v == null) return;
                      _pushHistory();
                      setState(() {
                        _mutateSelectedTextStyle(
                          textLayer,
                          (s) => s.fontSize = v,
                        );
                      });
                    },
                  ),
                  _styleToggle(
                    label: 'B',
                    tooltip: _t('previewGenBold', 'Bold'),
                    selected:
                        _activeTextStyle(textLayer).fontWeight ==
                        FontWeight.bold,
                    style: const TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                    onTap: () {
                      _pushHistory();
                      setState(() {
                        final on =
                            _activeTextStyle(textLayer).fontWeight !=
                            FontWeight.bold;
                        _mutateSelectedTextStyle(
                          textLayer,
                          (s) => s.fontWeight = on
                              ? FontWeight.bold
                              : FontWeight.w400,
                        );
                      });
                    },
                  ),
                  _styleToggle(
                    label: 'I',
                    tooltip: _t('previewGenItalic', 'Italic'),
                    selected: _activeTextStyle(textLayer).italic,
                    style: const TextStyle(
                      fontStyle: FontStyle.italic,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    onTap: () {
                      _pushHistory();
                      setState(() {
                        _mutateSelectedTextStyle(
                          textLayer,
                          (s) => s.italic = !s.italic,
                        );
                      });
                    },
                  ),
                  _styleToggle(
                    label: 'U',
                    tooltip: _t('previewGenUnderline', 'Underline'),
                    selected: _activeTextStyle(textLayer).underline,
                    style: const TextStyle(
                      decoration: TextDecoration.underline,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                    onTap: () {
                      _pushHistory();
                      setState(() {
                        _mutateSelectedTextStyle(
                          textLayer,
                          (s) => s.underline = !s.underline,
                        );
                      });
                    },
                  ),
                  _styleToggle(
                    label: 'O',
                    tooltip: _t('previewGenOutline', 'Outline'),
                    selected: _activeTextStyle(textLayer).outline,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                    onTap: () {
                      _pushHistory();
                      setState(() {
                        _mutateSelectedTextStyle(
                          textLayer,
                          (s) => s.outline = !s.outline,
                        );
                      });
                    },
                  ),
                  const SizedBox(width: 4),
                  _alignToggle(
                    icon: Icons.format_align_left,
                    tooltip: _t('previewGenAlignLeft', 'Align left'),
                    align: TextAlign.left,
                    layer: textLayer,
                  ),
                  _alignToggle(
                    icon: Icons.format_align_center,
                    tooltip: _t('previewGenAlignCenter', 'Align center'),
                    align: TextAlign.center,
                    layer: textLayer,
                  ),
                  _alignToggle(
                    icon: Icons.format_align_right,
                    tooltip: _t('previewGenAlignRight', 'Align right'),
                    align: TextAlign.right,
                    layer: textLayer,
                  ),
                  _alignToggle(
                    icon: Icons.format_align_justify,
                    tooltip: _t('previewGenAlignJustify', 'Justify'),
                    align: TextAlign.justify,
                    layer: textLayer,
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
