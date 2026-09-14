import 'package:flutter/material.dart';

Future<bool?> showPreviewGifPngNoticeDialog({
  required BuildContext context,
  required String Function(String key, [String? fallback]) t,
}) => showDialog<bool>(
  context: context,
  builder: (context) => AlertDialog(
    key: const ValueKey('previewGifPngNoticeDialog'),
    scrollable: true,
    title: Text(t('previewGenGifPngNoticeTitle', 'Export as PNG')),
    content: SizedBox(
      width: 480,
      child: Text(
        t(
          'previewGenGifPngNotice',
          'The preview will be exported as PNG. Any GIFs added to it will show only their first frame.',
        ),
      ),
    ),
    actions: [
      TextButton(
        key: const ValueKey('previewGifPngNoticeCancel'),
        onPressed: () => Navigator.pop(context, false),
        child: Text(t('previewGenCancel', 'Cancel')),
      ),
      FilledButton(
        key: const ValueKey('previewGifPngNoticeExport'),
        onPressed: () => Navigator.pop(context, true),
        child: Text(t('previewGenExport', 'Export image')),
      ),
    ],
  ),
);
