import 'package:intl/intl.dart';

final _vndFormat = NumberFormat.currency(
  locale: 'vi_VN',
  symbol: '₫',
  decimalDigits: 0,
);

String formatVnd(num amount) => _vndFormat.format(amount);
