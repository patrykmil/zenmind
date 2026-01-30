class DateUtils {
  DateUtils._();

  static String toLocalDateKey(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static bool isTodayFromTimestamp(int milliseconds, DateTime now) {
    final date = DateTime.fromMillisecondsSinceEpoch(milliseconds);
    return isSameDay(date, now);
  }
}
