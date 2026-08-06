import 'dart:io' show Platform, Directory;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb, Uint8List;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/data/app_links.dart';
import 'package:c_editor/data/launch_external_url.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/data/repository/level_repository_base.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/plugins/plugin_constants.dart';
import 'package:c_editor/plugins/plugin_manager.dart';
import 'package:c_editor/plugins/plugin_ui_host.dart';
import 'package:c_editor/screens/level_list_platform.dart';
import 'package:c_editor/widgets/app_message.dart';
import 'package:c_editor/screens/export/export_screen.dart';
import 'package:c_editor/widgets/web_transfer_progress_dialog.dart';

enum LevelViewMode { all, favorites }

enum _WebUploadConflictStrategy { skip, overwrite, copy }

enum _SmartUploadChoice {
  skipThis,
  overwriteThis,
  copyThis,
  skipAll,
  overwriteAll,
  copyAll,
}

class LevelListScreen extends StatefulWidget {
  const LevelListScreen({
    super.key,
    required this.onLevelClick,
    required this.onAboutClick,
    required this.onPluginsClick,
    required this.onLanguageTap,
  });

  final void Function(String fileName, String filePath) onLevelClick;
  final VoidCallback onAboutClick;
  final VoidCallback onPluginsClick;
  final ValueChanged<BuildContext> onLanguageTap;

  @override
  State<LevelListScreen> createState() => _LevelListScreenState();
}

