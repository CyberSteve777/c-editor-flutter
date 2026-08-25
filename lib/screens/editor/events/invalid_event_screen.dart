import 'package:flutter/material.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Invalid/broken event reference screen. Ported from Z-Editor-master InvalidEventEP.kt
class InvalidEventScreen extends StatelessWidget {
  const InvalidEventScreen({
    super.key,
    required this.rtid,
    required this.waveIndex,
    required this.onDeleteReference,
    required this.onBack,
  });

  final String rtid;
  final int waveIndex;
  final void Function(String) onDeleteReference;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final alias = LevelParser.extractAlias(rtid);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        title: Text(l10n?.invalidReference ?? 'Invalid reference'),
        backgroundColor: theme.colorScheme.error,
        foregroundColor: theme.colorScheme.onError,
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline),
            onPressed: () => showEditorHelpDialog(
              context,
              isEvent: true,
              title: l10n?.invalidEventTitle ?? 'Invalid event',
              themeColor: theme.colorScheme.error,
              sections: [
                HelpSectionData(
                  title: l10n?.overview ?? 'Overview',
                  body:
                      l10n?.eventHelpInvalidBody ??
                      'This event is referenced in the wave container but the parser cannot find its entity definition. The RTID points to nothing.',
                ),
                HelpSectionData(
                  title: l10n?.impact ?? 'Impact',
                  body:
                      l10n?.eventHelpInvalidImpact ??
                      'Keeping this invalid reference in the level will cause the game to crash when loading. You must remove it manually.',
                ),
              ],
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(editorErrorIcon, size: 80, color: theme.colorScheme.error),
              const SizedBox(height: 16),
              Text(
                l10n?.aliasNotFound(alias) ?? 'Alias "$alias" not found',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                l10n?.invalidRefBody(waveIndex) ??
                    'Wave $waveIndex references this event, but no matching entity exists in the level. This usually happens when an object was deleted or renamed. Keeping it will cause a crash.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    onDeleteReference(rtid);
                    onBack();
                  },
                  icon: const Icon(Icons.delete_forever),
                  label: Text(
                    l10n?.removeInvalidRef ??
                        'Remove this invalid reference from wave',
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: theme.colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
