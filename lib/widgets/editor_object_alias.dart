import 'package:flutter/material.dart';
import 'package:c_editor/data/pvz_alias_utils.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/registry/module_registry.dart';
import 'package:c_editor/data/rtid_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/screens/select/event_selection_screen.dart';
import 'package:c_editor/widgets/app_message.dart';

/// Resolves a localized event title from its [objClass].
String resolveEventTitleByObjClass(
  BuildContext context,
  String objClass,
  AppLocalizations? l10n,
) {
  return EventSelectionScreen.resolveEventTitleByObjClass(
    context,
    objClass,
    l10n,
  );
}

/// Resolves a localized module title from its [objClass].
String resolveModuleTitleByObjClass(BuildContext context, String objClass) {
  return ModuleRegistry.getMetadata(objClass).getTitle(context);
}

/// App bar title: "Edit {name} event/module" with [objClass] underneath.
Widget buildEditorObjectAppBarTitle({
  required BuildContext context,
  required String localizedName,
  required bool isEvent,
  required String objClass,
  Color? foregroundColor,
}) {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final fg =
      foregroundColor ??
      theme.appBarTheme.foregroundColor ??
      theme.colorScheme.onSurface;
  final titleText = isEvent
      ? (l10n?.editNamedEvent(localizedName) ?? 'Edit $localizedName event')
      : (l10n?.editNamedModule(localizedName) ??
            'Edit $localizedName module');

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(titleText, overflow: TextOverflow.ellipsis),
      Text(
        objClass,
        style: theme.textTheme.bodySmall?.copyWith(
          color: fg.withValues(alpha: 0.85),
        ),
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

Color editorObjectAccentColor(BuildContext context, {Color? appBarColor}) {
  if (appBarColor != null) return appBarColor;
  return Theme.of(context).colorScheme.primary;
}

/// Labeled alias field; border/focus uses [accentColor] (app bar color) when set.
class EditorAliasInputField extends StatefulWidget {
  const EditorAliasInputField({
    super.key,
    required this.alias,
    required this.levelFile,
    required this.onAliasChanged,
    this.accentColor,
    this.onChanged,
    this.wrapInCard = true,
  });

  final String alias;
  final PvzLevelFile levelFile;
  final ValueChanged<String> onAliasChanged;
  final Color? accentColor;
  final VoidCallback? onChanged;
  final bool wrapInCard;

  @override
  State<EditorAliasInputField> createState() => _EditorAliasInputFieldState();
}

class _EditorAliasInputFieldState extends State<EditorAliasInputField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.alias);
    _focusNode = FocusNode()..addListener(_handleFocusChange);
  }

  @override
  void didUpdateWidget(EditorAliasInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.alias != widget.alias &&
        _controller.text.trim() != widget.alias) {
      _controller.text = widget.alias;
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && mounted) {
      _commit();
    }
  }

  Future<void> _commit() async {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context);
    final next = _controller.text.trim();
    if (next.isEmpty || next == widget.alias) {
      if (mounted) {
        _controller.text = widget.alias;
      }
      return;
    }
    if (!PvzAliasUtils.isAliasAvailable(
      widget.levelFile,
      next,
      excludeAlias: widget.alias,
    )) {
      if (!mounted) return;
      AppMessage.show(
        context,
        l10n?.aliasAlreadyExists ?? 'Alias already exists in this level.',
        icon: Icons.warning_amber_rounded,
      );
      if (mounted) {
        _controller.text = widget.alias;
      }
      return;
    }
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n?.aliasRenameConfirmTitle ?? 'Rename alias?'),
        content: Text(
          l10n?.aliasRenameConfirmMessage(widget.alias, next) ??
              'Rename "${widget.alias}" to "$next"? All references in this level will be updated.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.confirm ?? 'Confirm'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    if (confirm != true) {
      _controller.text = widget.alias;
      return;
    }
    widget.onAliasChanged(next);
    widget.onChanged?.call();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final accent = editorObjectAccentColor(
      context,
      appBarColor: widget.accentColor,
    );
    final isDirty = _controller.text.trim() != widget.alias;

    final field = TextField(
      controller: _controller,
      focusNode: _focusNode,
      textInputAction: TextInputAction.done,
      onSubmitted: (_) => _commit(),
      decoration: InputDecoration(
        labelText: l10n?.aliasLabel ?? 'Alias',
        isDense: true,
        border: const OutlineInputBorder(),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDirty
                ? accent
                : theme.colorScheme.outline.withValues(alpha: 0.5),
            width: isDirty ? 1.5 : 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: accent, width: 2),
        ),
        labelStyle: TextStyle(
          color: isDirty ? accent : null,
        ),
      ),
      onChanged: (_) => setState(() {}),
    );

    if (!widget.wrapInCard) {
      return SizedBox(width: double.infinity, child: field);
    }

    return SizedBox(
      width: double.infinity,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: field,
        ),
      ),
    );
  }
}

/// Prompts for an alias when adding an event or module.
Future<String?> showPvzAliasInputDialog(
  BuildContext context, {
  required String defaultAlias,
  required String title,
  required String objClass,
  required PvzLevelFile levelFile,
}) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => _PvzAliasInputDialog(
      defaultAlias: defaultAlias,
      title: title,
      objClass: objClass,
      levelFile: levelFile,
    ),
  );
}

class _PvzAliasInputDialog extends StatefulWidget {
  const _PvzAliasInputDialog({
    required this.defaultAlias,
    required this.title,
    required this.objClass,
    required this.levelFile,
  });

  final String defaultAlias;
  final String title;
  final String objClass;
  final PvzLevelFile levelFile;

  @override
  State<_PvzAliasInputDialog> createState() => _PvzAliasInputDialogState();
}

class _PvzAliasInputDialogState extends State<_PvzAliasInputDialog> {
  late final TextEditingController _controller;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.defaultAlias);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final l10n = AppLocalizations.of(context);
    final alias = _controller.text.trim();
    if (alias.isEmpty ||
        !PvzAliasUtils.isAliasAvailable(widget.levelFile, alias)) {
      setState(
        () => _errorText =
            l10n?.aliasAlreadyExists ??
            'Alias already exists in this level.',
      );
      return;
    }
    Navigator.pop(context, alias);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.objClass,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                labelText: l10n?.aliasLabel ?? 'Alias',
                errorText: _errorText,
              ),
              onSubmitted: (_) => _submit(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: Text(l10n?.add ?? 'Add'),
        ),
      ],
    );
  }
}

/// Commits an alias rename for a level object referenced by [rtid].
void renameLevelObjectAlias({
  required PvzLevelFile levelFile,
  required String oldAlias,
  required String newAlias,
  String source = 'CurrentLevel',
  required VoidCallback onChanged,
}) {
  PvzAliasUtils.renameAlias(
    levelFile: levelFile,
    oldAlias: oldAlias,
    newAlias: newAlias,
    source: source,
  );
  onChanged();
}

String aliasFromRtid(String rtid) {
  return RtidParser.parse(rtid)?.alias ?? rtid;
}
