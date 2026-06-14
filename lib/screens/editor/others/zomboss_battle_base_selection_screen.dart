import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/zomboss_battle_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/zomboss_mech_editor_widgets.dart';

/// Picks a base Zomboss family; returns base id string.
class ZombossBattleBaseSelectionScreen extends StatelessWidget {
  const ZombossBattleBaseSelectionScreen({
    super.key,
    required this.selectedBaseId,
  });

  final String selectedBaseId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final bases = ZombossBattleRepository.allZombosses;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n?.zombossBattleSelectBaseTitle ?? 'Select base Zomboss',
        ),
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
