import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/rift_theme_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/utils/selection_search.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/rift_theme_widgets.dart';

/// Multi-select picker for rift themes. Tap to toggle; confirm with the check button.
class RiftThemeSelectionScreen extends StatefulWidget {
  const RiftThemeSelectionScreen({
    super.key,
    required this.initialSelectedIds,
    required this.accentColor,
    required this.onThemesConfirmed,
    required this.onBack,
  });

  final List<String> initialSelectedIds;
  final Color accentColor;
  final void Function(List<String> ids) onThemesConfirmed;
  final VoidCallback onBack;

  @override
  State<RiftThemeSelectionScreen> createState() =>
      _RiftThemeSelectionScreenState();
}

class _RiftThemeSelectionScreenState extends State<RiftThemeSelectionScreen> {
  String _searchQuery = '';
  late List<String> _selectedIds;

  @override
  void initState() {
    super.initState();
    _selectedIds = List<String>.from(widget.initialSelectedIds);
  }

  List<String> get _filteredThemes {
    final query = normalizeSelectionSearchQuery(_searchQuery);
    if (query.isEmpty) return RiftThemeRepository.themeIds;
    return RiftThemeRepository.themeIds.where((id) {
      final nameKey = RiftThemeRepository.nameKey(id);
      return matchesSelectionSearch(_searchQuery, [
        id,
        nameKey,
        ResourceNames.lookup(context, nameKey),
      ]);
    }).toList();
  }

  String _themeLabel(String id) {
    final nameKey = RiftThemeRepository.nameKey(id);
    final name = ResourceNames.lookup(context, nameKey);
    if (name != nameKey) {
      return name;
    }
    return id;
  }

  void _toggle(String id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final themes = _filteredThemes;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: widget.accentColor,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: widget.onBack,
        ),
        title: AppBarSearchField(
          hintText:
              l10n?.selectedCountTapToSearch(_selectedIds.length) ??
              'Selected ${_selectedIds.length}, tap to search',
          query: _searchQuery,
          borderRadius: 24,
          onChanged: (v) => setState(() => _searchQuery = v),
          onClear: () => setState(() => _searchQuery = ''),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () =>
            widget.onThemesConfirmed(List<String>.from(_selectedIds)),
        backgroundColor: widget.accentColor,
        foregroundColor: Colors.white,
        tooltip: l10n?.confirm ?? 'Confirm',
        child: const Icon(Icons.check),
      ),
      body: themes.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  l10n?.riftThemeNoSearchResults ?? 'No matching themes',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: themes.length,
              itemBuilder: (context, index) {
                final id = themes[index];
                final isSelected = _selectedIds.contains(id);
                final displayName = _themeLabel(id);

                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  color: isSelected
                      ? widget.accentColor.withValues(alpha: 0.08)
                      : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(
                      color: isSelected
                          ? widget.accentColor
                          : theme.dividerColor.withValues(alpha: 0.3),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: InkWell(
                    onTap: () => _toggle(id),
                    onLongPress: () => showRiftThemeDetailsDialog(context, id),
                    onSecondaryTap: () =>
                        showRiftThemeDetailsDialog(context, id),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          RiftThemeIcon(themeId: id),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  displayName,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  id,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Checkbox(
                            value: isSelected,
                            activeColor: widget.accentColor,
                            onChanged: (_) => _toggle(id),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
