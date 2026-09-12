import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:c_editor/bundled_plugins/level_preview_cplugin/lib/src/preview/stage_banner_resolver.dart';
import 'package:c_editor/data/repository/stage_repository.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/widgets/asset_image.dart';

/// Banner picker: localized names, round icons, custom entry.
Future<String?> showPreviewBannerPicker({
  required BuildContext context,
  required StageBannerResolver banners,
  required String Function(String key, [String? fallback]) t,
}) async {
  await StageRepository.init();
  if (!context.mounted) return null;
  return showDialog<String>(
    context: context,
    builder: (ctx) {
      final stems = banners.allStems;
      return AlertDialog(
        title: Text(t('previewGenChooseBanner', 'Choose banner')),
        content: SizedBox(
          width: 420,
          height: 360,
          child: ListView.builder(
            itemCount: stems.length + 1,
            itemBuilder: (_, i) {
              if (i == stems.length) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 10,
                  ),
                  leading: const CircleAvatar(
                    child: Icon(Icons.folder_open, size: 22),
                  ),
                  title: Text(
                    t('previewGenCustomBanner', 'Custom image'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  onTap: () => Navigator.pop(ctx, '__custom__'),
                );
              }
              final stem = stems[i];
              final aliases = banners.aliasesForStem(stem);
              final alias = aliases.isNotEmpty ? aliases.first : stem;
              final nameKey = StageRepository.getName(alias);
              final label = ResourceNames.lookup(ctx, nameKey);
              final display = (label == nameKey || label.isEmpty) ? stem : label;
              return ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                leading: ClipOval(
                  child: SizedBox(
                    width: 48,
                    height: 48,
                    child: AssetImageWidget(
                      assetPath: banners.roundIconAssetForStem(stem),
                      altCandidates: banners.roundIconAltCandidatesForStem(
                        stem,
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(display, style: const TextStyle(fontSize: 16)),
                subtitle: Text(stem, style: const TextStyle(fontSize: 12)),
                onTap: () => Navigator.pop(ctx, stem),
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
  final all = manifest.listAssets()
      .where((p) => p.startsWith('assets/images/'))
      .where((p) {
        final lower = p.toLowerCase();
        return lower.endsWith('.png') ||
            lower.endsWith('.webp') ||
            lower.endsWith('.jpg') ||
            lower.endsWith('.jpeg') ||
            lower.endsWith('.gif');
      })
      .toList()
    ..sort();

  if (!context.mounted) return null;

  return showDialog<PreviewAssetImageChoice>(
    context: context,
    builder: (ctx) => _AssetImagePickerDialog(
      assets: all,
      t: t,
    ),
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
      ...found.where((f) => !kPreviewImageFolders.contains(f)).toList()
        ..sort(),
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
          onPressed: () => Navigator.pop(
            context,
            const PreviewAssetImageChoice.custom(),
          ),
          child: Text(t('previewGenCustomImage', 'Custom file')),
        ),
      ],
    );
  }
}
