import 'package:flutter/material.dart';

double responsiveSelectionGridTileExtent(
  BuildContext context, {
  required double baseExtent,
  double scaledTextAllowance = 56,
}) {
  final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 3.0);
  return baseExtent + (textScale - 1) * scaledTextAllowance;
}

double responsiveSelectionToolbarHeight(BuildContext context) {
  final textScale = MediaQuery.textScalerOf(context).scale(1).clamp(1.0, 2.5);
  return 56 + (textScale - 1) * 20;
}
