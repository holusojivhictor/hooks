import 'package:get_it/get_it.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';

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
  }
}
