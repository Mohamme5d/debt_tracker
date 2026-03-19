import 'package:flutter/material.dart';
import 'package:raseed/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/theme.dart';
import '../../../shared/widgets/gradient_card.dart';
import '../../../shared/widgets/person_avatar.dart';
import '../providers/dashboard_provider.dart';
import 'widgets/balance_line_chart.dart';
import 'widgets/debt_loan_chart.dart';
import 'widgets/monthly_bar_chart.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late final AnimationController _summaryAnimController;
  late final AnimationController _listAnimController;
  late final AnimationController _fabAnimController;
  int _chartTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _summaryAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _listAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fabAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _summaryAnimController.forward();
    });
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) _listAnimController.forward();
    });
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _fabAnimController.forward();
    });
  }

  @override
  void dispose() {
    _summaryAnimController.dispose();
    _listAnimController.dispose();
    _fabAnimController.dispose();
    super.dispose();
  }

  static final _formatter = NumberFormat('#,##0.00');

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppTheme.backgroundDark,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        ),
        slivers: [
          SliverAppBar(
            expandedHeight: 80,
            floating: true,
            pinned: true,
            backgroundColor: AppTheme.backgroundDark,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsetsDirectional.only(start: 20, bottom: 16),
              title: Text(
                l10n.greeting,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 22,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: summaryAsync.when(
              data: (summary) => _buildContent(summary, l10n),
              loading: () => const Padding(
                padding: EdgeInsets.symmetric(vertical: 100),
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (error, _) => _buildErrorState(error, l10n),
            ),
          ),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: CurvedAnimation(
          parent: _fabAnimController,
          curve: Curves.elasticOut,
        ),
        child: FloatingActionButton.extended(
          onPressed: () => context.push('/add-transaction'),
          icon: const Icon(Icons.add_rounded),
          label: Text(l10n.addTransaction),
        ),
      ),
    );
  }

  Widget _buildContent(DashboardSummary summary, AppLocalizations l10n) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary Row
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            children: [
              Expanded(child: _buildSummaryCard(
                title: l10n.iOwe,
                amount: summary.totalIOwe,
                color: AppTheme.debtColor,
                icon: Icons.arrow_upward_rounded,
                delay: 0.0,
              )),
              const SizedBox(width: 12),
              Expanded(child: _buildSummaryCard(
                title: l10n.owedToMe,
                amount: summary.totalOwedToMe,
                color: AppTheme.loanColor,
                icon: Icons.arrow_downward_rounded,
                delay: 0.15,
              )),
            ],
          ),
        ),

        // Net balance pill
        _buildNetBalancePill(summary, l10n),

        const SizedBox(height: 20),

        // Charts Section
        _buildChartsSection(summary, l10n),

        const SizedBox(height: 20),

        // Person List Header
        if (summary.personBalances.isNotEmpty) ...[
          FadeTransition(
            opacity: _listAnimController,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(20, 8, 20, 8),
              child: Text(
                l10n.people,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
          ...List.generate(
            summary.personBalances.length,
            (index) => _buildPersonCard(summary.personBalances[index], index),
          ),
        ] else
          _buildEmptyState(l10n),

        const SizedBox(height: 100),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required double amount,
    required Color color,
    required IconData icon,
    required double delay,
  }) {
    final endInterval = (delay + 0.6).clamp(0.0, 1.0);

    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _summaryAnimController,
      curve: Interval(delay, endInterval, curve: Curves.easeOutCubic),
    ));

    final fadeAnim = CurvedAnimation(
      parent: _summaryAnimController,
      curve: Interval(delay, (delay + 0.5).clamp(0.0, 1.0),
          curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: GradientCard(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topStart,
            end: AlignmentDirectional.bottomEnd,
            colors: [
              color.withOpacity(0.15),
              AppTheme.surfaceDark2,
            ],
          ),
          borderColor: color.withOpacity(0.2),
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 16),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: TextStyle(
                      color: color,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: amount),
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                builder: (context, val, _) {
                  return Text(
                    _formatter.format(val),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNetBalancePill(DashboardSummary summary, AppLocalizations l10n) {
    final net = summary.totalOwedToMe - summary.totalIOwe;
    final isPositive = net >= 0;
    final color = isPositive ? AppTheme.loanColor : AppTheme.debtColor;
    final statusText = isPositive ? l10n.goodStatus : l10n.badStatus;

    final fadeAnim = CurvedAnimation(
      parent: _summaryAnimController,
      curve: const Interval(0.3, 0.8, curve: Curves.easeOut),
    );

    return FadeTransition(
      opacity: fadeAnim,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.15)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isPositive
                        ? Icons.check_circle_rounded
                        : Icons.warning_rounded,
                    color: color,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    statusText,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: color,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: net.abs()),
                duration: const Duration(milliseconds: 1400),
                curve: Curves.easeOutCubic,
                builder: (context, val, _) {
                  return Text(
                    _formatter.format(val),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartsSection(DashboardSummary summary, AppLocalizations l10n) {
    final tabs = [l10n.debtVsLoan, l10n.monthlyOverview, l10n.balanceTrend];

    return FadeTransition(
      opacity: CurvedAnimation(
        parent: _listAnimController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GradientCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tab bar
              SizedBox(
                height: 36,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: tabs.length,
                  itemBuilder: (context, index) {
                    final selected = _chartTabIndex == index;
                    return GestureDetector(
                      onTap: () => setState(() => _chartTabIndex = index),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsetsDirectional.only(end: 8),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: selected
                              ? AppTheme.primaryColor.withOpacity(0.2)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: selected
                                ? AppTheme.primaryColor
                                : AppTheme.borderDark,
                          ),
                        ),
                        child: Text(
                          tabs[index],
                          style: TextStyle(
                            color: selected
                                ? AppTheme.primaryColor
                                : Colors.white.withOpacity(0.5),
                            fontSize: 12,
                            fontWeight:
                                selected ? FontWeight.w600 : FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: _buildChartContent(summary),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildChartContent(DashboardSummary summary) {
    switch (_chartTabIndex) {
      case 0:
        return DebtLoanChart(
          key: const ValueKey('pie'),
          totalDebt: summary.totalIOwe,
          totalLoan: summary.totalOwedToMe,
        );
      case 1:
        return MonthlyBarChart(
          key: const ValueKey('bar'),
          transactions: summary.allTransactions,
        );
      case 2:
        return BalanceLineChart(
          key: const ValueKey('line'),
          transactions: summary.allTransactions,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonCard(PersonBalance pb, int index) {
    final start = (index * 0.06).clamp(0.0, 0.7);
    final end = (start + 0.5).clamp(start + 0.1, 1.0);

    final slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _listAnimController,
      curve: Interval(start, end, curve: Curves.easeOutQuart),
    ));

    final fadeAnim = CurvedAnimation(
      parent: _listAnimController,
      curve: Interval(start, end, curve: Curves.easeOut),
    );

    final isPositive = pb.netBalance >= 0;
    final color = isPositive ? AppTheme.loanColor : AppTheme.debtColor;
    final l10n = AppLocalizations.of(context)!;
    final label = isPositive ? l10n.owesYou : l10n.youOwe;

    final dateFormat = DateFormat('MMM dd');

    return FadeTransition(
      opacity: fadeAnim,
      child: SlideTransition(
        position: slideAnim,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => context.push('/person/${pb.person.id}'),
              borderRadius: BorderRadius.circular(24),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.glassCardDecoration,
                child: Column(
                  children: [
                    Row(
                      children: [
                        PersonAvatar(
                          name: pb.person.name,
                          size: 50,
                          heroTag: 'avatar_${pb.person.id}',
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                pb.person.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${pb.activeCount} ${l10n.active}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (pb.lastTransactionDate != null)
                                    Text(
                                      dateFormat
                                          .format(pb.lastTransactionDate!),
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.white.withOpacity(0.4),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: TweenAnimationBuilder<double>(
                            tween:
                                Tween(begin: 0, end: pb.netBalance.abs()),
                            duration:
                                Duration(milliseconds: 800 + index * 100),
                            curve: Curves.easeOutCubic,
                            builder: (context, val, _) {
                              return Text(
                                _formatter.format(val),
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: color,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0, end: pb.progressRatio),
                        duration:
                            Duration(milliseconds: 1000 + index * 100),
                        curve: Curves.easeOutCubic,
                        builder: (context, val, _) {
                          return LinearProgressIndicator(
                            value: val,
                            minHeight: 4,
                            backgroundColor:
                                AppTheme.borderDark.withOpacity(0.3),
                            valueColor:
                                AlwaysStoppedAnimation<Color>(color),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                        Text(
                          '${(pb.progressRatio * 100).toInt()}% ${l10n.paid}',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return FadeTransition(
      opacity: _listAnimController,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 60),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primaryColor.withOpacity(0.15),
                      AppTheme.loanColor.withOpacity(0.08),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 48,
                  color: Colors.white.withOpacity(0.3),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                l10n.noActiveDebts,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.tapToAdd,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.3),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(Object error, AppLocalizations l10n) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 60),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppTheme.debtColor),
            const SizedBox(height: 16),
            Text(l10n.errorLoading,
                style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 8),
            Text(error.toString(),
                style: TextStyle(
                    color: Colors.white.withOpacity(0.5), fontSize: 12)),
          ],
        ),
      ),
    );
  }
}
