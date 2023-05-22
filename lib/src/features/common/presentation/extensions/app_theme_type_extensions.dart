import 'package:flutter/material.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/presentation/colors.dart';
import 'package:hooks/src/features/common/presentation/theme.dart';

extension AppThemeTypeExtensions on AppThemeType {
  ThemeData lightTheme() {
    return ThemeData(
      useMaterial3: true,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.black,
      ),
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF1F1F1),
      typography: AppTheme.appMaterialTypography,
      primaryTextTheme: AppTheme.appMaterialLightPrimaryTextTheme,
      textTheme: AppTheme.appMaterialLightTextTheme,
      colorScheme: AppTheme.appMaterialLightColorScheme,
      extensions: const <ThemeExtension<dynamic>>[
        AppThemeExtension(
          baseTextColor: Colors.black,
          placeHolderBase: AppColors.grey3,
          placeHolderHighlight: AppColors.grey1,
        ),
      ],
    );
  }

  ThemeData darkTheme({bool useDarkAmoled = false}) {
    final base = ThemeData(
      useMaterial3: true,
      textSelectionTheme: const TextSelectionThemeData(
        cursorColor: Colors.white,
      ),
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color.fromARGB(255, 20, 20, 20),
      typography: AppTheme.appMaterialTypography,
      primaryTextTheme: AppTheme.appMaterialDarkPrimaryTextTheme,
      textTheme: AppTheme.appMaterialDarkTextTheme,
      colorScheme: AppTheme.appMaterialDarkColorScheme,
      extensions: <ThemeExtension<dynamic>>[
        AppThemeExtension(
          baseTextColor: Colors.white,
          placeHolderBase: AppColors.variantGrey3,
          placeHolderHighlight: AppColors.variantGrey1,
        ),
      ],
    );

    if (!useDarkAmoled) {
      return base;
    }

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF000000),
    );
  }

  ThemeData getThemeData({bool useDarkAmoled = false}) {
    switch (this) {
      case AppThemeType.light:
        return lightTheme();
      case AppThemeType.dark:
        return darkTheme(useDarkAmoled: useDarkAmoled);
    }
  }
}
