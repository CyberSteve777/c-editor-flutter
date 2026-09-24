part of 'settings_cubit.dart';

final class SettingsState extends Equatable {
  const SettingsState({
    required this.locale,
    required this.themeMode,
    required this.uiScale,
    this.autosave = false,
  });

  final Locale locale;
  final ThemeMode themeMode;
  final double uiScale;

  /// When true, leaving the level editor with dirty changes saves without
  /// showing the unsaved-changes confirmation dialog.
  final bool autosave;

  SettingsState copyWith({
    Locale? locale,
    ThemeMode? themeMode,
    double? uiScale,
    bool? autosave,
  }) {
    return SettingsState(
      locale: locale ?? this.locale,
      themeMode: themeMode ?? this.themeMode,
      uiScale: uiScale ?? this.uiScale,
      autosave: autosave ?? this.autosave,
    );
  }

  @override
  List<Object?> get props => [locale, themeMode, uiScale, autosave];
}
