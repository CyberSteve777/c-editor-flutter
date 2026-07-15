import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/app_message.dart';
import 'package:c_editor/widgets/labeled_progress_bar.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/data/level_validator.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/data/repository/world_repository.dart';
import 'package:c_editor/utils/3rdParty/sen_rsb_unpack.dart';
import 'package:c_editor/utils/3rdParty/sen_rsb_pack.dart';
import 'package:c_editor/utils/3rdParty/sen_rsg_unpack.dart';
import 'package:c_editor/utils/3rdParty/sen_rsg_pack.dart';
import 'package:c_editor/utils/3rdParty/pyvz2_rton_codec.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:path/path.dart' as p;

enum ExportStep { disclaimer, selectingArchive, selectingLevels, reviewSelection, proposingAssignments, finalCheck, success }

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String? _selectedArchivePath;
  final Set<String> _selectedLevelPaths = {};
  final Map<String, ({String world, int level})> _levelAssignments = {};
  bool _noFilesFound = false;
  ExportStep _currentStep = ExportStep.disclaimer;

  // State for custom file picker
  String? _rootPath;
  final List<({String name, String path})> _pathStack = [];
  List<FileSystemEntity> _currentPathItems = [];
  bool _isScanning = false;

  double _exportProgress = 0;
  String _exportStatus = '';
  bool _isExporting = false;

  @override
  void initState() {
    super.initState();
    _initRootPath();
  }

  Future<void> _initRootPath() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        _rootPath = prefs.getString('folder_path');
      });
    }
  }

  Future<void> _performGlobalScan() async {
    if (_rootPath == null || _rootPath!.isEmpty) {
      setState(() => _noFilesFound = true);
      return;
    }

    setState(() => _isScanning = true);

    try {
      final rootDir = Directory(_rootPath!);
      bool hasEligibleFile = false;

      // Recursive check for at least one .rsb.smf file
      await for (final entity in rootDir.list(recursive: true)) {
        if (entity is File && entity.path.endsWith('.rsb.smf')) {
          hasEligibleFile = true;
          break;
        }
      }

      if (mounted) {
        if (hasEligibleFile) {
          setState(() {
            _currentStep = ExportStep.selectingArchive;
            _noFilesFound = false;
          });
          await _loadDirectory(_rootPath!);
        } else {
          setState(() => _noFilesFound = true);
        }
      }
    } catch (e) {
      debugPrint("Scan failed: $e");
      if (mounted) {
        setState(() => _noFilesFound = true);
      }
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  Future<void> _loadDirectory(String path) async {
    try {
      final dir = Directory(path);
      final items = await dir.list().toList();
      
      // Filter for directories and eligible files
      final filtered = items.where((item) {
        if (item is Directory) return true;
        if (item is File) {
          final fileName = p.basename(item.path).toLowerCase();
          if (_currentStep == ExportStep.selectingArchive) {
            return fileName.endsWith('.rsb.smf');
          } else if (_currentStep == ExportStep.selectingLevels) {
            return fileName.endsWith('.json') || fileName.endsWith('.rton');
          }
        }
        return false;
      }).toList();

      // Sort: Directories first, then files
      filtered.sort((a, b) {
        if (a is Directory && b is File) return -1;
        if (a is File && b is Directory) return 1;
        return p.basename(a.path).toLowerCase().compareTo(p.basename(b.path).toLowerCase());
      });

      if (mounted) {
        setState(() {
          _currentPathItems = filtered;
          if (_pathStack.isEmpty || _pathStack.last.path != path) {
            final name = path == _rootPath ? p.basename(path) : p.basename(path);
            _pathStack.add((name: name.isEmpty ? 'Root' : name, path: path));
          }
        });
      }
    } catch (e) {
      debugPrint("Load directory failed: $e");
    }
  }

  void _navigateBack() {
    if (_pathStack.length > 1) {
      setState(() {
        _pathStack.removeLast();
        _loadDirectory(_pathStack.last.path);
      });
    } else {
      setState(() {
        _pathStack.clear();
        _currentStep = ExportStep.disclaimer;
      });
    }
  }

  void _breadcrumbTap(int index) {
    if (index < _pathStack.length - 1) {
      final target = _pathStack[index];
      setState(() {
        _pathStack.removeRange(index + 1, _pathStack.length);
        _loadDirectory(target.path);
      });
    }
  }

  Future<void> _showBackupRecommendation() async {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.backupRecommendationTitle),
          content: Text(l10n.backupRecommendationBody),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.proceedWithoutBackup),
              onPressed: () {
                Navigator.of(context).pop();
                _switchToLevelSelection();
              },
            ),
            FilledButton(
              child: Text(l10n.backupAndProceed),
              onPressed: () async {
                final nav = Navigator.of(context);
                await _createBackup();
                nav.pop();
                _switchToLevelSelection();
              },
            ),
          ],
        );
      },
    );
  }

  void _switchToLevelSelection() {
    setState(() {
      _currentStep = ExportStep.selectingLevels;
      _pathStack.clear();
    });
    _loadDirectory(_rootPath!);
  }

  Future<void> _createBackup() async {
    if (_selectedArchivePath == null) return;

    final l10n = AppLocalizations.of(context)!;
    final file = File(_selectedArchivePath!);
    final directory = file.parent.path;
    final fileName = p.basename(_selectedArchivePath!);

    String baseName;
    String extension;
    const rsbExt = '.rsb.smf';
    if (fileName.toLowerCase().endsWith(rsbExt)) {
      baseName = fileName.substring(0, fileName.length - rsbExt.length);
      extension = rsbExt;
    } else {
      baseName = p.basenameWithoutExtension(fileName);
      extension = p.extension(fileName);
    }

    final suggestedBase = "$baseName${l10n.backupSuffix}";
    final backupName = await LevelRepository.getFirstAvailableIndexedName(
      directory,
      suggestedBase,
      extension,
    );

    final backupPath = p.join(directory, backupName);

    // Show progress dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.backupProgressTitle),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            LabeledProgressBar(value: null),
            SizedBox(height: 16),
          ],
        ),
      ),
    );

    try {
      await file.copy(backupPath);
      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog
        
        // Auto-refresh the list so the new backup file appears immediately
        await _loadDirectory(_pathStack.last.path);
        
        if (mounted) {
          AppMessage.show(
            context,
            l10n.success,
            icon: Icons.check_circle,
          );
        }
      }
    } catch (e) {
      debugPrint("Backup failed: $e");
      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog
        AppMessage.show(
          context,
          "${l10n.error}: $e",
          icon: Icons.error_outline,
        );
      }
    }
  }


  Future<void> _validateAndFinishExport() async {
    final l10n = AppLocalizations.of(context)!;
    final total = _selectedLevelPaths.length;
    int current = 0;

    // Use a ValueNotifier to update the progress dialog
    final progressNotifier = ValueNotifier<double>(0);
    final statusNotifier = ValueNotifier<String>(l10n.validationProgress(0, total));

    // Show progress dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(l10n.exportProgressTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: progressNotifier,
              builder: (context, value, child) => LabeledProgressBar(value: value),
            ),
            const SizedBox(height: 16),
            ValueListenableBuilder<String>(
              valueListenable: statusNotifier,
              builder: (context, status, child) => Text(status),
            ),
          ],
        ),
      ),
    );

    final allIssues = <String, List<ValidationIssue>>{};

    try {
      for (final path in _selectedLevelPaths) {
        current++;
        progressNotifier.value = current / total;
        statusNotifier.value = l10n.validationProgress(current, total);

        final lowerPath = path.toLowerCase();
        final isJson = lowerPath.endsWith('.json');
        final isRton = lowerPath.endsWith('.rton');

        if (!isJson && !isRton) continue;

        try {
          final levelFile = await LevelRepository.loadLevelFromPath(path);

          if (levelFile != null && mounted) {
            final issues = LevelValidator.validate(context, levelFile);
            if (issues.isNotEmpty) {
              allIssues[p.basename(path)] = issues;
            }
          }
        } catch (e) {
          debugPrint("Validation failed for $path: $e");
        }
      }
    } catch (e) {
      debugPrint("Global validation process failed: $e");
    } finally {
      if (mounted) {
        Navigator.of(context).pop(); // Close progress dialog
      }
    }

    if (allIssues.isNotEmpty) {
      final action = await _showValidationIssuesDialog(allIssues);
      if (action == 'proceed' || action == 'close') {
        setState(() {
          _currentStep = ExportStep.reviewSelection;
        });
      }
      return;
    }

    setState(() {
      _currentStep = ExportStep.reviewSelection;
    });
  }

  void _initializeAssignments() {
    _levelAssignments.clear();
    final worlds = WorldRepository.allWorlds;
    int worldIdx = 0;
    int levelIdx = 1;

    for (final path in _selectedLevelPaths) {
      if (worldIdx >= worlds.length) {
        // Fallback or stop if too many levels selected? 
        // Just repeat last world if necessary, user will have to fix duplicates anyway
        final world = worlds.last;
        _levelAssignments[path] = (world: world.codename, level: 1);
        continue;
      }

      final world = worlds[worldIdx];
      _levelAssignments[path] = (world: world.codename, level: levelIdx);

      levelIdx++;
      if (levelIdx > world.levelCount) {
        levelIdx = 1;
        worldIdx++;
      }
    }
  }

  Future<String?> _showValidationIssuesDialog(
    Map<String, List<ValidationIssue>> allIssues,
  ) async {
    final l10n = AppLocalizations.of(context)!;

    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.conflictTitle_ModuleLogic),
        content: SizedBox(
          width: 600,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    l10n.validationReviewRequest,
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                ),
                ...allIssues.entries.map((entry) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          entry.key,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                      ...entry.value.map((issue) {
                        if (issue.isError) {
                          return Card(
                            color: Theme.of(context).colorScheme.errorContainer,
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.error,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          issue.title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.onErrorContainer,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    issue.message,
                                    style: TextStyle(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onErrorContainer,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        } else {
                          return EditorWarningBanner(
                            title: issue.title,
                            message: issue.message,
                            margin: const EdgeInsets.only(bottom: 8),
                            children: issue.bulletPoints
                                .map(
                                  (bp) => Text(
                                    '• $bp',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: editorWarningBannerForeground(
                                        Theme.of(context).brightness,
                                      ),
                                    ),
                                  ),
                                )
                                .toList(),
                          );
                        }
                      }),
                      const Divider(),
                    ],
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
                  child: Text(
                    l10n.validationRecommendation,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop('reselect'),
            child: Text(l10n.reselectFiles),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('close'),
            child: Text(l10n.close),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop('proceed'),
            child: Text(
              l10n.proceed,
              style: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool> _onWillPop() async {
    if (_isExporting) return false;
    if (_currentStep == ExportStep.disclaimer) {
      return true;
    }

    if (_currentStep == ExportStep.selectingArchive && _selectedArchivePath != null) {
      setState(() => _selectedArchivePath = null);
      return false;
    }

    if (_currentStep == ExportStep.selectingLevels && _selectedLevelPaths.isNotEmpty) {
      setState(() => _selectedLevelPaths.clear());
      return false;
    }

    if (_currentStep == ExportStep.reviewSelection) {
      setState(() {
        _currentStep = ExportStep.selectingLevels;
      });
      return false;
    }

    if (_currentStep == ExportStep.proposingAssignments) {
      setState(() {
        _currentStep = ExportStep.reviewSelection;
        _levelAssignments.clear();
      });
      return false;
    }

    if (_currentStep == ExportStep.finalCheck) {
      setState(() {
        _currentStep = ExportStep.proposingAssignments;
      });
      return false;
    }

    // If we are in selecting step, back button should navigate folders
    if (_currentStep == ExportStep.selectingArchive || _currentStep == ExportStep.selectingLevels) {
      if (_pathStack.length > 1) {
        _navigateBack();
        return false;
      } else if (_currentStep == ExportStep.selectingLevels) {
        // From root of level selection, go back to archive selection
        setState(() {
          _currentStep = ExportStep.selectingArchive;
          _selectedArchivePath = null;
          _pathStack.clear();
        });
        _loadDirectory(_rootPath!);
        return false;
      } else {
        // From root of archive selection, go back to disclaimer
        _navigateBack();
        return false;
      }
    }

    return true;
  }

  Future<void> _handleClose() async {
    if (_isExporting) return;
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.cancelExportTitle),
        content: Text(l10n.cancelExportMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              l10n.confirm,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final nav = Navigator.of(context);
        final shouldPop = await _onWillPop();
        if (shouldPop && mounted) {
          nav.pop();
        }
      },
      child: Scaffold(
        appBar: _currentStep == ExportStep.success
            ? null
            : AppBar(
                title: Text(
                  l10n.exportLevels,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () async {
                    if (_isExporting) return;
                    if (_currentStep == ExportStep.disclaimer) {
                      Navigator.of(context).pop();
                    } else {
                      final nav = Navigator.of(context);
                      final shouldPop = await _onWillPop();
                      if (shouldPop && mounted) {
                        nav.pop();
                      }
                    }
                  },
                ),
                actions: _currentStep == ExportStep.disclaimer
                    ? null
                    : [
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: _isExporting ? null : _handleClose,
                          tooltip: l10n.cancel,
                        ),
                      ],
              ),
        body: _buildStepContent(l10n, theme),
      ),
    );
  }

  Widget _buildStepContent(AppLocalizations l10n, ThemeData theme) {
    if (_isExporting) {
      return _buildExportProgress(l10n, theme);
    }
    if (_currentStep == ExportStep.disclaimer) {
      return _buildDisclaimer(l10n, theme);
    }

    if (_currentStep == ExportStep.reviewSelection) {
      return _buildReviewSelection(l10n, theme);
    }

    if (_currentStep == ExportStep.proposingAssignments) {
      return _buildAssignmentProposal(l10n, theme);
    }

    if (_currentStep == ExportStep.finalCheck) {
      return _buildFinalCheck(l10n, theme);
    }

    if (_currentStep == ExportStep.success) {
      return _buildSuccessStep(l10n, theme);
    }

    final String stepTitle = _currentStep == ExportStep.selectingArchive
        ? l10n.exportSelectFile
        : l10n.exportSelectLevels;

    return Column(
      children: [
        const SizedBox(height: 16),
        Text(
          stepTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        _ExportBreadcrumbBar(
          pathStack: _pathStack,
          onBreadcrumbClick: _breadcrumbTap,
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_pathStack.length > 1)
                _ExportFileItemRow(
                  name: l10n.returnUp,
                  isDir: true,
                  isBack: true,
                  onTap: _navigateBack,
                ),
              ..._currentPathItems.map((item) {
                final isDir = item is Directory;
                final fullPath = item.path;
                final fileName = p.basename(fullPath);
                
                String displayName = fileName;
                String? extension;
                
                if (!isDir) {
                  if (fileName.toLowerCase().endsWith('.rsb.smf')) {
                    displayName = fileName.substring(0, fileName.length - '.rsb.smf'.length);
                    extension = '.rsb.smf';
                  } else if (fileName.toLowerCase().endsWith('.json')) {
                    displayName = fileName.substring(0, fileName.length - '.json'.length);
                    extension = '.json';
                  } else if (fileName.toLowerCase().endsWith('.rton')) {
                    displayName = fileName.substring(0, fileName.length - '.rton'.length);
                    extension = '.rton';
                  } else if (fileName.toLowerCase().endsWith('.smf')) {
                    displayName = fileName.substring(0, fileName.length - '.smf'.length);
                    extension = '.smf';
                  }
                }

                final bool isSelected = _currentStep == ExportStep.selectingArchive
                    ? _selectedArchivePath == fullPath
                    : _selectedLevelPaths.contains(fullPath);

                return _ExportFileItemRow(
                  name: displayName,
                  isDir: isDir,
                  isSelected: isSelected,
                  extension: extension,
                  onTap: () {
                    if (isDir) {
                      _loadDirectory(fullPath);
                    } else {
                      setState(() {
                        if (_currentStep == ExportStep.selectingArchive) {
                          if (isSelected) {
                            _selectedArchivePath = null;
                          } else {
                            _selectedArchivePath = fullPath;
                          }
                        } else {
                          if (isSelected) {
                            _selectedLevelPaths.remove(fullPath);
                          } else {
                            _selectedLevelPaths.add(fullPath);
                          }
                        }
                      });
                    }
                  },
                );
              }),
            ],
          ),
        ),
        if (_noFilesFound) ...[
          const SizedBox(height: 16),
          Text(
            l10n.exportNoFilesFound,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ],
        if (_isScanning) ...[
          const SizedBox(height: 16),
          const Center(child: CircularProgressIndicator()),
        ],
        Padding(
          padding: const EdgeInsets.all(24),
          child: Align(
            alignment: Alignment.centerRight,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton(
                  onPressed: _isScanning
                      ? null
                      : () {
                          if (_noFilesFound) {
                            Navigator.of(context).pop();
                          } else {
                            if (_currentStep == ExportStep.selectingArchive && _selectedArchivePath != null) {
                              _showBackupRecommendation();
                            } else if (_currentStep == ExportStep.selectingLevels && _selectedLevelPaths.isNotEmpty) {
                              _validateAndFinishExport();
                            }
                          }
                        },
                  child: Text(
                    _noFilesFound ? l10n.close : l10n.proceed,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: _isScanning
                          ? null
                          : ((_currentStep == ExportStep.selectingArchive && _selectedArchivePath != null) ||
                                  (_currentStep == ExportStep.selectingLevels && _selectedLevelPaths.isNotEmpty)
                              ? Colors.green
                              : theme.colorScheme.onSurfaceVariant),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildExportProgress(AppLocalizations l10n, ThemeData theme) {
    debugPrint("Export progress: $_exportProgress, status: $_exportStatus");
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              l10n.exportProgressTitle,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),
            LabeledProgressBar(value: _exportProgress),
            const SizedBox(height: 16),
            Text(_exportStatus),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewSelection(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 800),
                  child: Column(
                    children: [
                      Text(
                        l10n.exportAssignmentProposalTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        l10n.exportAssignmentProposalBody,
                        textAlign: TextAlign.left,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      const SizedBox(height: 32),
                      ..._selectedLevelPaths.map((path) => Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: const Icon(Icons.description, color: Colors.blue),
                              title: Text(p.basename(path)),
                            ),
                          )),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: TextButton(
                onPressed: () {
                  _initializeAssignments();
                  setState(() {
                    _currentStep = ExportStep.proposingAssignments;
                  });
                },
                child: Text(
                  l10n.exportBegin,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentProposal(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    children: [
                      Text(
                        l10n.exportAssignmentProposalTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      ..._selectedLevelPaths.map((path) {
                        final assignment = _levelAssignments[path];
                        return _WorldDistributionRow(
                          fileName: p.basename(path),
                          assignment: assignment,
                          onCheckDuplicate: (newAssignment) {
                            return _levelAssignments.values.any((a) => 
                              a.world == newAssignment.world && a.level == newAssignment.level);
                          },
                          onChanged: (newAssignment) {
                            setState(() {
                              if (newAssignment == null) {
                                _levelAssignments.remove(path);
                              } else {
                                _levelAssignments[path] = newAssignment;
                              }
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: FilledButton(
                onPressed: _finishAssignments,
                child: Text(
                  l10n.exportFinish,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _finishAssignments() async {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    // 1. Check if all levels have assignments
    if (_levelAssignments.length < _selectedLevelPaths.length) {
      AppMessage.show(context, l10n.exportAssignmentIncomplete);
      return;
    }

    // 3. Confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.exportConfirmationTitle),
        content: SizedBox(
          width: 500,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.exportConfirmationBody),
              const SizedBox(height: 16),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: _selectedLevelPaths.map((path) {
                      final assignment = _levelAssignments[path]!;
                      final worldInfo = WorldRepository.findByCodename(assignment.world);
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            if (worldInfo != null) ...[
                              ClipOval(
                                child: AssetImageWidget(
                                  assetPath: worldInfo.getIconPath(),
                                  width: 24,
                                  height: 24,
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Expanded(
                              child: Text(
                                p.basename(path),
                                style: const TextStyle(fontSize: 13),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '→ ${worldInfo?.nameGetter(l10n) ?? assignment.world} ${l10n.exportLevelShort(assignment.level)}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.back),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.exportProceed),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() {
        _currentStep = ExportStep.finalCheck;
      });
    }
  }

  Widget _buildFinalCheck(AppLocalizations l10n, ThemeData theme) {
    final String archiveName = _selectedArchivePath != null ? p.basename(_selectedArchivePath!) : '';
    String relativeArchivePath = _selectedArchivePath ?? '';
    if (_rootPath != null && relativeArchivePath.startsWith(_rootPath!)) {
      relativeArchivePath = p.relative(relativeArchivePath, from: _rootPath!);
    }

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          Text(
            l10n.exportFinalCheckTitle,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.exportFinalCheckBody,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          if (_selectedArchivePath != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.inventory_2_outlined, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.exportTargetArchive(archiveName),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          relativeArchivePath,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.7),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 24),
          Expanded(
            child: ListView.builder(
              itemCount: _selectedLevelPaths.length,
              itemBuilder: (context, index) {
                final path = _selectedLevelPaths.elementAt(index);
                final assignment = _levelAssignments[path]!;
                final worldInfo = WorldRepository.findByCodename(assignment.world);
                final exportedName = '${assignment.world}${assignment.level}.json';

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: worldInfo != null
                        ? ClipOval(
                            child: AssetImageWidget(
                              assetPath: worldInfo.getIconPath(),
                              width: 40,
                              height: 40,
                            ),
                          )
                        : const Icon(Icons.help_outline),
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.basename(path)),
                        const SizedBox(height: 2),
                        Text(
                          '→ $exportedName',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      '${worldInfo?.nameGetter(l10n) ?? assignment.world} ${l10n.exportLevelShort(assignment.level)}',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.bottomRight,
            child: FilledButton.icon(
              onPressed: _isExporting ? null : _performExport,
              icon: _isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.file_upload),
              label: Text(l10n.exportStart),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessStep(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle_outline, color: Colors.green, size: 80),
            const SizedBox(height: 24),
            Text(
              l10n.exportSuccessTitle,
              style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Text(
              l10n.exportSuccessMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 48),
            SizedBox(
              width: 200,
              child: FilledButton(
                onPressed: () {
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: Text(l10n.close),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performExport() async {
    if (_selectedArchivePath == null) return;
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isExporting = true;
      _exportProgress = 0;
      _exportStatus = l10n.exportProgressTitle;
    });

    final tempDir = await Directory.systemTemp.createTemp('c_editor_export_');
    final String tempPath = tempDir.path;
    final String archivePath = _selectedArchivePath!;

    try {
      // 1. Create renamed copies of levels as RTON
      setState(() {
        _exportProgress = 0.1;
        _exportStatus = l10n.exportStatusCreatingRton;
      });

      final Map<String, Uint8List> rtonLevels = {};
      final rtonCodec = const Pyvz2RtonCodec();

      for (final entry in _levelAssignments.entries) {
        final srcPath = entry.key;
        final assignment = entry.value;
        final exportedName = '${assignment.world}${assignment.level}.rton';

        final levelFile = await LevelRepository.loadLevelFromPath(srcPath);
        if (levelFile == null) throw Exception("Failed to load level: $srcPath");

        final rtonBytes = rtonCodec.encode(levelFile, encrypt: true);
        rtonLevels[exportedName] = rtonBytes;
      }

      // 3. Rename .rsb.smf to .rsb (temporarily copy to temp)
      setState(() {
        _exportProgress = 0.2;
        _exportStatus = l10n.exportStatusUnpackingRsb;
      });

      final rsbFile = File(archivePath);
      final tempRsbPath = p.join(tempPath, "temp.rsb");
      await rsbFile.copy(tempRsbPath);

      // 4. Unpack RSB
      final rsbUnpackDir = p.join(tempPath, "rsb.bundle");
      Directory(rsbUnpackDir).createSync(recursive: true);
      RsbUnpack.process(tempRsbPath, rsbUnpackDir, l10n);

      // 5. Look for Packages.rsg
      setState(() {
        _exportProgress = 0.4;
        _exportStatus = l10n.exportStatusUnpackingRsg;
      });

      final packetDir = Directory(p.join(rsbUnpackDir, "packet"));
      if (!packetDir.existsSync()) {
        // Diagnostic: list rsbUnpackDir
        final rsbFiles = Directory(rsbUnpackDir).listSync(recursive: true)
          .map((e) => p.relative(e.path, from: rsbUnpackDir)).take(10).join(", ");
        throw Exception("Packet directory not found in RSB bundle. Contents: $rsbFiles");
      }

      String? packagesRsgPath;
      for (final entity in packetDir.listSync()) {
        if (entity is File && p.basename(entity.path).toLowerCase() == "packages.rsg") {
          packagesRsgPath = entity.path;
          break;
        }
      }

      if (packagesRsgPath == null) {
        throw Exception("Packages.rsg not found in archive.");
      }

      // 6. Unpack Packages.rsg
      final rsgUnpackDir = p.join(tempPath, "Packages.packet");
      Directory(rsgUnpackDir).createSync(recursive: true);
      RsgUnpack.process(packagesRsgPath, rsgUnpackDir, l10n);

      // 7. Look for LEVELS folder
      setState(() {
        _exportProgress = 0.6;
        _exportStatus = l10n.exportStatusInjecting;
      });

      // Search for LEVELS folder case-insensitively
      Directory? levelsDir;
      final resDir = Directory(p.join(rsgUnpackDir, "res"));
      if (resDir.existsSync()) {
        for (final entity in resDir.listSync(recursive: true)) {
          if (entity is Directory && p.basename(entity.path).toLowerCase() == "levels") {
            levelsDir = entity;
            break;
          }
        }
      }

      if (levelsDir == null) {
        // Fallback: try to find it anywhere in rsgUnpackDir
        for (final entity in Directory(rsgUnpackDir).listSync(recursive: true)) {
          if (entity is Directory && p.basename(entity.path).toLowerCase() == "levels") {
            levelsDir = entity;
            break;
          }
        }
      }

      if (levelsDir == null) {
        // Diagnostic: list folders in rsgUnpackDir
        final allDirs = Directory(rsgUnpackDir).listSync(recursive: true)
          .whereType<Directory>()
          .map((e) => p.relative(e.path, from: rsgUnpackDir))
          .take(10).join(", ");
        throw Exception("LEVELS folder not found in Packages.rsg. Found dirs: ${allDirs.isEmpty ? 'none' : allDirs}");
      }

      // 8. Copy RTON files to LEVELS with replacement
      for (final entry in rtonLevels.entries) {
        final fileName = entry.key;
        final data = entry.value;
        final targetPath = p.join(levelsDir.path, fileName);
        await File(targetPath).writeAsBytes(data);
      }

      // 9. Pack Packages.packet back to Packages.rsg
      setState(() {
        _exportProgress = 0.7;
        _exportStatus = l10n.exportStatusRepackingRsg;
      });
      RsgPack.process(rsgUnpackDir, packagesRsgPath, l10n);

      // 10. Pack rsb.bundle back to .rsb
      setState(() {
        _exportProgress = 0.8;
        _exportStatus = l10n.exportStatusRepackingRsb;
      });
      RsbPack.process(rsbUnpackDir, tempRsbPath, l10n);

      // 11. Rename .rsb to .rsb.smf (overwrite original)
      setState(() {
        _exportProgress = 0.9;
        _exportStatus = l10n.exportStatusFinalizing;
      });
      await File(tempRsbPath).copy(archivePath);

      // 12. Cleanup (automatic since we used system temp and will delete it now)
      if (mounted) {
        setState(() {
          _exportProgress = 1.0;
          _isExporting = false;
          _currentStep = ExportStep.success;
        });
      }
    } catch (e) {
      debugPrint("Export failed: $e");
      if (mounted) {
        setState(() {
          _isExporting = false;
        });
        AppMessage.show(context, "${l10n.error}: $e", icon: Icons.error_outline);
      }
    } finally {
      if (tempDir.existsSync()) {
        await tempDir.delete(recursive: true);
      }
    }
  }

  Widget _buildDisclaimer(AppLocalizations l10n, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 48, 24, 24),
      child: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    children: [
                      Text(
                        l10n.exportDisclaimerTitle,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        l10n.exportDisclaimerBody,
                        textAlign: TextAlign.left,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          height: 1.6,
                          color:
                              theme.colorScheme.onSurface.withValues(alpha: 0.8),
                        ),
                      ),
                      if (_noFilesFound) ...[
                        const SizedBox(height: 32),
                        Text(
                          l10n.exportNoFilesFound,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Align(
            alignment: Alignment.bottomRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16, bottom: 16),
              child: TextButton(
                onPressed: _isScanning
                    ? null
                    : (_noFilesFound
                        ? () => Navigator.of(context).pop()
                        : _performGlobalScan),
                child: _isScanning
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _noFilesFound ? l10n.close : l10n.proceed,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: _noFilesFound
                              ? theme.colorScheme.onSurfaceVariant
                              : Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WorldDistributionRow extends StatefulWidget {
  const _WorldDistributionRow({
    required this.fileName,
    required this.assignment,
    required this.onChanged,
    required this.onCheckDuplicate,
  });

  final String fileName;
  final ({String world, int level})? assignment;
  final ValueChanged<({String world, int level})?> onChanged;
  final bool Function(({String world, int level}) assignment) onCheckDuplicate;

  @override
  State<_WorldDistributionRow> createState() => _WorldDistributionRowState();
}

class _WorldDistributionRowState extends State<_WorldDistributionRow> {
  late TextEditingController _levelController;

  @override
  void initState() {
    super.initState();
    _levelController = TextEditingController(
      text: widget.assignment?.level.toString() ?? '1',
    );
  }

  @override
  void didUpdateWidget(_WorldDistributionRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.assignment?.level != oldWidget.assignment?.level) {
      final newText = widget.assignment?.level.toString() ?? '1';
      if (_levelController.text != newText) {
        _levelController.text = newText;
      }
    }
  }

  @override
  void dispose() {
    _levelController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final worlds = WorldRepository.allWorlds;
    final currentWorld = worlds.where((w) => w.codename == widget.assignment?.world).firstOrNull;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.fileName,
              style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ClipOval(
                  child: Container(
                    width: 48,
                    height: 48,
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: currentWorld != null
                        ? AssetImageWidget(
                            assetPath: currentWorld.getIconPath(),
                            width: 48,
                            height: 48,
                          )
                        : const Icon(Icons.help_outline),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      labelText: l10n.exportWorld,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: const OutlineInputBorder(),
                    ),
                    initialValue: widget.assignment?.world,
                    items: worlds.map((w) {
                      return DropdownMenuItem(
                        value: w.codename,
                        child: Text(w.nameGetter(l10n)),
                      );
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) {
                        final newAssignment = (world: val, level: widget.assignment?.level ?? 1);
                        if (widget.onCheckDuplicate(newAssignment)) {
                          AppMessage.show(context, l10n.exportDuplicateAssignment(
                            WorldRepository.findByCodename(val)?.nameGetter(l10n) ?? val,
                            newAssignment.level,
                          ));
                        } else {
                          widget.onChanged(newAssignment);
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _levelController,
                    decoration: InputDecoration(
                      labelText: l10n.exportLevelNumber,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      border: const OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final num = int.tryParse(val) ?? 1;
                      if (currentWorld != null) {
                        final clamped = num.clamp(1, currentWorld.levelCount);
                        final newAssignment = (world: widget.assignment?.world ?? worlds.first.codename, level: clamped);
                        
                        if (widget.onCheckDuplicate(newAssignment)) {
                          AppMessage.show(context, l10n.exportDuplicateAssignment(
                            currentWorld.nameGetter(l10n),
                            clamped,
                          ));
                          // Reset controller to previous value
                          _levelController.text = widget.assignment?.level.toString() ?? '1';
                        } else {
                          widget.onChanged(newAssignment);
                        }
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Column(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_up),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (currentWorld != null) {
                          final currentLevel = widget.assignment?.level ?? 1;
                          if (currentLevel < currentWorld.levelCount) {
                            final newAssignment = (world: widget.assignment!.world, level: currentLevel + 1);
                            if (widget.onCheckDuplicate(newAssignment)) {
                              AppMessage.show(context, l10n.exportDuplicateAssignment(
                                currentWorld.nameGetter(l10n),
                                newAssignment.level,
                              ));
                            } else {
                              widget.onChanged(newAssignment);
                            }
                          }
                        }
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_drop_down),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      onPressed: () {
                        if (currentWorld != null) {
                          final currentLevel = widget.assignment?.level ?? 1;
                          if (currentLevel > 1) {
                            final newAssignment = (world: widget.assignment!.world, level: currentLevel - 1);
                            if (widget.onCheckDuplicate(newAssignment)) {
                              AppMessage.show(context, l10n.exportDuplicateAssignment(
                                currentWorld.nameGetter(l10n),
                                newAssignment.level,
                              ));
                            } else {
                              widget.onChanged(newAssignment);
                            }
                          }
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ExportBreadcrumbBar extends StatelessWidget {
  const _ExportBreadcrumbBar({
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
              onTap:
                  i < pathStack.length - 1 ? () => onBreadcrumbClick(i) : null,
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

class _ExportFileItemRow extends StatelessWidget {
  const _ExportFileItemRow({
    required this.name,
    required this.isDir,
    required this.onTap,
    this.isBack = false,
    this.isSelected = false,
    this.extension,
  });

  final String name;
  final bool isDir;
  final VoidCallback onTap;
  final bool isBack;
  final bool isSelected;
  final String? extension;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isResourceFile =
        !isDir && (name.toLowerCase().endsWith('.smf') || (extension?.toLowerCase().endsWith('.smf') ?? false));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isSelected
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 48,
                height: 48,
                child: Icon(
                  isBack
                      ? Icons.arrow_back
                      : (isDir
                          ? Icons.folder
                          : (isResourceFile
                              ? Icons.inventory_2_outlined
                              : Icons.description)),
                  size: isBack ? 30 : 36,
                  color: isBack
                      ? const Color(0xFFFFC107)
                      : (isDir
                          ? const Color(0xFFFFC107)
                          : (isResourceFile
                              ? Colors.blueGrey
                              : theme.colorScheme.primary)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (extension != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        extension!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: theme.colorScheme.primary,
                )
              else if (isDir && !isBack)
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}