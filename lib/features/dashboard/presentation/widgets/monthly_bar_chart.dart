import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../app/theme.dart';
import '../../../../core/db/models/debt_transaction.dart';
import '../../../../core/db/models/enums.dart';

class MonthlyBarChart extends StatefulWidget {
  const MonthlyBarChart({super.key, required this.transactions});

  final List<DebtTransaction> transactions;

  @override
  State<MonthlyBarChart> createState() => _MonthlyBarChartState();
}

class _MonthlyBarChartState extends State<MonthlyBarChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final locale = Localizations.localeOf(context);
    final isArabic = locale.languageCode == 'ar';
    final now = DateTime.now();
    final months = List.generate(6, (i) {
      final date = DateTime(now.year, now.month - 5 + i);
      return date;
    });

    final monthlyData = <DateTime, ({double debts, double loans})>{};
    for (final m in months) {
      monthlyData[m] = (debts: 0.0, loans: 0.0);
    }

    for (final tx in widget.transactions) {
      final txMonth = DateTime(tx.date.year, tx.date.month);
      if (monthlyData.containsKey(txMonth)) {
        final current = monthlyData[txMonth]!;
        if (tx.type == TransactionType.debt) {
          monthlyData[txMonth] =
              (debts: current.debts + tx.amount, loans: current.loans);
        } else {
          monthlyData[txMonth] =
              (debts: current.debts, loans: current.loans + tx.amount);
        }
      }
    }

    double maxY = 0;
    for (final entry in monthlyData.values) {
      if (entry.debts > maxY) maxY = entry.debts;
      if (entry.loans > maxY) maxY = entry.loans;
    }
    maxY = maxY == 0 ? 100 : maxY * 1.2;

    final monthFormat =
        isArabic ? DateFormat('MMM', 'ar') : DateFormat('MMM');

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final animVal = Curves.easeOutCubic.transform(_animController.value);
        return SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (_) => AppTheme.surfaceDark,
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    final value = rod.toY / animVal;
                    return BarTooltipItem(
                      NumberFormat('#,##0').format(value),
                      TextStyle(
                        color: rod.color ?? Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index < 0 || index >= months.length) {
                        return const SizedBox.shrink();
                      }
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          monthFormat.format(months[index]),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.5),
                            fontSize: 11,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: maxY / 4,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppTheme.borderDark.withOpacity(0.3),
                  strokeWidth: 0.5,
                ),
              ),
              barGroups: List.generate(months.length, (i) {
                final data = monthlyData[months[i]]!;
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: data.debts * animVal,
                      color: AppTheme.debtColor,
                      width: 10,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4)),
                    ),
                    BarChartRodData(
                      toY: data.loans * animVal,
                      color: AppTheme.loanColor,
                      width: 10,
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(4)),
                    ),
                  ],
                );
              }),
            ),
          ),
        );
      },
    );
  }
}
