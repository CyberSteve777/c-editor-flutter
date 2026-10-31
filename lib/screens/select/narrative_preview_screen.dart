import 'package:flutter/material.dart';
import 'package:c_editor/data/narrative_catalog.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;

class NarrativePreviewScreen extends StatelessWidget {
  const NarrativePreviewScreen({
    super.key,
    required this.catalog,
    required this.dialogue,
    this.onSelect,
  });

  final NarrativeCatalog catalog;
  final NarrativeEntry dialogue;
  final VoidCallback? onSelect;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final strings = catalog.strings;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          tooltip: l10n?.back ?? 'Back',
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(strings.detailsTitle),
      ),
      floatingActionButton: onSelect == null || !dialogue.selectable
          ? null
          : FloatingActionButton.extended(
              onPressed: onSelect,
              icon: const Icon(Icons.check),
              label: Text(strings.selectDialogue),
            ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
        children: [
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: AssetImageWidget(
                          assetPath: dialogue.iconAsset,
                          altCandidates: imageAltCandidates(dialogue.iconAsset),
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dialogue.title,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${strings.rawId}: ${dialogue.id}',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 920),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < dialogue.lines.length; index++)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 14),
                      child: NarrativeLineView(
                        key: ValueKey('narrative-line-$index'),
                        line: dialogue.lines[index],
                        localeCode: catalog.localeCode,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class NarrativeLineView extends StatelessWidget {
  const NarrativeLineView({
    super.key,
    required this.line,
    required this.localeCode,
  });

  final NarrativeLine line;
  final String localeCode;

  static bool isRightAlignedNpc(String? npc) =>
      npc == 'winnie' || npc == 'winnieicon' || npc == 'specialwinnie';

  @override
  Widget build(BuildContext context) {
    if (line.kind != NarrativeLineKind.speech) {
      return _NarrativeStageDirection(line: line);
    }

    final rightAligned = isRightAlignedNpc(line.npc);
    final avatar = _NarrativeNpcAvatar(npc: line.npc);
    final bubble = Expanded(
      child: Column(
        crossAxisAlignment: rightAligned
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Text(
            _speakerWithEmotion(),
            textAlign: rightAligned ? TextAlign.right : TextAlign.left,
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              border: Border.all(
                color: Theme.of(
                  context,
                ).colorScheme.outlineVariant.withValues(alpha: 0.9),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              line.text,
              textAlign: rightAligned ? TextAlign.right : TextAlign.left,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );

    return Row(
      key: ValueKey(rightAligned ? 'npc-right' : 'npc-left'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: rightAligned
          ? [bubble, const SizedBox(width: 12), avatar]
          : [avatar, const SizedBox(width: 12), bubble],
    );
  }

  String _speakerWithEmotion() {
    final speaker = line.speaker ?? '';
    final emotion = line.emotion;
    if (emotion == null || emotion.isEmpty) return speaker;
    return localeCode == 'zh' ? '$speaker（$emotion）' : '$speaker ($emotion)';
  }
}

class _NarrativeStageDirection extends StatelessWidget {
  const _NarrativeStageDirection({required this.line});

  final NarrativeLine line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        line.text,
        textAlign: TextAlign.center,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontStyle: line.kind == NarrativeLineKind.stage
              ? FontStyle.italic
              : null,
        ),
      ),
    );
  }
}

class _NarrativeNpcAvatar extends StatelessWidget {
  const _NarrativeNpcAvatar({required this.npc});

  final String? npc;

  @override
  Widget build(BuildContext context) {
    final id = npc;
    final asset = id == null || id.isEmpty
        ? 'assets/images/others/unknown.webp'
        : 'assets/images/npcs/npc_$id.webp';
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: AssetImageWidget(
        key: ValueKey('npc-avatar-${id ?? 'unknown'}'),
        assetPath: asset,
        altCandidates: imageAltCandidates(asset),
        width: 72,
        height: 72,
        fit: BoxFit.cover,
      ),
    );
  }
}
