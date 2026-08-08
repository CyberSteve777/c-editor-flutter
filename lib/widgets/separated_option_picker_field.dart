import 'package:flutter/material.dart';
import 'package:c_editor/widgets/editor_components.dart';

class SeparatedOptionPickerItem<T> {
  const SeparatedOptionPickerItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.fieldLabel,
  });

  final T value;
  final String label;
  final String? subtitle;
  final String? fieldLabel;
}

/// Form-field-style single selector whose choices use roomy, divided rows.
class SeparatedOptionPickerField<T> extends StatelessWidget {
  const SeparatedOptionPickerField({
    super.key,
    required this.labelText,
    required this.value,
    required this.items,
    required this.onChanged,
    this.enabled = true,
    this.decoration,
  });

  final String labelText;
  final T? value;
  final List<SeparatedOptionPickerItem<T>> items;
  final ValueChanged<T> onChanged;
  final bool enabled;
  final InputDecoration? decoration;

  SeparatedOptionPickerItem<T>? get _selectedItem {
    for (final item in items) {
      if (item.value == value) return item;
    }
    return null;
  }

  Future<void> _showOptions(BuildContext context) async {
    if (!enabled || items.isEmpty) return;
    final selected = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        final maxHeight = MediaQuery.sizeOf(sheetContext).height * 0.72;
        return SafeArea(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: maxHeight),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 4, 24, 16),
                  child: Semantics(
                    header: true,
                    child: Text(
                      labelText,
                      textAlign: TextAlign.center,
                      style: Theme.of(sheetContext).textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const Divider(height: 1),
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      final selected = item.value == value;
                      return ListTile(
                        selected: selected,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 8,
                        ),
                        title: Text(item.label, maxLines: 3),
                        subtitle: item.subtitle == null
                            ? null
                            : Padding(
                                padding: const EdgeInsets.only(top: 3),
                                child: Text(
                                  item.subtitle!,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                        trailing: selected
                            ? Icon(
                                Icons.check,
                                color: Theme.of(context).colorScheme.primary,
                              )
                            : null,
                        onTap: () => Navigator.pop(context, item.value),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (selected != null && selected != value) onChanged(selected);
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selectedItem;
    return Semantics(
      button: enabled,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? () => _showOptions(context) : null,
        child: InputDecorator(
          isEmpty: selected == null,
          decoration:
              (decoration ??
                      editorInputDecoration(context, labelText: labelText))
                  .copyWith(enabled: enabled),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected?.fieldLabel ?? selected?.label ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }
}
