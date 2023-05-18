import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/domain/enums/enums.dart';
import 'package:hooks/src/features/common/presentation/extensions/app_theme_type_extensions.dart';
import 'package:hooks/src/features/common/presentation/loading/loading.dart';
import 'package:hooks/src/routing/app_router.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AppBloc, AppState>(
      builder: (ctx, state) => state.map(
        loading: (_) => MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppThemeType.light.getLightTheme(),
          home: const Loading(),
        ),
        loaded: (s) {
          final autoThemeModeOn = s.autoThemeMode == AutoThemeModeType.on;
          return MaterialApp.router(
            debugShowCheckedModeBanner: false,
            routerConfig: AppRouter.router,
            title: s.appTitle,
            theme: autoThemeModeOn ? AppThemeType.light.getLightTheme() : s.theme.getThemeData(s.theme),
            darkTheme: autoThemeModeOn ? AppThemeType.light.getDarkTheme() : null,
          );
        },
      ),
    );
  }
}
