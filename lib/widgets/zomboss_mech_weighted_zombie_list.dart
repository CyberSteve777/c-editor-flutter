import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/zombie_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/screens/select/zombie_selection_screen.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';

const _kUnknownZombieIcon = 'assets/images/others/unknown.webp';

class ZombossMechWeightedZombieListEditor extends StatelessWidget {
  const ZombossMechWeightedZombieListEditor({
    super.key,
    required this.fieldLabel,
    required this.weightLabel,
    required this.zombieIds,
    required this.weights,
    required this.editable,
    required this.onChanged,
  });

  final String fieldLabel;
  final String weightLabel;
  final List<String> zombieIds;
  final List<int> weights;
  final bool editable;
  final void Function(List<String> zombieIds, List<int> weights) onChanged;

  int _weightAt(int index) {
    if (index >= 0 && index < weights.length) return weights[index];
    return 100;
  }

  Future<void> _pickZombie(BuildContext context) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => ZombieSelectionScreen(
          onZombieSelected: (id) {
            Navigator.pop(ctx);
            onChanged([...zombieIds, id], [...weights, 100]);
          },
          onBack: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  Future<void> _replaceZombie(BuildContext context, int index) async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder: (ctx) => ZombieSelectionScreen(
          onZombieSelected: (id) {
            Navigator.pop(ctx);
            final nextIds = List<String>.from(zombieIds);
            nextIds[index] = id;
            onChanged(nextIds, _normalizedWeights);
          },
          onBack: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  List<int> get _normalizedWeights => [
    for (var i = 0; i < zombieIds.length; i++) _weightAt(i),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(fieldLabel, style: theme.textTheme.titleSmall),
            ),
            if (editable)
              IconButton(
                visualDensity: VisualDensity.compact,
                tooltip: l10n?.zombossMechAddZombie ?? 'Add zombie',
                onPressed: () => _pickZombie(context),
                icon: const Icon(Icons.add_circle_outline),
              ),
          ],
        ),
        if (zombieIds.isEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text(
              l10n?.zombossMechNoZombiesInList ?? 'No zombies in list',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          for (var i = 0; i < zombieIds.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _WeightedZombieRow(
                zombieId: zombieIds[i],
                weight: _weightAt(i),
                weightLabel: weightLabel,
                editable: editable,
                onTap: editable ? () => _replaceZombie(context, i) : null,
                onWeightChanged: editable
                    ? (weight) {
                        final nextWeights = _normalizedWeights;
                        nextWeights[i] = weight;
                        onChanged(List<String>.from(zombieIds), nextWeights);
                      }
                    : null,
                onRemove: editable
                    ? () {
                        final nextIds = List<String>.from(zombieIds)
                          ..removeAt(i);
                        final nextWeights = _normalizedWeights..removeAt(i);
                        onChanged(nextIds, nextWeights);
                      }
                    : null,
              ),
            ),
      ],
    );
  }
}

class _WeightedZombieRow extends StatefulWidget {
  const _WeightedZombieRow({
    required this.zombieId,
    required this.weight,
    required this.weightLabel,
    required this.editable,
    this.onTap,
    this.onWeightChanged,
    this.onRemove,
  });

  final String zombieId;
  final int weight;
  final String weightLabel;
  final bool editable;
  final VoidCallback? onTap;
  final ValueChanged<int>? onWeightChanged;
  final VoidCallback? onRemove;

  @override
  State<_WeightedZombieRow> createState() => _WeightedZombieRowState();
}

class _WeightedZombieRowState extends State<_WeightedZombieRow> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _focused = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.weight}');
    _focusNode = FocusNode()
      ..addListener(() {
        final focused = _focusNode.hasFocus;
        if (_focused != focused) setState(() => _focused = focused);
      });
  }

  @override
  void didUpdateWidget(covariant _WeightedZombieRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_focused && oldWidget.weight != widget.weight) {
      _controller.text = '${widget.weight}';
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final repo = ZombieRepository();
    final info = repo.getZombieById(widget.zombieId);
    final nameKey = repo.getName(widget.zombieId);
    final localized = ResourceNames.lookup(context, nameKey);
    final displayName = localized != nameKey && localized.isNotEmpty
        ? localized
        : widget.zombieId;
    final iconPath = info?.iconAssetPath ?? _kUnknownZombieIcon;
    final weightFieldWidth =
        MediaQuery.sizeOf(context).width < 420 ? 144.0 : 168.0;

    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: widget.editable ? widget.onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: AssetImageWidget(
                  assetPath: iconPath,
                  width: 48,
                  height: 48,
                  fit: BoxFit.contain,
                  altCandidates: imageAltCandidates(iconPath),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      displayName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.zombieId,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: weightFieldWidth,
                child: TextFormField(
                  controller: _controller,
                  focusNode: _focusNode,
                  readOnly: !widget.editable,
                  decoration: editorInputDecoration(
                    context,
                    labelText: widget.weightLabel,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: widget.editable
                      ? (value) {
                          final parsed = int.tryParse(value);
                          if (parsed != null) {
                            widget.onWeightChanged?.call(parsed);
                          }
                        }
                      : null,
                ),
              ),
              if (widget.onRemove != null)
                IconButton(
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.close, size: 18),
                  tooltip: AppLocalizations.of(context)?.remove ?? 'Remove',
                  onPressed: widget.onRemove,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
