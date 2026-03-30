import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/locale_provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../widgets/common/month_year_picker.dart';
import '../../core/utils/num_format.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isArabic = context.watch<LocaleProvider>().isArabic;

    return Consumer<DashboardProvider>(
      builder: (context, provider, _) => Scaffold(
        body: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.surface,
          onRefresh: () => provider.load(),
          child: CustomScrollView(
            slivers: [
              // ── App Bar ─────────────────────────────────────────────────
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: AppColors.bgPage,
                title: Text(l.dashboard),
                actions: [
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: IconButton(
                      icon: const Icon(Icons.refresh_rounded),
                      onPressed: provider.load,
                    ),
                  ),
                ],
              ),

              // ── Body ────────────────────────────────────────────────────
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                sliver: provider.loading
                    ? const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 300,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      )
                    : SliverList(
                        delegate: SliverChildListDelegate([
                          const SizedBox(height: 8),
                          _HeaderCard(
                              provider: provider,
                              l: l,
                              isArabic: isArabic),
                          const SizedBox(height: 24),
                          _SectionTitle(l.quickStats),
                          const SizedBox(height: 12),
                          if (provider.summary != null) ...[
                            _QuickStatsGrid(
                                s: provider.summary!, l: l),
                            const SizedBox(height: 24),
                            _SectionTitle(l.financialSummary),
                            const SizedBox(height: 12),
                            _FinancialRow(s: provider.summary!, l: l),
                            const SizedBox(height: 24),
                            _SectionTitle(l.recentPayments),
                            const SizedBox(height: 12),
                            if (provider.summary!.recentPayments.isEmpty)
                              Padding(
                                padding: const EdgeInsets.all(24),
                                child: Center(
                                  child: Text(
                                    l.noData,
                                    style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.35),
                                    ),
                                  ),
                                ),
                              )
                            else
                              ...provider.summary!.recentPayments
                                  .asMap()
                                  .entries
                                  .map((e) => Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: _PaymentTile(
                                          payment: e.value,
                                          l: l,
                                          isArabic: isArabic,
                                          index: e.key,
                                        ),
                                      )),
                          ],
                          const SizedBox(height: 100),
                        ]),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

// ─── Header Card ─────────────────────────────────────────────────────────────
class _HeaderCard extends StatelessWidget {
  final DashboardProvider provider;
  final AppLocalizations l;
  final bool isArabic;

  const _HeaderCard({
    required this.provider,
    required this.l,
    required this.isArabic,
  });

  @override
  Widget build(BuildContext context) {
    final monthLabel = AppDateUtils.formatMonthYear(
        provider.selectedMonth, provider.selectedYear,
        arabic: isArabic);
    final hour = DateTime.now().hour;
    final greeting = isArabic
        ? (hour < 12 ? 'صباح الخير' : hour < 18 ? 'مساء الخير' : 'مساء الخير')
        : (hour < 12 ? 'Good morning' : hour < 18 ? 'Good afternoon' : 'Good evening');

    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: AppColors.gradientDash,
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.4),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(greeting,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7), fontSize: 14)),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(monthLabel,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w800)),
              ),
              GestureDetector(
                onTap: () => _pickMonth(context),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25)),
                  ),
                  child: Row(children: [
                    const Icon(Icons.calendar_month_rounded,
                        color: Colors.white, size: 15),
                    const SizedBox(width: 5),
                    Text(isArabic ? 'تغيير' : 'Change',
                        style: const TextStyle(
                            color: Colors.white, fontSize: 13)),
                  ]),
                ),
              ),
            ],
          ),
          // Decorative circles
          if (provider.summary != null) ...[
            const SizedBox(height: 16),
            Row(children: [
              _MiniStat(
                label: l.totalApartments,
                value: '${provider.summary!.totalApartments}',
                icon: Icons.apartment_rounded,
              ),
              const SizedBox(width: 16),
              _MiniStat(
                label: l.totalRenters,
                value: '${provider.summary!.totalRenters}',
                icon: Icons.people_rounded,
              ),
            ]),
          ],
        ],
      ),
    );
  }

  void _pickMonth(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            MonthYearPicker(
              initialMonth: provider.selectedMonth,
              initialYear: provider.selectedYear,
              onChanged: (mv) {
                Navigator.of(ctx).pop();
                provider.setMonthYear(mv.$1, mv.$2);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _MiniStat({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(children: [
          Icon(icon, color: Colors.white, size: 18),
          const SizedBox(width: 8),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value,
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 18)),
            Text(label,
                style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 11)),
          ]),
        ]),
      ),
    );
  }
}

