import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:z_editor/data/repository/level_repository.dart';
import 'package:z_editor/data/pvz_models.dart';
import 'package:z_editor/data/rtid_parser.dart';
import 'package:z_editor/l10n/app_localizations.dart';
import 'package:z_editor/escape_override.dart';
import 'package:z_editor/theme/app_theme.dart';

const _fontSizeKey = 'json_viewer_font_size';

class _EscapeIntent extends Intent {
  const _EscapeIntent();
}

/// Cached font size for immediate apply on screen enter (before async load).
double? _cachedFontSize;

enum _JsonViewMode { rawText, structured }

/// JSON code viewer. Ported from Z-Editor-master JsonCodeViewerScreen.kt
/// Includes font size slider, edit/save, and scrollbar.
class JsonViewerScreen extends StatefulWidget {
  const JsonViewerScreen({
    super.key,
    required this.fileName,
    required this.filePath,
    required this.levelFile,
    required this.onBack,
    this.onSaved,
  });

  final String fileName;
  final String filePath;
  final PvzLevelFile levelFile;
  final VoidCallback onBack;
  final VoidCallback? onSaved;

  @override
  State<JsonViewerScreen> createState() => _JsonViewerScreenState();
}

class _JsonViewerScreenState extends State<JsonViewerScreen> {
  double _fontSize = _cachedFontSize ?? 12;
  final _verticalController = ScrollController();
  bool _isEditing = false;
  final _editController = TextEditingController();
  String? _syntaxError;
  _JsonViewMode _viewMode = _JsonViewMode.rawText;
  final Map<int, bool> _expandedStates = {};

