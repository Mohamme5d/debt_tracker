import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AmountDisplay extends StatelessWidget {
  const AmountDisplay({
    super.key,
    required this.amount,
    this.style,
    this.color,
    this.prefix,
  });

  final double amount;
  final TextStyle? style;
  final Color? color;
  final String? prefix;

  static final _formatter = NumberFormat('#,##0.00');

  static String format(double amount) => _formatter.format(amount);

  @override
  Widget build(BuildContext context) {
    final text = '${prefix ?? ''}${_formatter.format(amount)}';
    final effectiveStyle = (style ?? Theme.of(context).textTheme.titleMedium)
        ?.copyWith(color: color);

    return Text(
      text,
      style: effectiveStyle,
    );
  }
}
