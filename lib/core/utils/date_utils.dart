import 'package:intl/intl.dart';

class DateHelper {
  /// Format any DateTime or String date
  static String formatDate({
    dynamic date,
    String format = 'yyyy-MM-dd',
  }) {
    DateTime parsedDate;
    if (date == null) {
      parsedDate = DateTime.now();
    } else if (date is String) {
      parsedDate = DateTime.parse(date);
    } else if (date is DateTime) {
      parsedDate = date;
    } else {
      throw ArgumentError('Invalid date type');
    }
    return DateFormat(format).format(parsedDate);
  }

  /// Get current date in specified format
  static String currentDate({String format = 'yyyy-MM-dd'}) {
    return formatDate(date: DateTime.now(), format: format);
  }

  /// Format a date string (yyyy-MM-dd) to a readable label.
  /// Shows "Today", "Tomorrow", or "Tue, 06 Mar"
  static String prettyDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      final date = DateTime.parse(dateStr);
      return DateFormat('EEE, MMM d').format(date);
    } catch (_) {
      return dateStr;
    }
  }

  /// Format time string "HH:mm:ss" or "HH:mm" to "10:00 AM"
  static String prettyTime(String? timeStr) {
    if (timeStr == null || timeStr.isEmpty) return '';
    try {
      final parts = timeStr.split(':');
      int hour = int.parse(parts[0]);
      int minute = int.parse(parts[1]);
      final period = hour >= 12 ? 'PM' : 'AM';
      hour = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
      final minuteStr = minute < 10 ? '0$minute' : '$minute';
      return '$hour:$minuteStr $period';
    } catch (_) {
      return timeStr;
    }
  }

  /// Format time range: "10:00 AM – 11:00 AM"
  static String prettyTimeRange(String? start, String? end) {
    final s = prettyTime(start);
    final e = prettyTime(end);
    if (s.isEmpty && e.isEmpty) return '';
    if (e.isEmpty) return s;
    return '$s – $e';
  }

  /// Full readable date: "06 March 2026"
  static String fullDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '';
    try {
      return DateFormat('dd MMMM yyyy').format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  static String formatDateTimeRange(String? startDateTime, String? endDateTime) {
    if (startDateTime == null || startDateTime.isEmpty) return '';
    if (endDateTime == null || endDateTime.isEmpty) return '';
    try {
      final start = DateTime.parse(startDateTime).toLocal();
      final end = DateTime.parse(endDateTime).toLocal();
      final startTime = _formatTime(start);
      final endTime = _formatTime(end);
      if (start.year == end.year &&
          start.month == end.month &&
          start.day == end.day) {
        return '${_formatDate(start)} • $startTime - $endTime';
      } else {
        return '${_formatDate(start)} $startTime - ${_formatDate(end)} $endTime';
      }
    } catch (_) {
      return '';
    }
  }

  static String _formatDate(DateTime date) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  static String _formatTime(DateTime time) {
    int hour = time.hour;
    final minute = time.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    hour = hour == 0 ? 12 : hour > 12 ? hour - 12 : hour;
    final minuteStr = minute < 10 ? '0$minute' : '$minute';
    return '$hour:$minuteStr $period';
  }
}