class _LevelListScreenState extends State<LevelListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<FileItem> _fileItems = [];
  bool _isLoading = false;
  LevelViewMode _viewMode = LevelViewMode.all;
  List<({String name, String path})> _pathStack = [];
  String? _rootFolderPath;
  FileItem? _itemToDelete;
  FileItem? _itemToRename;
  FileItem? _itemToCopy;
  FileItem? _itemToMove;
  String? _moveSourcePath;
  String _renameInput = '';
  String _copyInput = '';
  bool _showNewFolderDialog = false;
  String _newFolderNameInput = '';
  List<String> _templates = [];
  String _selectedTemplate = '';
  String _newLevelNameInput = '';
  bool _showUiScaleDialog = false;
  LevelSortMode _sortMode = LevelSortMode.name;
  final ScrollController _listScrollController = ScrollController();
  bool _listScrollAtTop = true;

  bool get _canGoBack => _pathStack.length > 1;

  void _showMessage(String message, {IconData? icon}) {
    AppMessage.show(context, message, icon: icon ?? Icons.info_outline);
  }

  void _showSuccessMessage(String message) {
    AppMessage.show(context, message, icon: Icons.check_circle);
  }

  void _showWarningMessage(String message) {
    AppMessage.show(context, message, icon: Icons.warning_amber_rounded);
  }

  /// Extension to use when the user omits one (matches [LevelRepository] level files).
  String _levelExtensionFromFileName(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.hujson')) return '.hujson';
    if (lower.endsWith('.rton')) return '.rton';
    if (lower.endsWith('.json')) return '.json';
    return '.json';
  }

  /// If [inputName] already has a level extension, returns it; else appends the extension from [referenceFileName].
  String _ensureLevelExtension(String inputName, String referenceFileName) {
    final trimmed = inputName.trim();
    final lower = trimmed.toLowerCase();
    if (lower.endsWith('.json') ||
        lower.endsWith('.hujson') ||
        lower.endsWith('.rton') ||
        lower.endsWith('.zlib') ||
        lower.endsWith('.bin') ||
        lower.endsWith('.smf') ||
        lower.endsWith('.rsb') ||
        lower.endsWith('.rsg')) {
      return trimmed;
    }
    return trimmed + _levelExtensionFromFileName(referenceFileName);
  }

  Future<void> _toggleSortMode() async {
    final next = switch (_sortMode) {
      LevelSortMode.name => LevelSortMode.created,
      LevelSortMode.created => LevelSortMode.modified,
      LevelSortMode.modified => LevelSortMode.size,
      LevelSortMode.size => LevelSortMode.type,
      LevelSortMode.type => LevelSortMode.name,
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('level_list_sort_mode', next.index);

    setState(() => _sortMode = next);
    _loadCurrentDirectory();

    if (mounted) {
      final l10n = AppLocalizations.of(context);
      final msg = switch (next) {
        LevelSortMode.name => l10n?.sortByName ?? 'Sorted by name',
        LevelSortMode.modified =>
          l10n?.sortByModificationDate ?? 'Sorted by modification date',
        LevelSortMode.created =>
          l10n?.sortByCreationDate ?? 'Sorted by creation date',
        LevelSortMode.size => l10n?.sortBySize ?? 'Sorted by size',
        LevelSortMode.type => l10n?.sortByFileType ?? 'Sorted by file type',
      };
      _showMessage(msg, icon: Icons.sort);
    }
  }

  @override
  void initState() {
    super.initState();
    _listScrollController.addListener(_onListScroll);
    _seedRootFromStartupCache();
    _loadSavedPathAndList();
  }

  void _seedRootFromStartupCache() {
    final cache = LevelRepository.startupCache;
    if (cache == null) return;

    if (kIsWeb && cache.webReady) {
      const webPath = 'web://';
      final libraryLabel = cache.webLibraryDisplayName ?? 'My levels';
      _rootFolderPath = webPath;
      _pathStack = [(name: libraryLabel, path: webPath)];
      return;
    }

    final path = cache.savedFolderPath;
    if (path == null || path.isEmpty) return;

    _rootFolderPath = path;
    final rootName = path.split(RegExp(r'[/\\]')).last;
    final stack = <({String name, String path})>[
      (name: rootName.isEmpty ? 'Root' : rootName, path: path),
    ];
    final lastLevelDir = cache.lastOpenedLevelDirectory;
    if (lastLevelDir != null && lastLevelDir != path) {
      try {
        final rel = p.relative(lastLevelDir, from: path);
        if (!rel.startsWith('..') && rel.isNotEmpty && rel != '.') {
          var current = path;
          for (final segment in p.split(rel)) {
            if (segment.isEmpty) continue;
            current = p.join(current, segment);
            stack.add((name: segment, path: current));
          }
        }
      } catch (_) {
      }
    }
    _pathStack = stack;
  }

  @override
  void dispose() {
    _listScrollController.removeListener(_onListScroll);
    _listScrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onListScroll() {
    if (!_listScrollController.hasClients) return;
    final atTop = _listScrollController.offset <= 0;
    if (atTop != _listScrollAtTop && mounted) {
      setState(() => _listScrollAtTop = atTop);
    }
  }

  void _resetListScrollToTop() {
    _listScrollAtTop = true;
    if (_listScrollController.hasClients) {
      _listScrollController.jumpTo(0);
    }
  }

  Future<void> _ensureStoragePermission() async {
    if (kIsWeb) return;
    if (!mounted) return;
    await ensureStoragePermission(context);
  }

  Future<void> _loadSavedPathAndList() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSortIndex = prefs.getInt('level_list_sort_mode') ?? 0;
    if (savedSortIndex < LevelSortMode.values.length) {
      _sortMode = LevelSortMode.values[savedSortIndex];
    }

    await _ensureStoragePermission();
    if (kIsWeb) {
      await LevelRepository.ensureWebStorageReady();
      const webPath = 'web://';
      final libraryLabel =
          await LevelRepository.getWebLibraryDisplayName() ?? 'My levels';
      if (!mounted) return;
      setState(() {
        _rootFolderPath = webPath;
        _pathStack = [(name: libraryLabel, path: webPath)];
      });
      _loadCurrentDirectory();
      return;
    }
    final path = await LevelRepository.getSavedFolderPath();
    final lastLevelDir = await LevelRepository.getLastOpenedLevelDirectory();
    var resolvedPath = path;
    if (resolvedPath != null && mounted) {
      final libraryPath = resolvedPath;
      setState(() {
        _rootFolderPath = libraryPath;
        if (_pathStack.isEmpty) {
          List<({String name, String path})> stack = [];
          final rootName = libraryPath.split(RegExp(r'[/\\]')).last;
          stack.add((name: rootName.isEmpty ? 'Root' : rootName, path: libraryPath));
          if (lastLevelDir != null && lastLevelDir != libraryPath) {
            try {
              final rel = p.relative(lastLevelDir, from: libraryPath);
              if (rel.startsWith('..')) throw ArgumentError('not under root');
              if (rel.isNotEmpty && rel != '.') {
                var current = libraryPath;
                for (final segment in p.split(rel)) {
                  if (segment.isEmpty) continue;
                  current = p.join(current, segment);
                  stack.add((name: segment, path: current));
                }
              }
            } catch (_) {
              /* lastLevelDir not under root, use root only */
            }
          }
          _pathStack = stack;
        }
      });
      _loadCurrentDirectory();
    }
  }

  Future<void> _pickFolder() async {
    if (kIsWeb) return;
    final prefs = await SharedPreferences.getInstance();
    final savedSortIndex = prefs.getInt('level_list_sort_mode') ?? 0;
    if (savedSortIndex < LevelSortMode.values.length) {
      _sortMode = LevelSortMode.values[savedSortIndex];
    }

    await _ensureStoragePermission();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.getDirectoryPath(
      dialogTitle: l10n.openFolder,
    );
    if (result == null || !mounted) return;
    await _applyLibraryFolder(result);
  }

  Future<void> _useDefaultIosLibraryFolder() async {
    final path = await LevelRepository.ensureIosLibraryPath();
    await _applyLibraryFolder(path);
  }

  Future<void> _applyLibraryFolder(String path) async {
    await LevelRepository.setSavedFolderPath(path);
    if (PluginManager.isInitialized) {
      await PluginManager.instance.reload();
    }
    if (!mounted) return;
    if (!kIsWeb && Platform.isIOS) {
      final ok = await LevelRepository.ensureFolderAccess();
      if (!ok) {
        if (!mounted) return;
        _showWarningMessage(
          AppLocalizations.of(context)!.selectFolderPrompt,
        );
        return;
      }
    }
    if (!mounted) return;
    setState(() {
      _rootFolderPath = path;
      final name = path.split(RegExp(r'[/\\]')).last;
      _pathStack = [(name: name.isEmpty ? 'Root' : name, path: path)];
    });
    _loadCurrentDirectory();
  }

  /// Builds a storage key relative to the virtual web library root.
  String _webStorageKey(String currentDir, String fileName) {
    const webPath = 'web://';
    if (currentDir == webPath) {
      return fileName;
    }
    if (!currentDir.startsWith(webPath)) {
      return fileName;
    }
    final rel = currentDir.substring(webPath.length);
    if (rel.isEmpty) {
      return fileName;
    }
    return '$rel/$fileName';
  }

  /// Web-only: pick one or more level files and add them to the virtual workspace.
  Future<void> _pickAndAddFile() async {
    final l10n = AppLocalizations.of(context)!;
    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      withData: true,
      type: FileType.custom,
      allowedExtensions: ['json', 'hujson', 'rton'],
      dialogTitle: l10n.importFiles,
    );
    if (result == null || result.files.isEmpty || !mounted) return;

    const webPath = 'web://';
    final currentDir = _pathStack.isNotEmpty ? _pathStack.last.path : webPath;
    final files = <({String storageKey, List<int> bytes})>[];

    for (final file in result.files) {
      if (file.name.isEmpty) continue;
      final bytes = file.bytes;
      if (bytes == null) continue;
      files.add((
        storageKey: _webStorageKey(currentDir, file.name),
        bytes: bytes,
      ));
    }

    if (files.isEmpty) {
      _showWarningMessage(l10n.importFilesUnreadable);
      return;
    }

    final imported = await _importFilesWithSmartUpload(
      files,
      progressTitle: l10n.importProgressTitle,
    );
    if (!mounted || imported == 0) return;
    _showSuccessMessage(l10n.importFolderSuccess(imported));
  }

  String _sanitizeFolderImportName(String name) {
    final trimmed = name.trim().replaceAll('\\', '/');
    if (trimmed.isEmpty) {
      return 'Imported folder';
    }
    final parts = trimmed.split('/').where((part) {
      return part.isNotEmpty && part != '.';
    }).toList();
    if (parts.isEmpty) {
      return 'Imported folder';
    }
    return parts.last;
  }

  /// Web-only: recursively import a folder and all subfolders into the library.
  Future<void> _pickAndImportFolder() async {
    final l10n = AppLocalizations.of(context)!;
    if (!LevelRepository.isWebFolderImportSupported) {
      _showWarningMessage(l10n.importFolderUnsupported);
      return;
    }

    final folder = await LevelRepository.pickWebFolderForImport();
    if (!mounted) return;
    if (folder == null) {
      return;
    }

    if (folder.paths.isEmpty) {
      _showWarningMessage(l10n.importFolderEmpty);
      return;
    }

    const webPath = 'web://';
    final currentDir = _pathStack.isNotEmpty ? _pathStack.last.path : webPath;
    final folderName = _sanitizeFolderImportName(folder.name);

    final entries = folder.paths
        .map(
          (path) => (
            storageKey: _webStorageKey(currentDir, '$folderName/$path'),
            relativePath: path,
          ),
        )
        .toList();

    final imported = await _importFolderPathsWithSmartUpload(
      entries,
      progressTitle: l10n.importProgressTitle,
    );
    if (!mounted || imported == 0) return;
    _showSuccessMessage(l10n.importFolderSuccess(imported));
  }

  Future<bool> _webStorageKeyExists(String storageKey) async {
    const webPath = 'web://';
    final slash = storageKey.lastIndexOf('/');
    if (slash < 0) {
      return LevelRepository.fileExistsInDirectory(webPath, storageKey);
    }
    final parentKey = storageKey.substring(0, slash);
    final leaf = storageKey.substring(slash + 1);
    return LevelRepository.fileExistsInDirectory('$webPath$parentKey', leaf);
  }

  Future<int> _importFilesWithSmartUpload(
    List<({String storageKey, List<int> bytes})> files, {
    String? progressTitle,
  }) async {
    if (files.isEmpty || !mounted) return 0;

    await LevelRepository.ensureWebStorageReady();

    final pending = <({String storageKey, List<int> bytes})>[];
    final conflicts = <({String storageKey, List<int> bytes})>[];

    for (final file in files) {
      final exists = await _webStorageKeyExists(file.storageKey);
      if (exists) {
        conflicts.add(file);
      } else {
        pending.add(file);
      }
    }

    if (conflicts.isNotEmpty) {
      await _resolveSmartUploadConflicts(conflicts, pending);
      if (!mounted) return 0;
    }

    if (pending.isEmpty) return 0;

    final batched = pending
        .map(
          (file) => (
            storageKey: file.storageKey,
            bytes: Uint8List.fromList(file.bytes),
          ),
        )
        .toList();

    if (!mounted) return 0;
    final imported = progressTitle == null
        ? await LevelRepository.importWebFilesBatched(batched)
        : await _runWebImportProgress(progressTitle, batched) ?? 0;

    if (!mounted || imported == 0) return imported;
    const webPath = 'web://';
    setState(() {
      _rootFolderPath ??= webPath;
      if (_pathStack.isEmpty) {
        _pathStack = [(name: 'My levels', path: webPath)];
      }
    });
    _loadCurrentDirectory();
    return imported;
  }

  Future<int> _importFolderPathsWithSmartUpload(
    List<({String storageKey, String relativePath})> entries, {
    String? progressTitle,
  }) async {
    if (entries.isEmpty || !mounted) return 0;

    await LevelRepository.ensureWebStorageReady();

    final pending = <({String storageKey, String relativePath})>[];
    final conflicts = <({String storageKey, String relativePath})>[];

    for (final entry in entries) {
      final exists = await _webStorageKeyExists(entry.storageKey);
      if (exists) {
        conflicts.add(entry);
      } else {
        pending.add(entry);
      }
    }

    if (conflicts.isNotEmpty) {
      await _resolveSmartUploadPathConflicts(conflicts, pending);
      if (!mounted) {
        LevelRepository.releaseWebFolderImport();
        return 0;
      }
    }

    if (pending.isEmpty) {
      LevelRepository.releaseWebFolderImport();
      return 0;
    }

    if (!mounted) {
      LevelRepository.releaseWebFolderImport();
      return 0;
    }
    final imported = progressTitle == null
        ? await LevelRepository.importWebFolderPathsBatched(pending)
        : await _runWebFolderImportProgress(progressTitle, pending) ?? 0;

    if (!mounted || imported == 0) return imported;
    const webPath = 'web://';
    setState(() {
      _rootFolderPath ??= webPath;
      if (_pathStack.isEmpty) {
        _pathStack = [(name: 'My levels', path: webPath)];
      }
    });
    _loadCurrentDirectory();
    return imported;
  }

  Future<int?> _runWebFolderImportProgress(
    String title,
    List<({String storageKey, String relativePath})> entries,
  ) {
    if (!mounted) {
      return Future.value(null);
    }
    return runWebTransferWithProgress<int>(
      context,
      title: title,
      cancellable: true,
      task: (report, controller) => LevelRepository.importWebFolderPathsBatched(
        entries,
        onProgress: report,
        isCancelled: () => controller.isCancelled,
      ),
    );
  }

  Future<int?> _runWebImportProgress(
    String title,
    List<({String storageKey, Uint8List bytes})> files,
  ) {
    if (!mounted) {
      return Future.value(null);
    }
    return runWebTransferWithProgress<int>(
      context,
      title: title,
      cancellable: true,
      task: (report, controller) => LevelRepository.importWebFilesBatched(
        files,
        onProgress: report,
        isCancelled: () => controller.isCancelled,
      ),
    );
  }

  Future<void> _downloadFolderZip(FileItem folder) async {
    final l10n = AppLocalizations.of(context)!;
    await runWebTransferWithProgress<void>(
      context,
      title: l10n.exportProgressTitle,
      task: (report, controller) => LevelRepository.downloadFolderAsZip(
        folder.path,
        onProgress: report,
      ),
    );
  }

  Future<void> _resolveSmartUploadConflicts(
    List<({String storageKey, List<int> bytes})> conflicts,
    List<({String storageKey, List<int> bytes})> pending,
  ) async {
    _WebUploadConflictStrategy? bulkStrategy;
    final reservedKeys = pending.map((e) => e.storageKey.toLowerCase()).toSet();

    for (final conflict in conflicts) {
      if (!mounted) return;

      late final _WebUploadConflictStrategy strategy;
      if (bulkStrategy != null) {
        strategy = bulkStrategy;
      } else {
        final choice = await _showSmartUploadFileDialog(conflict.storageKey);
        if (!mounted) return;
        if (choice == null) continue;

        switch (choice) {
          case _SmartUploadChoice.skipThis:
            strategy = _WebUploadConflictStrategy.skip;
          case _SmartUploadChoice.skipAll:
            bulkStrategy = _WebUploadConflictStrategy.skip;
            strategy = bulkStrategy;
          case _SmartUploadChoice.overwriteThis:
            strategy = _WebUploadConflictStrategy.overwrite;
          case _SmartUploadChoice.overwriteAll:
            bulkStrategy = _WebUploadConflictStrategy.overwrite;
            strategy = bulkStrategy;
          case _SmartUploadChoice.copyThis:
            strategy = _WebUploadConflictStrategy.copy;
          case _SmartUploadChoice.copyAll:
            bulkStrategy = _WebUploadConflictStrategy.copy;
            strategy = bulkStrategy;
        }
      }

      switch (strategy) {
        case _WebUploadConflictStrategy.skip:
          break;
        case _WebUploadConflictStrategy.overwrite:
          pending.add(conflict);
          reservedKeys.add(conflict.storageKey.toLowerCase());
        case _WebUploadConflictStrategy.copy:
          final copyKey = await _nextSmartUploadCopyStorageKey(
            conflict.storageKey,
            reservedKeys,
          );
          pending.add((storageKey: copyKey, bytes: conflict.bytes));
          reservedKeys.add(copyKey.toLowerCase());
      }
    }
  }

  Future<void> _resolveSmartUploadPathConflicts(
    List<({String storageKey, String relativePath})> conflicts,
    List<({String storageKey, String relativePath})> pending,
  ) async {
    _WebUploadConflictStrategy? bulkStrategy;
    final reservedKeys = pending.map((e) => e.storageKey.toLowerCase()).toSet();

    for (final conflict in conflicts) {
      if (!mounted) return;

      late final _WebUploadConflictStrategy strategy;
      if (bulkStrategy != null) {
        strategy = bulkStrategy;
      } else {
        final choice = await _showSmartUploadFileDialog(conflict.storageKey);
        if (!mounted) return;
        if (choice == null) continue;

        switch (choice) {
          case _SmartUploadChoice.skipThis:
            strategy = _WebUploadConflictStrategy.skip;
          case _SmartUploadChoice.skipAll:
            bulkStrategy = _WebUploadConflictStrategy.skip;
            strategy = bulkStrategy;
          case _SmartUploadChoice.overwriteThis:
            strategy = _WebUploadConflictStrategy.overwrite;
          case _SmartUploadChoice.overwriteAll:
            bulkStrategy = _WebUploadConflictStrategy.overwrite;
            strategy = bulkStrategy;
          case _SmartUploadChoice.copyThis:
            strategy = _WebUploadConflictStrategy.copy;
          case _SmartUploadChoice.copyAll:
            bulkStrategy = _WebUploadConflictStrategy.copy;
            strategy = bulkStrategy;
        }
      }

      switch (strategy) {
        case _WebUploadConflictStrategy.skip:
          break;
        case _WebUploadConflictStrategy.overwrite:
          pending.add(conflict);
          reservedKeys.add(conflict.storageKey.toLowerCase());
        case _WebUploadConflictStrategy.copy:
          final copyKey = await _nextSmartUploadCopyStorageKey(
            conflict.storageKey,
            reservedKeys,
          );
          pending.add((
            storageKey: copyKey,
            relativePath: conflict.relativePath,
          ));
          reservedKeys.add(copyKey.toLowerCase());
      }
    }
  }

  Future<String> _nextSmartUploadCopyStorageKey(
    String storageKey,
    Set<String> reservedKeys,
  ) async {
    final slash = storageKey.lastIndexOf('/');
    final parentKey = slash >= 0 ? storageKey.substring(0, slash) : '';
    final leaf = slash >= 0 ? storageKey.substring(slash + 1) : storageKey;

    Future<bool> isTaken(String candidateKey) async {
      return reservedKeys.contains(candidateKey.toLowerCase()) ||
          await _webStorageKeyExists(candidateKey);
    }

    final baseName = LevelRepository.baseNameWithoutLevelExtension(leaf);
    final ext = leaf.substring(baseName.length);

    var copyBase = '${baseName}_copy';
    var candidateLeaf = '$copyBase$ext';
    var candidateKey =
        parentKey.isEmpty ? candidateLeaf : '$parentKey/$candidateLeaf';
    if (!await isTaken(candidateKey)) return candidateKey;

    var n = 1;
    while (true) {
      copyBase = '${baseName}_copy$n';
      candidateLeaf = '$copyBase$ext';
      candidateKey =
          parentKey.isEmpty ? candidateLeaf : '$parentKey/$candidateLeaf';
      if (!await isTaken(candidateKey)) return candidateKey;
      n++;
    }
  }

  Future<_SmartUploadChoice?> _showSmartUploadFileDialog(String fileName) async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<_SmartUploadChoice>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.smartUploadTitle),
        content: Text(l10n.smartUploadFileMessage(fileName)),
        actions: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(ctx, _SmartUploadChoice.skipThis),
                child: Text(l10n.smartUploadSkip),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(ctx, _SmartUploadChoice.overwriteThis),
                child: Text(l10n.smartUploadOverwrite),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(ctx, _SmartUploadChoice.copyThis),
                child: Text(l10n.smartUploadAsCopy),
              ),
              const Divider(height: 1),
              TextButton(
                onPressed: () =>
                    Navigator.pop(ctx, _SmartUploadChoice.skipAll),
                child: Text(l10n.smartUploadSkipAll),
              ),
              TextButton(
                onPressed: () =>
                    Navigator.pop(ctx, _SmartUploadChoice.overwriteAll),
                child: Text(l10n.smartUploadOverwriteAll),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(ctx, _SmartUploadChoice.copyAll),
                child: Text(l10n.smartUploadCopyAll),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _loadCurrentDirectory() async {
    final currentPath = _pathStack.isNotEmpty
        ? _pathStack.last.path
        : _rootFolderPath;

    if (currentPath == null) return;

    if (!kIsWeb) {
      final dir = Directory(currentPath);
      if (!await dir.exists()) {
        if (_pathStack.length > 1 && mounted) {
          setState(() {
            _pathStack = [_pathStack.first];
          });
          _loadCurrentDirectory();
          return;
        }
      }
    }

    setState(() => _isLoading = true);
    try {
      var activePath = currentPath;
      if (!kIsWeb && Platform.isIOS) {
        final ok = await LevelRepository.ensureFolderAccess();
        if (!ok && mounted) {
          setState(() {
            _fileItems = [];
            _isLoading = false;
          });
          _showWarningMessage(AppLocalizations.of(context)!.selectFolderPrompt);
          return;
        }
      }

      List<FileItem> items;
      if (_viewMode == LevelViewMode.favorites) {
        items = await LevelRepository.getFavorites(_rootFolderPath!);
      } else {
        items = await LevelRepository.getDirectoryContents(
          activePath,
          sortMode: _sortMode,
        );
      }

      if (mounted) {
        setState(() {
          _fileItems = items;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _fileItems = [];
          _isLoading = false;
          if (_pathStack.length > 1) {
            _pathStack = [_pathStack.first];
            _loadCurrentDirectory();
          }
        });
      }
    }
  }

  void _navigateToFolder(FileItem folder) {
    setState(
      () =>
          _pathStack = [..._pathStack, (name: folder.name, path: folder.path)],
    );
    _resetListScrollToTop();
    _loadCurrentDirectory();
  }

  void _breadcrumbTap(int index) {
    setState(() => _pathStack = _pathStack.take(index + 1).toList());
    _resetListScrollToTop();
    _loadCurrentDirectory();
  }

  void _goToParentDirectory() {
    if (!_canGoBack) return;
    setState(
      () => _pathStack = _pathStack.take(_pathStack.length - 1).toList(),
    );
    _resetListScrollToTop();
    _loadCurrentDirectory();
  }

  Future<void> _handleRenameConfirm() async {
    final target = _itemToRename;
    if (target == null || _pathStack.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    var finalName = _renameInput.trim();
    if (!target.isDirectory) {
      final lowerRef = target.name.toLowerCase();
      if (lowerRef.endsWith('.rsb.smf')) {
        finalName = '$finalName.rsb.smf';
      } else if (lowerRef.endsWith('.smf')) {
        finalName = '$finalName.smf';
      } else {
        finalName = _ensureLevelExtension(finalName, target.name);
      }
    } else if (isReservedLibraryFolderName(finalName)) {
      _showWarningMessage(l10n.pluginsFolderReserved);
      return;
    }
    final ok = await LevelRepository.renameItem(
      _pathStack.last.path,
      target.name,
      finalName,
      target.isDirectory,
    );
    if (mounted) {
      if (ok) {
        _showSuccessMessage(l10n.renameSuccess);
        setState(() => _itemToRename = null);
        _loadCurrentDirectory();
      } else {
        _showWarningMessage(l10n.renamingFailed);
      }
    }
  }

  Future<void> _handleCopyConfirm(FileItem? target) async {
    if (target == null || _pathStack.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    var finalName = _copyInput.trim();
    finalName = _ensureLevelExtension(finalName, target.name);
    final ok = await LevelRepository.copyLevelToTarget(
      target.path,
      _pathStack.last.path,
      finalName,
    );
    if (mounted) {
      if (ok) {
        _showSuccessMessage(l10n.copySuccess);
        setState(() => _itemToCopy = null);
        _loadCurrentDirectory();
      } else {
        _showWarningMessage(l10n.copyFail);
      }
    }
  }

  Future<void> _handleNewFolder() async {
    if (_pathStack.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;

    String nameInput = _newFolderNameInput.trim();
    if (nameInput.isEmpty) {
      nameInput = l10n.newFolder;
    }

    if (isReservedLibraryFolderName(nameInput)) {
      if (mounted) {
        _showWarningMessage(l10n.pluginsFolderReserved);
      }
      return;
    }

    final finalName = await LevelRepository.getNextAvailableNameForTemplate(
      _pathStack.last.path,
      nameInput,
    );

    if (isReservedLibraryFolderName(finalName)) {
      if (mounted) {
        _showWarningMessage(l10n.pluginsFolderReserved);
      }
      return;
    }

    final ok = await LevelRepository.createDirectory(
      _pathStack.last.path,
      finalName,
    );

    if (mounted) {
      if (ok) {
        _showSuccessMessage(l10n.folderCreated);
        setState(() {
          _showNewFolderDialog = false;
          _newFolderNameInput = '';
        });
        _loadCurrentDirectory();
      } else {
        _showWarningMessage(l10n.createFail);
      }
    }
  }

  Future<void> _uploadLevel() async {
    final links = await AppLinks.load();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.uploadLevel),
        content: Text(l10n.uploadLevelConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.back),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.proceed),
          ),
        ],
      ),
    );

    if (ok == true) {
      await launchExternalUrl(links.levelUpload);
    }
  }

  void _openTemplateSelector() async {
    final l10n = AppLocalizations.of(context);
    List<String> list;
    try {
      final manifest = await rootBundle.loadString(
        'assets/reference/template/manifest.json',
      );
      list = LevelRepository.parseTemplateManifest(manifest);
    } catch (_) {
      list = [];
    }
    if (list.isEmpty) list = await LevelRepository.getTemplateList();
    if (!mounted) return;
    if (list.isEmpty) {
      _showMessage(l10n?.noTemplates ?? 'No templates found');
    } else {
      _templates = list;
      _showTemplateListDialog();
    }
  }

  static String _templateDisplayName(String filename, AppLocalizations? l10n) {
    if (l10n == null) return filename.replaceFirst(RegExp(r'\.json$'), '');
    switch (filename) {
      case '1_blank_level.json':
        return l10n.templateBlankLevel;
      case '2_card_pick_example.json':
        return l10n.templateCardPickExample;
      case '3_conveyor_example.json':
        return l10n.templateConveyorExample;
      case '4_last_stand_example.json':
        return l10n.templateLastStandExample;
      case '5_i_zombie_example.json':
        return l10n.templateIZombieExample;
      case '6_vase_breaker_example.json':
        return l10n.templateVaseBreakerExample;
      case '7_zombossmech_battle_example.json':
        return l10n.templateZombossMechExample;
      case '8_zomboss_battle_example.json':
        return l10n.templateZombossBattleExample;
      case '9_custom_zombie_example.json':
        return l10n.templateCustomZombieExample;
      case '10_i_plant_example.json':
        return l10n.templateIPlantExample;
      case '11_old_style_example.json':
        return l10n.templateOldStyleExample;
      case '12_custom_stage_example.json':
        return l10n.templateCustomStageExample;
      default:
        return filename.replaceFirst(RegExp(r'\.json$'), '');
    }
  }

  void _showTemplateListDialog() {
    final l10n = AppLocalizations.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.newLevelTemplate ?? 'New level - Select template'),
        content: SizedBox(
          width: double.maxFinite,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 320),
            child: ListView.builder(
              shrinkWrap: false,
              itemCount: _templates.length,
              itemBuilder: (_, i) {
                final t = _templates[i];
                return ListTile(
                  leading: const Icon(Icons.description, color: Colors.grey),
                  title: Text(_templateDisplayName(t, l10n)),
                  onTap: () async {
                    Navigator.pop(ctx);
                    _selectedTemplate = t;
                    final defaultBase = t.replaceFirst(RegExp(r'\.json$'), '');
                    if (_pathStack.isNotEmpty) {
                      _newLevelNameInput =
                          await LevelRepository.getNextAvailableNameForTemplate(
                            _pathStack.last.path,
                            defaultBase,
                          );
                    } else {
                      _newLevelNameInput = defaultBase;
                    }
                    if (mounted) _methodShowCreateNameDialog();
                  },
                );
              },
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
        ],
      ),
    );
  }

  void _methodShowCreateNameDialog() {
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: _newLevelNameInput);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.nameLevel),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: 'Name'),
          onChanged: (v) => _newLevelNameInput = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              _newLevelNameInput = ctrl.text;
              Navigator.pop(ctx);
              await _handleCreateLevelConfirm();
            },
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  Future<void> _handleCreateLevelConfirm() async {
    if (_pathStack.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    var name = _newLevelNameInput.trim();
    if (!name.toLowerCase().endsWith('.json')) name += '.json';
    // Load template from assets
    String content;
    try {
      content = await rootBundle.loadString(
        'assets/reference/template/$_selectedTemplate',
      );
    } catch (_) {
      content =
          '{"objects":[{"objclass":"LevelDefinition","objdata":{"Name":"","LevelNumber":1,"Description":"","StageModule":"RTID(TutorialStage@LevelModules)","Loot":"RTID(DefaultLoot@LevelModules)","StartingSun":200,"VictoryModule":"RTID(VictoryOutro@LevelModules)","MusicType":"MainPath","Modules":[]}}],"version":1}';
    }
    final ok = await LevelRepository.createLevelFromTemplate(
      _pathStack.last.path,
      _selectedTemplate,
      name,
      content,
    );
    if (mounted) {
      if (ok) {
        _showSuccessMessage(l10n.levelCreated);
        setState(() {
          _newLevelNameInput = '';
        });
        _loadCurrentDirectory();
      } else {
        _showWarningMessage(l10n.levelCreateFail);
      }
    }
  }

  Future<void> _downloadAllLevels() async {
    final l10n = AppLocalizations.of(context)!;
    if (!mounted) return;
    await runWebTransferWithProgress<void>(
      context,
      title: l10n.exportProgressTitle,
      task: (report, controller) => LevelRepository.downloadAllLevelsAsZip(
        onProgress: report,
      ),
    );
  }

  static const _compactHeaderBreakpoint = 300.0;

  List<Widget> _buildLevelListHeaderChildren({
    required ThemeData theme,
    required AppLocalizations l10n,
    required Color fabBgColor,
    required Color fabFgColor,
  }) {
    return [
      if (_viewMode != LevelViewMode.favorites)
        _BreadcrumbBar(
          pathStack: _pathStack,
          onBreadcrumbClick: _breadcrumbTap,
        ),
      Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxWidth < 240;
            return SizedBox(
              width: double.infinity,
              child: SegmentedButton<LevelViewMode>(
                showSelectedIcon: false,
                style: SegmentedButton.styleFrom(
                  visualDensity: VisualDensity.compact,
                  selectedBackgroundColor: fabBgColor,
                  selectedForegroundColor: fabFgColor,
                ),
                segments: [
                  ButtonSegment(
                    value: LevelViewMode.all,
                    icon: const Icon(
                      Icons.folder_outlined,
                      size: 20,
                    ),
                    label: compact ? null : Text(l10n.allLevelsCategory),
                    tooltip: l10n.allLevelsCategory,
                  ),
                  ButtonSegment(
                    value: LevelViewMode.favorites,
                    icon: const Icon(
                      Icons.favorite_outline,
                      size: 20,
                    ),
                    label: compact ? null : Text(l10n.favoritesCategory),
                    tooltip: l10n.favoritesCategory,
                  ),
                ],
                selected: {_viewMode},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    _viewMode = newSelection.first;
                    if (_viewMode == LevelViewMode.favorites &&
                        _pathStack.isNotEmpty) {
                      _pathStack = [_pathStack.first];
                      _resetListScrollToTop();
                    }
                    _loadCurrentDirectory();
                  });
                },
              ),
            );
          },
        ),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: TextField(
          controller: _searchController,
          onChanged: (value) => setState(() => _searchQuery = value),
          decoration: InputDecoration(
            hintText: l10n.searchLevel,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                : null,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 0),
          ),
        ),
      ),
      if (_canGoBack)
        Card(
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            onTap: _goToParentDirectory,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    alignment: Alignment.center,
                    child: const Icon(
                      Icons.arrow_back,
                      size: 30,
                      color: Color(0xFFFFC107),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      l10n.returnUp,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      if (_itemToMove != null)
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          color: theme.colorScheme.secondaryContainer,
          child: Row(
            children: [
              Icon(
                Icons.drive_file_move,
                color: theme.colorScheme.onSecondaryContainer,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      l10n.moving(_itemToMove!.name),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                    Text(
                      l10n.movePrompt,
                      style: TextStyle(
                        fontSize: 12,
                        color: theme.colorScheme.onSecondaryContainer
                            .withAlpha(204),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsCubit>().state;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final filteredItems = _fileItems.where((item) {
      if (_searchQuery.isEmpty) return true;
      return item.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    final fabBgColor =
        theme.floatingActionButtonTheme.backgroundColor ??
        theme.colorScheme.primaryContainer;
    final fabFgColor =
        theme.floatingActionButtonTheme.foregroundColor ??
        theme.colorScheme.onPrimaryContainer;

    final screenWidth = MediaQuery.sizeOf(context).width;
    final bool useCompactActions = screenWidth < 540;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          if (_viewMode == LevelViewMode.all)
            IconButton(
              icon: const Icon(Icons.sort),
              tooltip: l10n.sortByLabel,
              onPressed: _toggleSortMode,
            ),
          if (!kIsWeb && !useCompactActions) ...[
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: l10n.refresh,
              onPressed: _loadCurrentDirectory,
            ),
            IconButton(
              icon: const Icon(Icons.folder_open),
              tooltip: l10n.switchFolder,
              onPressed: _pickFolder,
            ),
          ],
          if (kIsWeb && !useCompactActions) ...[
            IconButton(
              icon: const Icon(Icons.file_open),
              tooltip: l10n.importFiles,
              onPressed: _pickAndAddFile,
            ),
            IconButton(
              icon: const Icon(Icons.drive_folder_upload_outlined),
              tooltip: l10n.importFolder,
              onPressed: _pickAndImportFolder,
            ),
            IconButton(
              icon: const Icon(Icons.download),
              tooltip: l10n.downloadAllLevels,
              onPressed: _downloadAllLevels,
            ),
          ],
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              if (useCompactActions) ...[
                if (!kIsWeb) ...[
                  PopupMenuItem(
                    value: 'refresh',
                    child: ListTile(
                      leading: const Icon(Icons.refresh),
                      title: Text(l10n.refresh),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'switch_folder',
                    child: ListTile(
                      leading: const Icon(Icons.folder_open),
                      title: Text(l10n.switchFolder),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                if (kIsWeb) ...[
                  PopupMenuItem(
                    value: 'import_files',
                    child: ListTile(
                      leading: const Icon(Icons.file_open),
                      title: Text(l10n.importFiles),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'import_folder',
                    child: ListTile(
                      leading: const Icon(Icons.drive_folder_upload_outlined),
                      title: Text(l10n.importFolder),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  PopupMenuItem(
                    value: 'download_all',
                    child: ListTile(
                      leading: const Icon(Icons.download),
                      title: Text(l10n.downloadAllLevels),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                const PopupMenuDivider(),
              ],
              PopupMenuItem(
                value: 'theme',
                child: ListTile(
                  leading: Icon(
                    settings.themeMode == ThemeMode.dark
                        ? Icons.light_mode
                        : Icons.dark_mode,
                  ),
                  title: Text(l10n.toggleTheme),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'cache',
                child: ListTile(
                  leading: const Icon(Icons.delete_outline),
                  title: Text(l10n.clearCache),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'ui',
                child: ListTile(
                  leading: const Icon(Icons.aspect_ratio),
                  title: Text(l10n.uiSize),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              PopupMenuItem(
                value: 'lang',
                child: ListTile(
                  leading: const Icon(Icons.language),
                  title: Text(l10n.language),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              if (!kIsWeb && !Platform.isIOS)
                PopupMenuItem(
                  value: 'export',
                  child: ListTile(
                    leading: const Icon(Icons.output_rounded),
                    title: Text(l10n.exportLevels),
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              PopupMenuItem(
                value: 'plugins',
                child: ListTile(
                  leading: const Icon(Icons.extension),
                  title: Text(l10n.pluginsTitle),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              ...pluginOverflowMenuItems(
                context: context,
                slot: CPluginUiSlots.levelListOverflow,
                valuePrefix: 'plugin:',
              ),
              PopupMenuItem(
                value: 'about',
                child: ListTile(
                  leading: const Icon(Icons.info_outline),
                  title: Text(l10n.aboutSoftware),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
            onSelected: (value) async {
              if (value == 'refresh') {
                _loadCurrentDirectory();
              } else if (value == 'switch_folder') {
                _pickFolder();
              } else if (value == 'import_files') {
                _pickAndAddFile();
              } else if (value == 'import_folder') {
                _pickAndImportFolder();
              } else if (value == 'download_all') {
                _downloadAllLevels();
              } else if (value == 'theme') {
                context.read<SettingsCubit>().cycleTheme();
              } else if (value == 'cache') {
                final count = await LevelRepository.clearAllInternalCache();
                if (context.mounted) {
                  _showMessage(l10n.cacheCleared(count));
                }
              } else if (value == 'ui') {
                setState(() => _showUiScaleDialog = true);
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _showUiScaleDialogImpl(),
                );
              } else if (value == 'lang') {
                Future.microtask(() {
                  if (!context.mounted) return;
                  widget.onLanguageTap(context);
                });
              } else if (value == 'export') {
                await Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => const ExportScreen(),
                  ),
                );
                if (mounted) {
                  _loadCurrentDirectory();
                }
              } else if (value == 'plugins') {
                widget.onPluginsClick();
              } else if (value == 'about') {
                Future.microtask(() {
                  if (!context.mounted) return;
                  widget.onAboutClick();
                });
              } else {
                handlePluginOverflowSelection(
                  context,
                  value: value,
                  valuePrefix: 'plugin:',
                  slot: CPluginUiSlots.levelListOverflow,
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_rootFolderPath == null)
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        l10n.initSetup,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.selectFolderPrompt,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      if (!kIsWeb)
                        FilledButton.icon(
                          onPressed: _pickFolder,
                          icon: const Icon(Icons.folder_open),
                          label: Text(l10n.selectFolderButton),
                        ),
                      if (kIsWeb) ...[
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _pickAndAddFile,
                          icon: const Icon(Icons.file_open),
                          label: Text(l10n.importFiles),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: _pickAndImportFolder,
                          icon: const Icon(
                            Icons.drive_folder_upload_outlined,
                          ),
                          label: Text(l10n.importFolder),
                        ),
                      ],
                      if (!kIsWeb && Platform.isIOS) ...[
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: _useDefaultIosLibraryFolder,
                          child: Text(l10n.useDefaultLibraryFolder),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            )
          else
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final useScrollableHeader =
                      constraints.maxHeight < _compactHeaderBreakpoint;
                  final headerChildren = _buildLevelListHeaderChildren(
                    theme: theme,
                    l10n: l10n,
                    fabBgColor: fabBgColor,
                    fabFgColor: fabFgColor,
                  );

                  return Column(
                    children: [
                      if (useScrollableHeader)
                        Flexible(
                          fit: FlexFit.loose,
                          child: ListView(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const ClampingScrollPhysics(),
                            children: headerChildren,
                          ),
                        )
                      else
                        ...headerChildren,
                      Expanded(
                        child: _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : filteredItems.isEmpty
                                ? Center(
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            _searchQuery.isEmpty
                                                ? Icons.folder_open
                                                : Icons.search_off,
                                            size: 64,
                                            color: theme.colorScheme
                                                .surfaceContainerHighest,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            _searchQuery.isEmpty
                                                ? (_viewMode ==
                                                        LevelViewMode.favorites
                                                    ? l10n.emptyFavorites
                                                    : l10n.emptyFolder)
                                                : l10n.noLevelsFound,
                                            style: TextStyle(
                                              color: theme
                                                  .colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    controller: _listScrollController,
                                    padding: const EdgeInsets.all(16),
                                    itemCount: filteredItems.length,
                                    itemBuilder: (context, index) {
                                      final item = filteredItems[index];
                                      final isMovingMode = _itemToMove != null;
                                      final isSelfMoving =
                                          isMovingMode && _itemToMove == item;
                                      final actionsDisabled = isMovingMode;
                                      return Opacity(
                                        opacity: (isMovingMode &&
                                                    !item.isDirectory) ||
                                                isSelfMoving
                                            ? 0.5
                                            : 1,
                                        child: _FileItemRow(
                                          item: item,
                                          l10n: l10n,
                                          rootFolderPath: _rootFolderPath,
                                          onTap: () async {
                                            if (isMovingMode) {
                                              if (item.isDirectory) {
                                                _navigateToFolder(item);
                                              }
                                            } else {
                                              if (item.isDirectory) {
                                                _navigateToFolder(item);
                                              } else {
                                                final lowerName =
                                                    item.name.toLowerCase();
                                                if (lowerName
                                                        .endsWith('.hujson') ||
                                                    lowerName
                                                        .endsWith('.rton')) {
                                                  final convertedPath =
                                                      await _showConversionRequiredDialog(
                                                    item,
                                                  );
                                                  if (!mounted ||
                                                      convertedPath == null) {
                                                    return;
                                                  }
                                                  final convertedName =
                                                      p.basename(
                                                    convertedPath,
                                                  );
                                                  final ok =
                                                      await LevelRepository
                                                          .prepareInternalCache(
                                                    convertedPath,
                                                    convertedName,
                                                  );
                                                  if (mounted && ok) {
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) {
                                                      if (!mounted) return;
                                                      widget.onLevelClick(
                                                        convertedName,
                                                        convertedPath,
                                                      );
                                                    });
                                                  }
                                                } else {
                                                  final ok =
                                                      await LevelRepository
                                                          .prepareInternalCache(
                                                    item.path,
                                                    item.name,
                                                  );
                                                  if (mounted && ok) {
                                                    WidgetsBinding.instance
                                                        .addPostFrameCallback(
                                                            (_) {
                                                      if (!mounted) return;
                                                      widget.onLevelClick(
                                                        item.name,
                                                        item.path,
                                                      );
                                                    });
                                                  }
                                                }
                                              }
                                            }
                                          },
                                          onRename: actionsDisabled
                                              ? () {}
                                              : () {
                                                  setState(() {
                                                    final lower = item.name
                                                        .toLowerCase();
                                                    if (lower.endsWith(
                                                        '.rsb.smf')) {
                                                      _renameInput = item.name
                                                          .substring(
                                                              0,
                                                              item.name.length -
                                                                  '.rsb.smf'
                                                                      .length);
                                                    } else if (lower
                                                        .endsWith('.smf')) {
                                                      _renameInput = item.name
                                                          .substring(
                                                              0,
                                                              item.name.length -
                                                                  '.smf'
                                                                      .length);
                                                    } else {
                                                      _renameInput = item
                                                              .isDirectory
                                                          ? item.name
                                                          : LevelRepository
                                                              .baseNameWithoutLevelExtension(
                                                              item.name,
                                                            );
                                                    }
                                                    _itemToRename = item;
                                                  });
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                    (_) => _showRenameDialog(),
                                                  );
                                                },
                                          onDelete: actionsDisabled
                                              ? () {}
                                              : () {
                                                  setState(() =>
                                                      _itemToDelete = item);
                                                  WidgetsBinding.instance
                                                      .addPostFrameCallback(
                                                    (_) => _showDeleteDialog(),
                                                  );
                                                },
                                          onDownload: kIsWeb &&
                                                  !item.isDirectory
                                              ? () => LevelRepository
                                                  .downloadLevel(
                                                  item.name,
                                                )
                                              : null,
                                          onDownloadFolder: kIsWeb &&
                                                  item.isDirectory
                                              ? () => _downloadFolderZip(item)
                                              : null,
                                          onCopy: actionsDisabled
                                              ? () {}
                                              : () async {
                                                  if (!item.isDirectory &&
                                                      _pathStack.isNotEmpty) {
                                                    final baseName =
                                                        LevelRepository
                                                            .baseNameWithoutLevelExtension(
                                                      item.name,
                                                    );
                                                    final nextName =
                                                        await LevelRepository
                                                            .getNextAvailableCopyName(
                                                      _pathStack.last.path,
                                                      baseName,
                                                    );
                                                    if (mounted) {
                                                      setState(() {
                                                        _copyInput = nextName;
                                                        _itemToCopy = item;
                                                      });
                                                      WidgetsBinding.instance
                                                          .addPostFrameCallback(
                                                        (_) =>
                                                            _showCopyDialog(),
                                                      );
                                                    }
                                                  }
                                                },
                                          onMove: actionsDisabled
                                              ? () {}
                                              : () {
                                                  if (!item.isDirectory &&
                                                      _pathStack.isNotEmpty) {
                                                    setState(() {
                                                      _itemToMove = item;
                                                      _moveSourcePath =
                                                          _pathStack.last.path;
                                                    });
                                                  }
                                                },
                                          onConvert: actionsDisabled ||
                                                  item.isDirectory ||
                                                  item.name
                                                      .toLowerCase()
                                                      .endsWith('.smf')
                                              ? null
                                              : () => _showConvertMenuFor(item),
                                          onToggleFavorite: actionsDisabled ||
                                                  item.isDirectory
                                              ? null
                                              : () => _toggleFavorite(item),
                                          onShare: actionsDisabled ||
                                                  item.isDirectory ||
                                                  !isLevelFileShareSupported
                                              ? null
                                              : () => _handleShare(item),
                                          showMove:
                                              !item.isDirectory && !kIsWeb,
                                        ),
                                      );
                                    },
                                  ),
                      ),
                    ],
                  );
                },
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _rootFolderPath != null
          ? _itemToMove != null
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FloatingActionButton.extended(
                      heroTag: 'moveCancel',
                      onPressed: () {
                        setState(() {
                          _itemToMove = null;
                          _moveSourcePath = null;
                        });
                      },
                      backgroundColor: theme.colorScheme.error,
                      foregroundColor: theme.colorScheme.onError,
                      icon: const Icon(Icons.close),
                      label: Text(l10n.cancel),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton.extended(
                      heroTag: 'movePaste',
                      onPressed: _handleMoveConfirm,
                      icon: const Icon(Icons.content_paste),
                      label: Text(l10n.paste),
                    ),
                  ],
                )
              : _AnimatedUploadFab(
                  visible: _listScrollAtTop,
                  onPressed: _uploadLevel,
                  label: l10n.uploadLevel,
                )
          : null,
      bottomNavigationBar: _rootFolderPath == null || _itemToMove != null
          ? null
          : SafeArea(
              top: false,
              child: Container(
                color: fabBgColor,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    _buildBottomNavButton(
                      onPressed: _canGoBack ? _goToParentDirectory : null,
                      icon: Icons.arrow_upward,
                      label: l10n.back,
                      fgColor: fabFgColor,
                      disabledFgColor: fabFgColor.withValues(alpha: 0.45),
                    ),
                    _buildBottomNavButton(
                      onPressed: _openTemplateSelector,
                      icon: Icons.add,
                      label: l10n.newLevel,
                      fgColor: fabFgColor,
                    ),
                    _buildBottomNavButton(
                      onPressed: () {
                        setState(() => _showNewFolderDialog = true);
                        WidgetsBinding.instance.addPostFrameCallback(
                          (_) => _showNewFolderDialogImpl(),
                        );
                      },
                      icon: Icons.create_new_folder,
                      label: l10n.newFolder,
                      fgColor: fabFgColor,
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBottomNavButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color fgColor,
    Color? disabledFgColor,
  }) {
    return Expanded(
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: fgColor,
          disabledForegroundColor: disabledFgColor,
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 4),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }

  void _showNewFolderDialogImpl() {
    if (!_showNewFolderDialog || !mounted) return;
    setState(() => _showNewFolderDialog = false);
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: _newFolderNameInput);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.newFolder),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(
              labelText: l10n.folderName, helperText: l10n.newFolderNameHint),
          onChanged: (v) => _newFolderNameInput = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              _newFolderNameInput = ctrl.text;
              Navigator.pop(ctx);
              await _handleNewFolder();
            },
            child: Text(l10n.create),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog() {
    final item = _itemToRename;
    if (item == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: _renameInput);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.rename),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(labelText: l10n.newName),
          onChanged: (v) => _renameInput = v,
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() => _itemToRename = null);
              Navigator.pop(ctx);
            },
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              _renameInput = ctrl.text;
              Navigator.pop(ctx);
              await _handleRenameConfirm();
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    final target = _itemToDelete;
    if (target == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    var confirm = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.confirmDelete),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.confirmDeleteMessage(
                  target.isDirectory
                      ? l10n.folderDeleteDetail
                      : l10n.levelDeleteDetail,
                  target.name,
                ),
              ),
              const SizedBox(height: 16),
              CheckboxListTile(
                value: confirm,
                onChanged: (v) => setDialogState(() => confirm = v ?? false),
                title: Text(l10n.confirmDeleteCheckbox),
                controlAffinity: ListTileControlAffinity.leading,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => _itemToDelete = null);
                Navigator.pop(ctx);
              },
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: confirm
                  ? () async {
                      Navigator.pop(ctx);
                      await _handleDeleteConfirmFor(target);
                    }
                  : null,
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error,
                foregroundColor: Colors.white,
              ),
              child: Text(l10n.confirm),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoveSnackbar(String type, {String? newFileName}) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final String text;
    final bool isSuccess;
    switch (type) {
      case 'success':
        text = l10n.movingSuccess;
        isSuccess = true;
        break;
      case 'renamed':
        text = l10n.movedAs(newFileName ?? '');
        isSuccess = true;
        break;
      case 'overwritten':
        text = l10n.fileOverwritten(newFileName ?? '');
        isSuccess = true;
        break;
      case 'cancelled':
        text = l10n.moveCancelled;
        isSuccess = false;
        break;
      case 'sameFolder':
        text = l10n.moveSameFolder;
        isSuccess = false;
        break;
      case 'fail':
        text = l10n.movingFail;
        isSuccess = false;
        break;
      default:
        return;
    }
    if (isSuccess) {
      _showSuccessMessage(text);
    } else {
      _showWarningMessage(text);
    }
  }

  Future<String?> _showConversionRequiredDialog(FileItem item) async {
    if (_pathStack.isEmpty || item.isDirectory) return null;
    final l10n = AppLocalizations.of(context)!;
    final lower = item.name.toLowerCase();
    final formatDescription = lower.endsWith('.hujson')
        ? l10n.hujsonFormatDescription
        : lower.endsWith('.rton')
            ? l10n.rtonFormatDescription
            : null;
    final shouldConvert = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.conversionRequiredTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.conversionRequiredMessage),
            if (formatDescription != null) ...[
              const SizedBox(height: 12),
              Text(
                formatDescription,
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.convertAction),
          ),
        ],
      ),
    );
    if (shouldConvert != true || !mounted) return null;
    final convertedName = await _convertItemToExtension(item, '.json');
    if (!mounted || convertedName == null || _pathStack.isEmpty) return null;
    return p.join(_pathStack.last.path, convertedName);
  }

  Future<String?> _convertItemToExtension(
    FileItem item,
    String targetExt,
  ) async {
    if (_pathStack.isEmpty || item.isDirectory) return null;
    final l10n = AppLocalizations.of(context)!;

    final dir = _pathStack.last.path;
    final base = LevelRepository.baseNameWithoutLevelExtension(item.name);
    var targetName = '$base$targetExt';
    final exists = await LevelRepository.fileExistsInDirectory(dir, targetName);
    if (!mounted) return null;
    if (exists) {
      final suggested = await LevelRepository.getFirstAvailableIndexedName(
        dir,
        base,
        targetExt,
      );
      if (!mounted) return null;
      final input = TextEditingController(text: suggested);
      final chosen = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.moveFileExistsTitle),
          content: TextField(
            controller: input,
            decoration: InputDecoration(labelText: l10n.newFileName),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.cancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, input.text.trim()),
              child: Text(l10n.convertAction),
            ),
          ],
        ),
      );
      if (chosen == null || chosen.isEmpty) return null;
      if (!mounted) return null;
      targetName = chosen;
      if (!targetName.toLowerCase().endsWith(targetExt)) {
        targetName += targetExt;
      }
    }

    final converted = await LevelRepository.convertLevelFile(
      sourcePath: item.path,
      sourceName: item.name,
      targetExtension: targetExt,
      targetName: targetName,
    );
    if (!mounted) return null;
    if (converted != null) {
      _showSuccessMessage(l10n.convertedMessage(converted));
      await _loadCurrentDirectory();
      return converted;
    }
    _showWarningMessage(l10n.conversionFailed);
    return null;
  }

  Future<void> _showConvertMenuFor(FileItem item) async {
    if (_pathStack.isEmpty || item.isDirectory) return;
    final l10n = AppLocalizations.of(context)!;
    final lower = item.name.toLowerCase();
    String? targetExt;
    if (lower.endsWith('.json')) {
      targetExt = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.convertAction),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.sync_alt),
                title: Text(l10n.convertToHotUpdateJson),
                subtitle: Text(l10n.hujsonFormatDescription),
                isThreeLine: true,
                onTap: () => Navigator.pop(ctx, '.hujson'),
              ),
              ListTile(
                leading: const Icon(Icons.sync_alt),
                title: Text(l10n.convertToEncryptedRton),
                subtitle: Text(l10n.rtonFormatDescription),
                isThreeLine: true,
                onTap: () => Navigator.pop(ctx, '.rton'),
              ),
              if (kDebugMode)
                ListTile(
                  leading: const Icon(Icons.compress),
                  title: const Text('Compress with ZLib'),
                  onTap: () => Navigator.pop(ctx, '.zlib'),
                ),
            ],
          ),
        ),
      );
    } else if (lower.endsWith('.hujson') || lower.endsWith('.rton')) {
      targetExt = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.convertAction),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.sync_alt),
                title: Text(l10n.convertToJson),
                onTap: () => Navigator.pop(ctx, '.json'),
              ),
              if (kDebugMode)
                ListTile(
                  leading: const Icon(Icons.compress),
                  title: const Text('Compress with ZLib'),
                  onTap: () => Navigator.pop(ctx, '.zlib'),
                ),
            ],
          ),
        ),
      );
    } else if (lower.endsWith('.zlib')) {
      targetExt = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.convertAction),
          content: ListTile(
            leading: const Icon(Icons.expand),
            title: const Text('Decompress ZLib'),
            onTap: () => Navigator.pop(ctx, '.bin'),
          ),
        ),
      );
    }
    if (targetExt == null || !mounted) return;
    await _convertItemToExtension(item, targetExt);
  }

  Future<void> _handleMoveConfirm() async {
    final target = _itemToMove;
    final srcPath = _moveSourcePath;
    if (target == null || srcPath == null || _pathStack.isEmpty) return;
    final destPath = _pathStack.last.path;
    if (srcPath == destPath) {
      _showMoveSnackbar('sameFolder');
      setState(() {
        _itemToMove = null;
        _moveSourcePath = null;
      });
      return;
    }
    final destExists = await LevelRepository.fileExistsInDirectory(
      destPath,
      target.name,
    );
    if (!mounted) return;
    if (destExists) {
      final l10n = AppLocalizations.of(context)!;
      final choice = await showDialog<int>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.moveFileExistsTitle),
          content: Text(l10n.moveFileExistsMessage),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, 0),
              style: TextButton.styleFrom(foregroundColor: Colors.amber),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 2),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
              child: Text(l10n.moveSaveAsCopy),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, 1),
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(ctx).colorScheme.error,
              ),
              child: Text(l10n.moveOverwrite),
            ),
          ],
        ),
      );
      if (!mounted) return;
      if (choice == 0) {
        _showMoveSnackbar('cancelled');
        setState(() {
          _itemToMove = null;
          _moveSourcePath = null;
        });
        return;
      }
      if (choice == 1) {
        final ok = await LevelRepository.moveFileOverwriting(
          srcPath,
          target.name,
          destPath,
        );
        if (mounted) {
          _showMoveSnackbar(
            ok ? 'overwritten' : 'fail',
            newFileName: target.name,
          );
          setState(() {
            _itemToMove = null;
            _moveSourcePath = null;
          });
          _loadCurrentDirectory();
        }
        return;
      }
      if (choice == 2) {
        final baseName = LevelRepository.baseNameWithoutLevelExtension(
          target.name,
        );
        final suggested = await LevelRepository.getNextAvailableCopyName(
          destPath,
          baseName,
        );
        final ext = _levelExtensionFromFileName(target.name);
        final suggestedFileName = '$suggested$ext';
        if (!mounted) return;
        final nameResult = await showDialog<String>(
          context: context,
          barrierDismissible: false,
          builder: (ctx) {
            final ctrl = TextEditingController(text: suggestedFileName);
            return AlertDialog(
              title: Text(l10n.moveSaveAsCopy),
              content: TextField(
                controller: ctrl,
                decoration: InputDecoration(labelText: l10n.newFileName),
                onSubmitted: (v) =>
                    Navigator.pop(ctx, v.trim().isEmpty ? null : v),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx, null),
                  style: TextButton.styleFrom(
                    foregroundColor: Theme.of(ctx).colorScheme.error,
                  ),
                  child: Text(l10n.cancel),
                ),
                FilledButton(
                  onPressed: () {
                    final v = ctrl.text.trim();
                    Navigator.pop(ctx, v.isEmpty ? null : v);
                  },
                  style: FilledButton.styleFrom(backgroundColor: Colors.green),
                  child: Text(l10n.confirm),
                ),
              ],
            );
          },
        );
        if (!mounted) return;
        if (nameResult == null) {
          _showMoveSnackbar('cancelled');
          setState(() {
            _itemToMove = null;
            _moveSourcePath = null;
          });
          return;
        }
        final finalName = _ensureLevelExtension(nameResult, target.name);
        final newName = await LevelRepository.moveFileWithName(
          srcPath,
          target.name,
          destPath,
          finalName,
        );
        if (mounted) {
          if (newName != null) {
            _showMoveSnackbar('renamed', newFileName: newName);
          } else {
            _showMoveSnackbar('fail');
          }
          setState(() {
            _itemToMove = null;
            _moveSourcePath = null;
          });
          _loadCurrentDirectory();
        }
        return;
      }
    }
    final ok = await LevelRepository.moveFile(srcPath, target.name, destPath);
    if (mounted) {
      _showMoveSnackbar(ok ? 'success' : 'fail');
      setState(() {
        _itemToMove = null;
        _moveSourcePath = null;
      });
      _loadCurrentDirectory();
    }
  }

  Future<void> _handleDeleteConfirmFor(FileItem target) async {
    if (_pathStack.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    await LevelRepository.deleteItem(
      _pathStack.last.path,
      target.name,
      target.isDirectory,
    );
    if (mounted) {
      _showSuccessMessage(l10n.deleted);
      _loadCurrentDirectory();
    }
  }

  Future<void> _toggleFavorite(FileItem item) async {
    if (item.isDirectory) return;
    final l10n = AppLocalizations.of(context)!;
    final next = !item.isFavorite;
    await LevelRepository.setFavoriteLevelPath(item.path, next);
    if (!mounted) return;
    _showSuccessMessage(
      next ? l10n.addedToFavorites : l10n.removedFromFavorites,
    );
    await _loadCurrentDirectory();
    if (!mounted) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _resetListScrollToTop();
      setState(() {});
    });
  }

  Future<void> _handleShare(FileItem item) async {
    if (item.isDirectory || !mounted || !isLevelFileShareSupported) return;
    final l10n = AppLocalizations.of(context)!;

    await shareLevelFile(
      context: context,
      itemPath: item.path,
      caption: l10n.shareLevelFileText(item.name),
      failureMessage: l10n.shareLevelFailed,
      onFailure: _showMessage,
    );
  }

  void _showCopyDialog() {
    final item = _itemToCopy;
    if (item == null || !mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final ctrl = TextEditingController(text: _copyInput);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.copyLevel),
        content: TextField(
          controller: ctrl,
          decoration: InputDecoration(labelText: l10n.newFileName),
          onChanged: (v) => _copyInput = v,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () async {
              _copyInput = ctrl.text;
              Navigator.pop(ctx);
              await _handleCopyConfirm(item);
            },
            child: Text(l10n.copy),
          ),
        ],
      ),
    );
  }

  void _showUiScaleDialogImpl() {
    if (!_showUiScaleDialog || !mounted) return;
    setState(() => _showUiScaleDialog = false);
    final l10n = AppLocalizations.of(context)!;
    var tempScale = context.read<SettingsCubit>().state.uiScale;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(l10n.adjustUiSize),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.currentScale((tempScale * 100).toInt().toString())),
              Slider(
                value: tempScale,
                min: 0.75,
                max: 1.5,
                onChanged: (v) => setDialogState(() => tempScale = v),
              ),
              _UiScalePresetLabels(
                currentScale: tempScale,
                onPresetSelected: (scale) =>
                    setDialogState(() => tempScale = scale),
                smallLabel: l10n.small,
                standardLabel: l10n.standard,
                largeLabel: l10n.large,
                ultraLabel: l10n.ultra,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<SettingsCubit>().setUiScale(1.0);
                Navigator.pop(ctx);
              },
              child: Text(l10n.reset),
            ),
            TextButton(
              onPressed: () {
                context.read<SettingsCubit>().setUiScale(tempScale);
                Navigator.pop(ctx);
              },
              child: Text(l10n.done),
            ),
          ],
        ),
      ),
    );
  }
}

