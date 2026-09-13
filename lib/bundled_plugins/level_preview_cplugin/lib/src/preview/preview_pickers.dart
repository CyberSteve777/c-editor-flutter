import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/stage_banner_resolver.dart';
import 'package:c_editor/data/repository/custom_stage_preset_repository.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart';

class _PreviewBannerPresentation {
  const _PreviewBannerPresentation({required this.name, this.iconAssetPath});

  final String name;
  final String? iconAssetPath;
}

String _roundIconAssetPath(String iconName) {
  if (iconName.startsWith('assets/')) return iconName;
  if (iconName == 'unknown.webp' || iconName.endsWith('/unknown.webp')) {
    return 'assets/images/others/unknown.webp';
  }
  return 'assets/images/round_icons/$iconName';
}

_PreviewBannerPresentation _bannerPresentationFor({
  required BuildContext context,
  required String stem,
  required StageBannerResolver banners,
  required String Function(String key, [String? fallback]) t,
}) {
  if (stem == banners.defaultStem || stem.toLowerCase() == 'unknown') {
    return _PreviewBannerPresentation(
      name: t('previewGenUnknownBanner', 'Unknown background'),
      iconAssetPath: 'assets/images/others/unknown.webp',
    );
  }

  final aliases = banners.stageAliasesForStem(stem);
  final candidates = [
    for (final stage in StageRepository.allItems)
      if (aliases.contains(stage.alias)) stage,
  ];
  final expectedAlias = '${stem}Stage'.toLowerCase();
  StageItem? representative;
  for (final stage in candidates) {
    if (stage.alias.toLowerCase() == expectedAlias) {
      representative = stage;
      break;
    }
  }
  if (representative == null) {
    for (final stage in candidates) {
      if (stage.type == StageType.main) {
        representative = stage;
        break;
      }
    }
  }
  if (representative == null && candidates.isNotEmpty) {
    representative = candidates.first;
  }
  if (representative != null) {
    final iconName = representative.iconName;
    return _PreviewBannerPresentation(
      name: ResourceNames.lookupOrFallback(
        context,
        StageRepository.getName(representative.alias),
        representative.alias,
      ),
      iconAssetPath: iconName == null ? null : _roundIconAssetPath(iconName),
    );
  }

  for (final alias in aliases) {
    final preset = CustomStagePresetRepository.presetForAlias(alias);
    if (preset == null) continue;
    final iconName = preset.iconName;
    return _PreviewBannerPresentation(
      name: ResourceNames.lookupOrFallback(
        context,
        preset.nameKey,
        preset.alias,
      ),
      iconAssetPath: _roundIconAssetPath(iconName),
    );
  }

  return _PreviewBannerPresentation(
    name: t('previewGenUnknownBanner', 'Unknown background'),
    iconAssetPath: 'assets/images/others/unknown.webp',
  );
}

/// Banner picker: catalog-ordered localized cards, round icons, custom entry.
/// The unknown/fallback banner is always the last list item.
Future<String?> showPreviewBannerPicker({
  required BuildContext context,
  required StageBannerResolver banners,
  required String Function(String key, [String? fallback]) t,
  String? currentStem,
}) async {
  await Future.wait([
    StageRepository.init(),
    CustomStagePresetRepository.init(),
    ResourceNames.ensureLoaded(),
  ]);
  if (!context.mounted) return null;
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      final height = (MediaQuery.sizeOf(ctx).height - 180).clamp(140.0, 620.0);
      final stems = banners.orderedStemsForStageAliases(
        StageRepository.allItems.map((stage) => stage.alias),
      );
      final entries = [
        ...stems.take(stems.length - 1),
        '__custom__',
        stems.last,
      ];
      return AlertDialog(
        title: Text(t('previewGenChooseBanner', 'Choose banner')),
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
        content: SizedBox(
          width: 520,
          height: height,
          child: ListView.builder(
            itemCount: entries.length,
            itemBuilder: (_, i) {
              final stem = entries[i];
              if (stem == '__custom__') {
                return Card(
                  key: const ValueKey('preview-banner-custom'),
                  margin: const EdgeInsets.only(bottom: 8),
                  clipBehavior: Clip.antiAlias,
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    leading: const CircleAvatar(
                      child: Icon(Icons.folder_open, size: 22),
                    ),
                    title: Text(
                      t('previewGenCustomBanner', 'Custom image'),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () => Navigator.pop(ctx, '__custom__'),
                  ),
                );
              }
              final info = _bannerPresentationFor(
                context: ctx,
                stem: stem,
                banners: banners,
                t: t,
              );
              final isSelected = stem == currentStem;
              return Card(
                key: ValueKey('preview-banner-$stem'),
                margin: const EdgeInsets.only(bottom: 8),
                color: isSelected
                    ? theme.colorScheme.primary.withValues(alpha: 0.08)
                    : null,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.dividerColor.withValues(alpha: 0.3),
                    width: isSelected ? 2 : 1,
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  onTap: () => Navigator.pop(ctx, stem),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          height: 48,
                          child: AssetImageWidget(
                            assetPath:
                                info.iconAssetPath ??
                                banners.roundIconAssetForStem(stem),
                            altCandidates: banners
                                .roundIconAltCandidatesForStem(stem),
                            width: 48,
                            height: 48,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                info.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                stem,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 8),
                          Icon(
                            Icons.check_circle,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t('previewGenCancel', 'Cancel')),
          ),
        ],
      );
    },
  );
}

