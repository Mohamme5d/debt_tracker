import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/monthly_deposit_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/list_card_widgets.dart';
import '../../core/utils/date_utils.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/num_format.dart';

class DepositListScreen extends StatefulWidget {
  const DepositListScreen({super.key});

  @override
  State<DepositListScreen> createState() => _DepositListScreenState();
}

class _DepositListScreenState extends State<DepositListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MonthlyDepositProvider>().load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isArabic = context.watch<LocaleProvider>().isArabic;
    final isOwner = context.watch<AuthProvider>().isOwner;

    return Consumer<MonthlyDepositProvider>(
      builder: (context, provider, _) => Scaffold(
        appBar: AppBar(title: Text(l.deposits)),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            await context.push('/deposits/new');
            provider.load();
          },
          icon: const Icon(Icons.add),
          label: Text(l.add),
          backgroundColor: AppColors.secondary,
          foregroundColor: Colors.white,
        ),
        body: provider.loading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.secondary))
            : provider.deposits.isEmpty
                ? EmptyListState(l.noData, Icons.savings_rounded)
                : RefreshIndicator(
                    color: AppColors.secondary,
                    backgroundColor: AppColors.surface,
                    onRefresh: provider.load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
                      itemCount: provider.deposits.length,
                      itemBuilder: (context, i) {
                        final d = provider.deposits[i];
                        final label = AppDateUtils.formatMonthYear(
                            d.depositMonth, d.depositYear,
                            arabic: isArabic);

                        return AnimatedListItem(
                          index: i,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: SwipeCard(
                              onEdit: () async {
                                await context.push('/deposits/edit/${d.id}');
                                provider.load();
                              },
                              onDelete: isOwner
                                  ? () async {
                                      if (await showConfirmDialog(context)) {
                                        if (!context.mounted) return;
                                        await provider.remove(d.id!);
                                      }
                                    }
                                  : null,
                              editLabel: l.edit,
                              deleteLabel: l.delete,
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Row(children: [
                                  LeadingIcon(
                                    icon: Icons.savings_rounded,
                                    accentColor: AppColors.secondary,
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(children: [
                                          Expanded(
                                            child: Text(label,
                                                style: const TextStyle(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w700,
                                                    fontSize: 15)),
                                          ),
                                          _statusBadge(d.status),
                                        ]),
                                        if (d.notes != null) ...[
                                          const SizedBox(height: 4),
                                          Text(d.notes!,
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(alpha: 0.45),
                                                  fontSize: 12)),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        NumFormat.fmt(d.amount),
                                        style: const TextStyle(
                                            color: AppColors.secondary,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 18),
                                      ),
                                      Text('SAR',
                                          style: TextStyle(
                                              color: Colors.white
                                                  .withValues(alpha: 0.3),
                                              fontSize: 10)),
                                    ],
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
