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

  Future<List<RentPayment>> getByRenter(String renterId) async {
    final all = await _api.getAll();
    return all.where((p) => p.renterId == renterId).toList();
  }

  Future<List<RentPayment>> getByApartment(String apartmentId) async {
    final all = await _api.getAll();
    return all.where((p) => p.apartmentId == apartmentId).toList();
  }

  Future<List<Map<String, dynamic>>> getAllMonthlySummaries() async {
    final all = await _api.getAll();
    final seen = <String>{};
    final result = <Map<String, dynamic>>[];
    for (final p in all) {
      final key = '${p.paymentYear}-${p.paymentMonth}';
      if (seen.add(key)) {
        result.add({'payment_month': p.paymentMonth, 'payment_year': p.paymentYear});
      }
    }
    result.sort((a, b) {
      final aKey = a['payment_year'] * 100 + a['payment_month'] as int;
      final bKey = b['payment_year'] * 100 + b['payment_month'] as int;
      return aKey.compareTo(bKey);
    });
    return result;
  }

  Future<double> getPreviousOutstandingByApartment(String apartmentId, int month, int year) async {
    final all = await _api.getAll();
    final prev = all.where((p) =>
      p.apartmentId == apartmentId &&
      (p.paymentYear < year || (p.paymentYear == year && p.paymentMonth < month))
    ).toList();
    if (prev.isEmpty) return 0.0;
    prev.sort((a, b) {
      final ak = a.paymentYear * 100 + a.paymentMonth;
      final bk = b.paymentYear * 100 + b.paymentMonth;
      return bk.compareTo(ak);
    });
    return prev.first.outstandingAfter;
  }
}
