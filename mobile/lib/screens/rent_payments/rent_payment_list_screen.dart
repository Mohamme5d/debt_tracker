import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/rent_payment_provider.dart';
import '../../providers/renter_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/month_year_picker.dart';
import '../../widgets/common/list_card_widgets.dart';
import '../../models/rent_payment.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/num_format.dart';

class RentPaymentListScreen extends StatefulWidget {
  const RentPaymentListScreen({super.key});

  @override
  State<RentPaymentListScreen> createState() => _RentPaymentListScreenState();
}

class _RentPaymentListScreenState extends State<RentPaymentListScreen> {
  int _filterMonth = DateTime.now().month;
  int _filterYear = DateTime.now().year;
  List<RentPayment> _payments = [];
  bool _loading = false;
  String _search = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    _payments = await context
        .read<RentPaymentProvider>()
        .getByMonthYear(_filterMonth, _filterYear);
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _generateMonth() async {
    final l = AppLocalizations.of(context)!;
    final activeRenters = context.read<RenterProvider>().activeRenters;
    final monthName = AppDateUtils.monthName(_filterMonth);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.generatePaymentsTitle),
        content: Text(
          '$monthName $_filterYear — ${activeRenters.length} ${l.active}',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l.cancel)),
          ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l.generatePayments)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final created = await context
        .read<RentPaymentProvider>()
        .generateMonth(_filterMonth, _filterYear);
    final count = created.length;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.recordsCreated(count))),
    );
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isOwner = context.watch<AuthProvider>().isOwner;
    final filtered = _payments
        .where((p) =>
            (p.renterName ?? '').toLowerCase().contains(_search.toLowerCase()) ||
            (p.apartmentName ?? '')
                .toLowerCase()
                .contains(_search.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(l.payments),
        actions: [
          IconButton(
            icon: const Icon(Icons.playlist_add_rounded),
            tooltip: l.generatePayments,
            onPressed: _generateMonth,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/payments/new');
          _load();
        },
        icon: const Icon(Icons.add),
        label: Text(l.add),
        backgroundColor: AppColors.secondary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Month filter
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: MonthYearPicker(
              initialMonth: _filterMonth,
              initialYear: _filterYear,
              onChanged: (mv) {
                setState(() {
                  _filterMonth = mv.$1;
                  _filterYear = mv.$2;
                });
                _load();
              },
            ),
          ),
          ListSearchBar(
            hint: l.searchRenter,
            onChanged: (v) => setState(() => _search = v),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.primary))
                : filtered.isEmpty
                    ? EmptyListState(l.noData, Icons.payment_rounded)
                    : RefreshIndicator(
                        color: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        onRefresh: _load,
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) {
                            final p = filtered[i];
                            final hasBalance = p.outstandingAfter > 0;
                            final colors =
                                AppColors.avatarGradient(p.renterName ?? '');

                            return AnimatedListItem(
                              index: i,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: SwipeCard(
                                  onEdit: () async {
                                    await context
                                        .push('/payments/edit/${p.id}');
                                    _load();
                                  },
                                  onDelete: isOwner
                                      ? () async {
                                          if (await showConfirmDialog(context)) {
                                            if (!context.mounted) return;
                                            await context
                                                .read<RentPaymentProvider>()
                                                .remove(p.id!);
                                            _load();
                                          }
                                        }
                                      : null,
                                  editLabel: l.edit,
                                  deleteLabel: l.delete,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(children: [
                                      // Month badge
                                      Container(
                                        width: 52,
                                        height: 52,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: AlignmentDirectional
                                                .topStart,
                                            end:
                                                AlignmentDirectional.bottomEnd,
                                            colors: colors,
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color: colors[0]
                                                  .withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset: const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppDateUtils.monthName(
                                                      p.paymentMonth)
                                                  .substring(0, 3),
                                              style: const TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 13,
                                                  height: 1),
                                            ),
                                            Text(
                                              '${p.paymentYear % 100}',
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.7),
                                                  fontSize: 11,
                                                  height: 1.4),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              Expanded(
                                                child: p.isVacant
                                                    ? Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color: AppColors.warning.withValues(alpha: 0.15),
                                                          borderRadius: BorderRadius.circular(6),
                                                          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                                                        ),
                                                        child: const Text('شاغرة / Vacant',
                                                            style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 13)),
                                                      )
                                                    : Text(p.renterName ?? '',
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: 15)),
                                              ),
                                              _statusBadge(p.status),
                                            ]),
                                            const SizedBox(height: 3),
                                            Text(p.apartmentName ?? '',
                                                style: TextStyle(
                                                    color: Colors.white
                                                        .withValues(alpha: 0.45),
                                                    fontSize: 12)),
                                            const SizedBox(height: 8),
                                            Row(children: [
                                              _AmountBadge(
                                                icon: Icons
                                                    .check_circle_rounded,
                                                amount: p.amountPaid,
                                                color: AppColors.success,
                                              ),
                                              if (hasBalance) ...[
                                                const SizedBox(width: 8),
                                                _AmountBadge(
                                                  icon:
                                                      Icons.warning_rounded,
                                                  amount:
                                                      p.outstandingAfter,
                                                  color: AppColors.warning,
                                                ),
                                              ],
                                            ]),
                                          ],
                                        ),
                                      ),
                                    ]),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}

Widget _statusBadge(String? status) {
  if (status == null) return const SizedBox.shrink();
  final color = status == 'Approved'
      ? const Color(0xFF10B981)
      : status == 'Rejected'
          ? const Color(0xFFF43F5E)
          : const Color(0xFFF59E0B); // Draft / Pending
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withValues(alpha: 0.35)),
    ),
    child: Text(
      status,
      style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w700),
    ),
  );
}

class _AmountBadge extends StatelessWidget {
  final IconData icon;
  final double amount;
  final Color color;

  const _AmountBadge(
      {required this.icon, required this.amount, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(NumFormat.fmt(amount),
              style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 12)),
        ],
      ),
    );
  }
}
