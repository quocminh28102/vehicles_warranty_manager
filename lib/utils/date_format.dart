import 'package:intl/intl.dart';

String formatDate(DateTime date, {String? locale}) {
  return DateFormat.yMMMd(locale).format(date);
}

String formatDateTime(DateTime date, {String? locale}) {
  return DateFormat.yMMMd(locale).add_Hm().format(date);
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
