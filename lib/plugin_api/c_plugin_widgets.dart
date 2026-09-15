import 'package:flutter/material.dart';
import 'package:c_editor/widgets/asset_image.dart';
import 'package:c_editor/widgets/editor_components.dart';

/// Curated host widgets exposed to plugins via dart_eval bridges.
///
/// Plugin authors import `package:c_editor/plugin_api.dart` and call these
/// top-level factories so they can reuse editor chrome without depending on
/// the full editor source tree.

Widget editorWarningBanner({
  String? title,
  required String message,
}) {
  return EditorWarningBanner(title: title, message: message);
}

Widget pvzAddButton({
  required VoidCallback onPressed,
  double size = 48,
  String? label,
  bool useSecondaryColor = false,
}) {
  return PvzAddButton(
    onPressed: onPressed,
    size: size,
    label: label,
    useSecondaryColor: useSecondaryColor,
  );
}

Widget addItemCard({
  required VoidCallback onPressed,
  double width = 100,
  double? minHeight,
}) {
  return AddItemCard(
    onPressed: onPressed,
    width: width,
    minHeight: minHeight,
  );
}

Widget appBarSearchField({
  required String hintText,
  required ValueChanged<String> onChanged,
  String query = '',
  VoidCallback? onClear,
}) {
  return AppBarSearchField(
    hintText: hintText,
    onChanged: onChanged,
    query: query,
    onClear: onClear,
  );
}

/// Displays an image from the **host app** asset bundle (plants, zombies, …).
Widget hostAssetImage({
  required String assetPath,
  double? width,
  double? height,
  BoxFit fit = BoxFit.cover,
}) {
  return AssetImageWidget(
    assetPath: assetPath,
    width: width,
    height: height,
    fit: fit,
  );
}
