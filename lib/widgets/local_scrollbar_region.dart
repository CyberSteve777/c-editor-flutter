import 'package:flutter/widgets.dart';

/// Keeps a scrollbar aligned with a viewport already placed by its parent.
/// Screen safe-area padding otherwise shifts a local horizontal thumb upward
/// on iOS, even when the viewport is far from the screen's bottom edge.
class LocalScrollbarRegion extends StatelessWidget {
  const LocalScrollbarRegion({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => MediaQuery.removePadding(
    context: context,
    removeLeft: true,
    removeTop: true,
    removeRight: true,
    removeBottom: true,
    child: child,
  );
}
