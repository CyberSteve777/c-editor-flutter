import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:c_editor/data/registry/event_registry.dart';
import 'package:c_editor/data/level_parser.dart';
import 'package:c_editor/data/pvz_models.dart';
import 'package:c_editor/data/repository/grid_item_repository.dart';
import 'package:c_editor/data/repository/plant_repository.dart';
import 'package:c_editor/l10n/app_localizations.dart';
import 'package:c_editor/l10n/resource_names.dart';
import 'package:c_editor/theme/app_theme.dart';
import 'package:c_editor/widgets/asset_image.dart'
    show AssetImageWidget, imageAltCandidates;

export 'package:c_editor/theme/app_theme.dart'
    show
        editorWarningIcon,
        editorErrorIcon,
        warningBarDark,
        warningBarLight,
        editorWarningBannerBackground,
        editorWarningBannerForeground;

/// Yellow warning card used across editor screens (Settings, modules, events).
class EditorWarningBanner extends StatelessWidget {
  const EditorWarningBanner({
    super.key,
    this.title,
    required this.message,
    this.children = const [],
    this.margin,
  });

  final String? title;
  final String message;
  final List<Widget> children;
  final EdgeInsetsGeometry? margin;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final fg = editorWarningBannerForeground(brightness);
    final bodyStyle = TextStyle(color: fg);
    final titleStyle = TextStyle(fontWeight: FontWeight.bold, color: fg);

    return Card(
      margin: margin,
      color: editorWarningBannerBackground(brightness),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(editorWarningIcon, color: fg),
                const SizedBox(width: 8),
                Expanded(
                  child: title != null
                      ? Text(title!, style: titleStyle)
                      : Text(message, style: bodyStyle),
                ),
              ],
            ),
            if (title != null) ...[
              const SizedBox(height: 8),
              Text(message, style: bodyStyle),
            ],
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Shared hint for event editors that expose ColumnStart / ColumnEnd.
class EventColumnRangeHint extends StatelessWidget {
  const EventColumnRangeHint({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final style = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      height: 1.55,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.eventColumnRangeBoundaryHint ??
              'The lawn’s left edge is column 0 and the right edge is column 9. The start column must be less than the end column.',
          style: style,
          softWrap: true,
        ),
        const SizedBox(height: 8),
        Text(
          l10n?.eventColumnRangeExampleHint ??
              'To spawn from columns n through m, enter n - 1 for the start column and m for the end column.',
          style: style,
          softWrap: true,
        ),
      ],
    );
  }
}

String localizedPropertyLabel(
  BuildContext context,
  String localizedName,
  String codeName,
) {
  final languageCode = Localizations.localeOf(context).languageCode;
  return languageCode == 'zh'
      ? '$localizedName（$codeName）'
      : '$localizedName ($codeName)';
}

/// Shared editor UI components. Ported from Z-Editor-master EditorComponents.kt

/// Square add button with rounded corners and + symbol.
/// Used in jittered, groundspawn and similar row-based editors.
/// Green for numbered rows, gray for random row.
class PvzAddButton extends StatelessWidget {
  const PvzAddButton({
    super.key,
    required this.onPressed,
    this.size = 48,
    this.label,
    this.useSecondaryColor = false,
  });

  final VoidCallback onPressed;
  final double size;
  final String? label;

  /// When true, uses gray (surface variant) instead of green (e.g. for random row).
  final bool useSecondaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final Color bgColor;
    final Color iconColor;
    if (useSecondaryColor) {
      bgColor = theme.colorScheme.surfaceContainerHighest;
      iconColor = theme.colorScheme.onSurfaceVariant;
    } else {
      bgColor = isDark
          ? pvzGreenDark.withValues(alpha: 0.35)
          : const Color(0xFFC8E6C9);
      iconColor = pvzGreenDark;
    }
    final btn = Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(Icons.add, color: iconColor, size: size * 0.55),
        ),
      ),
    );
    if (label != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          btn,
          if (label!.isNotEmpty) ...[
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 160),
              child: Text(
                label!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ),
          ],
        ],
      );
    }
    return btn;
  }
}

/// Layout metrics for editor item cards and placement grids on narrow screens.
abstract final class EditorItemCardLayout {
  static bool compact(BuildContext context) =>
      MediaQuery.sizeOf(context).width < 400;

  static double cardWidth(BuildContext context, {double base = 100}) =>
      compact(context) ? base * 0.92 : base;

  static double iconSlotSize(BuildContext context, {double base = 64}) =>
      compact(context) ? base * 0.875 : base;

  static double gridPreviewMaxWidth(BuildContext context) =>
      compact(context) ? 360 : 480;

  /// Scales +N count badges from rendered lawn cell width (cells are square).
  static double gridCellBadgeScaleForCell(double cellWidth) {
    if (cellWidth <= 0 || !cellWidth.isFinite) return 1.0;
    const referenceCell = 52.0;
    return (cellWidth / referenceCell).clamp(0.4, 1.0);
  }
}

