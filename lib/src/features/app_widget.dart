import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/config/injection.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hooks/src/features/common/presentation/extensions/app_theme_type_extensions.dart';
import 'package:hooks/src/features/common/presentation/loading/loading.dart';
import 'package:hooks/src/routing/app_router.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (ctx, state) => state.map(
        loading: (_) {
          final pref = getIt<SettingsService>();
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: pref.appTheme.getThemeData(),
            home: const Loading(),
          );
        },
        loaded: (s) {
          final autoThemeModeOn = s.autoThemeMode == AutoThemeModeType.on;
          final led = s.useDarkAmoled;
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
            title: s.appTitle,
            theme: autoThemeModeOn
                ? s.theme.lightTheme()
                : s.theme.getThemeData(useDarkAmoled: led),
            darkTheme: autoThemeModeOn
                ? s.theme.darkTheme(useDarkAmoled: led) : null,
          );
        },
      ),
    );
  }
}
