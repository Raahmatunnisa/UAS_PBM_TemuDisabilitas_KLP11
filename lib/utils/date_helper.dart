import 'package:intl/intl.dart';

class DateHelper {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _timeFormat = DateFormat('HH:mm');
  static final DateFormat _displayDateFormat = DateFormat('dd MMM yyyy', 'id_ID');
  static final DateFormat _displayDateTimeFormat =
      DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

  static String formatDate(DateTime date) => _dateFormat.format(date);

  static String formatTime(DateTime time) => _timeFormat.format(time);

  static String formatDisplayDate(String dateStr) {
    try {
      return _displayDateFormat.format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  static String formatDisplayDateTime(String dateStr) {
    try {
      return _displayDateTimeFormat.format(DateTime.parse(dateStr));
    } catch (_) {
      return dateStr;
    }
  }

  static DateTime? parseDateTime(String date, String time) {
    try {
      return DateTime.parse('$date $time:00');
    } catch (_) {
      return null;
    }
  }

  static String nowIso() => DateTime.now().toIso8601String();
}
