import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks/src/app.dart';
import 'package:hooks/src/config/injection.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerErrorHandlers();
  await Injection.init();

  runApp(const HooksApp());
}


void registerErrorHandlers() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
    debugPrint(details.toString());
  };
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    debugPrint(error.toString());
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
