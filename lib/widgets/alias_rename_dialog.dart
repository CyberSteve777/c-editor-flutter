import 'package:flutter/material.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart';

/// Alert with a single OK action when an alias is already taken.
Future<void> showAliasAlreadyTakenDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final okGreen = isDark ? pvzGreenLight : pvzGreenDark;

  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n?.aliasAlreadyTakenTitle ?? 'Alias already taken'),
      content: Text(
        l10n?.aliasAlreadyExists ?? 'Alias already exists in this level.',
      ),
      actions: [
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: okGreen,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n?.ok ?? 'OK'),
        ),
      ],
    ),
  );
}

/// Confirm renaming an alias; OK applies the rename, Cancel keeps the old name.
Future<bool> showAliasRenameConfirmDialog(
  BuildContext context, {
  required String oldAlias,
  required String newAlias,
}) async {
  final l10n = AppLocalizations.of(context);
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;
  final okGreen = isDark ? pvzGreenLight : pvzGreenDark;

  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n?.aliasRenameConfirmTitle ?? 'Rename alias?'),
      content: Text(
        l10n?.aliasRenameConfirmMessage(oldAlias, newAlias) ??
            'Rename "$oldAlias" to "$newAlias"? All references in this level will be updated.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          style: TextButton.styleFrom(
            foregroundColor: theme.colorScheme.error,
          ),
          child: Text(l10n?.cancel ?? 'Cancel'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: okGreen,
            foregroundColor: Colors.white,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n?.ok ?? 'OK'),
        ),
      ],
    ),
  );
  return result == true;
}