/// Top-level folders under assets/images that we expose in the picker.
const kPreviewImageFolders = <String>[
  'plants',
  'zombies',
  'griditems',
  'round_icons',
  'others',
  'ui',
  'worlds',
];

class PreviewAssetImageChoice {
  const PreviewAssetImageChoice.asset(this.assetPath) : isCustom = false;
  const PreviewAssetImageChoice.custom() : assetPath = null, isCustom = true;

  final String? assetPath;
  final bool isCustom;
}

Future<PreviewAssetImageChoice?> showPreviewAssetImagePicker({
  required BuildContext context,
  required String Function(String key, [String? fallback]) t,
}) async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  final all =
      manifest.listAssets().where((p) => p.startsWith('assets/images/')).where((
        p,
      ) {
        final lower = p.toLowerCase();
        return lower.endsWith('.png') ||
            lower.endsWith('.webp') ||
            lower.endsWith('.jpg') ||
            lower.endsWith('.jpeg') ||
            lower.endsWith('.gif');
      }).toList()..sort();

  if (!context.mounted) return null;

  return showDialog<PreviewAssetImageChoice>(
    context: context,
    builder: (ctx) => _AssetImagePickerDialog(assets: all, t: t),
  );
}

class _AssetImagePickerDialog extends StatefulWidget {
  const _AssetImagePickerDialog({required this.assets, required this.t});

  final List<String> assets;
  final String Function(String key, [String? fallback]) t;

  @override
  State<_AssetImagePickerDialog> createState() =>
      _AssetImagePickerDialogState();
}

class _AssetImagePickerDialogState extends State<_AssetImagePickerDialog> {
  String? _folder;
  String _query = '';

  List<String> get _folders {
    final found = <String>{};
    for (final a in widget.assets) {
      final rest = a.substring('assets/images/'.length);
      final slash = rest.indexOf('/');
      if (slash > 0) found.add(rest.substring(0, slash));
    }
    final ordered = [
      for (final f in kPreviewImageFolders)
        if (found.contains(f)) f,
      ...found.where((f) => !kPreviewImageFolders.contains(f)).toList()..sort(),
    ];
    return ordered;
  }

  List<String> get _filtered {
    var list = widget.assets;
    if (_folder != null) {
      final prefix = 'assets/images/$_folder/';
      list = list.where((a) => a.startsWith(prefix)).toList();
    }
    final q = _query.trim().toLowerCase();
    if (q.isNotEmpty) {
      list = list.where((a) => a.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final folders = _folders;
    final items = _filtered;
    return AlertDialog(
      title: Text(t('previewGenAddImage', 'Add image')),
      content: SizedBox(
        width: 520,
        height: 440,
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                isDense: true,
                prefixIcon: const Icon(Icons.search),
                hintText: t('previewGenImageSearch', 'Search images'),
              ),
              onChanged: (v) => setState(() => _query = v),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 6),
                    child: ChoiceChip(
                      label: Text(t('previewGenImageAll', 'All')),
                      selected: _folder == null,
                      onSelected: (_) => setState(() => _folder = null),
                    ),
                  ),
                  for (final f in folders)
                    Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: ChoiceChip(
                        label: Text(f),
                        selected: _folder == f,
                        onSelected: (_) => setState(() => _folder = f),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: items.isEmpty
                  ? Center(child: Text(t('previewGenImageEmpty', 'No images')))
                  : GridView.builder(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisSpacing: 6,
                            crossAxisSpacing: 6,
                          ),
                      itemCount: items.length,
                      itemBuilder: (_, i) {
                        final path = items[i];
                        final name = path.split('/').last;
                        return InkWell(
                          onTap: () => Navigator.pop(
                            context,
                            PreviewAssetImageChoice.asset(path),
                          ),
                          child: Tooltip(
                            message: name,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: Colors.black26,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.white24),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(4),
                                child: AssetImageWidget(
                                  assetPath: path,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
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
          child: Text(t('previewGenCancel', 'Cancel')),
        ),
        TextButton(
          onPressed: () =>
              Navigator.pop(context, const PreviewAssetImageChoice.custom()),
          child: Text(t('previewGenCustomImage', 'Custom file')),
        ),
      ],
    );
  }
}
