import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

class AppLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 200,
      colors: true,
      printEmojis: false,
    ),
  );

  static const bool _isDebugMode = kDebugMode;

  static void print(String title, dynamic message) {
    if (!_isDebugMode) return;
    _logger.d('$title: $message');
  }

  static void info(String title, String message) {
    if (_isDebugMode) _logger.i('$title: $message');
  }

  static void warning(String message) {
    if (_isDebugMode) _logger.w(message);
  }

  static void error(String message, [Object? err, StackTrace? stackTrace]) {
    if (_isDebugMode) _logger.e(message, error: err, stackTrace: stackTrace);
  }

  static void logFullJson(dynamic data) {
    if (!_isDebugMode) return;
    try {
      if (data is Map || data is List) {
        _logger.i(JsonEncoder.withIndent('  ').convert(data));
        return;
      }
      if (data is String) {
        try {
          final parsed = jsonDecode(data);
          _logger.i(JsonEncoder.withIndent('  ').convert(parsed));
          return;
        } catch (_) {}
      }
      _logger.i(data.toString());
    } catch (_) {
      _logger.i(data.toString());
    }
  }
}
