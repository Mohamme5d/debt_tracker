import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/rent_payment_provider.dart';
import '../../providers/renter_provider.dart';
import '../../providers/apartment_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/common/confirm_dialog.dart';
import '../../widgets/common/month_year_picker.dart';
import '../../widgets/common/list_card_widgets.dart';
import '../../models/rent_payment.dart';
import '../../models/renter.dart';
import '../../models/apartment.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../core/utils/num_format.dart';
import '../../services/api/rent_payment_api_service.dart';

enum _SortField { period, renter, apartment, amount, status }

class RentPaymentListScreen extends StatefulWidget {
  const RentPaymentListScreen({super.key});

  @override
  State<RentPaymentListScreen> createState() => _RentPaymentListScreenState();
}

class _RentPaymentListScreenState extends State<RentPaymentListScreen> {
  // --- Server result state ---
  List<RentPayment> _payments = [];
  int _totalCount = 0;
  bool _loading = false;

  // --- Filters ---
  int? _filterMonth = DateTime.now().month;
  int? _filterYear  = DateTime.now().year;
  String? _filterRenterId;
  String? _filterApartmentId;
  String? _filterStatus;

  // --- Sort ---
  _SortField _sortField   = _SortField.period;
  bool       _sortAscending = false;

  // --- Pagination ---
  static const int _pageSize = 15;
  int _currentPage = 1;

  // --- UI state ---
  bool _filtersExpanded = false;

  bool get _hasActiveFilters =>
      _filterRenterId != null ||
      _filterApartmentId != null ||
      _filterStatus != null;

