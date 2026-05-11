import 'package:intl/intl.dart';

class DateHelpers {
  DateHelpers._();

  static final DateFormat _dayFormat = DateFormat('dd');
  static final DateFormat _shortDate = DateFormat('MMM dd');
  static final DateFormat _fullDate = DateFormat('MMM dd, yyyy');
  static final DateFormat _monthYear = DateFormat('MMMM yyyy');
  static final DateFormat _dayName = DateFormat('EEEE');
  static final DateFormat _shortDayName = DateFormat('EEE');

  /// "14"
  static String day(DateTime date) => _dayFormat.format(date);

  /// "Apr 14"
  static String shortDate(DateTime date) => _shortDate.format(date);

  /// "Apr 14, 2026"
  static String fullDate(DateTime date) => _fullDate.format(date);

  /// "April 2026"
  static String monthYear(DateTime date) => _monthYear.format(date);

  /// "Monday"
  static String dayName(DateTime date) => _dayName.format(date);

  /// "Mon"
  static String shortDayName(DateTime date) => _shortDayName.format(date);

  /// "Today", "Yesterday", or "Apr 14"
  static String relativeDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final dateOnly = DateTime(date.year, date.month, date.day);
    final difference = today.difference(dateOnly).inDays;

    if (difference == 0) return 'Today';
    if (difference == 1) return 'Yesterday';
    if (difference < 7) return shortDayName(date);
    return shortDate(date);
  }


  /// Start of today
  static DateTime get startOfToday {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  /// Start of current week (Monday)
  static DateTime get startOfWeek {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Start of current month
  static DateTime get startOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }
}
