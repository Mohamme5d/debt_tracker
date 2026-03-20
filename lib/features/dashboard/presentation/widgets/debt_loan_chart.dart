import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:raseed/l10n/app_localizations.dart';

import '../../../../app/theme.dart';

class DebtLoanChart extends StatefulWidget {
  const DebtLoanChart({
    super.key,
    required this.totalDebt,
    required this.totalLoan,
  });

  final double totalDebt;
  final double totalLoan;

  @override
  State<DebtLoanChart> createState() => _DebtLoanChartState();
}

class _DebtLoanChartState extends State<DebtLoanChart>
    with SingleTickerProviderStateMixin {
  int _touchedIndex = -1;
  late final AnimationController _animController;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final total = widget.totalDebt + widget.totalLoan;

    if (total == 0) {
      return Center(
        child: Text(
          l10n.noData,
          style: TextStyle(color: Colors.white.withOpacity(0.5)),
        ),
      );
    }

    return AnimatedBuilder(
      animation: _animController,
      builder: (context, _) {
        return Row(
          children: [
            Expanded(
              flex: 3,
              child: SizedBox(
                height: 160,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, response) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              response == null ||
                              response.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex =
                              response.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 3,
                    centerSpaceRadius: 36,
                    sections: [
                      PieChartSectionData(
                        value: widget.totalDebt * _animController.value,
                        color: AppTheme.debtColor,
                        radius: _touchedIndex == 0 ? 50 : 40,
                        title: '${((widget.totalDebt / total) * 100).toInt()}%',
                        titleStyle: TextStyle(
                          fontSize: _touchedIndex == 0 ? 14 : 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      PieChartSectionData(
                        value: widget.totalLoan * _animController.value,
                        color: AppTheme.loanColor,
                        radius: _touchedIndex == 1 ? 50 : 40,
                        title: '${((widget.totalLoan / total) * 100).toInt()}%',
                        titleStyle: TextStyle(
                          fontSize: _touchedIndex == 1 ? 14 : 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _LegendItem(
                    color: AppTheme.debtColor,
                    label: l10n.debt,
                  ),
                  const SizedBox(height: 8),
                  _LegendItem(
                    color: AppTheme.loanColor,
                    label: l10n.loan,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}
