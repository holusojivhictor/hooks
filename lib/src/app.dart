import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks/src/config/injection.dart';
import 'package:hooks/src/features/app_widget.dart';
import 'package:hooks/src/features/common/application/bloc.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hooks/src/features/stories/application/stories_bloc.dart';
import 'package:hooks/src/features/stories/infrastructure/stories_service.dart';

class HooksApp extends StatelessWidget {
  const HooksApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) {
            final settingsService = getIt<SettingsService>();
            return FilterCubit(settingsService);
          },
        ),
        BlocProvider(
          create: (ctx) {
            final storiesService = getIt<StoriesService>();
            final settingsService = getIt<SettingsService>();
            return StoriesBloc(
              storiesService,
              settingsService,
              ctx.read<FilterCubit>(),
            );
          },
        ),
        BlocProvider(
          create: (ctx) {
            final loggingService = getIt<LoggingService>();
            final settingsService = getIt<SettingsService>();
            final deviceInfoService = getIt<DeviceInfoService>();
            return AppBloc(
              loggingService,
              settingsService,
              deviceInfoService,
            )..add(const AppEvent.init());
          },
        ),
        BlocProvider(
          create: (ctx) {
            final settingsService = getIt<SettingsService>();
            final deviceInfoService = getIt<DeviceInfoService>();
            return SettingsBloc(
              settingsService,
              deviceInfoService,
              ctx.read<AppBloc>(),
            )..add(const SettingsEvent.init());
          },
        ),
      ],
      child: BlocBuilder<AppBloc, AppState>(
        builder: (ctx, state) => const AppWidget(),
      ),
    );
  }
}