/// Keeps related form controls side by side when there is enough room and
/// stacks them when UI scaling leaves the editor with a narrow layout.
class EditorResponsiveFieldRow extends StatelessWidget {
  const EditorResponsiveFieldRow({
    super.key,
    required this.children,
    this.breakpoint = 600,
    this.spacing = 12,
  });

  final List<Widget> children;
  final double breakpoint;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final fields = children
            .where(
              (child) =>
                  child is! SizedBox ||
                  child.child != null ||
                  child.width == null ||
                  child.height != null,
            )
            .map((child) => child is Flexible ? child.child : child)
            .toList(growable: false);
        final stack = constraints.maxWidth < breakpoint;
        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var i = 0; i < fields.length; i++) ...[
                if (i > 0) SizedBox(height: spacing),
                fields[i],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < fields.length; i++) ...[
              if (i > 0) SizedBox(width: spacing),
              Expanded(child: fields[i]),
            ],
          ],
        );
      },
    );
  }
}

/// A label and its field use separate lines in compact editor layouts.
class EditorResponsiveLabelField extends StatelessWidget {
  const EditorResponsiveLabelField({
    super.key,
    required this.label,
    required this.field,
    this.labelWidth = 120,
    this.breakpoint = 520,
    this.spacing = 12,
  });

  final Widget label;
  final Widget field;
  final double labelWidth;
  final double breakpoint;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              label,
              SizedBox(height: spacing / 2),
              field,
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(width: labelWidth, child: label),
            SizedBox(width: spacing),
            Expanded(child: field),
          ],
        );
      },
    );
  }
}

/// Keeps a heading or status label clear of its trailing action. The action
/// moves below the text when a scaled editor no longer has enough width.
class EditorResponsiveActionRow extends StatelessWidget {
  const EditorResponsiveActionRow({
    super.key,
    required this.content,
    required this.action,
    this.breakpoint = 520,
    this.spacing = 12,
  });

  final Widget content;
  final Widget action;
  final double breakpoint;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < breakpoint) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              content,
              SizedBox(height: spacing / 2),
              Align(alignment: Alignment.centerRight, child: action),
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(child: content),
            SizedBox(width: spacing),
            action,
          ],
        );
      },
    );
  }
}

/// +N overlay badge for interactive lawn grid cells.
/// Tight "borderless" pill: background hugs the label with minimal padding.
class GridCellCountBadge extends StatelessWidget {
  const GridCellCountBadge({
    super.key,
    required this.label,
    required this.cellWidth,
  });

