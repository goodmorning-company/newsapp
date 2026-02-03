part of 'theme_cubit.dart';

class ThemeState {
  final bool isDarkMode;
  final ThemeMode themeMode;

  const ThemeState({
    required this.isDarkMode,
  }) : themeMode = isDarkMode ? ThemeMode.dark : ThemeMode.light;

  ThemeState copyWith({bool? isDarkMode}) {
    final nextIsDark = isDarkMode ?? this.isDarkMode;
    return ThemeState(isDarkMode: nextIsDark);
  }
}
