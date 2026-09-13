import 'package:flutter/material.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';

class SelectionDialog<T> extends StatefulWidget {
  const SelectionDialog({
    super.key,
    required this.title,
    required this.items,
    required this.onSelected,
    required this.itemBuilder,
    required this.filter,
  });

  final String title;
  final List<T> items;
  final ValueChanged<T> onSelected;
  final Widget Function(BuildContext, T) itemBuilder;
  final bool Function(T, String) filter;

  @override
  State<SelectionDialog<T>> createState() => _SelectionDialogState<T>();
}

class _SelectionDialogState<T> extends State<SelectionDialog<T>> {
  final TextEditingController _searchController = TextEditingController();
  late List<T> _filteredItems;

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredItems = widget.items
          .where((item) => widget.filter(item, query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final media = MediaQuery.of(context);
    final compact = media.size.width < 480;
    final availableHeight = media.size.height - media.viewInsets.bottom;
    final contentHeight = (availableHeight - 200).clamp(160.0, 500.0);
    return AlertDialog(
      scrollable: true,
      constraints: const BoxConstraints(maxWidth: 640),
      insetPadding: EdgeInsets.symmetric(
        horizontal: compact ? 12 : 40,
        vertical: compact ? 16 : 24,
      ),
      titlePadding: compact ? const EdgeInsets.fromLTRB(16, 16, 16, 12) : null,
      contentPadding: compact ? const EdgeInsets.fromLTRB(16, 0, 16, 8) : null,
      actionsPadding: compact ? const EdgeInsets.fromLTRB(16, 8, 16, 16) : null,
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        height: contentHeight,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SelectionSearchField(
              hintText: l10n?.search ?? 'Search',
              query: _searchController.text,
              controller: _searchController,
              useOutlineBorder: true,
              onChanged: (_) {},
              onClear: () => _searchController.clear(),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _filteredItems.length,
                itemBuilder: (context, index) {
                  final item = _filteredItems[index];
                  return InkWell(
                    onTap: () {
                      widget.onSelected(item);
                      Navigator.pop(context);
                    },
                    child: widget.itemBuilder(context, item),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
      ],
    );
  }
}