// ─── Quick Stats 2×2 Grid ────────────────────────────────────────────────────
class _QuickStatsGrid extends StatelessWidget {
  final dynamic s;
  final AppLocalizations l;
  const _QuickStatsGrid({required this.s, required this.l});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(children: [
        Expanded(
          child: _StatCard(
            label: l.totalCollected,
            value: s.totalCollectedThisMonth,
            icon: Icons.attach_money_rounded,
            color: AppColors.success,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: l.outstandingBalance,
            value: s.totalOutstandingThisMonth,
            icon: Icons.warning_amber_rounded,
            color: AppColors.warning,
          ),
        ),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        Expanded(
          child: _StatCard(
            label: l.totalExpenses,
            value: s.totalExpenses,
            icon: Icons.receipt_long_rounded,
            color: AppColors.danger,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: l.netAmount,
            value: s.netAmount,
            icon: Icons.account_balance_rounded,
            color: AppColors.primary,
          ),
        ),
      ]),
    ]);
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final double value;
  final IconData icon;
  final Color color;
  const _StatCard(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: AppColors.cardGradient,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25), width: 1),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (_, v, __) => Text(
              NumFormat.fmt(v),
              style: TextStyle(
                  color: color, fontSize: 22, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─── Financial Row (horizontal scroll) ───────────────────────────────────────
class _FinancialRow extends StatelessWidget {
  final dynamic s;
  final AppLocalizations l;
  const _FinancialRow({required this.s, required this.l});

  @override
  Widget build(BuildContext context) {
    final chips = [
      (l.totalCollected,    s.totalCollectedThisMonth, Icons.attach_money_rounded,        AppColors.success),
      (l.commission,        s.commission,              Icons.percent_rounded,              Colors.purple),
      (l.totalExpenses,     s.totalExpenses,           Icons.receipt_long_rounded,         AppColors.danger),
      (l.netAmount,         s.netAmount,               Icons.account_balance_rounded,      AppColors.primary),
      (l.depositedAmount,   s.depositedAmount,         Icons.savings_rounded,              AppColors.secondary),
      (l.leftAmount,        s.leftAmount,              Icons.account_balance_wallet_rounded,
          s.leftAmount >= 0 ? AppColors.success : AppColors.danger),
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (_, i) => _FinancialChip(
          label:  chips[i].$1,
          amount: chips[i].$2,
          icon:   chips[i].$3,
          color:  chips[i].$4,
        ),
      ),
    );
  }
}

class _FinancialChip extends StatelessWidget {
  final String label;
  final double amount;
  final IconData icon;
  final Color color;
  const _FinancialChip(
      {required this.label,
      required this.amount,
      required this.icon,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: AppColors.cardGradient,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 6),
          Text(
            NumFormat.fmt(amount),
            style: TextStyle(
                color: color, fontSize: 16, fontWeight: FontWeight.w800),
          ),
          Text(label,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45), fontSize: 11),
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

// ─── Recent Payment Tile ──────────────────────────────────────────────────────
class _PaymentTile extends StatelessWidget {
  final dynamic payment;
  final AppLocalizations l;
  final bool isArabic;
  final int index;

  const _PaymentTile({
    required this.payment,
    required this.l,
    required this.isArabic,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    final name = (payment.renterName ?? '') as String;
    final colors = AppColors.avatarGradient(name);
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    final monthLabel = AppDateUtils.formatMonthYear(
        payment.paymentMonth, payment.paymentYear,
        arabic: isArabic);

    final delay = Duration(milliseconds: 50 + index * 60);

    return FutureBuilder(
      future: Future.delayed(delay),
      builder: (_, snap) {
        final visible = snap.connectionState == ConnectionState.done;
        return AnimatedOpacity(
          opacity: visible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 400),
          child: AnimatedSlide(
            offset: visible ? Offset.zero : const Offset(0, 0.2),
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOut,
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: AlignmentDirectional.topStart,
                  end: AlignmentDirectional.bottomEnd,
                  colors: AppColors.cardGradient,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
                boxShadow: AppColors.cardShadow,
              ),
              child: Row(children: [
                // Gradient avatar
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: AlignmentDirectional.topStart,
                      end: AlignmentDirectional.bottomEnd,
                      colors: colors,
                    ),
                    borderRadius: BorderRadius.circular(13),
                    boxShadow: [
                      BoxShadow(
                        color: colors[0].withValues(alpha: 0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(initial,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 18)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name,
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(monthLabel,
                          style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.45),
                              fontSize: 12)),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                        color: AppColors.success.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    NumFormat.fmt(payment.amountPaid as double),
                    style: const TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w700,
                        fontSize: 14),
                  ),
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}
