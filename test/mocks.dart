import 'package:hooks/src/features/auth/infrastructure/auth_service.dart';
import 'package:hooks/src/features/common/infrastructure/caches/caches.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hooks/src/features/stories/infrastructure/stories_service.dart';
import 'package:hooks/src/utils/utils.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:mocktail/mocktail.dart';

class MockLoggingService extends Mock implements LoggingService {}

class MockDeviceInfoService extends Mock implements DeviceInfoService {}

class MockAuthService extends Mock implements AuthService {}

class MockSettingsService extends Mock implements SettingsService {}

class MockStoriesService extends Mock implements StoriesService {}

class MockDataService extends Mock implements DataService {}

class MockDraftCache extends Mock implements DraftCache {}

class MockDebouncer extends Mock implements Debouncer {}

class MockStorage extends Mock implements Storage {}

