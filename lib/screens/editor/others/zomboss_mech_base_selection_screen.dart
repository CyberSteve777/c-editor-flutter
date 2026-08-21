import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/zomboss_mech_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';
import 'package:c_editor/widgets/zomboss_mech_editor_widgets.dart';

/// Picks a base ZombossMech family; returns base id string.
class ZombossMechBaseSelectionScreen extends StatelessWidget {
  const ZombossMechBaseSelectionScreen({
    super.key,
    required this.selectedBaseId,
  });

  final String selectedBaseId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bases = ZombossMechRepository.allZombossMechs;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.zombossMechSelectBaseTitle ?? 'Select base ZombossMech',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            tooltip: l10n?.tooltipAboutSection ?? 'About this section',
            onPressed: () => showEditorHelpDialog(
              context,
              title:
                  l10n?.zombossMechSelectBaseTitle ?? 'Select base ZombossMech',
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body: l10n?.zombossMechBaseHint ?? '',
                ),
              ],
            ),
          ),
        ],
      ),
      body: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        itemCount: bases.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final base = bases[index];
          return ZombossMechBaseCard(
            baseId: base.id,
            icon: base.icon,
            selected: base.id == selectedBaseId,
            onTap: () => Navigator.pop(context, base.id),
          );
        },
      ),
    );
  }
}
