import 'package:flutter/material.dart';

/// Gives picker contents one scroll controller and a draggable vertical thumb.
class PreviewPickerScrollArea extends StatefulWidget {
  const PreviewPickerScrollArea({
    super.key,
    required this.builder,
    this.controller,
    this.scrollbarKey,
  });

  final Widget Function(ScrollController controller) builder;
  final ScrollController? controller;
  final Key? scrollbarKey;

  @override
  State<PreviewPickerScrollArea> createState() =>
      _PreviewPickerScrollAreaState();
}

class _PreviewPickerScrollAreaState extends State<PreviewPickerScrollArea> {
  final _ownedController = ScrollController();

  @override
  void dispose() {
    _ownedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller ?? _ownedController;
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: Scrollbar(
        key: widget.scrollbarKey,
        controller: controller,
        thumbVisibility: true,
        interactive: true,
        notificationPredicate: (notification) =>
            notification.depth == 0 &&
            notification.metrics.axis == Axis.vertical,
        child: widget.builder(controller),
      ),
    );
  }
}