  @override
  void initState() {
    super.initState();
    _loadFontSize();
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_fontSizeKey);
    if (saved != null && mounted) {
      final isDesktop = Theme.of(context).platform == TargetPlatform.windows ||
          Theme.of(context).platform == TargetPlatform.macOS ||
          Theme.of(context).platform == TargetPlatform.linux;
      final min = isDesktop ? 12.0 : 6.0;
      final max = isDesktop ? 24.0 : 18.0;
      final value = saved.clamp(min, max);
      _cachedFontSize = value;
      setState(() => _fontSize = value);
    }
  }

  Future<void> _saveFontSize(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, value);
  }

  @override
  void dispose() {
    EscapeOverride.tryHandle = null;
    _verticalController.dispose();
    _editController.dispose();
    super.dispose();
  }

  void _startEdit() {
    final pretty =
        const JsonEncoder.withIndent('  ').convert(widget.levelFile.toJson());
    _editController.text = pretty;
    setState(() {
      _isEditing = true;
      _syntaxError = null;
    });
    EscapeOverride.tryHandle = () {
      if (_isEditing) {
        _cancelEdit();
        return true;
      }
      return false;
    };
  }

  void _cancelEdit() {
    EscapeOverride.tryHandle = null;
    setState(() {
      _isEditing = false;
      _syntaxError = null;
    });
  }

  Future<void> _saveEdit() async {
    try {
      final json = jsonDecode(_editController.text) as Map<String, dynamic>;
      final newLevel = PvzLevelFile.fromJson(json);
      widget.levelFile.objects.clear();
      widget.levelFile.objects.addAll(newLevel.objects);
      await LevelRepository.saveAndExport(widget.filePath, widget.levelFile);
      if (mounted) {
        EscapeOverride.tryHandle = null;
        setState(() {
          _isEditing = false;
          _syntaxError = null;
        });
        widget.onSaved?.call();
        final l10n = AppLocalizations.of(context);
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isDark ? pvzGreenDark : pvzGreenLight,
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.saved ?? 'Saved',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _syntaxError = 'JSON error: $e');
        final l10n = AppLocalizations.of(context);
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isDark ? snackbarFailedDark : snackbarFailedLight,
            content: Row(
              children: [
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () =>
                        ScaffoldMessenger.of(context).hideCurrentSnackBar(),
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 28,
                      height: 28,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.black87, size: 18),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n?.saveFail ?? 'Save failed',
                    style: const TextStyle(color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDesktop = Theme.of(context).platform == TargetPlatform.windows ||
        Theme.of(context).platform == TargetPlatform.macOS ||
        Theme.of(context).platform == TargetPlatform.linux;
    final pretty = _isEditing
        ? ''
        : const JsonEncoder.withIndent('  ').convert(widget.levelFile.toJson());

    Widget child = PopScope(
      canPop: !_isEditing,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isEditing) {
          _cancelEdit();
        } else {
          widget.onBack();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          leading: IconButton(
            icon: Icon(_isEditing ? Icons.close : Icons.arrow_back),
            tooltip: _isEditing
                ? (l10n?.tooltipClose ?? 'Close')
                : (l10n?.back ?? 'Back'),
            onPressed: () {
              if (_isEditing) {
                _cancelEdit();
              } else {
                widget.onBack();
              }
            },
          ),
        title: Text(
          _isEditing
              ? '${widget.fileName} ${l10n?.jsonViewerModeEdit ?? '(edit mode)'}'
              : _viewMode == _JsonViewMode.structured
                  ? '${widget.fileName} ${l10n?.jsonViewerModeObjectReading ?? '(object reading mode)'}'
                  : '${widget.fileName} ${l10n?.jsonViewerModeReading ?? '(reading mode)'}',
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.save),
              tooltip: l10n?.tooltipSave ?? 'Save',
              onPressed: _saveEdit,
            )
          else ...[
            IconButton(
              icon: Icon(
                _viewMode == _JsonViewMode.structured
                    ? Icons.list
                    : Icons.data_object,
              ),
              tooltip: l10n?.tooltipToggleObjectView ?? 'Toggle object/raw view',
              onPressed: () {
                setState(() {
                  _viewMode = _viewMode == _JsonViewMode.rawText
                      ? _JsonViewMode.structured
                      : _JsonViewMode.rawText;
                });
              },
            ),
            IconButton(
              icon: const Icon(Icons.cleaning_services),
              tooltip: l10n?.tooltipClearUnused ?? 'Clear unused objects',
              onPressed: _showClearUnusedDialog,
            ),
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: l10n?.tooltipEdit ?? 'Edit',
              onPressed: _startEdit,
            ),
          ],
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            margin: EdgeInsets.zero,
            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.format_size,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  SizedBox(
                    width: 28,
                    child: Text(
                      '${_fontSize.round()}',
                      style: Theme.of(context).textTheme.bodyMedium,
                      textAlign: TextAlign.right,
                    ),
                  ),
                  Expanded(
                    child: Slider(
                      value: _fontSize.clamp(
                        isDesktop ? 12.0 : 6.0,
                        isDesktop ? 24.0 : 18.0,
                      ),
                      min: isDesktop ? 12 : 6,
                      max: isDesktop ? 24 : 18,
                      onChanged: (v) {
                        _cachedFontSize = v;
                        setState(() => _fontSize = v);
                        _saveFontSize(v);
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_syntaxError != null)
            Container(
              width: double.infinity,
              color: Theme.of(context).colorScheme.error,
              padding: const EdgeInsets.all(8),
              child: Text(
                _syntaxError!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onError,
                  fontSize: 12,
                ),
              ),
            ),
          Expanded(
            child: _isEditing
                ? _buildEditView()
                : _viewMode == _JsonViewMode.structured
                    ? _buildObjectMode(isDesktop, l10n)
                    : _buildViewMode(pretty, isDesktop, l10n),
          ),
        ],
      ),
    ),
    );

    if (isDesktop) {
      child = Shortcuts(
        shortcuts: const {
          SingleActivator(LogicalKeyboardKey.escape): _EscapeIntent(),
        },
        child: Actions(
          actions: {
            _EscapeIntent: CallbackAction<_EscapeIntent>(
              onInvoke: (_) {
                if (_isEditing) {
                  _cancelEdit();
                  return null;
                }
                widget.onBack();
                return null;
              },
            ),
          },
          child: child,
        ),
      );
    }
    return child;
  }

  static const _codeFontFamily = 'monospace';

  Widget _buildEditView() {
    final baseStyle = TextStyle(
      fontFamily: _codeFontFamily,
      fontSize: _fontSize,
      height: 1.3,
    );
    return Scrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      trackVisibility: true,
      child: SingleChildScrollView(
        controller: _verticalController,
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLineNumbersColumn(_editController.text, baseStyle),
            const SizedBox(width: 16),
            Expanded(
              child: TextField(
                controller: _editController,
                maxLines: null,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontFamily: _codeFontFamily,
                      fontSize: _fontSize,
                      height: 1.3,
                    ),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (_) => setState(() {}),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineNumbersColumn(String text, TextStyle baseStyle) {
    final lines = text.split('\n');
    final lineCount = lines.isEmpty ? 1 : lines.length;
    final digitCount = '$lineCount'.length;
    final width = _fontSize * (digitCount * 0.6 + 1.5);
    return SizedBox(
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          lineCount,
          (i) => Text(
            '${i + 1}',
            style: baseStyle.copyWith(
              fontFamily: _codeFontFamily,
              color: Theme.of(context).colorScheme.onSurface.withValues(
                    alpha: 0.5,
                  ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewMode(String pretty, bool isDesktop, AppLocalizations? l10n) {
    return SelectionArea(
      child: _buildScrollLayout(pretty, isDesktop, l10n),
    );
  }

  Widget _buildObjectMode(bool isDesktop, AppLocalizations? l10n) {
    final objects = widget.levelFile.objects;
    return Scrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      trackVisibility: isDesktop,
      child: ListView.builder(
        controller: _verticalController,
        padding: const EdgeInsets.all(16),
        itemCount: objects.length,
        itemBuilder: (context, index) {
          return _ObjectCodeCard(
            index: index,
            obj: objects[index],
            fontSize: _fontSize,
            expanded: _expandedStates[index] ?? true,
            onToggle: () {
              setState(() {
                _expandedStates[index] = !(_expandedStates[index] ?? false);
              });
            },
            onDelete: () => _deleteObjectAtIndex(index),
            deleteTooltip: l10n?.delete ?? 'Delete',
          );
        },
      ),
    );
  }

  /// Collects all aliases referenced via RTID in the level file.
  Set<String> _collectReferencedAliases() {
    final used = <String>{};
    void scan(dynamic value) {
      if (value is Map) {
        for (final entry in value.entries) {
          if (entry.value is String) {
            final rtid = entry.value as String;
            final info = RtidParser.parse(rtid);
            if (info != null) used.add(info.alias);
          } else {
            scan(entry.value);
          }
        }
      } else if (value is List) {
        for (final item in value) {
          if (item is String) {
            final info = RtidParser.parse(item);
            if (info != null) used.add(info.alias);
          } else {
            scan(item);
          }
        }
      }
    }
    for (final obj in widget.levelFile.objects) {
      if (obj.objData != null) scan(obj.objData);
    }
    return used;
  }

  void _showClearUnusedDialog() async {
    final used = _collectReferencedAliases();
    final toRemove = <PvzObject>[];
    for (final obj in widget.levelFile.objects) {
      if (obj.objClass == 'LevelDefinition') continue;
      final aliases = obj.aliases ?? [];
      final isUsed = aliases.any((a) => used.contains(a));
      if (!isUsed) toRemove.add(obj);
    }
    if (toRemove.isEmpty) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isDark ? pvzGreenDark : pvzGreenLight,
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n?.clearUnusedNone ?? 'No unused objects found.',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }
      return;
    }
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.clearUnusedTitle ?? 'Clear unused objects?'),
        content: Text(
          l10n?.clearUnusedMessage ??
              'This will permanently delete all unused objects from the level file, including custom zombies, their properties, and any other unreferenced data. This action cannot be undone. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      for (final obj in toRemove) {
        widget.levelFile.objects.remove(obj);
      }
      await LevelRepository.saveAndExport(widget.filePath, widget.levelFile);
      widget.onSaved?.call();
      setState(() {});
      if (mounted) {
        final theme = Theme.of(context);
        final isDark = theme.brightness == Brightness.dark;
        final msg = l10n?.clearUnusedDone(toRemove.length) ??
            'Removed ${toRemove.length} unused object(s).';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: toRemove.isNotEmpty
                ? (isDark ? pvzGreenDark : pvzGreenLight)
                : null,
            content: toRemove.isNotEmpty
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.check_circle,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          msg,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  )
                : Text(msg, overflow: TextOverflow.ellipsis),
          ),
        );
      }
    }
  }

  void _deleteObjectAtIndex(int index) async {
    final l10n = AppLocalizations.of(context);
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.deleteObjectTitle ?? 'Delete object?'),
        content: Text(
          l10n?.deleteObjectConfirmMessage ??
              'Remove this object from the level file? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );
    if (ok == true && mounted) {
      widget.levelFile.objects.removeAt(index);
      await LevelRepository.saveAndExport(widget.filePath, widget.levelFile);
      widget.onSaved?.call();
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.objectDeleted ?? 'Object deleted'),
          ),
        );
      }
    }
  }

  /// Scrollable JSON view: wraps long logical lines; gutter shows a line number
  /// only on the first visual row, and a continuation glyph on wrapped rows.
  Widget _buildScrollLayout(String pretty, bool isDesktop, AppLocalizations? l10n) {
    final baseStyle = TextStyle(
      fontFamily: _codeFontFamily,
      fontSize: _fontSize,
      height: 1.3,
    );
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final logicalLines = pretty.split('\n');
    final logicalLineCount = logicalLines.isEmpty ? 1 : logicalLines.length;
    final digitCount = '$logicalLineCount'.length;
    final gutterW = _fontSize * (digitCount * 0.62 + 0.6);
    final contSymbol = l10n?.jsonViewerLineContinuation ?? '↳';

    return Scrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      trackVisibility: isDesktop,
      interactive: isDesktop,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const pad = 16.0;
          const gutterTextGap = 12.0;
          final maxTextW = constraints.maxWidth - pad * 2 - gutterW - gutterTextGap;
          final safeMaxTextW = maxTextW.clamp(32.0, double.maxFinite);

          final visualRows = _wrapJsonLogicalLines(
            logicalLines,
            safeMaxTextW,
            baseStyle,
          );

          return SingleChildScrollView(
            controller: _verticalController,
            padding: const EdgeInsets.all(pad),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final row in visualRows)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          width: gutterW,
                          child: row.isContinuation
                              ? Text(
                                  contSymbol,
                                  textAlign: TextAlign.right,
                                  style: baseStyle.copyWith(
                                    fontFamily: _codeFontFamily,
                                    color: muted,
                                    fontSize: _fontSize * 0.92,
                                  ),
                                )
                              : Text(
                                  '${row.logicalLineOneBased}',
                                  textAlign: TextAlign.right,
                                  style: baseStyle.copyWith(
                                    fontFamily: _codeFontFamily,
                                    color: muted,
                                  ),
                                ),
                        ),
                        SizedBox(width: gutterTextGap),
                        Expanded(
                          child: Text(
                            row.text,
                            style: baseStyle,
                            softWrap: false,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _WrappedJsonRow {
  const _WrappedJsonRow({
    required this.logicalLineOneBased,
    required this.isContinuation,
    required this.text,
  });

  final int logicalLineOneBased;
  final bool isContinuation;
  final String text;
}

List<_WrappedJsonRow> _wrapJsonLogicalLines(
  List<String> logicalLines,
  double maxWidth,
  TextStyle style,
) {
  final rows = <_WrappedJsonRow>[];
  final w = maxWidth <= 8 ? 8.0 : maxWidth;
  for (var i = 0; i < logicalLines.length; i++) {
    final line = logicalLines[i];
    final n = i + 1;
    if (line.isEmpty) {
      rows.add(_WrappedJsonRow(logicalLineOneBased: n, isContinuation: false, text: ''));
      continue;
    }
    final tp = TextPainter(
      text: TextSpan(text: line, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w);
    final metrics = tp.computeLineMetrics();
    if (metrics.isEmpty) {
      rows.add(_WrappedJsonRow(logicalLineOneBased: n, isContinuation: false, text: line));
      continue;
    }
    for (var j = 0; j < metrics.length; j++) {
      final m = metrics[j];
      final dy = m.baseline - m.ascent;
      final yMid = dy + m.height / 2;
      final start = tp.getPositionForOffset(Offset(0, yMid)).offset;
      final end = tp.getPositionForOffset(Offset(w, yMid)).offset;
      var a = start;
      var b = end;
      if (a < 0) a = 0;
      if (a > line.length) a = line.length;
      if (b < 0) b = 0;
      if (b > line.length) b = line.length;
      if (b < a) {
        final t = a;
        a = b;
        b = t;
      }
      rows.add(
        _WrappedJsonRow(
          logicalLineOneBased: n,
          isContinuation: j > 0,
          text: line.substring(a, b),
        ),
      );
    }
  }
  return rows;
}

class _ObjectCodeCard extends StatelessWidget {
  static const codeFontFamily = 'monospace';

  const _ObjectCodeCard({
    required this.index,
    required this.obj,
    required this.fontSize,
    required this.expanded,
    required this.onToggle,
    required this.onDelete,
    required this.deleteTooltip,
  });

  final int index;
  final PvzObject obj;
  final double fontSize;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final String deleteTooltip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLevelDef = obj.objClass == 'LevelDefinition';
    final jsonContent =
        const JsonEncoder.withIndent('  ').convert(obj.objData);
    final headerBg = isDark
        ? const Color(0xFF2E7D32)
        : const Color(0xFF4CAF50);
    final deleteBtnBg = theme.colorScheme.error;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: headerBg,
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (!isLevelDef &&
                            obj.aliases != null &&
                            obj.aliases!.isNotEmpty)
                          Text(
                            'Aliases: ${obj.aliases!.join(', ')}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                        Text(
                          'ObjClass: ${obj.objClass}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Material(
                    color: deleteBtnBg,
                    borderRadius: BorderRadius.circular(6),
                    child: IconButton(
                      icon: const Icon(Icons.delete_outline),
                      tooltip: deleteTooltip,
                      onPressed: onDelete,
                      color: theme.colorScheme.onError,
                      iconSize: 20,
                      padding: const EdgeInsets.all(6),
                      constraints: const BoxConstraints(),
                      style: IconButton.styleFrom(
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    expanded ? Icons.expand_less : Icons.expand_more,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ),
          if (expanded)
            SelectionArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                  child: Text(
                  jsonContent,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: _ObjectCodeCard.codeFontFamily,
                    fontSize: fontSize,
                    height: 1.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
