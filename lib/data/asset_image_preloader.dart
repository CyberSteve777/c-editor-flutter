import 'package:flutter/services.dart';
import 'package:c_editor/widgets/asset_image.dart';

typedef AssetPreloadProgressCallback = void Function(
  double progress,
  String? label,
);

/// Preloads image assets listed in the Flutter asset manifest.
abstract final class AssetImagePreloader {
  static bool _complete = false;

  static bool get isComplete => _complete;

  static Future<void> preloadAll({
    AssetPreloadProgressCallback? onProgress,
  }) async {
    if (_complete) return;

    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest
        .listAssets()
        .where(_isImageAsset)
        .toList(growable: false)
      ..sort();

    if (assets.isEmpty) {
      _complete = true;
      AssetImageWidget.markPreloadComplete();
      onProgress?.call(1, null);
      return;
    }

    for (var i = 0; i < assets.length; i++) {
      final path = assets[i];
      await rootBundle.load(path);
      AssetImageWidget.registerManifestPath(path);
      onProgress?.call((i + 1) / assets.length, path);
    }

    _complete = true;
    AssetImageWidget.markPreloadComplete();
    onProgress?.call(1, null);
  }

  static bool _isImageAsset(String path) {
    if (!path.startsWith('assets/')) return false;
    final lower = path.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif');
  }
}
