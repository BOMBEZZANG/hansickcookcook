import 'dart:developer' as developer;

/// Simple logger utility for the application
class Logger {
  static const String _defaultTag = 'RecipeApp';
  
  /// Log debug information
  static void debug(String message, {String? tag}) {
    developer.log(message, name: tag ?? _defaultTag, level: 700);
  }
  
  /// Log informational messages
  static void info(String message, {String? tag}) {
    developer.log(message, name: tag ?? _defaultTag, level: 800);
  }
  
  /// Log warning messages
  static void warning(String message, {String? tag}) {
    developer.log(message, name: tag ?? _defaultTag, level: 900);
  }
  
  /// Log error messages
  static void error(String message, {String? tag, Object? error, StackTrace? stackTrace}) {
    developer.log(
      message,
      name: tag ?? _defaultTag,
      level: 1000,
      error: error,
      stackTrace: stackTrace,
    );
  }
}