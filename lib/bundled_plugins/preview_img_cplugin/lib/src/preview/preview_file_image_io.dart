import 'dart:io';

import 'package:flutter/widgets.dart';

Widget? fileBannerImage(
  String path, {
  required BoxFit fit,
  double? width,
  double? height,
}) {
  return Image.file(
    File(path),
    fit: fit,
    width: width,
    height: height,
    errorBuilder: (_, _, _) => const SizedBox.shrink(),
  );
}
