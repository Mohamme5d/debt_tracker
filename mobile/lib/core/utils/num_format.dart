import 'package:intl/intl.dart';

class NumFormat {
  // Shows up to 2 decimal places, only if non-zero. Adds thousand separators.
  // Examples: 11000 → "11,000"  |  11000.5 → "11,000.5"  |  11000.23 → "11,000.23"
  static final _fmt = NumberFormat('#,##0.##');

  static String fmt(double v) => _fmt.format(v);
}
