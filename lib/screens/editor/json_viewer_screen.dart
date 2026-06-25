import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/escape_override.dart';
import 'package:c_editor/utils/json_viewer_search.dart';
import 'package:c_editor/widgets/app_message.dart';
import 'package:c_editor/widgets/json_viewer_search_bar.dart';

const _fontSizeKey = 'json_viewer_font_size';
const _searchHistoryKey = 'json_viewer_search_history';
const _replaceHistoryKey = 'json_viewer_replace_history';
const _maxSearchHistory = 10;

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
  final _searchController = TextEditingController();
  final _replaceController = TextEditingController();
  String? _syntaxError;
  _JsonViewMode _viewMode = _JsonViewMode.rawText;
  final Map<int, bool> _expandedStates = {};
  bool Function()? _escapeHandler;

  bool _matchCase = false;
  bool _wholeWords = false;
  bool _useRegex = false;
  bool _regexError = false;
  List<String> _searchHistory = [];
  List<String> _replaceHistory = [];
  List<JsonViewerTextMatch> _matches = const [];
  int _currentMatchIndex = 0;
  final List<int?> _matchObjectIndices = [];
  final Map<int, List<JsonViewerTextMatch>> _objectMatches = {};

  @override
  void initState() {
    super.initState();
    _loadFontSize();
    _loadSearchHistories();
  }

  JsonViewerSearchOptions get _searchOptions => JsonViewerSearchOptions(
    caseSensitive: _matchCase,
    wholeWords: _wholeWords,
    regex: _useRegex,
  );

  Future<void> _loadSearchHistories() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _searchHistory = prefs.getStringList(_searchHistoryKey) ?? [];
      _replaceHistory = prefs.getStringList(_replaceHistoryKey) ?? [];
    });
  }

  Future<void> _pushHistory(
    String key,
    String value,
    List<String> current,
  ) async {
    if (value.isEmpty) return;
    final next = [
      value,
      ...current.where((e) => e != value),
    ].take(_maxSearchHistory).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, next);
    if (!mounted) return;
    setState(() {
      if (key == _searchHistoryKey) {
        _searchHistory = next;
      } else {
        _replaceHistory = next;
      }
    });
  }

  List<int> _fontSizeOptions(bool isDesktop) => isDesktop
      ? const [12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24]
      : const [6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18];

  void _setFontSize(double value) {
    _cachedFontSize = value;
    setState(() => _fontSize = value);
    _saveFontSize(value);
  }

  String _rawPrettyText() =>
      const JsonEncoder.withIndent('  ').convert(widget.levelFile.toJson());

  void _runSearch() {
    final query = _searchController.text;
    if (query.isEmpty) {
      setState(() {
        _matches = const [];
        _matchObjectIndices.clear();
        _objectMatches.clear();
        _currentMatchIndex = 0;
        _regexError = false;
      });
      return;
    }

    final opts = _searchOptions;
    if (_useRegex && buildJsonViewerSearchPattern(query, opts) == null) {
      setState(() {
        _matches = const [];
        _matchObjectIndices.clear();
        _objectMatches.clear();
        _currentMatchIndex = 0;
        _regexError = true;
      });
      return;
    }

    final matches = <JsonViewerTextMatch>[];
    final objectIndices = <int?>[];
    _objectMatches.clear();
    if (_isEditing) {
      matches.addAll(findJsonViewerMatches(_editController.text, query, opts));
      objectIndices.addAll(List.filled(matches.length, null));
    } else if (_viewMode == _JsonViewMode.structured) {
      final objects = widget.levelFile.objects;
      for (var i = 0; i < objects.length; i++) {
        final json = const JsonEncoder.withIndent(
          '  ',
        ).convert(objects[i].objData);
        final objectMatches = findJsonViewerMatches(json, query, opts);
        if (objectMatches.isNotEmpty) {
          _objectMatches[i] = objectMatches;
          matches.addAll(objectMatches);
          objectIndices.addAll(List.filled(objectMatches.length, i));
        }
      }
    } else {
      matches.addAll(findJsonViewerMatches(_rawPrettyText(), query, opts));
      objectIndices.addAll(List.filled(matches.length, null));
    }

    setState(() {
      _matches = matches;
      _matchObjectIndices
        ..clear()
        ..addAll(objectIndices);
      _currentMatchIndex = 0;
      _regexError = false;
    });
    if (matches.isNotEmpty) {
      _goToMatch(0);
    }
  }

  void _goToMatch(int index) {
    if (_matches.isEmpty) return;
    final safeIndex = index.clamp(0, _matches.length - 1);
    setState(() => _currentMatchIndex = safeIndex);
    final match = _matches[safeIndex];

    if (_isEditing) {
      _editController.selection = TextSelection(
        baseOffset: match.start,
        extentOffset: match.end,
      );
      _scrollToLine(match.lineIndex);
      return;
    }

    if (_viewMode == _JsonViewMode.structured) {
      final objectIndex = _matchObjectIndices[safeIndex];
      if (objectIndex != null) {
        setState(() => _expandedStates[objectIndex] = true);
        _scrollToLine(objectIndex);
      }
      return;
    }

    _scrollToLine(match.lineIndex);
  }

  void _scrollToLine(int lineIndex) {
    if (!_verticalController.hasClients) return;
    final lineHeight = _fontSize * 1.3;
    final target = (lineIndex * lineHeight).clamp(
      0.0,
      _verticalController.position.maxScrollExtent,
    );
    _verticalController.animateTo(
      target,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  void _onPreviousMatch() {
    if (_matches.isEmpty) return;
    final next = (_currentMatchIndex - 1 + _matches.length) % _matches.length;
    _goToMatch(next);
  }

  void _onNextMatch() {
    if (_matches.isEmpty) return;
    final next = (_currentMatchIndex + 1) % _matches.length;
    _goToMatch(next);
  }

  void _replaceCurrentMatch() {
    if (!_isEditing || _matches.isEmpty) return;
    final match = _matches[_currentMatchIndex];
    final replacement = _replaceController.text;
    final next = replaceJsonViewerMatch(
      _editController.text,
      match,
      replacement,
    );
    _editController.text = next;
    _pushHistory(_replaceHistoryKey, replacement, _replaceHistory);
    _runSearch();
  }

  void _replaceAllMatches() {
    if (!_isEditing || _searchController.text.isEmpty) return;
    final replacement = _replaceController.text;
    final next = replaceAllJsonViewerMatches(
      _editController.text,
      _searchController.text,
      replacement,
      _searchOptions,
    );
    _editController.text = next;
    _pushHistory(_replaceHistoryKey, replacement, _replaceHistory);
    _runSearch();
  }

  void _onSearchChanged(String value) {
    _runSearch();
  }

  void _commitSearchHistory() {
    _pushHistory(_searchHistoryKey, _searchController.text, _searchHistory);
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getDouble(_fontSizeKey);
    if (saved != null && mounted) {
      final isDesktop =
          Theme.of(context).platform == TargetPlatform.windows ||
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

  void _pushEscapeHandler() {
    if (_escapeHandler != null) return;
    _escapeHandler = () {
      if (_isEditing) {
        _cancelEdit();
        return true;
      }
      return false;
    };
    EscapeOverride.push(_escapeHandler!);
  }

  void _popEscapeHandler() {
    if (_escapeHandler == null) return;
    EscapeOverride.pop(_escapeHandler!);
    _escapeHandler = null;
  }

  @override
  void dispose() {
    _popEscapeHandler();
    _verticalController.dispose();
    _editController.dispose();
    _searchController.dispose();
    _replaceController.dispose();
    super.dispose();
  }

  void _startEdit() {
    final pretty = const JsonEncoder.withIndent(
      '  ',
    ).convert(widget.levelFile.toJson());
    _editController.text = pretty;
    setState(() {
      _isEditing = true;
      _syntaxError = null;
    });
    _runSearch();
    _pushEscapeHandler();
  }

  void _cancelEdit() {
    _popEscapeHandler();
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
        _popEscapeHandler();
        setState(() {
          _isEditing = false;
          _syntaxError = null;
        });
        widget.onSaved?.call();
        final l10n = AppLocalizations.of(context);
        AppMessage.show(
          context,
          l10n?.saved ?? 'Saved',
          icon: Icons.check_circle,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _syntaxError = 'JSON error: $e');
        final l10n = AppLocalizations.of(context);
        AppMessage.show(
          context,
          l10n?.saveFail ?? 'Save failed',
          icon: Icons.warning_amber_rounded,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final isDesktop =
        Theme.of(context).platform == TargetPlatform.windows ||
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
            JsonViewerFontSizeButton(
              currentSize: _fontSize,
              sizes: _fontSizeOptions(isDesktop),
              tooltip: l10n?.jsonViewerFontSize ?? 'Font size',
              onSelected: _setFontSize,
            ),
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
                tooltip:
                    l10n?.tooltipToggleObjectView ?? 'Toggle object/raw view',
                onPressed: () {
                  setState(() {
                    _viewMode = _viewMode == _JsonViewMode.rawText
                        ? _JsonViewMode.structured
                        : _JsonViewMode.rawText;
                  });
                  _runSearch();
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
            JsonViewerSearchBar(
              searchController: _searchController,
              replaceController: _replaceController,
              showReplace: _isEditing,
              matchCase: _matchCase,
              wholeWords: _wholeWords,
              useRegex: _useRegex,
              searchHistory: _searchHistory,
              replaceHistory: _replaceHistory,
              matchCount: _matches.length,
              currentMatchIndex: _currentMatchIndex,
              regexError: _regexError,
              onSearchChanged: _onSearchChanged,
              onReplaceChanged: (_) => setState(() {}),
              onMatchCaseChanged: (v) {
                setState(() => _matchCase = v);
                _runSearch();
              },
              onWholeWordsChanged: (v) {
                setState(() => _wholeWords = v);
                _runSearch();
              },
              onRegexChanged: (v) {
                setState(() => _useRegex = v);
                _runSearch();
              },
              onPreviousMatch: _onPreviousMatch,
              onNextMatch: _onNextMatch,
              onReplaceOne: _replaceCurrentMatch,
              onReplaceAll: _replaceAllMatches,
              onHistorySelected: (v) =>
                  _pushHistory(_searchHistoryKey, v, _searchHistory),
              onReplaceHistorySelected: (v) =>
                  _pushHistory(_replaceHistoryKey, v, _replaceHistory),
              onSearchSubmitted: _commitSearchHistory,
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
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildViewMode(String pretty, bool isDesktop, AppLocalizations? l10n) {
    return SelectionArea(child: _buildScrollLayout(pretty, isDesktop, l10n));
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
            objectMatches: _objectMatches[index] ?? const [],
            activeMatchIndex: _activeMatchIndexForObject(index),
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
        AppMessage.show(
          context,
          l10n?.clearUnusedNone ?? 'No unused objects found.',
          icon: Icons.check_circle,
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
        final msg =
            l10n?.clearUnusedDone(toRemove.length) ??
            'Removed ${toRemove.length} unused object(s).';
        AppMessage.show(context, msg, icon: Icons.check_circle);
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
        AppMessage.show(
          context,
          l10n?.objectDeleted ?? 'Object deleted',
          icon: Icons.check_circle,
        );
      }
    }
  }

  int? _activeMatchIndexForObject(int objectIndex) {
    if (_matches.isEmpty || _currentMatchIndex >= _matchObjectIndices.length) {
      return null;
    }
    if (_matchObjectIndices[_currentMatchIndex] != objectIndex) return null;
    final objectMatches = _objectMatches[objectIndex];
    if (objectMatches == null) return null;
    return objectMatches.indexOf(_matches[_currentMatchIndex]);
  }

  /// Scrollable JSON view: wraps long logical lines; gutter shows a line number
  /// only on the first visual row, and a continuation glyph on wrapped rows.
  Widget _buildScrollLayout(
    String pretty,
    bool isDesktop,
    AppLocalizations? l10n,
  ) {
    final theme = Theme.of(context);
    final baseStyle = TextStyle(
      fontFamily: _codeFontFamily,
      fontSize: _fontSize,
      height: 1.3,
      color: theme.colorScheme.onSurface,
    );
    final muted = theme.colorScheme.onSurface.withValues(alpha: 0.5);
    final logicalLines = pretty.split('\n');
    final logicalLineCount = logicalLines.isEmpty ? 1 : logicalLines.length;
    final digitCount = '$logicalLineCount'.length;
    final gutterW = _fontSize * (digitCount * 0.62 + 0.6);
    final contSymbol = l10n?.jsonViewerLineContinuation ?? '↳';
    final highlightStyle = baseStyle.copyWith(
      backgroundColor: theme.colorScheme.tertiary.withValues(alpha: 0.35),
    );
    final activeHighlightStyle = baseStyle.copyWith(
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.45),
    );
    final lineStarts = <int>[];
    var runningOffset = 0;
    for (final line in logicalLines) {
      lineStarts.add(runningOffset);
      runningOffset += line.length + 1;
    }
    final activeMatch = _matches.isEmpty
        ? null
        : _matches[_currentMatchIndex.clamp(0, _matches.length - 1)];

    return Scrollbar(
      controller: _verticalController,
      thumbVisibility: true,
      trackVisibility: isDesktop,
      interactive: isDesktop,
      child: LayoutBuilder(
        builder: (context, constraints) {
          const pad = 16.0;
          const gutterTextGap = 12.0;
          final maxTextW =
              constraints.maxWidth - pad * 2 - gutterW - gutterTextGap;
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
                          child: _matches.isEmpty
                              ? Text(
                                  row.text,
                                  style: baseStyle,
                                  softWrap: false,
                                )
                              : RichText(
                                  text: TextSpan(
                                    style: baseStyle,
                                    children: buildHighlightedTextSpans(
                                      text: row.text,
                                      segmentStartInLine:
                                          row.segmentStartInLine,
                                      segmentEndInLine:
                                          row.segmentStartInLine +
                                          row.text.length,
                                      baseStyle: baseStyle,
                                      highlightStyle: highlightStyle,
                                      activeHighlightStyle:
                                          activeHighlightStyle,
                                      lineMatches: _matches
                                          .where(
                                            (m) =>
                                                m.lineIndex ==
                                                row.logicalLineOneBased - 1,
                                          )
                                          .toList(),
                                      activeMatch: activeMatch,
                                      lineStartOffset:
                                          lineStarts[row.logicalLineOneBased -
                                              1],
                                    ),
                                  ),
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
    required this.segmentStartInLine,
  });

  final int logicalLineOneBased;
  final bool isContinuation;
  final String text;
  final int segmentStartInLine;
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
      rows.add(
        _WrappedJsonRow(
          logicalLineOneBased: n,
          isContinuation: false,
          text: '',
          segmentStartInLine: 0,
        ),
      );
      continue;
    }
    final tp = TextPainter(
      text: TextSpan(text: line, style: style),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: w);
    final metrics = tp.computeLineMetrics();
    if (metrics.isEmpty) {
      rows.add(
        _WrappedJsonRow(
          logicalLineOneBased: n,
          isContinuation: false,
          text: line,
          segmentStartInLine: 0,
        ),
      );
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
          segmentStartInLine: a,
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
    required this.objectMatches,
    required this.activeMatchIndex,
  });

  final int index;
  final PvzObject obj;
  final double fontSize;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final String deleteTooltip;
  final List<JsonViewerTextMatch> objectMatches;
  final int? activeMatchIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLevelDef = obj.objClass == 'LevelDefinition';
    final jsonContent = const JsonEncoder.withIndent('  ').convert(obj.objData);
    final headerBg = isDark ? const Color(0xFF2E7D32) : const Color(0xFF4CAF50);
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
              decoration: BoxDecoration(color: headerBg),
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
                child: _HighlightedJsonText(
                  jsonContent: jsonContent,
                  fontSize: fontSize,
                  objectMatches: objectMatches,
                  activeMatch:
                      activeMatchIndex != null &&
                          activeMatchIndex! >= 0 &&
                          activeMatchIndex! < objectMatches.length
                      ? objectMatches[activeMatchIndex!]
                      : null,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _HighlightedJsonText extends StatelessWidget {
  const _HighlightedJsonText({
    required this.jsonContent,
    required this.fontSize,
    required this.objectMatches,
    required this.activeMatch,
  });

  final String jsonContent;
  final double fontSize;
  final List<JsonViewerTextMatch> objectMatches;
  final JsonViewerTextMatch? activeMatch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseStyle =
        theme.textTheme.bodyMedium?.copyWith(
          fontFamily: _ObjectCodeCard.codeFontFamily,
          fontSize: fontSize,
          height: 1.3,
          color: theme.colorScheme.onSurface,
        ) ??
        TextStyle(
          fontFamily: _ObjectCodeCard.codeFontFamily,
          fontSize: fontSize,
          height: 1.3,
          color: theme.colorScheme.onSurface,
        );
    if (objectMatches.isEmpty) {
      return Text(jsonContent, style: baseStyle);
    }

    final highlightStyle = baseStyle.copyWith(
      backgroundColor: theme.colorScheme.tertiary.withValues(alpha: 0.35),
    );
    final activeHighlightStyle = baseStyle.copyWith(
      backgroundColor: theme.colorScheme.primary.withValues(alpha: 0.45),
    );
    final lines = jsonContent.split('\n');
    final lineStarts = <int>[];
    var offset = 0;
    for (final line in lines) {
      lineStarts.add(offset);
      offset += line.length + 1;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines.length; i++)
          RichText(
            text: TextSpan(
              style: baseStyle,
              children: [
                ...buildHighlightedTextSpans(
                  text: lines[i],
                  segmentStartInLine: 0,
                  segmentEndInLine: lines[i].length,
                  baseStyle: baseStyle,
                  highlightStyle: highlightStyle,
                  activeHighlightStyle: activeHighlightStyle,
                  lineMatches: objectMatches
                      .where((m) => m.lineIndex == i)
                      .toList(),
                  activeMatch: activeMatch,
                  lineStartOffset: lineStarts[i],
                ),
                if (i < lines.length - 1) const TextSpan(text: '\n'),
              ],
            ),
          ),
      ],
    );
  }
}
