import 'package:flutter/material.dart';
import 'package:c_editor/widgets/editor_components.dart';

enum PreviewImageExportFormat { png, gif }

Future<PreviewImageExportFormat?> showPreviewExportFormatDialog({
  required BuildContext context,
  required String Function(String key, [String? fallback]) t,
}) => showDialog<PreviewImageExportFormat>(
  context: context,
  builder: (context) => AlertDialog(
    key: const ValueKey('previewExportFormatDialog'),
    scrollable: true,
    title: Text(t('previewGenExportFormat', 'Choose image format')),
    content: SizedBox(
      width: 480,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            t(
              'previewGenExportFormatHint',
              'GIF preserves animation; PNG saves a still image.',
            ),
          ),
          const SizedBox(height: 12),
          EditorOptionTile(
            key: const ValueKey('previewExportPngOption'),
            leading: const Icon(Icons.image_outlined),
            title: const Text('PNG'),
            subtitle: Text(t('previewGenExportPngHint', 'Static image')),
            onTap: () => Navigator.pop(context, PreviewImageExportFormat.png),
          ),
          EditorOptionTile(
            key: const ValueKey('previewExportGifOption'),
            leading: const Icon(Icons.gif_box_outlined),
            title: const Text('GIF'),
            subtitle: Text(t('previewGenExportGifHint', 'Animated image')),
            onTap: () => Navigator.pop(context, PreviewImageExportFormat.gif),
          ),
        ],
      ),
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(t('previewGenCancel', 'Cancel')),
      ),
    ],
  ),
);
