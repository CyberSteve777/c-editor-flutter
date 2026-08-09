import 'package:flutter/material.dart';

import 'package:c_editor/escape_override.dart';
import 'package:c_editor/plugin_api/c_plugin_host.dart';
import 'package:c_editor/bundled_plugins/dynamic_fetch_cplugin/lib/src/download.dart';
import 'package:c_editor/bundled_plugins/dynamic_fetch_cplugin/lib/src/releases_api.dart';

/// Shared, platform-agnostic UI helpers for the dynamic-fetch plugin. Used by
/// both the native (`dart:io`) and web offer flows.

String formatDynamicBytes(int bytes) {
  if (bytes < 1024) return '$bytes B';
  final kb = bytes / 1024;
  if (kb < 1024) return '${kb.toStringAsFixed(0)} KB';
  final mb = kb / 1024;
  if (mb < 1024) return '${mb.toStringAsFixed(1)} MB';
  return '${(mb / 1024).toStringAsFixed(2)} GB';
}

String localizeDynamicDownloadError(
  CPluginHost host,
  BuildContext context,
  Object error,
) {
  switch (classifyDownloadError(error)) {
    case DownloadErrorKind.canceled:
      return host.localize(context, 'dynamicCanceled', 'Download canceled.');
    case DownloadErrorKind.noConnection:
      return host.localize(
        context,
        'dynamicNoConnection',
        'No internet connection. Check your network and try again.',
      );
    case DownloadErrorKind.connectionLost:
      return host.localize(
        context,
        'dynamicConnectionLost',
        'Connection lost while downloading. Please try again.',
      );
    case DownloadErrorKind.server:
      final code = serverStatusCode(error);
      return host.localize(
        context,
        'dynamicServerError',
        'Server error${code != null ? ' ($code)' : ''}. Please try again later.',
        {'code': '${code ?? ''}'},
      );
    case DownloadErrorKind.other:
      return host.localize(
        context,
        'dynamicFetchError',
        'Download failed: $error',
        {'error': '$error'},
      );
  }
}

/// Shows the GitHub release picker and returns the chosen option (or null).
Future<DynamicReleaseOption?> showDynamicReleasePicker(
  BuildContext context,
  CPluginHost host,
) {
  return showDialog<DynamicReleaseOption>(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => EscapeClosesModal(
      child: _ReleasePickerDialog(host: host),
    ),
  );
}

class _ReleasePickerDialog extends StatefulWidget {
  const _ReleasePickerDialog({required this.host});

  final CPluginHost host;

  @override
  State<_ReleasePickerDialog> createState() => _ReleasePickerDialogState();
}

class _ReleasePickerDialogState extends State<_ReleasePickerDialog> {
  late Future<List<DynamicReleaseOption>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<DynamicReleaseOption>> _load() => Pvz2cDynamicReleases().list();

  @override
  Widget build(BuildContext context) {
    final host = widget.host;
    return AlertDialog(
      title: Text(host.localize(context, 'dynamicSelectTitle')),
      content: SizedBox(
        width: 420,
        height: 360,
        child: FutureBuilder<List<DynamicReleaseOption>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              final message = localizeDynamicDownloadError(
                host,
                context,
                snapshot.error!,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Text(
                      message,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => setState(() {
                        _future = _load();
                      }),
                      child: Text(
                        host.localize(context, 'dynamicRetry', 'Retry'),
                      ),
                    ),
                  ),
                ],
              );
            }
            final items = snapshot.data ?? const [];
            if (items.isEmpty) {
              return Text(host.localize(context, 'dynamicEmpty'));
            }
            return ListView.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final item = items[index];
                final sizeLabel = item.sizeBytes > 0
                    ? formatDynamicBytes(item.sizeBytes)
                    : '';
                return ListTile(
                  leading: item.isLatest
                      ? const Icon(Icons.star, color: Colors.amber)
                      : const Icon(Icons.inventory_2_outlined),
                  title: Text(item.name),
                  subtitle: Text(
                    [
                      item.tagName,
                      if (sizeLabel.isNotEmpty) sizeLabel,
                      if (item.isLatest)
                        host.localize(context, 'dynamicLatestBadge'),
                    ].join(' · '),
                  ),
                  onTap: () => Navigator.of(context).pop(item),
                );
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(host.localize(context, 'cancel', 'Cancel')),
        ),
      ],
    );
  }
}
