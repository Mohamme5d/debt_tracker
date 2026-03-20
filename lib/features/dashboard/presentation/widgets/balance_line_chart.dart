import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/db/models/debt_transaction.dart';
import '../../../../core/db/models/enums.dart';

class BalanceLineChart extends StatefulWidget {
  const BalanceLineChart({super.key, required this.transactions});

  final List<DebtTransaction> transactions;

  @override
  State<BalanceLineChart> createState() => _BalanceLineChartState();
}

class _BalanceLineChartState extends State<BalanceLineChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sorted = List<DebtTransaction>.from(widget.transactions)
      ..sort((a, b) => a.date.compareTo(b.date));

    if (sorted.isEmpty) {
      return SizedBox(
        height: 200,
        child: Center(
          child: Text(
            '',
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ),
      );
    }

    // Calculate running net balance
    double runningBalance = 0;
    final spots = <FlSpot>[];
    for (int i = 0; i < sorted.length; i++) {
      final tx = sorted[i];
      if (tx.type == TransactionType.loan) {
        runningBalance += tx.remaining;
      } else {
        runningBalance -= tx.remaining;
      }
      spots.add(FlSpot(i.toDouble(), runningBalance));
    }

    double minY = spots.map((s) => s.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);

    if (minY == maxY) {
      minY -= 100;
      maxY += 100;
    }

    final range = maxY - minY;
    minY -= range * 0.1;
    maxY += range * 0.1;

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        final animVal = Curves.easeOutCubic.transform(_animController.value);
        final visibleCount = (spots.length * animVal).ceil().clamp(1, spots.length);
        final visibleSpots = spots.sublist(0, visibleCount);

        return SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              minY: minY,
              maxY: maxY,
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppTheme.surfaceDark,
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final isPositive = spot.y >= 0;
                      return LineTooltipItem(
                        spot.y.toStringAsFixed(0),
                        TextStyle(
                          color: isPositive
                              ? AppTheme.loanColor
                              : AppTheme.debtColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: range > 0 ? range / 4 : 50,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppTheme.borderDark.withOpacity(0.3),
                  strokeWidth: 0.5,
                ),
              ),
              titlesData: const FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: visibleSpots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: AppTheme.primaryColor,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: visibleSpots.length <= 10,
                    getDotPainter: (spot, percent, bar, index) {
                      return FlDotCirclePainter(
                        radius: 4,
                        color: spot.y >= 0
                            ? AppTheme.loanColor
                            : AppTheme.debtColor,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      );
                    },
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.primaryColor.withOpacity(0.2),
                        AppTheme.primaryColor.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ],
              extraLinesData: ExtraLinesData(
                horizontalLines: [
                  HorizontalLine(
                    y: 0,
                    color: Colors.white.withOpacity(0.2),
                    strokeWidth: 1,
                    dashArray: [5, 5],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
