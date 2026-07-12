import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:c_editor/data/bootstrap_loading_category.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/theme/app_theme.dart';

class StartupLoadingScreen extends StatelessWidget {
  const StartupLoadingScreen({
    super.key,
    required this.progress,
    required this.locale,
    this.loadingCategory,
  });

  final double progress;
  final Locale locale;
  final BootstrapLoadingCategory? loadingCategory;

  static const _barHeight = 6.0;
  static const _labelGap = 8.0;
  static const _labelReserve = 40.0;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: ThemeMode.system,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Builder(
        builder: (context) {
          final theme = Theme.of(context);
          final l10n = AppLocalizations.of(context)!;
          final isDark = theme.brightness == Brightness.dark;
          final accent = isDark ? pvzGreenDark : pvzGreenLight;
          final clamped = progress.clamp(0.0, 1.0);
          final percentLabel = '${(clamped * 100).round()}%';
          final labelStyle = TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: accent,
          );
          final rowHeight = math.max(20.0, labelStyle.fontSize! + 8);
          final barTop = (rowHeight - _barHeight) / 2;
          final categoryLabel = loadingCategory?.loadingLabel(l10n);

          return Scaffold(
            body: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 320),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    24,
                    24,
                    24 + _labelReserve,
                    24,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/meta/icon.png',
                          width: 96,
                          height: 96,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'C-Editor',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: accent,
                        ),
                      ),
                      const SizedBox(height: 24),
                      LayoutBuilder(
                        builder: (context, constraints) {
                          final barWidth = constraints.maxWidth;

                          return SizedBox(
                            width: barWidth,
                            height: rowHeight,
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                Positioned(
                                  left: 0,
                                  width: barWidth,
                                  top: barTop,
                                  height: _barHeight,
                                  child: LinearProgressIndicator(
                                    value: progress > 0 ? clamped : null,
                                    minHeight: _barHeight,
                                    borderRadius: BorderRadius.circular(999),
                                    color: accent,
                                    backgroundColor:
                                        accent.withValues(alpha: 0.18),
                                  ),
                                ),
                                Positioned(
                                  left: barWidth + _labelGap,
                                  top: 0,
                                  height: rowHeight,
                                  child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      percentLabel,
                                      style: labelStyle,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      if (categoryLabel != null) ...[
                        const SizedBox(height: 12),
                        Text(
                          categoryLabel,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
