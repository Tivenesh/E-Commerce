import 'package:logger/logger.dart';
import 'package:flutter/foundation.dart'; // For kDebugMode

final Logger appLogger = Logger(
  printer: PrettyPrinter(
    methodCount: 0, // No method calls to be displayed for cleaner output in models
    errorMethodCount: 5, // Number of method calls if stacktrace is provided
    lineLength: 120, // width of the output
    colors: true, // Colorful log messages
    printEmojis: true, // Print an emoji for each log message
    dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart, // Should each log print a timestamp
  ),
  filter: kDebugMode ? DevelopmentFilter() : ProductionFilter(), // Only show logs in debug mode (except errors)
  level: Level.debug, // Default logging level in debug mode
);

// A simple production filter (optional, default ProductionFilter omits all but error)
class ProductionFilter extends LogFilter {
  @override
  bool shouldLog(LogEvent event) {
    return event.level.index >= Level.error.index; // Only log errors in production
  }
}