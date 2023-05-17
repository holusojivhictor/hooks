import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks/src/app.dart';
import 'package:hooks/src/extensions/string_extensions.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  registerErrorHandlers();

  runApp(const MyApp());
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
        title: Text('An error occurred'.hardcoded),
      ),
      body: Center(child: Text(details.toString())),
    );
  };
}
