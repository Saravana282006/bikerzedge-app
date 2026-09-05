import 'package:intl/intl.dart';

/// Formatting helpers used across the app.
class Formatters {
  Formatters._();

  static final DateFormat _dayMonth = DateFormat('d MMM');
  static final DateFormat _dayMonthYear = DateFormat('d MMM yyyy');
  static final DateFormat _time = DateFormat('h:mm a');
  static final DateFormat _full = DateFormat('d MMM yyyy, h:mm a');
  static final NumberFormat _rupee =
      NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);

  static String date(DateTime d) => _dayMonthYear.format(d);
  static String shortDate(DateTime d) => _dayMonth.format(d);
  static String time(DateTime d) => _time.format(d);
  static String dateTime(DateTime d) => _full.format(d);

  static String money(num value) => _rupee.format(value);

  /// Relative time, e.g. "3h ago", "2d ago", "Just now".
  static String relative(DateTime d) {
    final diff = DateTime.now().difference(d);
    if (diff.inSeconds < 60) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return _dayMonth.format(d);
  }
}
