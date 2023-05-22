import 'package:hooks/src/extensions/extensions.dart';
import 'package:logger/logger.dart';
import 'package:sprintf/sprintf.dart';

class LoggingService {
  final _logger = Logger();

  void info(Type type, String msg, [List<Object>? args]) {
    assert(!msg.isNullOrEmpty, 'Msg cannot be empty');

    if (args != null && args.isNotEmpty) {
      _logger.i('$type - ${sprintf(msg, args)}');
    } else {
      _logger.i('$type - $msg');
    }
  }

  void warning(Type type, String msg, [dynamic ex, StackTrace? trace]) {
    assert(!msg.isNullOrEmpty, 'Msg cannot be empty');
    final tag = type.toString();
    _logger.w('$tag - ${_formatEx(msg, ex)}', ex, trace);
  }

  void error(Type type, String msg, {dynamic ex, StackTrace? trace}) {
    assert(!msg.isNullOrEmpty, 'Msg cannot be empty');
    final tag = type.toString();
    _logger.e('$tag - ${_formatEx(msg, ex)}', ex, trace);
  }

  String _formatEx(String msg, dynamic ex) {
    if (ex != null) {
      return '$msg \n $ex';
    }
    return '$msg \n No exception available';
  }
}