  final String label;
  final double cellWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scale = EditorItemCardLayout.gridCellBadgeScaleForCell(cellWidth);
    final inset = 1.0 * scale;
    return Positioned(
      top: inset,
      right: inset,
      child: Transform.scale(
        scale: scale,
        alignment: Alignment.topRight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(3),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 1),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                height: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Responsive grid metrics for asset picker screens (tools, grid items, statues).
abstract final class SelectionGridLayout {
  static const double spacing = 12;
  static const double padding = 16;

  static int crossAxisCount(double maxWidth) {
    if (maxWidth >= 1100) return 5;
    if (maxWidth >= 720) return 4;
    if (maxWidth >= 480) return 3;
    return 2;
  }

  static double childAspectRatio(double maxWidth) {
    if (maxWidth >= 720) return 0.72;
    if (maxWidth >= 480) return 0.68;
    return 0.62;
  }

  static double cellWidth(double maxWidth, int crossAxisCount) {
    return (maxWidth - padding * 2 - spacing * (crossAxisCount - 1)) /
        crossAxisCount;
  }

  static double iconSize(double cellWidth) {
    return (cellWidth * 0.82).clamp(80.0, 120.0);
  }

  static int toolCrossAxisCount(double maxWidth) => maxWidth >= 600 ? 4 : 2;

  static double toolChildAspectRatio(double maxWidth) =>
      maxWidth >= 600 ? 0.88 : 0.72;

  static ({double width, double height}) toolIconBox(double maxWidth) {
    if (maxWidth >= 600) {
      return (width: 112, height: 96);
    }
    return (width: 96, height: 80);
  }
}

/// Layout metrics for Renai statue cards and the statue picker grid.
abstract final class RenaiStatueCardLayout {
  static double tileCardWidth(BuildContext context) =>
      EditorItemCardLayout.cardWidth(
        context,
        base: compact(context) ? 156 : 180,
      );

  static double tileIconSize(BuildContext context) =>
      EditorItemCardLayout.iconSlotSize(
        context,
        base: compact(context) ? 84 : 100,
      );

  static int selectionCrossAxisCount(double maxWidth) =>
      SelectionGridLayout.crossAxisCount(maxWidth);

  static double selectionChildAspectRatio(double maxWidth) =>
      SelectionGridLayout.childAspectRatio(maxWidth);

  static double selectionIconSize(double cellWidth) =>
      SelectionGridLayout.iconSize(cellWidth);

  static bool compact(BuildContext context) =>
      EditorItemCardLayout.compact(context);
}

/// Icon header for editor item cards: artwork in a fixed slot, delete control
/// in its own top-right column so it never overlaps scaled icons or badges.
class EditorDeletableIconHeader extends StatelessWidget {
  const EditorDeletableIconHeader({
    super.key,
    required this.icon,
    required this.onDelete,
    required this.deleteTooltip,
    this.iconSize = 64,
    this.height,
  });

  final Widget icon;
  final VoidCallback onDelete;
  final String deleteTooltip;
  final double iconSize;
  final double? height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final compact = EditorItemCardLayout.compact(context);
    final slotSize = EditorItemCardLayout.iconSlotSize(context, base: iconSize);
    final headerHeight = height ?? (slotSize + (compact ? 14 : 16));
    final deleteSize = compact ? 24.0 : 28.0;

    return SizedBox(
      height: headerHeight,
      child: Padding(
        padding: EdgeInsets.fromLTRB(8, 8, compact ? 2 : 4, 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: SizedBox(width: slotSize, height: slotSize, child: icon),
              ),
            ),
            SizedBox(
              width: deleteSize,
              height: deleteSize,
              child: IconButton(
                onPressed: onDelete,
                icon: Icon(Icons.delete_outline, size: compact ? 16 : 18),
                tooltip: deleteTooltip,
                color: theme.colorScheme.onSurfaceVariant,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
                constraints: BoxConstraints(
                  minWidth: deleteSize,
                  minHeight: deleteSize,
                  maxWidth: deleteSize,
                  maxHeight: deleteSize,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  padding: const EdgeInsets.all(2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Card-sized add button that matches item card dimensions.
/// Used in initial plant/zombie/grid entry screens.
class AddItemCard extends StatelessWidget {
  const AddItemCard({
    super.key,
    required this.onPressed,
    this.width = 100,
    this.minHeight,
  });

  final VoidCallback onPressed;

  /// Card width. Use 140 to match [RenaiModuleScreen] statue cards.
  final double width;

  /// When set, card uses this height and centers the plus button vertically.
  /// Use to align with taller item cards (e.g. Renai statue cards).
  final double? minHeight;

  @override
  Widget build(BuildContext context) {
    final cardWidth = EditorItemCardLayout.cardWidth(context, base: width);
    final button = PvzAddButton(onPressed: onPressed, size: 56);
    final content = minHeight != null
        ? Center(
            child: SizedBox(
              width: 64,
              height: 64,
              child: Center(child: button),
            ),
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 8, right: 8),
                child: Center(
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: Center(child: button),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(8, 4, 8, 12),
                child: SizedBox.shrink(),
              ),
            ],
          );
    return Card(
      clipBehavior: Clip.antiAlias,
      child: SizedBox(width: cardWidth, height: minHeight, child: content),
    );
  }
}

/// Tab label colors for category rows on saturated accent headers.
abstract class AccentBarTabBarStyle {
  AccentBarTabBarStyle._();

  static ({Color label, Color unselectedLabel, Color indicator}) colors(
    BuildContext context,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final indicator = isDark ? const Color(0xFFEEEEEE) : Colors.white;
    return (
      label: Colors.white,
      unselectedLabel: Colors.white.withValues(alpha: isDark ? 0.72 : 0.88),
      indicator: indicator,
    );
  }
}

/// Scrollable filter tab row for saturated accent headers.
/// Matches accent [TabBar] underline selection. On desktop, shows a horizontal
/// scrollbar below. Vertical wheel / trackpad scroll moves the row horizontally.
class AccentBarFilterTabRow extends StatefulWidget {
  const AccentBarFilterTabRow({
    super.key,
    required this.tabs,
    required this.selectedIndex,
    required this.onSelected,
    this.height = 46,
    this.scrollbarSlotHeight = 16,
  });

  final List<Widget> tabs;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final double height;
  final double scrollbarSlotHeight;

  @override
  State<AccentBarFilterTabRow> createState() => _AccentBarFilterTabRowState();
}

class _AccentBarFilterTabRowState extends State<AccentBarFilterTabRow> {
  static const double _scrollbarUnderlineGap = 6;

  late final ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onPointerScroll(PointerScrollEvent event) {
    if (!_scrollController.hasClients) return;
    final position = _scrollController.position;
    final target = (_scrollController.offset + event.scrollDelta.dy).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );
    if (target != _scrollController.offset) {
      _scrollController.jumpTo(target);
    }
  }

  Widget _buildTab(
    int index,
    ({Color label, Color unselectedLabel, Color indicator}) tabColors,
  ) {
    final selected = index == widget.selectedIndex;
    final baseLabelStyle =
        Theme.of(context).textTheme.titleSmall ?? const TextStyle(fontSize: 14);
    final labelStyle = baseLabelStyle.copyWith(
      color: selected ? tabColors.label : tabColors.unselectedLabel,
      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
    );
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => widget.onSelected(index),
        mouseCursor: SystemMouseCursors.click,
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) {
            return Colors.white.withValues(alpha: 0.12);
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return Colors.white.withValues(alpha: 0.08);
          }
          return null;
        }),
        child: IntrinsicWidth(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SizedBox(
              height: widget.height,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Expanded(
                    child: Center(
                      child: DefaultTextStyle(
                        style: labelStyle,
                        child: widget.tabs[index],
                      ),
                    ),
                  ),
                  Container(
                    height: 3,
                    color: selected ? tabColors.indicator : Colors.transparent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabRow(
    ({Color label, Color unselectedLabel, Color indicator}) tabColors,
  ) {
    return Row(
      children: [
        for (var i = 0; i < widget.tabs.length; i++) _buildTab(i, tabColors),
      ],
    );
  }

  ScrollbarThemeData _desktopScrollbarTheme() {
    return ScrollbarThemeData(
      thumbColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.75)),
      trackColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.18)),
      trackBorderColor: WidgetStateProperty.all(Colors.transparent),
      thickness: WidgetStateProperty.all(6),
      radius: const Radius.circular(4),
      crossAxisMargin: 0,
      mainAxisMargin: 0,
    );
  }

  Widget _buildScrollableRow(
    ({Color label, Color unselectedLabel, Color indicator}) tabColors, {
    bool alignTabsToBottom = false,
  }) {
    Widget row = _buildTabRow(tabColors);
    if (alignTabsToBottom) {
      row = Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(bottom: _scrollbarUnderlineGap),
          child: SizedBox(height: widget.height, child: row),
        ),
      );
    }

    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent) {
          _onPointerScroll(event);
        }
      },
      child: ScrollableWithMouseDrag(
        child: SingleChildScrollView(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          child: row,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tabColors = AccentBarTabBarStyle.colors(context);
    final showDesktopScrollbar = isDesktopPlatform(context);

    if (!showDesktopScrollbar) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: widget.height,
            child: _buildScrollableRow(tabColors),
          ),
          SizedBox(height: widget.scrollbarSlotHeight),
        ],
      );
    }

    return SizedBox(
      height: widget.height + widget.scrollbarSlotHeight,
      child: ScrollbarTheme(
        data: _desktopScrollbarTheme(),
        child: Scrollbar(
          controller: _scrollController,
          thumbVisibility: true,
          interactive: true,
          child: _buildScrollableRow(tabColors, alignTabsToBottom: true),
        ),
      ),
    );
  }
}

