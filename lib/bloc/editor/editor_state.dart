part of 'editor_cubit.dart';

final class EditorState extends Equatable {
  const EditorState({
    this.levelFile,
    this.parsedData,
    this.isLoading = true,
    this.hasChanges = false,
    this.availableTabs = const [EditorTabType.settings],
    this.loadErrorKind,
  });

  final PvzLevelFile? levelFile;
  final ParsedLevelData? parsedData;
  final bool isLoading;
  final bool hasChanges;
  final List<EditorTabType> availableTabs;

  /// Set when the level failed to decode because of a structural RTON error.
  /// The UI reads this to show a localized notification instead of crashing.
  final RtonErrorKind? loadErrorKind;

  EditorState copyWith({
    PvzLevelFile? levelFile,
    ParsedLevelData? parsedData,
    bool? isLoading,
    bool? hasChanges,
    List<EditorTabType>? availableTabs,
    bool clearLevel = false,
  }) {
    return EditorState(
      levelFile: clearLevel ? null : (levelFile ?? this.levelFile),
      parsedData: clearLevel ? null : (parsedData ?? this.parsedData),
      isLoading: isLoading ?? this.isLoading,
      hasChanges: hasChanges ?? this.hasChanges,
      availableTabs: availableTabs ?? this.availableTabs,
    );
  }

  @override
  List<Object?> get props => [
    levelFile,
    parsedData,
    isLoading,
    hasChanges,
    availableTabs,
    loadErrorKind,
  ];
}
