import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/mold_colony_module_utils.dart';
import 'package:c_editor/data/pvz_alias_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/editor_object_alias.dart';

class MoldColonyChallengeScreen extends StatefulWidget {
  const MoldColonyChallengeScreen({
    super.key,
    required this.rtid,
    required this.levelFile,
    required this.onChanged,
    required this.onBack,
  });

  final String rtid;
  final PvzLevelFile levelFile;
  final VoidCallback onChanged;
  final VoidCallback onBack;

  @override
  State<MoldColonyChallengeScreen> createState() =>
      _MoldColonyChallengeScreenState();
}

class _MoldColonyChallengeScreenState extends State<MoldColonyChallengeScreen> {
  static const _objClass = MoldColonyModuleUtils.moduleObjClass;
  static const _moldIconPath = 'assets/images/griditems/fake_mold.webp';

  late PvzObject _moduleObject;
  late MoldColonyChallengePropsData _moduleData;
  PvzObject? _layoutObject;
  late BoardGridMapPropsData _layoutData;
  int _selectedRow = 0;
  int _selectedColumn = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final moduleAlias =
        RtidParser.parse(widget.rtid)?.alias ??
        MoldColonyModuleUtils.defaultModuleAlias;
    _moduleObject = widget.levelFile.objects.firstWhere(
      (object) => object.aliases?.contains(moduleAlias) == true,
      orElse: () => PvzObject(
        aliases: [moduleAlias],
        objClass: _objClass,
        objData: MoldColonyChallengePropsData().toJson(),
      ),
    );
    if (!widget.levelFile.objects.contains(_moduleObject)) {
      widget.levelFile.objects.add(_moduleObject);
    }
    _moduleData = MoldColonyChallengePropsData.fromJson(
      Map<String, dynamic>.from(_moduleObject.objData as Map? ?? const {}),
    );
    _reloadLayout();
  }

  void _reloadLayout() {
    _layoutObject = MoldColonyModuleUtils.findLayoutObject(
      widget.levelFile,
      _moduleData.locations,
    );
    final rawData = _layoutObject?.objData;
    final parsed = rawData is Map
        ? BoardGridMapPropsData.fromJson(Map<String, dynamic>.from(rawData))
        : BoardGridMapPropsData.empty(rows: _gridRows, columns: _gridColumns);
    _layoutData = parsed.normalized(rows: _gridRows, columns: _gridColumns);
  }

  bool get _isDeepSeaLawn {
    final parsed = LevelParser.parseLevel(widget.levelFile);
    return LevelParser.isDeepSeaLawn(parsed.levelDef, widget.levelFile);
  }

  int get _gridRows => _isDeepSeaLawn ? 6 : 5;
  int get _gridColumns => _isDeepSeaLawn ? 10 : 9;

  RtidInfo? get _locationsInfo => RtidParser.parse(_moduleData.locations);

  bool get _hasValidLink =>
      MoldColonyModuleUtils.hasValidLayoutLink(widget.levelFile, _moduleData);

  String get _repairAlias {
    final requestedAlias = _locationsInfo?.alias;
    final requestedLayout = requestedAlias == null
        ? null
        : widget.levelFile.objects.firstWhereOrNull(
            (object) =>
                object.objClass == MoldColonyModuleUtils.layoutObjClass &&
                object.aliases?.contains(requestedAlias) == true,
          );
    if (requestedLayout != null) return requestedAlias!;
    return PvzAliasUtils.uniqueAlias(
      widget.levelFile,
      MoldColonyModuleUtils.defaultLayoutAlias,
    );
  }

  void _repairLink() {
    MoldColonyModuleUtils.ensureCurrentLevelLayout(
      levelFile: widget.levelFile,
      moduleObject: _moduleObject,
      rows: _gridRows,
      columns: _gridColumns,
    );
    _moduleData = MoldColonyChallengePropsData.fromJson(
      Map<String, dynamic>.from(_moduleObject.objData as Map),
    );
    _reloadLayout();
    widget.onChanged();
    setState(() {});
  }

  void _toggleCell(int row, int column) {
    if (!_hasValidLink || _layoutObject == null) return;
    setState(() {
      _selectedRow = row;
      _selectedColumn = column;
      _layoutData.values[row][column] = _layoutData.values[row][column] == 0
          ? 1
          : 0;
      _layoutObject!.objData = _layoutData.toJson();
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n.back,
          onPressed: widget.onBack,
        ),
        title: buildEditorObjectAppBarTitle(
          context: context,
          localizedName: resolveModuleTitleByObjClass(context, _objClass),
          isEvent: false,
          objClass: _objClass,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n.tooltipAboutModule,
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: false,
              title: l10n.moduleTitle_MoldColonyChallengeProps,
              sections: [
                HelpSectionData(
                  title: l10n.briefOverview,
                  body: l10n.moldColonyHelpOverview,
                ),
                HelpSectionData(
                  title: l10n.moldColonyHelpGridTitle,
                  body: l10n.moldColonyHelpGridBody,
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildLinkStatusCard(theme, l10n),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.selectedPosition,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'R${_selectedRow + 1} : C${_selectedColumn + 1}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Center(child: _buildGrid(theme, l10n)),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _LegendItem(
                          label: l10n.moldColonyEmpty,
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: theme.colorScheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const SizedBox(width: 24),
                        _LegendItem(
                          label: l10n.moldColonies,
                          child: const AssetImageWidget(
                            assetPath: _moldIconPath,
                            width: 32,
                            height: 32,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLinkStatusCard(ThemeData theme, AppLocalizations l10n) {
    final valid = _hasValidLink;
    final isDark = theme.brightness == Brightness.dark;
    final background = valid
        ? (isDark ? const Color(0xFF173D23) : const Color(0xFFE8F5E9))
        : theme.colorScheme.errorContainer;
    final foreground = valid
        ? (isDark ? const Color(0xFF9DDBA8) : const Color(0xFF2E7D32))
        : theme.colorScheme.onErrorContainer;
    final levelModulesError = _locationsInfo?.source == 'LevelModules';

    return Card(
      color: background,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  valid ? Icons.check_circle : editorErrorIcon,
                  color: foreground,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.moldColonyLocationsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: foreground,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              l10n.moldColonyLocationsValue(_moduleData.locations),
              style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
            ),
            if (!valid) ...[
              const SizedBox(height: 12),
              Text(
                levelModulesError
                    ? l10n.moldColonyLevelModulesError
                    : l10n.moldColonyInvalidLinkError,
                style: theme.textTheme.bodyMedium?.copyWith(color: foreground),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: _repairLink,
                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
                icon: const Icon(Icons.build_circle_outlined),
                label: Text(l10n.moldColonyRepairLink(_repairAlias)),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGrid(ThemeData theme, AppLocalizations l10n) {
    return scaleTableForDesktop(
      context: context,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: EditorItemCardLayout.gridPreviewMaxWidth(context),
        ),
        child: AspectRatio(
          aspectRatio: _gridColumns / _gridRows,
          child: Opacity(
            opacity: _hasValidLink ? 1 : 0.72,
            child: Container(
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF31383B)
                    : const Color(0xFFD7ECF1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFF6B899A)),
              ),
              child: Column(
                children: List.generate(_gridRows, (row) {
                  return Expanded(
                    child: Row(
                      children: List.generate(_gridColumns, (column) {
                        final hasColonies =
                            _layoutData.values[row][column] != 0;
                        final selected =
                            row == _selectedRow && column == _selectedColumn;
                        return Expanded(
                          child: Semantics(
                            button: _hasValidLink,
                            selected: selected,
                            label:
                                'R${row + 1}:C${column + 1}, ${hasColonies ? l10n.moldColonies : l10n.moldColonyEmpty}',
                            child: GestureDetector(
                              onTap: _hasValidLink
                                  ? () => _toggleCell(row, column)
                                  : null,
                              child: Container(
                                margin: const EdgeInsets.all(0.5),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? theme.colorScheme.primary.withValues(
                                          alpha: 0.18,
                                        )
                                      : Colors.transparent,
                                  border: Border.all(
                                    color: selected
                                        ? theme.colorScheme.primary
                                        : const Color(0xFF6B899A),
                                    width: selected ? 1.2 : 0.5,
                                  ),
                                ),
                                child: hasColonies
                                    ? const Padding(
                                        padding: EdgeInsets.all(2),
                                        child: AssetImageWidget(
                                          assetPath: _moldIconPath,
                                          fit: BoxFit.contain,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.child, required this.label});

  final Widget child;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [child, const SizedBox(width: 8), Text(label)],
    );
  }
}
