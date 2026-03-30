import 'package:flutter/material.dart';
import '../models/rent_payment.dart';
import '../services/api/dashboard_api_service.dart';

class DashboardSummary {
  final int totalApartments;
  final int totalRenters;
  final double totalCollectedThisMonth;
  final double totalOutstandingThisMonth;
  final double commission;
  final double totalExpenses;
  final double netAmount;
  final double depositedAmount;
  final double leftAmount;
  final List<RentPayment> recentPayments;

  DashboardSummary({
    required this.totalApartments,
    required this.totalRenters,
    required this.totalCollectedThisMonth,
    required this.totalOutstandingThisMonth,
    required this.commission,
    required this.totalExpenses,
    required this.netAmount,
    required this.depositedAmount,
    required this.leftAmount,
    required this.recentPayments,
  });
}

class DashboardProvider extends ChangeNotifier {
  final _api = DashboardApiService();

  DashboardSummary? _summary;
  bool _loading = false;
  String? _error;
  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  DashboardSummary? get summary => _summary;
  bool get loading => _loading;
  String? get error => _error;
  int get selectedMonth => _selectedMonth;
  int get selectedYear => _selectedYear;

  void setMonthYear(int month, int year) {
    _selectedMonth = month;
    _selectedYear = year;
    load();
  }

  Future<void> load() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final results = await Future.wait([
        _api.getStats(),
        _api.getMonthlyReport(_selectedMonth, _selectedYear),
      ]);
      final stats = results[0];
      final monthly = results[1];

      final totalCollected = (monthly['totalRentCollected'] as num?)?.toDouble() ?? 0.0;
      final totalOutstanding = (monthly['totalOutstanding'] as num?)?.toDouble() ?? 0.0;
      final totalExpenses = (monthly['totalExpenses'] as num?)?.toDouble() ?? 0.0;
      final depositedAmount = (monthly['totalDeposit'] as num?)?.toDouble() ?? 0.0;
      final commission = totalCollected * 0.10;
      final netAmount = totalCollected - commission - totalExpenses;
      final leftAmount = netAmount - depositedAmount;

      // Map recent payments from monthly report
      final rawPayments = (monthly['payments'] as List<dynamic>?) ?? [];
      final recentPayments = rawPayments.take(5).map((p) {
        final m = p as Map<String, dynamic>;
        return RentPayment.fromJson({
          'apartmentId': m['apartmentId'] ?? '',
          'apartmentName': m['apartmentName'] ?? '',
          'renterName': m['renterName'],
          'paymentMonth': _selectedMonth,
          'paymentYear': _selectedYear,
          'rentAmount': m['rentAmount'] ?? 0,
          'outstandingBefore': 0,
          'amountPaid': m['amountPaid'] ?? 0,
          'outstandingAfter': m['outstanding'] ?? 0,
        });
      }).toList();

      _summary = DashboardSummary(
        totalApartments: (stats['totalApartments'] as num?)?.toInt() ?? 0,
        totalRenters: (stats['totalRenters'] as num?)?.toInt() ?? 0,
        totalCollectedThisMonth: totalCollected,
        totalOutstandingThisMonth: totalOutstanding,
        commission: commission,
        totalExpenses: totalExpenses,
        netAmount: netAmount,
        depositedAmount: depositedAmount,
        leftAmount: leftAmount,
        recentPayments: recentPayments,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }
}
