/// Browsing state owned by one generator edit, never persisted across edits.
class PreviewStickerPickerSession {
  String? selectedTag;
  String query = '';
  double tagStripOffset = 0;

  final _scrollOffsets = <(String?, String), double>{};

  double scrollOffsetFor(String? tag, String query) =>
      _scrollOffsets[(tag, query)] ?? 0;

  void rememberScrollOffset(String? tag, String query, double offset) {
    if (offset.isFinite) {
      _scrollOffsets[(tag, query)] = offset < 0 ? 0 : offset;
    }
  }
}
