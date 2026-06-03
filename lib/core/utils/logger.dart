import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final Logger logger = Logger(
  filter: _DebugLogFilter(),
  printer: PrettyPrinter(
    methodCount: 0,
    errorMethodCount: 5,
    lineLength: 100,
    colors: true,
    printEmojis: true,
    printTime: false,
  ),
);

class _DebugLogFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) => kDebugMode;
}
