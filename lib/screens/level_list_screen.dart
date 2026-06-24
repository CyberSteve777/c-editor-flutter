import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kDebugMode, kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as p;
import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/data/app_links.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/level_list_platform.dart';
import 'package:url_launcher/url_launcher.dart';

class LevelListScreen extends StatefulWidget {
  const LevelListScreen({
    super.key,
    required this.onLevelClick,
    required this.onAboutClick,
    required this.onLanguageTap,
  });

  final void Function(String fileName, String filePath) onLevelClick;
  final VoidCallback onAboutClick;
  final ValueChanged<BuildContext> onLanguageTap;

  @override
  State<LevelListScreen> createState() => _LevelListScreenState();
}

class _LevelListScreenState extends State<LevelListScreen> {
  static const _successSnackBarMaxWidth = 360.0;
  static const _successSnackBarHorizontalPadding = 16.0;
  static const _successSnackBarEstimatedHeight = 48.0;

  List<FileItem> _fileItems = [];
  bool _isLoading = false;
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
  final ScrollController _listScrollController = ScrollController();
  bool _listScrollAtTop = true;

  bool get _canGoBack => _pathStack.length > 1;

  void _showFloatingSuccessSnackBar(String message, {Color? backgroundColor}) {
    if (!mounted) return;
    final theme = Theme.of(context);
    final media = MediaQuery.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bgColor =
        backgroundColor ??
        (isDark ? const Color(0xFF2E7D32) : const Color(0xFF4CAF50));
    final maxSnackBarWidth =
        media.size.width - (_successSnackBarHorizontalPadding * 2);
    final snackBarWidth = maxSnackBarWidth < _successSnackBarMaxWidth
        ? maxSnackBarWidth
        : _successSnackBarMaxWidth;
    final horizontalMargin = (media.size.width - snackBarWidth) / 2;
    final usableHeight =
        media.size.height - media.padding.top - media.padding.bottom;
    final bottomMargin =
        (usableHeight / 2) - (_successSnackBarEstimatedHeight / 2);

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            left: horizontalMargin,
            right: horizontalMargin,
            bottom: bottomMargin > 0 ? bottomMargin : 0,
          ),
          backgroundColor: bgColor,
          content: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
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
        lower.endsWith('.bin')) {
      return trimmed;
    }
    return trimmed + _levelExtensionFromFileName(referenceFileName);
  }

  @override
  void initState() {
    super.initState();
    _listScrollController.addListener(_onListScroll);
    _loadSavedPathAndList();
  }

  @override
  void dispose() {
    _listScrollController.removeListener(_onListScroll);
    _listScrollController.dispose();
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
    await _ensureStoragePermission();
    final path = await LevelRepository.getSavedFolderPath();
    final lastLevelDir = kIsWeb
        ? null
        : await LevelRepository.getLastOpenedLevelDirectory();
    if (kIsWeb) {
      const webPath = 'web://';
      if (!mounted) return;
      setState(() {
        _rootFolderPath = webPath;
        _pathStack = [(name: 'My levels', path: webPath)];
      });
      _loadCurrentDirectory();
      return;
    }
    if (path != null && mounted) {
      setState(() {
        _rootFolderPath = path;
        if (_pathStack.isEmpty) {
          List<({String name, String path})> stack = [];
          final rootName = path.split(RegExp(r'[/\\]')).last;
          stack.add((name: rootName.isEmpty ? 'Root' : rootName, path: path));
          if (lastLevelDir != null && lastLevelDir != path) {
            try {
              final rel = p.relative(lastLevelDir, from: path);
              if (rel.startsWith('..')) throw ArgumentError('not under root');
              if (rel.isNotEmpty && rel != '.') {
                var current = path;
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
    await _ensureStoragePermission();
    if (kIsWeb) {
      await _pickAndAddFile();
      return;
    }
    final result = await FilePicker.platform.getDirectoryPath();
    if (result != null && mounted) {
      await LevelRepository.setSavedFolderPath(result);
      setState(() {
        _rootFolderPath = result;
        final name = result.split(RegExp(r'[/\\]')).last;
        _pathStack = [(name: name.isEmpty ? 'Root' : name, path: result)];
      });
      _loadCurrentDirectory();
    }
  }

  /// Web-only: pick a .json file and add to virtual workspace.
  Future<void> _pickAndAddFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json', 'hujson', 'rton'],
    );
    if (result == null || result.files.isEmpty || !mounted) return;
    for (final file in result.files) {
      if (file.name.isEmpty) continue;
      final bytes = file.bytes;
      if (bytes == null) continue;
      final ok = await LevelRepository.prepareInternalCacheFromBytes(
        file.name,
        bytes,
      );
      if (!ok) continue;
    }
    if (mounted) {
      const webPath = 'web://';
      setState(() {
        _rootFolderPath = webPath;
        _pathStack = [(name: 'My levels', path: webPath)];
      });
      _loadCurrentDirectory();
    }
  }

  Future<void> _loadCurrentDirectory() async {
    final currentPath = _pathStack.isNotEmpty
        ? _pathStack.last.path
        : _rootFolderPath;
    if (currentPath == null) return;
    setState(() => _isLoading = true);
    final items = await LevelRepository.getDirectoryContents(currentPath);
    if (mounted) {
      setState(() {
        _fileItems = items;
        _isLoading = false;
      });
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
      finalName = _ensureLevelExtension(finalName, target.name);
    }
    final ok = await LevelRepository.renameItem(
      _pathStack.last.path,
      target.name,
      finalName,
      target.isDirectory,
    );
    if (mounted) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      if (ok) {
        _showFloatingSuccessSnackBar(l10n.renameSuccess);
        setState(() => _itemToRename = null);
        _loadCurrentDirectory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isDark
                ? const Color(0xFF8D6E00)
                : const Color(0xFFFFF59D),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.report_problem,
                  color: isDark
                      ? const Color(0xFFFFEB3B)
                      : const Color(0xFF8D6E00),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.renamingFailed,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF5D4E00),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
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
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      if (ok) {
        _showFloatingSuccessSnackBar(l10n.copySuccess);
        setState(() => _itemToCopy = null);
        _loadCurrentDirectory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isDark
                ? const Color(0xFF8D6E00)
                : const Color(0xFFFFF59D),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.report_problem,
                  color: isDark
                      ? const Color(0xFFFFEB3B)
                      : const Color(0xFF8D6E00),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.copyFail,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF5D4E00),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  Future<void> _handleNewFolder() async {
    if (_newFolderNameInput.trim().isEmpty || _pathStack.isEmpty) return;
    final l10n = AppLocalizations.of(context)!;
    final ok = await LevelRepository.createDirectory(
      _pathStack.last.path,
      _newFolderNameInput.trim(),
    );
    if (mounted) {
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      if (ok) {
        _showFloatingSuccessSnackBar(l10n.folderCreated);
        setState(() {
          _showNewFolderDialog = false;
          _newFolderNameInput = '';
        });
        _loadCurrentDirectory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isDark
                ? const Color(0xFF8D6E00)
                : const Color(0xFFFFF59D),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.report_problem,
                  color: isDark
                      ? const Color(0xFFFFEB3B)
                      : const Color(0xFF8D6E00),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.createFail,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF5D4E00),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }

  Future<void> _uploadLevel() async {
    final links = await AppLinks.load();
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    final url = Uri.parse(links.levelUpload);
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

    if (ok == true && await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.noTemplates ?? 'No templates found')),
      );
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
      final theme = Theme.of(context);
      final isDark = theme.brightness == Brightness.dark;
      if (ok) {
        _showFloatingSuccessSnackBar(l10n.levelCreated);
        setState(() {
          _newLevelNameInput = '';
        });
        _loadCurrentDirectory();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: isDark
                ? const Color(0xFF8D6E00)
                : const Color(0xFFFFF59D),
            content: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.report_problem,
                  color: isDark
                      ? const Color(0xFFFFEB3B)
                      : const Color(0xFF8D6E00),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.levelCreateFail,
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF5D4E00),
                    ),
                    overflow: TextOverflow.ellipsis,
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
    final settings = context.watch<SettingsCubit>().state;
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    final fabBgColor =
        theme.floatingActionButtonTheme.backgroundColor ??
        theme.colorScheme.primaryContainer;
    final fabFgColor =
        theme.floatingActionButtonTheme.foregroundColor ??
        theme.colorScheme.onPrimaryContainer;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.appTitle,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: l10n.refresh,
            onPressed: _loadCurrentDirectory,
          ),
          IconButton(
            icon: Icon(
              settings.themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            tooltip: l10n.toggleTheme,
            onPressed: () => context.read<SettingsCubit>().cycleTheme(),
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: kIsWeb ? 'download_all' : 'folder',
                child: ListTile(
                  leading: Icon(kIsWeb ? Icons.download : Icons.folder_open),
                  title: Text(
                    kIsWeb ? 'Download all levels' : l10n.switchFolder,
                  ),
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
              if (value == 'folder') {
                _pickFolder();
              } else if (value == 'download_all') {
                await LevelRepository.downloadAllLevelsAsZip();
              } else if (value == 'cache') {
                final count = await LevelRepository.clearAllInternalCache();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(l10n.cacheCleared(count))),
                  );
                }
              } else if (value == 'ui') {
                setState(() => _showUiScaleDialog = true);
                WidgetsBinding.instance.addPostFrameCallback(
                  (_) => _showUiScaleDialogImpl(),
                );
              } else if (value == 'lang') {
                widget.onLanguageTap(context);
              } else if (value == 'about') {
                widget.onAboutClick();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
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
                            kIsWeb
                                ? 'Open a level file (.json) to get started.'
                                : l10n.selectFolderPrompt,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          FilledButton.icon(
                            onPressed: _pickFolder,
                            icon: Icon(
                              kIsWeb ? Icons.file_open : Icons.folder_open,
                            ),
                            label: Text(
                              kIsWeb ? 'Open file' : l10n.selectFolderButton,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              else ...[
                _BreadcrumbBar(
                  pathStack: _pathStack,
                  onBreadcrumbClick: _breadcrumbTap,
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
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(fontWeight: FontWeight.bold),
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
                Expanded(
                  child: _isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : _fileItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.folder_open,
                                size: 64,
                                color:
                                    theme.colorScheme.surfaceContainerHighest,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                l10n.emptyFolder,
                                style: TextStyle(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          controller: _listScrollController,
                          padding: const EdgeInsets.all(16),
                          itemCount: _fileItems.length + 1,
                          itemBuilder: (context, index) {
                            final itemIndex = index;
                            if (itemIndex >= _fileItems.length) {
                              return const SizedBox(height: 80);
                            }
                            final item = _fileItems[itemIndex];
                            final isMovingMode = _itemToMove != null;
                            final isSelfMoving =
                                isMovingMode && _itemToMove == item;
                            final actionsDisabled = isMovingMode;
                            return Opacity(
                              opacity:
                                  (isMovingMode && !item.isDirectory) ||
                                      isSelfMoving
                                  ? 0.5
                                  : 1,
                              child: _FileItemRow(
                                item: item,
                                l10n: l10n,
                                onTap: () async {
                                  if (isMovingMode) {
                                    if (item.isDirectory)
                                      _navigateToFolder(item);
                                  } else {
                                    if (item.isDirectory) {
                                      _navigateToFolder(item);
                                    } else {
                                      final lowerName = item.name.toLowerCase();
                                      if (lowerName.endsWith('.hujson') ||
                                          lowerName.endsWith('.rton')) {
                                        final convertedPath =
                                            await _showConversionRequiredDialog(
                                              item,
                                            );
                                        if (!mounted || convertedPath == null) {
                                          return;
                                        }
                                        final convertedName = p.basename(
                                          convertedPath,
                                        );
                                        final ok =
                                            await LevelRepository.prepareInternalCache(
                                              convertedPath,
                                              convertedName,
                                            );
                                        if (mounted && ok) {
                                          widget.onLevelClick(
                                            convertedName,
                                            convertedPath,
                                          );
                                        }
                                      } else {
                                        final ok =
                                            await LevelRepository.prepareInternalCache(
                                              item.path,
                                              item.name,
                                            );
                                        if (mounted && ok) {
                                          widget.onLevelClick(
                                            item.name,
                                            item.path,
                                          );
                                        }
                                      }
                                    }
                                  }
                                },
                                onRename: actionsDisabled
                                    ? () {}
                                    : () {
                                        setState(() {
                                          _renameInput = item.isDirectory
                                              ? item.name
                                              : LevelRepository.baseNameWithoutLevelExtension(
                                                  item.name,
                                                );
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
                                        setState(() => _itemToDelete = item);
                                        WidgetsBinding.instance
                                            .addPostFrameCallback(
                                              (_) => _showDeleteDialog(),
                                            );
                                      },
                                onDownload: kIsWeb && !item.isDirectory
                                    ? () => LevelRepository.downloadLevel(
                                        item.name,
                                      )
                                    : null,
                                onCopy: actionsDisabled
                                    ? () {}
                                    : () async {
                                        if (!item.isDirectory &&
                                            _pathStack.isNotEmpty) {
                                          final baseName =
                                              LevelRepository.baseNameWithoutLevelExtension(
                                                item.name,
                                              );
                                          final nextName =
                                              await LevelRepository.getNextAvailableCopyName(
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
                                                  (_) => _showCopyDialog(),
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
                                onConvert: actionsDisabled || item.isDirectory
                                    ? null
                                    : () => _showConvertMenuFor(item),
                                onToggleFavorite:
                                    actionsDisabled || item.isDirectory
                                    ? null
                                    : () => _toggleFavorite(item),
                                showMove: !item.isDirectory && !kIsWeb,
                              ),
                            );
                          },
                        ),
                ),
              ],
            ],
          ),
          if (_rootFolderPath != null && _itemToMove == null)
            Positioned(
              right: 16,
              bottom: 16,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _AnimatedUploadFab(
                    visible: _listScrollAtTop,
                    onPressed: _uploadLevel,
                    label: l10n.uploadLevel,
                  ),
                  if (_listScrollAtTop && kIsWeb) const SizedBox(height: 12),
                  if (kIsWeb)
                    FloatingActionButton(
                      heroTag: 'addFile',
                      onPressed: _pickAndAddFile,
                      child: const Icon(Icons.file_open),
                    ),
                ],
              ),
            ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: _rootFolderPath != null && _itemToMove != null
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
                      onPressed: kIsWeb
                          ? null
                          : () {
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
          decoration: InputDecoration(labelText: l10n.folderName),
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;
    Color bgColor;
    Widget leading;
    String text;
    switch (type) {
      case 'success':
        bgColor = isDark ? const Color(0xFF2E7D32) : const Color(0xFF4CAF50);
        leading = const Icon(Icons.check_circle, color: Colors.white, size: 20);
        text = l10n.movingSuccess;
        break;
      case 'renamed':
        bgColor = isDark ? const Color(0xFF43A047) : const Color(0xFF388E3C);
        leading = const Icon(Icons.check_circle, color: Colors.white, size: 20);
        text = l10n.movedAs(newFileName ?? '');
        break;
      case 'overwritten':
        bgColor = isDark ? const Color(0xFF2E7D32) : const Color(0xFF4CAF50);
        leading = const Icon(Icons.check_circle, color: Colors.white, size: 20);
        text = l10n.fileOverwritten(newFileName ?? '');
        break;
      case 'cancelled':
        bgColor = isDark ? const Color(0xFF8D6E00) : const Color(0xFFFFF59D);
        leading = Icon(
          Icons.warning,
          color: isDark ? const Color(0xFFFFEB3B) : const Color(0xFF8D6E00),
          size: 20,
        );
        text = l10n.moveCancelled;
        break;
      case 'sameFolder':
        bgColor = isDark ? const Color(0xFF8D6E00) : const Color(0xFFFFF59D);
        leading = Icon(
          Icons.warning,
          color: isDark ? const Color(0xFFFFEB3B) : const Color(0xFF8D6E00),
          size: 20,
        );
        text = l10n.moveSameFolder;
        break;
      case 'fail':
        bgColor = isDark ? const Color(0xFF8D6E00) : const Color(0xFFFFF59D);
        leading = Icon(
          Icons.report_problem,
          color: isDark ? const Color(0xFFFFEB3B) : const Color(0xFF8D6E00),
          size: 20,
        );
        text = l10n.movingFail;
        break;
      default:
        return;
    }
    final isGreen =
        type == 'success' || type == 'renamed' || type == 'overwritten';
    if (isGreen) {
      _showFloatingSuccessSnackBar(text, backgroundColor: bgColor);
      return;
    }
    final textColor = isDark ? Colors.white : const Color(0xFF5D4E00);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: bgColor,
        content: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            leading,
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: textColor),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<String?> _showConversionRequiredDialog(FileItem item) async {
    if (_pathStack.isEmpty || item.isDirectory) return null;
    final l10n = AppLocalizations.of(context)!;
    final shouldConvert = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.conversionRequiredTitle),
        content: Text(l10n.conversionRequiredMessage),
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
    final messenger = ScaffoldMessenger.of(context);

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
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.convertedMessage(converted))),
      );
      await _loadCurrentDirectory();
      return converted;
    }
    messenger.showSnackBar(SnackBar(content: Text(l10n.conversionFailed)));
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
                onTap: () => Navigator.pop(ctx, '.hujson'),
              ),
              ListTile(
                leading: const Icon(Icons.sync_alt),
                title: Text(l10n.convertToEncryptedRton),
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
      _showFloatingSuccessSnackBar(l10n.deleted);
      _loadCurrentDirectory();
    }
  }

  Future<void> _toggleFavorite(FileItem item) async {
    if (item.isDirectory) return;
    final l10n = AppLocalizations.of(context)!;
    final next = !item.isFavorite;
    await LevelRepository.setFavoriteLevelPath(item.path, next);
    if (!mounted) return;
    _showFloatingSuccessSnackBar(
      next ? l10n.addedToFavorites : l10n.removedFromFavorites,
    );
    await _loadCurrentDirectory();
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(l10n.small, overflow: TextOverflow.ellipsis),
                  ),
                  Flexible(
                    child: Text(l10n.standard, overflow: TextOverflow.ellipsis),
                  ),
                  Flexible(
                    child: Text(l10n.large, overflow: TextOverflow.ellipsis),
                  ),
                  Flexible(
                    child: Text(l10n.ultra, overflow: TextOverflow.ellipsis),
                  ),
                ],
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
    this.onDownload,
    this.onConvert,
    this.onToggleFavorite,
  });

  final FileItem item;
  final AppLocalizations l10n;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDelete;
  final VoidCallback onCopy;
  final VoidCallback onMove;
  final bool showMove;
  final VoidCallback? onDownload;
  final VoidCallback? onConvert;
  final VoidCallback? onToggleFavorite;

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
    final displayName = item.isDirectory
        ? item.name
        : LevelRepository.baseNameWithoutLevelExtension(item.name);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
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
                      item.isDirectory ? Icons.folder : Icons.description,
                      size: iconSize,
                      color: item.isDirectory
                          ? const Color(0xFFFFC107)
                          : theme.colorScheme.primary,
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
                            p
                                .extension(item.name)
                                .replaceFirst('.', '')
                                .toUpperCase(),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (compact)
                    actions
                  else
                    Flexible(
                      fit: FlexFit.loose,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: FittedBox(fit: BoxFit.scaleDown, child: actions),
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
            child: FloatingActionButton.extended(
              heroTag: 'uploadLevel',
              onPressed: widget.onPressed,
              icon: const Icon(Icons.cloud_upload),
              label: Text(widget.label),
            ),
          ),
        ),
      ),
    );
  }
}
