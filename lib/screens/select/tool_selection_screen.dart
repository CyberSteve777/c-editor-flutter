import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/tool_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/asset_image.dart' show AssetImageWidget;

/// Tool selection. Ported from Z-Editor-master ToolSelectionScreen.kt
class ToolSelectionScreen extends StatelessWidget {
  const ToolSelectionScreen({
    super.key,
    required this.onToolSelected,
    required this.onBack,
  });

  final void Function(String id) onToolSelected;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final tools = ToolRepository.getAll();
    final theme = Theme.of(context);
    final themeColor = theme.colorScheme.primary;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        backgroundColor: themeColor,
        foregroundColor: Colors.white,
        title: Text(
          l10n?.selectToolCard ?? 'Select tool card',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: Container(
        color: theme.colorScheme.surface,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isDesktop = constraints.maxWidth > 600;
            final crossAxisCount = isDesktop ? 4 : 2;
            return GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                childAspectRatio: 1.4,
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
                  onTap: () => onToolSelected(tool.id),
                );
              },
            );
          },
        ),
      ),
    );
  }
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
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _ToolIconFrame(iconPath: iconPath, theme: theme),
              const SizedBox(height: 8),
              Flexible(
                child: Text(
                  name,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                id,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelMedium?.copyWith(
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

class _ToolIconFrame extends StatelessWidget {
  const _ToolIconFrame({required this.iconPath, required this.theme});

  final String? iconPath;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 56,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: iconPath != null
          ? AssetImageWidget(assetPath: iconPath!, fit: BoxFit.contain)
          : Icon(Icons.build, size: 36, color: theme.colorScheme.outline),
    );
  }
}
