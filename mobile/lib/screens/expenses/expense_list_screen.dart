import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/expense_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/month_year_picker.dart';
import '../../widgets/common/list_card_widgets.dart';
import '../../models/expense.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/num_format.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  int? _filterMonth;   // null = all months
  int? _filterYear;
  List<Expense> _expenses = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _load();
      context.read<ExpenseProvider>().addListener(_onProviderChanged);
    });
  }

  void _onProviderChanged() {
    if (!mounted) return;
    if (_filterMonth == null) {
      // Provider already finished loading — just read its updated list
      setState(() => _expenses = context.read<ExpenseProvider>().expenses);
    } else {
      _load();
    }
  }

  @override
  void dispose() {
    context.read<ExpenseProvider>().removeListener(_onProviderChanged);
    super.dispose();
  }

  Future<void> _load() async {
    if (!mounted) return;
    setState(() => _loading = true);
    final provider = context.read<ExpenseProvider>();
    if (_filterMonth != null && _filterYear != null) {
      _expenses = await provider.getByMonthYear(_filterMonth!, _filterYear!);
    } else {
      await provider.load();
      _expenses = provider.expenses;
    }
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isOwner = context.watch<AuthProvider>().isOwner;
    final total = _expenses.fold<double>(0, (s, e) => s + e.amount);

    return Scaffold(
      appBar: AppBar(
        title: Text(l.expenses),
        actions: [
          if (_expenses.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.danger.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.danger.withValues(alpha: 0.3)),
                ),
                child: Text(
                  NumFormat.fmt(total),
                  style: const TextStyle(
                      color: AppColors.danger,
                      fontWeight: FontWeight.w800,
                      fontSize: 14),
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await context.push('/expenses/new');
          _load();
        },
        icon: const Icon(Icons.add),
        label: Text(l.add),
        backgroundColor: AppColors.danger,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _filterMonth == null
                      ? Text('كل الأشهر / All Months',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.7)))
                      : MonthYearPicker(
                          initialMonth: _filterMonth!,
                          initialYear: _filterYear!,
                          onChanged: (mv) {
                            setState(() {
                              _filterMonth = mv.$1;
                              _filterYear = mv.$2;
                            });
                            _load();
                          },
                        ),
                ),
                if (_filterMonth == null)
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _filterMonth = DateTime.now().month;
                        _filterYear = DateTime.now().year;
                      });
                      _load();
                    },
                    child: const Text('فلتر / Filter'),
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.clear, color: AppColors.textSecondary, size: 20),
                    tooltip: 'Show all',
                    onPressed: () {
                      setState(() {
                        _filterMonth = null;
                        _filterYear = null;
                      });
                      _load();
                    },
                  ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(
                    child:
                        CircularProgressIndicator(color: AppColors.danger))
                : _expenses.isEmpty
                    ? EmptyListState(l.noData, Icons.receipt_long_rounded)
                    : RefreshIndicator(
                        color: AppColors.danger,
                        backgroundColor: AppColors.surface,
                        onRefresh: _load,
                        child: ListView.builder(
                          padding:
                              const EdgeInsets.fromLTRB(16, 8, 16, 100),
                          itemCount: _expenses.length,
                          itemBuilder: (context, i) {
                            final e = _expenses[i];
                            return AnimatedListItem(
                              index: i,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: SwipeCard(
                                  onEdit: () async {
                                    await context
                                        .push('/expenses/edit/${e.id}');
                                    _load();
                                  },
                                  onDelete: isOwner
                                      ? () async {
                                          if (await showConfirmDialog(context)) {
                                            if (!context.mounted) return;
                                            await context
                                                .read<ExpenseProvider>()
                                                .remove(e.id!);
                                            _load();
                                          }
                                        }
                                      : null,
                                  editLabel: l.edit,
                                  deleteLabel: l.delete,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(children: [
                                      LeadingIcon(
                                        icon: Icons.receipt_long_rounded,
                                        accentColor: AppColors.danger,
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              Expanded(
                                                child: Text(e.description,
                                                    style: const TextStyle(
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        fontSize: 15)),
                                              ),
                                              _statusBadge(e.status),
                                            ]),
                                            const SizedBox(height: 4),
                                            Text(
                                              '${e.expenseDate}${e.category != null ? ' · ${e.category}' : ''}',
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withValues(
                                                          alpha: 0.45),
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Text(
                                        NumFormat.fmt(e.amount),
                                        style: const TextStyle(
                                            color: AppColors.danger,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 17),
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
