import '../../models/rent_payment.dart';
import 'api_client.dart';

class PagedResult<T> {
  final List<T> items;
  final int totalCount;
  final int page;
  final int pageSize;

  const PagedResult({
    required this.items,
    required this.totalCount,
    required this.page,
    required this.pageSize,
  });
}

class RentPaymentApiService {
  final _client = ApiClient();

  Future<PagedResult<RentPayment>> getAll({
    int? month,
    int? year,
    String? renterId,
    String? apartmentId,
    String? status,
    String sortBy = 'period',
    String sortDir = 'desc',
    int page = 1,
    int pageSize = 15,
  }) async {
    final resp = await _client.dio.get('/payments', queryParameters: {
      if (month != null && month > 0) 'month': month,
      if (year != null && year > 0)   'year':  year,
      if (renterId != null)           'renterId':    renterId,
      if (apartmentId != null)        'apartmentId': apartmentId,
      if (status != null)             'status':      status,
      'sortBy':   sortBy,
      'sortDir':  sortDir,
      'page':     page,
      'pageSize': pageSize,
    });
    final data = resp.data as Map<String, dynamic>;
    final items = (data['items'] as List)
        .map((e) => RentPayment.fromJson(e as Map<String, dynamic>))
        .toList();
    return PagedResult(
      items:      items,
      totalCount: data['totalCount'] as int,
      page:       data['page'] as int,
      pageSize:   data['pageSize'] as int,
    );
  }

  Future<RentPayment> create(RentPayment payment) async {
    final resp = await _client.dio.post('/payments', data: payment.toJson());
    return RentPayment.fromJson(resp.data);
  }

  Future<RentPayment> update(String id, RentPayment payment) async {
    final resp = await _client.dio.put('/payments/$id', data: payment.toJson());
    return RentPayment.fromJson(resp.data);
  }

  Future<void> delete(String id) async {
    await _client.dio.delete('/payments/$id');
  }

  Future<List<RentPayment>> generateMonth(int month, int year) async {
    final resp = await _client.dio.post('/payments/generate-month', data: {
      'month': month,
      'year':  year,
    });
    return (resp.data as List).map((e) => RentPayment.fromJson(e)).toList();
  }
}
