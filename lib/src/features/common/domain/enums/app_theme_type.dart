enum AppThemeType {
  light,
  dark;

  bool get darkMode {
    switch (this) {
      case AppThemeType.light:
        return false;
      case AppThemeType.dark:
        return true;
    }
  }
}
