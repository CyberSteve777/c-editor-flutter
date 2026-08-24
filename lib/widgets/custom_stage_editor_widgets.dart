import 'package:flutter/material.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/editor_components.dart';

Color customStageAccent(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? pvzGreenDark
    : pvzGreenLight;

InputDecoration customStageInputDecoration(
  BuildContext context, {
  String? labelText,
}) {
  final accent = customStageAccent(context);
  return editorInputDecoration(
    context,
    labelText: labelText,
    focusColor: accent,
  ).copyWith(
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: accent, width: 2),
    ),
  );
}

ThemeData customStageInputTheme(BuildContext context) {
  final theme = Theme.of(context);
  final accent = customStageAccent(context);
  return theme.copyWith(
    colorScheme: theme.colorScheme.copyWith(primary: accent),
    inputDecorationTheme: theme.inputDecorationTheme.copyWith(
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: accent, width: 2),
      ),
    ),
  );
}

Color customStageBadgeColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF1976D2)
    : const Color(0xFF42A5F5);

Color userCustomResourceBadgeColor(BuildContext context) =>
    const Color(0xFFFFC107);

Color presetCustomResourceBadgeColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF1B5E20)
    : const Color(0xFF2E7D32);

Color presetDerivedCustomResourceBadgeColor(BuildContext context) =>
    Theme.of(context).brightness == Brightness.dark
    ? const Color(0xFF8E24AA)
    : const Color(0xFF6A1B9A);

double customStageBadgeFontSize(BuildContext context) {
  final platform = Theme.of(context).platform;
  final isDesktop =
      platform == TargetPlatform.windows ||
      platform == TargetPlatform.macOS ||
      platform == TargetPlatform.linux;
  return isDesktop ? 11 : 9;
}

EdgeInsets customStageBadgePadding(BuildContext context) {
  final isDesktop = customStageBadgeFontSize(context) > 10;
  return EdgeInsets.symmetric(
    horizontal: isDesktop ? 5 : 4,
    vertical: isDesktop ? 2 : 1,
  );
}

/// Blue "C" badge for custom lawns (selection, basic info, etc.).
class CustomStageBadge extends StatelessWidget {
  const CustomStageBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomResourceBadge(color: customStageBadgeColor(context));
  }
}

/// Shared "C" badge shape used by custom resources.
class CustomResourceBadge extends StatelessWidget {
  const CustomResourceBadge({super.key, required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: customStageBadgePadding(context),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        'C',
        style: TextStyle(
          fontSize: customStageBadgeFontSize(context),
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );
  }
}
