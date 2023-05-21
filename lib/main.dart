import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks/src/app.dart';
import 'package:hooks/src/config/injection.dart';
import 'package:hooks/src/features/common/infrastructure/infrastructure.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Injection.init();
  registerErrorHandlers();

  final storage = await HydratedStorage.build(
    storageDirectory: await getTemporaryDirectory(),
  );
  HydratedBloc.storage = storage;

  runApp(const HooksApp());
}


void registerErrorHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    getIt<LoggingService>().error(
      details.runtimeType,
      details.summary.toString(),
      ex: details.exceptionAsString(),
      trace: details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    getIt<LoggingService>().error(
      error.runtimeType,
      error.toString(),
      trace: stack,
    );
    return true;
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        title: const Text('An error occurred'),
      ),
      body: Center(child: Text(details.toString())),
    );
  };
}