/// Choice chip with explicit selected/unselected colors for accent header bars.
class AccentBarChoiceChip extends StatelessWidget {
  const AccentBarChoiceChip({
    super.key,
    required this.label,
    required this.selected,
    required this.onSelected,
    this.padding = const EdgeInsets.only(right: 8),
  });

  final String label;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedBg = isDark ? const Color(0xFFEEEEEE) : Colors.white;
    final selectedFg = isDark
        ? const Color(0xFF1B1B1B)
        : const Color(0xFF212121);
    final unselectedBg = Colors.black.withValues(alpha: isDark ? 0.32 : 0.24);
    const unselectedFg = Colors.white;
    final borderColor = selected
        ? (isDark ? const Color(0xFFBDBDBD) : const Color(0xFF9E9E9E))
        : Colors.white.withValues(alpha: isDark ? 0.45 : 0.55);
    final borderWidth = selected ? 1.5 : 1.0;

    return Padding(
      padding: padding,
      child: Material(
        color: selected ? selectedBg : unselectedBg,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: borderColor, width: borderWidth),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onSelected(true),
          mouseCursor: SystemMouseCursors.click,
          splashFactory: NoSplash.splashFactory,
          highlightColor: Colors.transparent,
          overlayColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.pressed)) {
              return (selected ? selectedFg : unselectedFg).withValues(
                alpha: 0.12,
              );
            }
            if (states.contains(WidgetState.hovered) ||
                states.contains(WidgetState.focused)) {
              return (selected ? selectedFg : unselectedFg).withValues(
                alpha: 0.08,
              );
            }
            return null;
          }),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? selectedFg : unselectedFg,
                fontWeight: selected ? FontWeight.bold : FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Event chip for wave timeline. Ported from EventChip in EditorComponents.kt
class EventChipWidget extends StatelessWidget {
  const EventChipWidget({
    super.key,
    required this.rtid,
    required this.objectMap,
    required this.onTap,
  });

