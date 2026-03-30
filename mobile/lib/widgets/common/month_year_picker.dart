import 'package:flutter/material.dart';
import 'package:rent_manager/l10n/app_localizations.dart';
import '../../core/utils/date_utils.dart';

class MonthYearPicker extends StatefulWidget {
  final int initialMonth;
  final int initialYear;
  final ValueChanged<(int month, int year)> onChanged;

  const MonthYearPicker({
    super.key,
    required this.initialMonth,
    required this.initialYear,
    required this.onChanged,
  });

  @override
  State<MonthYearPicker> createState() => _MonthYearPickerState();
}

class _MonthYearPickerState extends State<MonthYearPicker> {
  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    _month = widget.initialMonth;
    _year = widget.initialYear;
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Row(
      children: [
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _month,
            decoration: InputDecoration(labelText: l.month),
            items: List.generate(12, (i) {
              final m = i + 1;
              return DropdownMenuItem(
                value: m,
                child: Text(AppDateUtils.monthName(m, arabic: isArabic)),
              );
            }),
            onChanged: (v) {
              if (v != null) {
                setState(() => _month = v);
                widget.onChanged((_month, _year));
              }
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: DropdownButtonFormField<int>(
            value: _year,
            decoration: InputDecoration(labelText: l.year),
            items: List.generate(10, (i) {
              final y = DateTime.now().year - 2 + i;
              return DropdownMenuItem(value: y, child: Text('$y'));
            }),
            onChanged: (v) {
              if (v != null) {
                setState(() => _year = v);
                widget.onChanged((_month, _year));
              }
            },
          ),
        ),
      ],
    );
  }
}
