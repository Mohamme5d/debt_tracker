import 'package:flutter/material.dart';
import '../models/rent_payment.dart';
import '../services/api/rent_payment_api_service.dart';

class RentPaymentProvider extends ChangeNotifier {
  final _api = RentPaymentApiService();
  List<RentPayment> _payments = [];
  bool _loading = false;
  String? _error;

  List<RentPayment> get payments => _payments;
  bool get loading => _loading;
  String? get error => _error;

  Future<void> load({int? month, int? year}) async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      final result = await _api.getAll(month: month, year: year, pageSize: 200);
      _payments = result.items;
    } catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Fetches a paged result with full filter/sort/pagination support.
  Future<PagedResult<RentPayment>> fetchPaged({
    int? month,
    int? year,
    String? renterId,
    String? apartmentId,
    String? status,
    String sortBy = 'period',
    String sortDir = 'desc',
    int page = 1,
    int pageSize = 15,
  }) =>
      _api.getAll(
        month: month,
        year: year,
        renterId: renterId,
        apartmentId: apartmentId,
        status: status,
        sortBy: sortBy,
        sortDir: sortDir,
        page: page,
        pageSize: pageSize,
      );

  /// Returns 'duplicate' if conflict (409), 'ok' on success, error string otherwise
  Future<String> add(RentPayment payment) async {
    try {
      await _api.create(payment);
      await load();
      return 'ok';
    } catch (e) {
      final msg = e.toString();
      if (msg.contains('409') || msg.contains('Conflict')) return 'duplicate';
      _error = msg;
      notifyListeners();
      return msg;
    }
  }

  Future<bool> edit(RentPayment payment) async {
    try {
      await _api.update(payment.id!, payment);
      await load();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> remove(String id) async {
    try {
      await _api.delete(id);
      await load();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<List<RentPayment>> generateMonth(int month, int year) async {
    final result = await _api.generateMonth(month, year);
    await load();
    return result;
  }

  Future<List<int>> getDistinctYears() async {
    if (_payments.isEmpty) await load();
    final years = _payments.map((p) => p.paymentYear).toSet().toList()..sort();
    if (years.isEmpty) years.add(DateTime.now().year);
    return years;
  }

  Future<List<RentPayment>> getByMonthYear(int month, int year) async {
    return _fetchAll(month: month, year: year);
  }

  Future<List<RentPayment>> getByRenter(String renterId) async {
    return _fetchAll(renterId: renterId);
  }

  Future<List<RentPayment>> getByApartment(String apartmentId) async {
    return _fetchAll(apartmentId: apartmentId);
  }

  Future<List<Map<String, dynamic>>> getAllMonthlySummaries() async {
    final all = await _fetchAll();
    final totals = <String, double>{};
    final order = <String>[];
    for (final p in all) {
      final key = '${p.paymentYear}-${p.paymentMonth.toString().padLeft(2, '0')}';
      totals[key] = (totals[key] ?? 0.0) + p.amountPaid;
      if (!order.contains(key)) order.add(key);
    }
    order.sort();
    return order.map((key) {
      final parts = key.split('-');
      return {
        'payment_year': int.parse(parts[0]),
        'payment_month': int.parse(parts[1]),
        'total_collected': totals[key] ?? 0.0,
      };
    }).toList();
  }

  Future<double> getPreviousOutstandingByApartment(String apartmentId, int month, int year) async {
    final all = await _fetchAll(apartmentId: apartmentId);
    final prev = all.where((p) =>
      p.paymentYear < year || (p.paymentYear == year && p.paymentMonth < month)
    ).toList();
    if (prev.isEmpty) return 0.0;
    prev.sort((a, b) {
      final ak = a.paymentYear * 100 + a.paymentMonth;
      final bk = b.paymentYear * 100 + b.paymentMonth;
      return bk.compareTo(ak);
    });
    return prev.first.outstandingAfter;
  }

  /// Fetches all pages for the given filters, returning a flat list.
  Future<List<RentPayment>> _fetchAll({
    int? month,
    int? year,
    String? renterId,
    String? apartmentId,
  }) async {
    const batchSize = 200;
    final first = await _api.getAll(
      month: month, year: year, renterId: renterId, apartmentId: apartmentId,
      pageSize: batchSize, page: 1, sortBy: 'period', sortDir: 'asc',
    );
    final all = List<RentPayment>.from(first.items);
    final totalPages = (first.totalCount / batchSize).ceil();
    for (int p = 2; p <= totalPages; p++) {
      final next = await _api.getAll(
        month: month, year: year, renterId: renterId, apartmentId: apartmentId,
        pageSize: batchSize, page: p, sortBy: 'period', sortDir: 'asc',
      );
      all.addAll(next.items);
    }
    return all;
  }
}