class _BreadcrumbBar extends StatelessWidget {
  const _BreadcrumbBar({
    required this.pathStack,
    required this.onBreadcrumbClick,
  });

  final List<({String name, String path})> pathStack;
  final void Function(int index) onBreadcrumbClick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: Row(
        children: [
          for (int i = 0; i < pathStack.length; i++) ...[
            InkWell(
              onTap: i < pathStack.length - 1
                  ? () => onBreadcrumbClick(i)
                  : null,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: i == pathStack.length - 1
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (i == 0) ...[
                      Icon(
                        Icons.folder_open,
                        size: 16,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 4),
                    ],
                    Text(
                      pathStack[i].name,
                      style: TextStyle(
                        fontWeight: i == pathStack.length - 1
                            ? FontWeight.bold
                            : FontWeight.w500,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (i < pathStack.length - 1) ...[
              const SizedBox(width: 4),
              Icon(
                Icons.arrow_forward_ios,
                size: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
            ],
          ],
        ],
      ),
    );
  }
}

class _FileItemRow extends StatelessWidget {
  const _FileItemRow({
    required this.item,
    required this.l10n,
    required this.onTap,
    required this.onRename,
    required this.onDelete,
    required this.onCopy,
    required this.onMove,
    required this.showMove,
    this.rootFolderPath,
    this.onDownload,
    this.onDownloadFolder,
    this.onConvert,
    this.onToggleFavorite,
    this.onShare,
  });

  final FileItem item;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final VoidCallback onMove;
  final bool showMove;
  final String? rootFolderPath;
  final VoidCallback? onDownload;
  final VoidCallback? onDownloadFolder;
  final VoidCallback? onConvert;
  final VoidCallback? onToggleFavorite;
  final VoidCallback? onShare;

  static const _iconBtnStyle = ButtonStyle(
    padding: WidgetStatePropertyAll(EdgeInsets.all(6)),
    minimumSize: WidgetStatePropertyAll(Size(32, 32)),
    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
  );

  static Widget _popupMenuTile({
    required IconData icon,
    required String label,
    Color? iconColor,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, size: 22, color: iconColor),
      title: Text(
        label,
        style: textColor != null ? TextStyle(color: textColor) : null,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      visualDensity: VisualDensity.compact,
    );
  }

  String _favoriteActionLabel(BuildContext context) {
    final languageCode = Localizations.localeOf(context).languageCode;
    if (item.isFavorite) {
      return switch (languageCode) {
        'zh' => '\u53d6\u6d88\u6536\u85cf',
        'ru' =>
          '\u0423\u0431\u0440\u0430\u0442\u044c \u0438\u0437 '
              '\u0438\u0437\u0431\u0440\u0430\u043d\u043d\u043e\u0433\u043e',
        _ => 'Unfavorite',
      };
    }
    return switch (languageCode) {
      'zh' => '\u6536\u85cf',
      'ru' => '\u0412 \u0438\u0437\u0431\u0440\u0430\u043d\u043d\u043e\u0435',
      _ => 'Favorite',
    };
  }

  Widget _buildLevelFileMenu(BuildContext context, ThemeData theme) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: theme.colorScheme.onSurfaceVariant,
        size: 22,
      ),
      padding: const EdgeInsets.all(6),
      itemBuilder: (_) => [
        if (onToggleFavorite != null)
          PopupMenuItem(
            value: 'favorite',
            child: _popupMenuTile(
              icon: item.isFavorite ? Icons.favorite : Icons.favorite_border,
              label: _favoriteActionLabel(context),
              iconColor: item.isFavorite ? theme.colorScheme.error : null,
            ),
          ),
        ...pluginLevelFileMenuItems(
          context: context,
          fileName: item.name,
          valuePrefix: 'pfile:',
        ),
        PopupMenuItem(
          value: 'rename',
          child: _popupMenuTile(icon: Icons.edit, label: l10n.rename),
        ),
        PopupMenuItem(
          value: 'copy',
          child: _popupMenuTile(icon: Icons.copy, label: l10n.copy),
        ),
        if (onDownload != null)
          PopupMenuItem(
            value: 'download',
            child: _popupMenuTile(icon: Icons.download, label: l10n.download),
          ),
        if (onConvert != null)
          PopupMenuItem(
            value: 'convert',
            child: _popupMenuTile(
              icon: Icons.swap_horiz,
              label: l10n.convertHelpTooltip,
            ),
          ),
        if (onShare != null)
          PopupMenuItem(
            value: 'share',
            child: _popupMenuTile(
              icon: Icons.share,
              label: l10n.share,
            ),
          ),
        if (showMove)
          PopupMenuItem(
            value: 'move',
            child: _popupMenuTile(
              icon: Icons.drive_file_move,
              label: l10n.move,
            ),
          ),
        PopupMenuItem(
          value: 'delete',
          child: _popupMenuTile(
            icon: Icons.delete,
            label: l10n.delete,
            iconColor: theme.colorScheme.error,
            textColor: theme.colorScheme.error,
          ),
        ),
      ],
      onSelected: (v) {
        if (handlePluginLevelFileSelection(
          context,
          value: v,
          valuePrefix: 'pfile:',
          fileName: item.name,
          filePath: item.path,
        )) {
          return;
        }
        switch (v) {
          case 'favorite':
            onToggleFavorite?.call();
          case 'rename':
            onRename();
          case 'copy':
            onCopy();
          case 'download':
            onDownload?.call();
          case 'convert':
            onConvert?.call();
          case 'share':
            onShare?.call();
          case 'move':
            onMove();
          case 'delete':
            onDelete();
        }
      },
    );
  }

  Widget _buildLevelFileActions(BuildContext context, ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (item.isFavorite) ...[
          const Icon(Icons.favorite, color: Colors.red, size: 20),
          const SizedBox(width: 4),
        ],
        _buildLevelFileMenu(context, theme),
      ],
    );
  }

  Widget _buildFolderMenu(ThemeData theme) {
    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert,
        color: theme.colorScheme.onSurfaceVariant,
        size: 22,
      ),
      padding: const EdgeInsets.all(6),
      itemBuilder: (_) => [
        if (onDownloadFolder != null)
          PopupMenuItem(
            value: 'download',
            child: _popupMenuTile(
              icon: Icons.download,
              label: l10n.downloadFolder,
            ),
          ),
        PopupMenuItem(
          value: 'rename',
          child: _popupMenuTile(icon: Icons.edit, label: l10n.rename),
        ),
        PopupMenuItem(
          value: 'delete',
          child: _popupMenuTile(
            icon: Icons.delete,
            label: l10n.delete,
            iconColor: theme.colorScheme.error,
            textColor: theme.colorScheme.error,
          ),
        ),
      ],
      onSelected: (v) {
        switch (v) {
          case 'download':
            onDownloadFolder?.call();
          case 'rename':
            onRename();
          case 'delete':
            onDelete();
        }
      },
    );
  }

  Widget _buildFolderActions(ThemeData theme) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (onDownloadFolder != null)
          IconButton(
            icon:
                Icon(Icons.download, color: theme.colorScheme.onSurfaceVariant),
            tooltip: l10n.downloadFolder,
            onPressed: onDownloadFolder,
            iconSize: 22,
            style: _iconBtnStyle,
          ),
        IconButton(
          icon: Icon(Icons.edit, color: theme.colorScheme.onSurfaceVariant),
          tooltip: l10n.rename,
          onPressed: onRename,
          iconSize: 22,
          style: _iconBtnStyle,
        ),
        IconButton(
          icon: Icon(Icons.delete, color: theme.colorScheme.error, size: 22),
          tooltip: l10n.delete,
          onPressed: onDelete,
          iconSize: 22,
          style: _iconBtnStyle,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmfFile =
        !item.isDirectory && item.name.toLowerCase().endsWith('.smf');
    final isRsbSmf =
        !item.isDirectory && item.name.toLowerCase().endsWith('.rsb.smf');

    final displayName = item.isDirectory
        ? item.name
        : (isRsbSmf
            ? item.name.substring(0, item.name.length - '.rsb.smf'.length)
            : (isSmfFile
                ? item.name.substring(0, item.name.length - '.smf'.length)
                : LevelRepository.baseNameWithoutLevelExtension(item.name)));

    final isResourceFile = isSmfFile;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: isResourceFile ? null : onTap,
        borderRadius: BorderRadius.circular(12),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const compactBreakpoint = 140.0;
            final compact = constraints.maxWidth < compactBreakpoint;
            final hPad = compact ? 8.0 : 16.0;
            final iconBox = compact ? 32.0 : 40.0;
            final iconSize = compact ? 28.0 : 36.0;
            final gap = compact ? 8.0 : 12.0;
            final actions = item.isDirectory
                ? (compact
                    ? _buildFolderMenu(theme)
                    : _buildFolderActions(theme))
                : _buildLevelFileActions(context, theme);

            return Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 12),
              child: Row(
                children: [
                  SizedBox(
                    width: iconBox,
                    height: iconBox,
                    child: Icon(
                      item.isDirectory
                          ? Icons.folder
                          : (isResourceFile
                              ? Icons.inventory_2_outlined
                              : Icons.description),
                      size: iconSize,
                      color: item.isDirectory
                          ? const Color(0xFFFFC107)
                          : (isResourceFile
                              ? Colors.blueGrey
                              : theme.colorScheme.primary),
                    ),
                  ),
                  SizedBox(width: gap),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (!item.isDirectory) ...[
                          const SizedBox(height: 2),
                          Text(
                            isRsbSmf
                                ? '.rsb.smf'
                                : (isSmfFile
                                    ? '.smf'
                                    : p
                                        .extension(item.name)
                                        .replaceFirst('.', '')
                                        .toUpperCase()),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Flexible(
                    fit: FlexFit.loose,
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerRight,
                        child: actions,
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _AnimatedUploadFab extends StatefulWidget {
  const _AnimatedUploadFab({
    required this.visible,
    required this.onPressed,
    required this.label,
  });

  final bool visible;
  final VoidCallback onPressed;
  final String label;

  @override
  State<_AnimatedUploadFab> createState() => _AnimatedUploadFabState();
}

class _AnimatedUploadFabState extends State<_AnimatedUploadFab>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 320);

  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _duration,
    value: widget.visible ? 1 : 0,
  );

  late final Animation<double> _reveal = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );

  late final Animation<Offset> _slide = Tween<Offset>(
    begin: const Offset(0, 0.5),
    end: Offset.zero,
  ).animate(_reveal);

  @override
  void didUpdateWidget(covariant _AnimatedUploadFab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizeTransition(
      sizeFactor: _reveal,
      axisAlignment: 1,
      child: FadeTransition(
        opacity: _reveal,
        child: SlideTransition(
          position: _slide,
          child: IgnorePointer(
            ignoring: !widget.visible,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = MediaQuery.sizeOf(context).width;
                final isNarrow = screenWidth < 500;

                final Widget fab;
                if (isNarrow) {
                  fab = FloatingActionButton(
                    heroTag: 'uploadLevel',
                    onPressed: widget.onPressed,
                    tooltip: widget.label,
                    child: const Icon(Icons.cloud_upload),
                  );
                } else {
                  fab = FloatingActionButton.extended(
                    heroTag: 'uploadLevel',
                    onPressed: widget.onPressed,
                    icon: const Icon(Icons.cloud_upload),
                    label: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: (screenWidth - 160).clamp(
                          0,
                          double.infinity,
                        ),
                      ),
                      child: Text(
                        widget.label,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  );
                }

                return Align(
                  alignment: Alignment.centerRight,
                  widthFactor: 1,
                  heightFactor: 1,
                  child: fab,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _UiScalePresetLabels extends StatelessWidget {
  const _UiScalePresetLabels({
    required this.currentScale,
    required this.onPresetSelected,
    required this.smallLabel,
    required this.standardLabel,
    required this.largeLabel,
    required this.ultraLabel,
  });

  static const double smallScale = 0.75;
  static const double standardScale = 1.0;
  static const double largeScale = 1.25;
  static const double ultraScale = 1.5;
  static const double _presetTolerance = 0.0001;

  final double currentScale;
  final ValueChanged<double> onPresetSelected;
  final String smallLabel;
  final String standardLabel;
  final String largeLabel;
  final String ultraLabel;

  bool _isSelected(double scale) {
    return (currentScale - scale).abs() <= _presetTolerance;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _UiScalePresetLabel(
          label: smallLabel,
          scale: smallScale,
          alignment: Alignment.centerLeft,
          isSelected: _isSelected(smallScale),
          onSelected: onPresetSelected,
        ),
        _UiScalePresetLabel(
          label: standardLabel,
          scale: standardScale,
          alignment: Alignment.center,
          isSelected: _isSelected(standardScale),
          onSelected: onPresetSelected,
        ),
        _UiScalePresetLabel(
          label: largeLabel,
          scale: largeScale,
          alignment: Alignment.center,
          isSelected: _isSelected(largeScale),
          onSelected: onPresetSelected,
        ),
        _UiScalePresetLabel(
          label: ultraLabel,
          scale: ultraScale,
          alignment: Alignment.centerRight,
          isSelected: _isSelected(ultraScale),
          onSelected: onPresetSelected,
        ),
      ],
    );
  }
}

class _UiScalePresetLabel extends StatelessWidget {
  const _UiScalePresetLabel({
    required this.label,
    required this.scale,
    required this.alignment,
    required this.isSelected,
    required this.onSelected,
  });

  final String label;
  final double scale;
  final AlignmentGeometry alignment;
  final bool isSelected;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.bodySmall?.copyWith(
      color: isSelected ? theme.colorScheme.primary : null,
      fontWeight: isSelected ? FontWeight.bold : null,
    );

    return Expanded(
      child: Semantics(
        button: true,
        selected: isSelected,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: () => onSelected(scale),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Align(
              alignment: alignment,
              child: Text(label, overflow: TextOverflow.ellipsis, style: style),
            ),
          ),
        ),
      ),
    );
  }
}
