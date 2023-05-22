import 'package:flutter/widgets.dart';
import 'package:get_it/get_it.dart';
import 'package:hooks/src/features/auth/infrastructure/auth_service.dart';
import 'package:hooks/src/features/common/infrastructure/caches/caches.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hooks/src/features/stories/infrastructure/stories_service.dart';

final GetIt getIt = GetIt.instance;

class Injection {
  static Future<void> init() async {
    final deviceInfoService = DeviceInfoService();
    getIt.registerSingleton<DeviceInfoService>(deviceInfoService);
    await deviceInfoService.init();

    final loggingService = LoggingService();
    getIt.registerSingleton<LoggingService>(loggingService);

    final settingsService = SettingsService(loggingService);
    await settingsService.init();
    getIt.registerSingleton<SettingsService>(settingsService);

    final dataService = DataService();
    await dataService.init();
    getIt
      ..registerSingleton<DataService>(dataService)
      ..registerSingleton<DraftCache>(DraftCache())
      ..registerSingleton<CommentCache>(CommentCache());

    final authService = AuthService(loggingService, settingsService);
    getIt.registerSingleton<AuthService>(authService);

    final postService = PostService(settingsService);
    getIt.registerSingleton<PostService>(postService);

    final storiesService = StoriesService();
    getIt
      ..registerSingleton<StoriesService>(storiesService)
      ..registerSingleton<RouteObserver<ModalRoute<dynamic>>>(
        RouteObserver<ModalRoute<dynamic>>(),
      );
  }
}
