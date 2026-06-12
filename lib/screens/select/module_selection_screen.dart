import 'package:flutter/material.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Module selection. Ported from Z-Editor-master ModuleSelectionScreen.kt
class ModuleSelectionScreen extends StatefulWidget {
  const ModuleSelectionScreen({
    super.key,
    required this.existingObjClasses,
  });

  final Set<String> existingObjClasses;

  @override
  State<ModuleSelectionScreen> createState() => _ModuleSelectionScreenState();
}

class _ModuleSelectionScreenState extends State<ModuleSelectionScreen> {
  String _searchQuery = '';
  ModuleCategory _selectedCategory = ModuleCategory.base;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final allModules = ModuleRegistry.getAllModules();

    final filteredModules = allModules.where((meta) {
      final categoryMatch = meta.category == _selectedCategory;
      final searchMatch = _searchQuery.trim().isEmpty ||
          meta.getTitle(context).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          meta.getDescription(context).toLowerCase().contains(_searchQuery.toLowerCase()) ||
          meta.defaultAlias.toLowerCase().contains(_searchQuery.toLowerCase());
      return categoryMatch && searchMatch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(l10n?.addNewModule ?? 'Add module'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextField(
                  onChanged: (v) => setState(() => _searchQuery = v),
                  decoration: InputDecoration(
                    hintText: l10n?.search ?? 'Search',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () => setState(() => _searchQuery = ''),
                          )
                        : null,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                  ),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                child: Row(
                  children: ModuleCategory.values.map((cat) {
                    return AccentBarChoiceChip(
                      label: _categoryLabel(cat, l10n),
                      selected: _selectedCategory == cat,
                      onSelected: (_) => setState(() => _selectedCategory = cat),
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      body: filteredModules.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.search_off, size: 64, color: theme.colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isNotEmpty
                        ? (l10n?.noResultsFor(_searchQuery) ?? 'No results for "$_searchQuery"')
                        : (l10n?.noModulesInCategory ?? 'No modules in this category'),
                    style: theme.textTheme.bodyLarge,
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: filteredModules.length,
              itemBuilder: (context, index) {
                final meta = filteredModules[index];
                final isAlreadyAdded = widget.existingObjClasses.contains(meta.objClass);
                final isEnabled = !isAlreadyAdded || meta.allowMultiple;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _ModuleSelectionCard(
                    meta: meta,
                    isAlreadyAdded: isAlreadyAdded,
                    isEnabled: isEnabled,
                    onTap: () {
                      if (isEnabled) Navigator.pop(context, meta);
                    },
                  ),
                );
              },
            ),
    );
  }

  String _categoryLabel(ModuleCategory cat, AppLocalizations? l10n) {
    if (l10n == null) {
      switch (cat) {
        case ModuleCategory.base: return 'Base';
        case ModuleCategory.mode: return 'Game Modes';
        case ModuleCategory.scene: return 'Scene';
        case ModuleCategory.gimmick: return 'Gimmick';
      }
    }
    switch (cat) {
      case ModuleCategory.base: return l10n.moduleCategoryBase;
      case ModuleCategory.mode: return l10n.moduleCategoryMode;
      case ModuleCategory.scene: return l10n.moduleCategoryScene;
      case ModuleCategory.gimmick: return l10n.moduleCategoryGimmick;
    }
  }
}

class _ModuleSelectionCard extends StatelessWidget {
  const _ModuleSelectionCard({
    required this.meta,
    required this.isAlreadyAdded,
    required this.isEnabled,
    required this.onTap,
  });

  final ModuleMetadata meta;
  final bool isAlreadyAdded;
  final bool isEnabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Opacity(
      opacity: isEnabled ? 1 : 0.6,
      child: Card(
        color: isEnabled ? theme.colorScheme.surface : theme.colorScheme.surfaceContainerHighest,
        elevation: isEnabled ? 2 : 0,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: (isEnabled ? theme.colorScheme.primary : theme.colorScheme.outline).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    meta.icon,
                    size: 28,
                    color: isEnabled ? theme.colorScheme.primary : theme.colorScheme.outline,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        meta.getTitle(context),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isEnabled ? theme.colorScheme.onSurface : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        meta.getDescription(context),
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isAlreadyAdded)
                  Icon(
                    meta.allowMultiple ? Icons.add_circle : Icons.check_circle,
                    color: const Color(0xFF4CAF50),
                    size: 24,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
