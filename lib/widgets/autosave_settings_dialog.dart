import 'package:c_editor/bloc/settings/settings_cubit.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Opens the Autosave settings dialog. Saves only when the user taps Save.
Future<void> showAutosaveSettingsDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final cubit = context.read<SettingsCubit>();
  var enabled = cubit.state.autosave;

  final saved = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setDialogState) => AlertDialog(
        title: Text(l10n?.autosave ?? 'Autosave'),
        content: CheckboxListTile(
          value: enabled,
          onChanged: (v) => setDialogState(() => enabled = v ?? false),
          title: Text(
            l10n?.autosaveSubtitle ??
                'Save automatically when leaving the editor',
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n?.save ?? 'Save'),
          ),
        ],
      ),
    ),
  );

  if (saved == true && context.mounted) {
    cubit.setAutosave(enabled);
  }
}
