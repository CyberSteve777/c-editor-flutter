import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Supported image extensions: png, jpg, gif (gif files play animation).
const List<String> kImageExtensions = ['.gif', '.png', '.jpg', '.webp'];

/// Returns alternate asset paths for fallback when primary path fails.
/// Prefers .gif first so animated icons display correctly.
List<String> imageAltCandidates(String assetPath) {
  final idx = assetPath.lastIndexOf('.');
  final base = idx == -1 ? assetPath : assetPath.substring(0, idx);
  final currentExt = idx == -1 ? '' : assetPath.substring(idx).toLowerCase();
  return kImageExtensions
      .where((e) => e != currentExt)
      .map((e) => '$base$e')
      .toList();
}

/// Loads and displays images from assets. Ported from Z-Editor-master AssetImage.kt
/// GIF files play animation automatically via Flutter's Image.asset.
class AssetImageWidget extends StatefulWidget {
  const AssetImageWidget({
    super.key,
    required this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.errorWidget,
    this.altCandidates,
    this.cacheWidth,
    this.cacheHeight,
  });

  /// Path relative to assets folder, e.g. 'images/round_icons/Stage_Modern.png'
  final String assetPath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? errorWidget;
  /// Alternative asset paths to try if [assetPath] is not found.
  /// Useful for multi-extension fallback (e.g., .gif, .png, .jpg).
  final List<String>? altCandidates;

  final int? cacheWidth;
  final int? cacheHeight;

  @override
  State<AssetImageWidget> createState() => _AssetImageWidgetState();
}

class _AssetImageWidgetState extends State<AssetImageWidget> {
  String? _resolvedPath;
  bool _resolving = false;
  int _requestId = 0;

  // Cache resolved paths to avoid repeated file system checks
  static final Map<String, String?> _pathCache = {};

  @override
  void initState() {
    super.initState();
    _resolveAsset();
  }

  @override
  void didUpdateWidget(covariant AssetImageWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.assetPath != widget.assetPath ||
        oldWidget.altCandidates != widget.altCandidates) {
      _resolveAsset();
    }
  }

  Future<void> _resolveAsset() async {
    final cacheKey = '${widget.assetPath}|${widget.altCandidates?.join(",")}';
    if (_pathCache.containsKey(cacheKey)) {
      if (mounted) {
        setState(() {
          _resolvedPath = _pathCache[cacheKey];
          _resolving = false;
        });
      }
      return;
    }

    final currentId = ++_requestId;
    if (mounted) {
      setState(() {
        _resolving = true;
        _resolvedPath = null;
      });
    }
    final candidates = <String>[widget.assetPath, ...?widget.altCandidates];
    for (final path in candidates) {
      try {
        await rootBundle.load(path);
        if (!mounted || currentId != _requestId) return;
        
        _pathCache[cacheKey] = path;
        setState(() {
          _resolvedPath = path;
          _resolving = false;
        });
        return;
      } catch (_) {
        // try next
      }
    }
    
    if (!mounted || currentId != _requestId) return;
    
    _pathCache[cacheKey] = null;
    setState(() {
      _resolving = false;
      _resolvedPath = null;
    });
  }

  static const String _unknownIconPath = 'assets/images/others/unknown.webp';

  @override
  Widget build(BuildContext context) {
    final placeholder = widget.errorWidget ??
        Image.asset(
          _unknownIconPath,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
          errorBuilder: (_, _, _) => Icon(
            Icons.image_not_supported,
            size: widget.width ?? widget.height ?? 48,
            color: Theme.of(context).colorScheme.outline,
          ),
        );
    if (_resolving) {
      return SizedBox(
        width: widget.width,
        height: widget.height,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    if (_resolvedPath == null) {
      return placeholder;
    }
    return Image.asset(
      _resolvedPath!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      cacheWidth: widget.cacheWidth,
      cacheHeight: widget.cacheHeight,
    );
  }
}
