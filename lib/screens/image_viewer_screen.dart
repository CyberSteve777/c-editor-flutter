import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:c_editor/data/repository/level_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';

/// Fullscreen zoomable viewer for library image files (PNG/JPEG/WebP/GIF/BMP).
class ImageViewerScreen extends StatefulWidget {
  const ImageViewerScreen({
    super.key,
    required this.fileName,
    required this.filePath,
  });

  final String fileName;
  final String filePath;

  @override
  State<ImageViewerScreen> createState() => _ImageViewerScreenState();
}

class _ImageViewerScreenState extends State<ImageViewerScreen> {
  Uint8List? _bytes;
  Object? _error;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bytes = await LevelRepository.readLibraryFileBytes(widget.filePath);
      if (!mounted) return;
      if (bytes == null || bytes.isEmpty) {
        setState(() {
          _loading = false;
          _error = 'Could not read image';
        });
        return;
      }
      setState(() {
        _bytes = bytes;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black87,
        foregroundColor: Colors.white,
        title: Text(widget.fileName),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null || _bytes == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  '${l10n?.error ?? 'Error'}: ${_error ?? 'missing'}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : InteractiveViewer(
              minScale: 0.25,
              maxScale: 8,
              child: Center(
                child: Image.memory(
                  _bytes!,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, error, _) => Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      '${l10n?.error ?? 'Error'}: $error',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ),
    );
  }
}
