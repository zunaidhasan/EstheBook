import 'package:intl/intl.dart';

/// Formats money amounts, dates, and times for display across the app.
class EbFormatters {
  const EbFormatters._();

  static final NumberFormat _money = NumberFormat.currency(
    locale: 'en_US',
    symbol: '\$',
    decimalDigits: 0,
  );

  static String money(num amount) => _money.format(amount);

  static String moneyRange(num from, num to) =>
      from == to ? money(from) : '${money(from)}–${money(to)}';

  static String dateShort(DateTime date) => DateFormat('EEE, MMM d').format(date);

  static String dateLong(DateTime date) => DateFormat('EEEE, MMMM d').format(date);

  static String time(DateTime time) => DateFormat('h:mm a').format(time);

  static String monthYear(DateTime date) => DateFormat('MMMM yyyy').format(date);

  static String relativeDay(DateTime date, DateTime now) {
    final a = DateTime(date.year, date.month, date.day);
    final b = DateTime(now.year, now.month, now.day);
    final diff = a.difference(b).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Tomorrow';
    if (diff == -1) return 'Yesterday';
    if (diff > 1 && diff < 7) return DateFormat('EEEE').format(date);
    return dateShort(date);
  }
}
