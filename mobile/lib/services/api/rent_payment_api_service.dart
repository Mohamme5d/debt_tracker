import '../../models/rent_payment.dart';
import 'api_client.dart';

class RentPaymentApiService {
  final _client = ApiClient();

  Future<List<RentPayment>> getAll({int? month, int? year}) async {
    final resp = await _client.dio.get('/payments', queryParameters: {
      if (month != null) 'month': month,
      if (year != null) 'year': year,
    });
    return (resp.data as List).map((e) => RentPayment.fromJson(e)).toList();
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
      'year': year,
    });
    return (resp.data as List).map((e) => RentPayment.fromJson(e)).toList();
  }
}