  int get _activeFilterCount {
    int c = 0;
    if (_filterRenterId != null) c++;
    if (_filterApartmentId != null) c++;
    if (_filterStatus != null) c++;
    return c;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RenterProvider>().load();
      context.read<ApartmentProvider>().load();
      _load();
    });
  }

  String get _sortByParam {
    switch (_sortField) {
      case _SortField.renter:    return 'renterName';
      case _SortField.apartment: return 'apartmentName';
      case _SortField.amount:    return 'amountPaid';
      case _SortField.status:    return 'status';
      case _SortField.period:    return 'period';
    }
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final result = await context.read<RentPaymentProvider>().fetchPaged(
        month:       _filterMonth,
        year:        _filterYear,
        renterId:    _filterRenterId,
        apartmentId: _filterApartmentId,
        status:      _filterStatus,
        sortBy:      _sortByParam,
        sortDir:     _sortAscending ? 'asc' : 'desc',
        page:        _currentPage,
        pageSize:    _pageSize,
      );
      if (mounted) {
        setState(() {
          _payments   = result.items;
          _totalCount = result.totalCount;
        });
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  int get _totalPages => (_totalCount / _pageSize).ceil().clamp(1, 9999);

  void _resetAndLoad() {
    setState(() => _currentPage = 1);
    _load();
  }

  Future<void> _generateMonth() async {
    final l = AppLocalizations.of(context)!;
    final activeRenters = context.read<RenterProvider>().activeRenters;
    final month = _filterMonth ?? DateTime.now().month;
    final year  = _filterYear ?? DateTime.now().year;
    final monthName = AppDateUtils.monthName(month);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.generatePaymentsTitle),
        content: Text('$monthName $year — ${activeRenters.length} ${l.active}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l.cancel)),
          ElevatedButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l.generatePayments)),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final created = await context.read<RentPaymentProvider>().generateMonth(month, year);
    final count = created.length;
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l.recordsCreated(count))),
    );
    _load();
  }

  void _showSortSheet(AppLocalizations l) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) {
          Widget tile(_SortField field, String label, IconData fieldIcon) {
            final isSelected = _sortField == field;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
              child: Material(
                color: isSelected
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    setState(() {
                      if (_sortField == field) {
                        _sortAscending = !_sortAscending;
                      } else {
                        _sortField = field;
                        _sortAscending = false;
                      }
                      _currentPage = 1;
                    });
                    setSheetState(() {});
                    _load();
                  },
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary.withValues(alpha: 0.2)
                                : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            fieldIcon,
                            size: 16,
                            color: isSelected
                                ? AppColors.primary
                                : Colors.white38,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            label,
                            style: TextStyle(
                              color: isSelected
                                  ? AppColors.primary
                                  : Colors.white70,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        if (isSelected)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  _sortAscending
                                      ? Icons.arrow_upward_rounded
                                      : Icons.arrow_downward_rounded,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 2),
                                Text(
                                  _sortAscending ? 'ASC' : 'DESC',
                                  style: const TextStyle(
                                    color: AppColors.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 6, bottom: 8),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                // Handle bar
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
                  child: Row(
                    children: [
                      const Icon(Icons.swap_vert_rounded,
                          color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        l.sortBy,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                tile(_SortField.period, l.sortByPeriod,
                    Icons.calendar_today_rounded),
                tile(_SortField.renter, l.sortByRenter,
                    Icons.person_rounded),
                tile(_SortField.apartment, l.sortByApartment,
                    Icons.apartment_rounded),
                tile(_SortField.amount, l.sortByAmount,
                    Icons.payments_rounded),
                tile(_SortField.status, l.sortByStatus,
                    Icons.flag_rounded),
              ]),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l         = AppLocalizations.of(context)!;
    final isOwner   = context.watch<AuthProvider>().isOwner;
    final renters   = context.watch<RenterProvider>().renters;
    final apartments = context.watch<ApartmentProvider>().apartments;
    final totalPages = _totalPages;

    return Scaffold(
      appBar: AppBar(
        title: Text(l.payments),
        actions: [
          IconButton(
            icon: Icon(
              Icons.sort_rounded,
              color: _sortField != _SortField.period || _sortAscending
                  ? AppColors.primary
                  : null,
            ),
            tooltip: l.sortBy,
            onPressed: () => _showSortSheet(l),
          ),
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
          // ── Modern Collapsible Filter Panel ──
          Container(
            margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              children: [
                // Month/Year picker
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: MonthYearPicker(
                    initialMonth: _filterMonth ?? DateTime.now().month,
                    initialYear:  _filterYear  ?? DateTime.now().year,
                    onChanged: (mv) {
                      setState(() { _filterMonth = mv.$1; _filterYear = mv.$2; });
                      _resetAndLoad();
                    },
                  ),
                ),

                // Expandable advanced filters
                InkWell(
                  borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
                  onTap: () => setState(() => _filtersExpanded = !_filtersExpanded),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Row(
                      children: [
                        Icon(Icons.tune_rounded,
                            size: 15,
                            color: _hasActiveFilters
                                ? AppColors.primary
                                : Colors.white38),
                        const SizedBox(width: 6),
                        Text(
                          l.filters,
                          style: TextStyle(
                            color: _hasActiveFilters
                                ? AppColors.primary
                                : Colors.white38,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (_activeFilterCount > 0) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              '$_activeFilterCount',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                        const Spacer(),
                        if (_hasActiveFilters)
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _filterRenterId = null;
                                _filterApartmentId = null;
                                _filterStatus = null;
                              });
                              _resetAndLoad();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: const Color(0xFFF43F5E).withValues(alpha: 0.12),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.close_rounded,
                                      size: 12, color: Color(0xFFF43F5E)),
                                  const SizedBox(width: 3),
                                  Text(
                                    l.clear,
                                    style: const TextStyle(
                                        color: Color(0xFFF43F5E),
                                        fontSize: 11,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        AnimatedRotation(
                          turns: _filtersExpanded ? 0.5 : 0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(Icons.expand_more_rounded,
                              size: 18, color: Colors.white38),
                        ),
                      ],
                    ),
                  ),
                ),

                // Filter dropdowns (animated)
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                    child: Row(children: [
                      Expanded(
                        child: _FilterDropdown<Renter>(
                          hint:      l.allRenters,
                          value:     renters.where((r) => r.id == _filterRenterId).firstOrNull,
                          items:     renters,
                          itemLabel: (r) => r.name,
                          icon:      Icons.person_rounded,
                          onChanged: (r) {
                            setState(() => _filterRenterId = r?.id);
                            _resetAndLoad();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _FilterDropdown<Apartment>(
                          hint:      l.allApartments,
                          value:     apartments.where((a) => a.id == _filterApartmentId).firstOrNull,
                          items:     apartments,
                          itemLabel: (a) => a.name,
                          icon:      Icons.apartment_rounded,
                          onChanged: (a) {
                            setState(() => _filterApartmentId = a?.id);
                            _resetAndLoad();
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      _StatusDropdown(
                        label:     l.allStatuses,
                        value:     _filterStatus,
                        onChanged: (v) {
                          setState(() => _filterStatus = v);
                          _resetAndLoad();
                        },
                      ),
                    ]),
                  ),
                  crossFadeState: _filtersExpanded
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 200),
                ),
              ],
            ),
          ),

          // Results count + active sort indicator
          if (!_loading && _totalCount > 0)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 2),
              child: Row(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_totalCount ${l.results}',
                    style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                const Spacer(),
                Text(
                  l.itemsRange(
                    (_currentPage - 1) * _pageSize + 1,
                    (_currentPage * _pageSize).clamp(0, _totalCount),
                    _totalCount,
                  ),
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 11),
                ),
              ]),
            ),

          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                : _payments.isEmpty
                    ? EmptyListState(l.noData, Icons.payment_rounded)
                    : RefreshIndicator(
                        color: AppColors.primary,
                        backgroundColor: AppColors.surface,
                        onRefresh: _load,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                          itemCount: _payments.length,
                          itemBuilder: (context, i) {
                            final p = _payments[i];
                            final hasBalance = p.outstandingAfter > 0;
                            final colors = AppColors.avatarGradient(p.renterName ?? '');

                            return AnimatedListItem(
                              index: i,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: SwipeCard(
                                  onEdit: () async {
                                    await context.push('/payments/edit/${p.id}');
                                    _load();
                                  },
                                  onDelete: isOwner
                                      ? () async {
                                          if (await showConfirmDialog(context)) {
                                            if (!context.mounted) return;
                                            await context.read<RentPaymentProvider>().remove(p.id!);
                                            _load();
                                          }
                                        }
                                      : null,
                                  editLabel:   l.edit,
                                  deleteLabel: l.delete,
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Row(children: [
                                      Container(
                                        width: 52, height: 52,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: AlignmentDirectional.topStart,
                                            end:   AlignmentDirectional.bottomEnd,
                                            colors: colors,
                                          ),
                                          borderRadius: BorderRadius.circular(14),
                                          boxShadow: [
                                            BoxShadow(
                                              color:      colors[0].withValues(alpha: 0.35),
                                              blurRadius: 8,
                                              offset:     const Offset(0, 3),
                                            ),
                                          ],
                                        ),
                                        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                                          Text(
                                            AppDateUtils.monthName(p.paymentMonth).substring(0, 3),
                                            style: const TextStyle(
                                                color: Colors.white, fontWeight: FontWeight.w800,
                                                fontSize: 13, height: 1),
                                          ),
                                          Text(
                                            '${p.paymentYear % 100}',
                                            style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.7),
                                                fontSize: 11, height: 1.4),
                                          ),
                                        ]),
                                      ),
                                      const SizedBox(width: 14),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(children: [
                                              Expanded(
                                                child: p.isVacant
                                                    ? Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(
                                                          color:  AppColors.warning.withValues(alpha: 0.15),
                                                          borderRadius: BorderRadius.circular(6),
                                                          border: Border.all(color: AppColors.warning.withValues(alpha: 0.4)),
                                                        ),
                                                        child: const Text('شاغرة / Vacant',
                                                            style: TextStyle(color: AppColors.warning, fontWeight: FontWeight.w700, fontSize: 13)),
                                                      )
                                                    : Text(p.renterName ?? '',
                                                        style: const TextStyle(
                                                            color: Colors.white, fontWeight: FontWeight.w700, fontSize: 15)),
                                              ),
                                              _statusBadge(p.status),
                                            ]),
                                            const SizedBox(height: 3),
                                            Text(p.apartmentName ?? '',
                                                style: TextStyle(
                                                    color: Colors.white.withValues(alpha: 0.45), fontSize: 12)),
                                            const SizedBox(height: 8),
                                            Row(children: [
                                              _AmountBadge(
                                                icon:   Icons.check_circle_rounded,
                                                amount: p.amountPaid,
                                                color:  AppColors.success,
                                              ),
                                              if (hasBalance) ...[
                                                const SizedBox(width: 8),
                                                _AmountBadge(
                                                  icon:   Icons.warning_rounded,
                                                  amount: p.outstandingAfter,
                                                  color:  AppColors.warning,
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

          // ── Modern Pagination ──
          if (!_loading && totalPages > 1)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                border: Border(top: BorderSide(color: AppColors.border)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _PaginationButton(
                    icon: Icons.chevron_left_rounded,
                    enabled: _currentPage > 1,
                    onTap: () {
                      setState(() => _currentPage--);
                      _load();
                    },
                  ),
                  const SizedBox(width: 8),
                  ..._buildPageIndicators(totalPages),
                  const SizedBox(width: 8),
                  _PaginationButton(
                    icon: Icons.chevron_right_rounded,
                    enabled: _currentPage < totalPages,
                    onTap: () {
                      setState(() => _currentPage++);
                      _load();
                    },
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  List<Widget> _buildPageIndicators(int totalPages) {
    final pages = <int>[];
    if (totalPages <= 5) {
      for (int i = 1; i <= totalPages; i++) pages.add(i);
    } else {
      pages.add(1);
      if (_currentPage > 3) pages.add(-1);
      for (int i = (_currentPage - 1).clamp(2, totalPages - 1);
          i <= (_currentPage + 1).clamp(2, totalPages - 1);
          i++) {
        pages.add(i);
      }
      if (_currentPage < totalPages - 2) pages.add(-1);
      pages.add(totalPages);
    }

    return pages.map((pg) {
      if (pg == -1) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 2),
          child: Text('…',
              style: TextStyle(color: Colors.white24, fontSize: 14)),
        );
      }
      final isActive = pg == _currentPage;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        child: GestureDetector(
          onTap: () {
            setState(() => _currentPage = pg);
            _load();
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 32,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isActive
                  ? AppColors.primary
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isActive
                    ? AppColors.primary
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              '$pg',
              style: TextStyle(
                color: isActive ? Colors.white : Colors.white54,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w400,
                fontSize: 13,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}

Widget _statusBadge(String? status) {
  if (status == null) return const SizedBox.shrink();
  final color = status == 'Approved'
      ? const Color(0xFF10B981)
      : status == 'Rejected'
          ? const Color(0xFFF43F5E)
          : const Color(0xFFF59E0B);
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

// Generic dropdown for filter chips
class _FilterDropdown<T> extends StatelessWidget {
  final String hint;
  final T? value;
  final List<T> items;
  final String Function(T) itemLabel;
  final void Function(T?) onChanged;
  final IconData? icon;

  const _FilterDropdown({
    required this.hint,
    required this.value,
    required this.items,
    required this.itemLabel,
    required this.onChanged,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<(bool, T?)>(
          context: context,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(icon ?? Icons.filter_list_rounded,
                    color: Colors.white38, size: 18),
                title: Text(hint,
                    style: const TextStyle(
                        color: Colors.white60, fontStyle: FontStyle.italic)),
                onTap: () => Navigator.pop(ctx, (true, null)),
              ),
              const Divider(color: Colors.white12, height: 1),
              ...items.map((item) {
                final isSelected =
                    value != null && itemLabel(value!) == itemLabel(item);
                return ListTile(
                  title: Text(
                    itemLabel(item),
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : Colors.white,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle_rounded,
                          color: AppColors.primary, size: 18)
                      : null,
                  onTap: () => Navigator.pop(ctx, (true, item)),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
        if (result != null && context.mounted) onChanged(result.$2);
      },
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: value != null
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: value != null
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Row(children: [
          if (icon != null) ...[
            Icon(icon,
                size: 14,
                color: value != null ? AppColors.primary : Colors.white30),
            const SizedBox(width: 5),
          ],
          Expanded(
            child: Text(
              value != null ? itemLabel(value!) : hint,
              style: TextStyle(
                color: value != null ? AppColors.primary : Colors.white38,
                fontSize: 12,
                fontWeight:
                    value != null ? FontWeight.w600 : FontWeight.normal,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (value != null)
            GestureDetector(
              onTap: () => onChanged(null),
              child: const Icon(Icons.close_rounded,
                  size: 14, color: AppColors.primary),
            )
          else
            const Icon(Icons.expand_more_rounded,
                size: 16, color: Colors.white38),
        ]),
      ),
    );
  }
}

class _StatusDropdown extends StatelessWidget {
  final String label;
  final String? value;
  final void Function(String?) onChanged;

  const _StatusDropdown(
      {required this.label, required this.value, required this.onChanged});

  static const _statusMeta = {
    'Draft':    (Color(0xFFF59E0B), Icons.schedule_rounded),
    'Approved': (Color(0xFF10B981), Icons.check_circle_rounded),
    'Rejected': (Color(0xFFF43F5E), Icons.cancel_rounded),
  };

  @override
  Widget build(BuildContext context) {
    final statuses = ['Draft', 'Approved', 'Rejected'];
    final isActive = value != null;

    return GestureDetector(
      onTap: () async {
        final result = await showModalBottomSheet<(bool, String?)>(
          context: context,
          backgroundColor: AppColors.surface,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (ctx) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36, height: 4,
                margin: const EdgeInsets.only(top: 10, bottom: 6),
                decoration: BoxDecoration(
                  color: Colors.white24,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.flag_rounded,
                    color: Colors.white38, size: 18),
                title: Text(label,
                    style: const TextStyle(
                        color: Colors.white60, fontStyle: FontStyle.italic)),
                onTap: () => Navigator.pop(ctx, (true, null)),
              ),
              const Divider(color: Colors.white12, height: 1),
              ...statuses.map((s) {
                final meta = _statusMeta[s]!;
                final isSelected = value == s;
                return ListTile(
                  leading: Icon(meta.$2,
                      color: isSelected ? meta.$1 : Colors.white30, size: 18),
                  title: Text(s,
                      style: TextStyle(
                        color: isSelected ? meta.$1 : Colors.white,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.normal,
                      )),
                  trailing: isSelected
                      ? Icon(Icons.check_circle_rounded,
                          color: meta.$1, size: 18)
                      : null,
                  onTap: () => Navigator.pop(ctx, (true, s)),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        );
        if (result != null && context.mounted) onChanged(result.$2);
      },
      child: Container(
        height: 38,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isActive
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.border,
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(Icons.flag_rounded,
              size: 14,
              color: isActive ? AppColors.primary : Colors.white30),
          const SizedBox(width: 4),
          Text(
            isActive ? value! : '•••',
            style: TextStyle(
              color: isActive ? AppColors.primary : Colors.white38,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(width: 2),
          if (isActive)
            GestureDetector(
              onTap: () => onChanged(null),
              child: const Icon(Icons.close_rounded,
                  size: 14, color: AppColors.primary),
            )
          else
            const Icon(Icons.expand_more_rounded,
                size: 14, color: Colors.white38),
        ]),
      ),
    );
  }
}

class _PaginationButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  const _PaginationButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 36,
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: enabled
                ? AppColors.primary.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.06),
          ),
        ),
        child: Icon(
          icon,
          size: 20,
          color: enabled ? AppColors.primary : Colors.white24,
        ),
      ),
    );
  }
}


