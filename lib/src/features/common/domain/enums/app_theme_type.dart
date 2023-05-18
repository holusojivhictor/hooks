// ignore_for_file: avoid_positional_boolean_parameters

enum AppThemeType {
  light(false),
  dark(true);

  const AppThemeType(this.darkMode);

  final bool darkMode;
}