  final String rtid;
  final Map<String, PvzObject> objectMap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final alias = LevelParser.extractAlias(rtid);
    final obj = objectMap[alias];
    final isInvalid = obj == null;
    final meta = EventRegistry.getByObjClass(obj?.objClass);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isInvalid
        ? theme.colorScheme.error
        : (isDark
              ? (meta?.darkColor ?? theme.colorScheme.primary)
              : (meta?.color ?? theme.colorScheme.primary));

    String? summaryText;
    if (!isInvalid) {
      try {
        summaryText = meta?.summaryProvider?.call(obj);
      } catch (_) {}
    }

    final displayLabel = alias;

    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isInvalid)
                Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: Icon(
                    Icons.error_outline,
                    size: 14,
                    color: theme.colorScheme.onError,
                  ),
                )
              else if (meta != null)
                Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: Icon(
                    meta.icon,
                    size: 14,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              Flexible(
                child: Text(
                  displayLabel,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (summaryText != null && summaryText.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    summaryText,
                    style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 10,
                    ),
                    maxLines: 1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Help dialog for editor screens.
void showEditorHelpDialog(
  BuildContext context, {
  required String title,
  required List<HelpSectionData> sections,
  Color? themeColor,
}) {
  showDialog<void>(
    context: context,
    builder: (ctx) {
      final l10n = AppLocalizations.of(ctx);
      final confirmLabel =
          l10n?.helpDialogGotIt ?? MaterialLocalizations.of(ctx).okButtonLabel;
      return AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: themeColor ?? Theme.of(ctx).colorScheme.primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: sections
                .map(
                  (s) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '• ${s.title}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color:
                                themeColor ?? Theme.of(ctx).colorScheme.primary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Padding(
                          padding: const EdgeInsets.only(left: 12),
                          child: Text(
                            s.body,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(ctx).colorScheme.onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: themeColor ?? Theme.of(ctx).colorScheme.primary,
              ),
            ),
          ),
        ],
      );
    },
  );
}

class HelpSectionData {
  const HelpSectionData({required this.title, required this.body});
  final String title;
  final String body;
}

const _kWaveDropConfigTitleIconSize = 32.0;
const _kPlantDropIconCardSize = 56.0;
const _kPlantFoodIconPath = 'assets/images/others/plantfood.png';
const _kPlantDropTagIconPath =
    'assets/images/tags/plants/rarity/Plant_Green.webp';

/// Plant drop token: icon plus a full-height remove strip (easier to tap than a
/// corner overlay on a small square).
class PlantDropIconCard extends StatelessWidget {
  const PlantDropIconCard({
    super.key,
    required this.iconPath,
    required this.onDelete,
    this.label,
    this.size = _kPlantDropIconCardSize,
  });

  final String? iconPath;
  final String? label;
  final VoidCallback onDelete;
  final double size;

  static const _removeStripWidth = 44.0;
  static const _maxLabelWidth = 200.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    final removeHint = label != null && label!.isNotEmpty
        ? '${l10n.remove} $label'
        : l10n.remove;

    final chipRow = Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: iconPath != null && iconPath!.isNotEmpty
                  ? AssetImageWidget(
                      assetPath: iconPath!,
                      altCandidates: imageAltCandidates(iconPath!),
                      width: size - 8,
                      height: size - 8,
                      fit: BoxFit.cover,
                    )
                  : Center(
                      child: Icon(
                        Icons.local_florist,
                        size: 24,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
        ),
        if (label != null && label!.isNotEmpty)
          Tooltip(
            message: label!,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: _maxLabelWidth),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: Text(
                  label!,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ),
        Tooltip(
          message: removeHint,
          child: Semantics(
            button: true,
            label: removeHint,
            child: Material(
              color: theme.colorScheme.surfaceContainerHighest,
              child: InkWell(
                onTap: onDelete,
                child: SizedBox(
                  width: _removeStripWidth,
                  height: size,
                  child: Center(
                    child: Icon(
                      Icons.close,
                      size: 22,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: SizedBox(
        height: size,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: chipRow,
        ),
      ),
    );
  }
}

/// Plant food / carried-plant drop settings for jittered and fish wave events.
class WaveDropConfigCard extends StatelessWidget {
  const WaveDropConfigCard({
    super.key,
    required this.totalDropCount,
    required this.plants,
    required this.zombieCount,
    required this.onTotalDropCountChanged,
    required this.onRemovePlantAt,
    this.onAddPlant,
  });

  /// [AdditionalPlantfood] — total zombies carrying any drop (plant food and/or plants).
  final int totalDropCount;
  final List<String> plants;
  final int zombieCount;
  final ValueChanged<int> onTotalDropCountChanged;
  final ValueChanged<int> onRemovePlantAt;
  final VoidCallback? onAddPlant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final isDark = theme.brightness == Brightness.dark;
    final leafColor = isDark ? pvzGreenLight : pvzGreenDark;
    final plantCount = plants.length;
    final plantFoodOnlyCount = (totalDropCount - plantCount).clamp(
      0,
      totalDropCount,
    );
    final canIncreaseTotal = totalDropCount < zombieCount;
    final canAddPlant =
        onAddPlant != null &&
        zombieCount > 0 &&
        totalDropCount > 0 &&
        plantCount < totalDropCount;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.eco,
                  size: _kWaveDropConfigTitleIconSize,
                  color: leafColor,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    l10n.waveDropConfigTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            LayoutBuilder(
              builder: (context, constraints) {
                final counterRow = Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      icon: const Icon(Icons.remove),
                      onPressed: totalDropCount > 0
                          ? () => onTotalDropCountChanged(totalDropCount - 1)
                          : null,
                    ),
                    Text('$totalDropCount', style: theme.textTheme.titleMedium),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(
                        minWidth: 36,
                        minHeight: 36,
                      ),
                      icon: const Icon(Icons.add),
                      onPressed: canIncreaseTotal
                          ? () => onTotalDropCountChanged(totalDropCount + 1)
                          : null,
                    ),
                  ],
                );
                final counterControls = FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: counterRow,
                );
                final labelText = Text(
                  l10n.waveDropTotalLabel,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                );

                if (constraints.maxWidth < 280) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      labelText,
                      const SizedBox(height: 4),
                      counterControls,
                    ],
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(child: labelText),
                    counterControls,
                  ],
                );
              },
            ),
            if (zombieCount == 0) ...[
              const SizedBox(height: 8),
              Text(
                l10n.waveDropAddZombiesFirst,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ] else if (totalDropCount > 0) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 12,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  if (plantFoodOnlyCount > 0)
                    _DropCountBadge(
                      iconPath: _kPlantFoodIconPath,
                      label: l10n.waveDropPlantFoodOnlyCount(
                        plantFoodOnlyCount,
                      ),
                    ),
                  if (plantCount > 0)
                    _DropCountBadge(
                      iconPath: _kPlantDropTagIconPath,
                      label: l10n.waveDropPlantsCount(plantCount),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 28,
                  height: 28,
                  child: AssetImageWidget(
                    assetPath: _kPlantDropTagIconPath,
                    altCandidates: imageAltCandidates(_kPlantDropTagIconPath),
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.dropConfigPlants,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ...plants.asMap().entries.map((entry) {
                  final idx = entry.key;
                  final id = entry.value;
                  final info = PlantRepository().getPlantInfoById(id);
                  final iconPath = info?.iconAssetPath;
                  final localizedName = ResourceNames.lookup(
                    context,
                    PlantRepository().getName(id),
                  );
                  return PlantDropIconCard(
                    iconPath: iconPath,
                    label: localizedName,
                    onDelete: () => onRemovePlantAt(idx),
                  );
                }),
                if (onAddPlant != null)
                  Opacity(
                    opacity: canAddPlant ? 1 : 0.38,
                    child: IgnorePointer(
                      ignoring: !canAddPlant,
                      child: PvzAddButton(
                        onPressed: onAddPlant!,
                        size: _kPlantDropIconCardSize,
                      ),
                    ),
                  ),
              ],
            ),
            if (onAddPlant != null &&
                totalDropCount == 0 &&
                zombieCount > 0) ...[
              const SizedBox(height: 8),
              Text(
                l10n.waveDropIncreaseTotalBeforePlants,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _DropCountBadge extends StatelessWidget {
  const _DropCountBadge({required this.iconPath, required this.label});

  final String iconPath;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        const iconSize = 20.0;
        const gap = 6.0;
        const horizontalPadding = 20.0;
        final maxWidth =
            constraints.hasBoundedWidth && constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : double.infinity;
        final maxLabelWidth = math.max(
          0.0,
          maxWidth - iconSize - gap - horizontalPadding,
        );

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: theme.colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: iconSize,
                height: iconSize,
                child: AssetImageWidget(
                  assetPath: iconPath,
                  altCandidates: imageAltCandidates(iconPath),
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(width: gap),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxLabelWidth),
                child: Text(
                  label,
                  style: theme.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Fish icon card with blue C (custom) badge. Similar to ZombieIconCard.
class FishIconCard extends StatelessWidget {
  const FishIconCard({
    super.key,
    required this.iconPath,
    required this.isCustom,
    required this.onTap,
    this.size = 56,
  });

  final String? iconPath;
  final bool isCustom;
  final VoidCallback onTap;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (iconPath != null && iconPath!.isNotEmpty)
                  AssetImageWidget(
                    assetPath: iconPath!,
                    altCandidates: imageAltCandidates(iconPath!),
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  )
                else
                  Center(
                    child: Icon(
                      Icons.water,
                      size: 24,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                if (isCustom)
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1976D2)
                            : const Color(0xFF42A5F5),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'C',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Zombie icon card with custom badge top-left and level badge top-right.
/// Reused by jittered, storm, grid item spawn and similar zombie editors.
class ZombieIconCard extends StatelessWidget {
  const ZombieIconCard({
    super.key,
    required this.iconPath,
    required this.levelDisplay,
    required this.isElite,
    required this.isCustom,
    required this.onTap,
    this.size = 56,
    this.showLevelBadge = true,
  });

  final String? iconPath;
  final String levelDisplay;
  final bool isElite;
  final bool isCustom;
  final VoidCallback onTap;
  final double size;
  final bool showLevelBadge;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.5),
              width: 0.5,
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (iconPath != null && iconPath!.isNotEmpty)
                  AssetImageWidget(
                    assetPath: iconPath!,
                    altCandidates: imageAltCandidates(iconPath!),
                    width: size,
                    height: size,
                    fit: BoxFit.cover,
                  )
                else
                  Center(
                    child: Icon(
                      Icons.warning,
                      size: 24,
                      color: theme.colorScheme.error,
                    ),
                  ),
                if (isCustom)
                  Positioned(
                    top: 2,
                    left: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: pvzOrangeLight,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'C',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                if (showLevelBadge)
                  Positioned(
                    top: 2,
                    right: 2,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.9,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        levelDisplay,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.surface,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Clickable zombie identity row for spawn edit bottom sheets (icon, name, custom tag, change).
class ZombieEditSheetIdentityTile extends StatelessWidget {
  const ZombieEditSheetIdentityTile({
    super.key,
    required this.iconPath,
    required this.displayName,
    required this.isCustom,
    required this.onChange,
    this.customLabel = 'Custom',
  });

  final String? iconPath;
  final String displayName;
  final bool isCustom;
  final VoidCallback onChange;
  final String customLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onChange,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              if (iconPath != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: AssetImageWidget(
                    assetPath: iconPath!,
                    altCandidates: imageAltCandidates(iconPath!),
                    width: 36,
                    height: 36,
                    fit: BoxFit.cover,
                  ),
                ),
              const SizedBox(width: 10),
              Expanded(
                child: Row(
                  children: [
                    Flexible(
                      child: Text(
                        displayName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isCustom) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: pvzOrangeLight,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          customLabel,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.edit_outlined,
                size: 20,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool isDesktopPlatform(BuildContext context) {
  final platform = Theme.of(context).platform;
  return platform == TargetPlatform.windows ||
      platform == TargetPlatform.macOS ||
      platform == TargetPlatform.linux;
}

Widget scaleTableForDesktop({
  required BuildContext context,
  required Widget child,
  double desktopScale = 0.6,
}) {
  if (!isDesktopPlatform(context)) return child;
  return Center(
    child: FractionallySizedBox(widthFactor: desktopScale, child: child),
  );
}

/// Input decoration for editor screens.
/// When not focused: border and label (including floating label) use theme onSurface.
/// When focused and [focusColor] set: border and floating label use [focusColor].
/// Pass [isFocused] from the field's FocusNode so the floating label only uses [focusColor] when focused.
InputDecoration editorInputDecoration(
  BuildContext context, {
  String? labelText,
  String? hintText,
  Color? focusColor,
  bool isFocused = false,
  bool filled = false,
  Color? fillColor,
}) {
  final theme = Theme.of(context);
  final unfocusedColor = theme.colorScheme.onSurface;
  final baseDecoration = InputDecoration(
    labelText: labelText,
    hintText: hintText,
    border: const OutlineInputBorder(),
    enabledBorder: OutlineInputBorder(
      borderSide: BorderSide(color: unfocusedColor.withValues(alpha: 0.6)),
    ),
    labelStyle: TextStyle(color: unfocusedColor),
    hintStyle: TextStyle(color: unfocusedColor.withValues(alpha: 0.7)),
    filled: filled,
    fillColor: fillColor,
  );
  if (focusColor == null) return baseDecoration;
  return baseDecoration.copyWith(
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: focusColor, width: 2),
    ),
    floatingLabelStyle: TextStyle(
      color: isFocused ? focusColor : unfocusedColor,
    ),
    focusColor: focusColor,
  );
}

/// Icon for grid items. Use anywhere grid item icons are displayed.
class GridItemIcon extends StatelessWidget {
  const GridItemIcon({
    super.key,
    required this.typeName,
    this.size = 40,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius = 8,
  });

  final String typeName;
  final double size;
  final double? width;
  final double? height;
  final BoxFit fit;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final w = width ?? size;
    final h = height ?? size;
    final path = GridItemRepository.getIconPath(typeName);
    final effectiveFit = GridItemRepository.isRenaiStatue(typeName)
        ? BoxFit.contain
        : fit;
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: AssetImageWidget(
        assetPath: path,
        width: w,
        height: h,
        fit: effectiveFit,
        altCandidates: imageAltCandidates(path),
      ),
    );
  }
}

/// Alias for [GridItemIcon] when used for Renai statues. Maintains backward compatibility.
class RenaiStatueIcon extends StatelessWidget {
  const RenaiStatueIcon({
    super.key,
    required this.typeName,
    this.size = 40,
    this.fit = BoxFit.contain,
  });

  final String typeName;
  final double size;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) =>
      GridItemIcon(typeName: typeName, size: size, fit: fit);
}

/// Default [MaterialScrollBehavior] omits [PointerDeviceKind.mouse], so horizontal
/// [TabBar]s and nested scroll views do not respond to click-drag on desktop.
/// Vertically centered search field for colored app bar titles (light text).
class AppBarSearchField extends StatelessWidget {
  const AppBarSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.query = '',
    this.onClear,
    this.foregroundColor = Colors.white,
    this.borderRadius = 0,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final String query;
  final VoidCallback? onClear;
  final Color foregroundColor;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final iconColor = foregroundColor.withValues(alpha: 0.9);
    final hintColor = foregroundColor.withValues(alpha: 0.75);
    final border = borderRadius > 0
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide.none,
          )
        : InputBorder.none;

    return TextField(
      onChanged: onChanged,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(color: foregroundColor, height: 1.2),
      cursorColor: foregroundColor,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor, height: 1.2),
        prefixIcon: Icon(Icons.search, color: iconColor),
        suffixIcon: query.isNotEmpty
            ? IconButton(
                icon: Icon(Icons.clear, color: iconColor),
                onPressed: onClear,
              )
            : null,
        border: border,
        enabledBorder: border,
        focusedBorder: border,
        filled: true,
        fillColor: foregroundColor.withValues(alpha: 0.18),
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        isDense: true,
      ),
    );
  }
}

/// Search field for selection screens (module, plant, zombie, dialogs, etc.).
class SelectionSearchField extends StatelessWidget {
  const SelectionSearchField({
    super.key,
    required this.hintText,
    required this.onChanged,
    this.query = '',
    this.onClear,
    this.controller,
    this.fillColor,
    this.foregroundColor,
    this.borderRadius = 24,
    this.useOutlineBorder = false,
  });

  final String hintText;
  final ValueChanged<String> onChanged;
  final String query;
  final VoidCallback? onClear;
  final TextEditingController? controller;
  final Color? fillColor;
  final Color? foregroundColor;
  final double borderRadius;
  final bool useOutlineBorder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final textColor = foregroundColor ?? theme.colorScheme.onSurface;
    final hintColor = foregroundColor != null
        ? foregroundColor!.withValues(alpha: 0.75)
        : (isDark
              ? theme.colorScheme.onSurface.withValues(alpha: 0.65)
              : theme.colorScheme.onSurface.withValues(alpha: 0.55));
    final iconColor = foregroundColor != null
        ? foregroundColor!.withValues(alpha: 0.9)
        : theme.colorScheme.onSurface.withValues(alpha: 0.7);
    final bg =
        fillColor ??
        (foregroundColor != null
            ? foregroundColor!.withValues(alpha: 0.18)
            : theme.colorScheme.surfaceContainerHighest);

    InputBorder border;
    if (useOutlineBorder) {
      border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide(
          color: theme.colorScheme.onSurface.withValues(alpha: 0.35),
        ),
      );
    } else {
      border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(borderRadius),
        borderSide: BorderSide.none,
      );
    }

    return TextField(
      controller: controller,
      onChanged: onChanged,
      textAlignVertical: TextAlignVertical.center,
      style: TextStyle(color: textColor, height: 1.2),
      cursorColor: textColor,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: hintColor, height: 1.2),
        prefixIcon: Icon(Icons.search, color: iconColor),
        suffixIcon: query.isNotEmpty && onClear != null
            ? IconButton(
                icon: Icon(Icons.clear, color: iconColor),
                onPressed: onClear,
              )
            : null,
        filled: true,
        fillColor: bg,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        isDense: true,
        border: border,
        enabledBorder: border,
        focusedBorder: useOutlineBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: theme.colorScheme.primary,
                  width: 1.5,
                ),
              )
            : OutlineInputBorder(
                borderRadius: BorderRadius.circular(borderRadius),
                borderSide: BorderSide(
                  color: foregroundColor ?? theme.colorScheme.primary,
                  width: 1.5,
                ),
              ),
      ),
    );
  }
}

class MouseDragScrollBehavior extends MaterialScrollBehavior {
  const MouseDragScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}

/// Applies [MouseDragScrollBehavior] to [child] (e.g. filter strips with [TabBar]).
class ScrollableWithMouseDrag extends StatelessWidget {
  const ScrollableWithMouseDrag({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: const MouseDragScrollBehavior(),
      child: child,
    );
  }
}
