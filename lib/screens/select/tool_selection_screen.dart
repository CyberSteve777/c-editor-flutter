import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/tool_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/widgets/asset_image.dart' show AssetImageWidget;
import 'package:c_editor/widgets/editor_components.dart';

/// Tool selection. Ported from Z-Editor-master ToolSelectionScreen.kt
class ToolSelectionScreen extends StatefulWidget {
  const ToolSelectionScreen({
    super.key,
    required this.onToolSelected,
    required this.onBack,
  });

  final void Function(String id) onToolSelected;
  final VoidCallback onBack;

  @override
  State<ToolSelectionScreen> createState() => _ToolSelectionScreenState();
}

class _ToolSelectionScreenState extends State<ToolSelectionScreen> {
  String _searchQuery = '';

  List<ToolCardInfo> _filteredTools(BuildContext context) {
    return ToolRepository.getAll().where((tool) {
      return matchesSelectionSearch(_searchQuery, [
        tool.id,
        tool.name,
        ToolRepository.localizedName(context, tool.id),
      ]);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tools = _filteredTools(context);
    final theme = Theme.of(context);
    final themeColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: widget.onBack,
          ),
          backgroundColor: themeColor,
          foregroundColor: Colors.white,
          title: Text(
            l10n?.selectToolCard ?? 'Select tool card',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(64),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SelectionSearchField(
                hintText: l10n?.search ?? 'Search',
                query: _searchQuery,
                fillColor: theme.colorScheme.surface,
                onChanged: (v) => setState(() => _searchQuery = v),
                onClear: () => setState(() => _searchQuery = ''),
              ),
            ),
          ),
        ),
        body: Container(
          color: theme.colorScheme.surface,
          child: tools.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.build,
                        size: 64,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.5,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n?.noItems ?? 'No items',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                )
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final crossAxisCount = _selectionGridColumnCount(
                      constraints.maxWidth,
                    );
                    return GridView.builder(
                      padding: const EdgeInsets.all(16),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        childAspectRatio: 0.85,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                      ),
                      itemCount: tools.length,
                      itemBuilder: (context, index) {
                        final tool = tools[index];
                        final iconPath = tool.icon != null
                            ? 'assets/images/tools/${tool.icon}'
                            : null;
                        return _ToolCard(
                          id: tool.id,
                          name: ToolRepository.localizedName(context, tool.id),
                          iconPath: iconPath,
                          theme: theme,
                          onTap: () => widget.onToolSelected(tool.id),
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

int _selectionGridColumnCount(double width) {
  final columns = (width / 180).floor();
  if (columns < 2) return 2;
  if (columns > 6) return 6;
  return columns;
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({
    required this.id,
    required this.name,
    required this.iconPath,
    required this.theme,
    required this.onTap,
  });

  final String id;
  final String name;
  final String? iconPath;
  final ThemeData theme;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: _ToolIcon(iconPath: iconPath, theme: theme),
              ),
              const SizedBox(height: 8),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                id,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToolIcon extends StatelessWidget {
  const _ToolIcon({required this.iconPath, required this.theme});

  final String? iconPath;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    if (iconPath != null) {
      return AssetImageWidget(assetPath: iconPath!, fit: BoxFit.contain);
    }
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Icon(Icons.build, size: 42, color: theme.colorScheme.outline),
      ),
    );
  }
}
