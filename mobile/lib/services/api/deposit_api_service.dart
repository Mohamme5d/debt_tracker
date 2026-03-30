import '../../models/monthly_deposit.dart';
import 'api_client.dart';

class DepositApiService {
  final _client = ApiClient();

  Future<List<MonthlyDeposit>> getAll() async {
    final resp = await _client.dio.get('/deposits');
    return (resp.data as List).map((e) => MonthlyDeposit.fromJson(e)).toList();
  }

  Future<MonthlyDeposit> create(MonthlyDeposit deposit) async {
    final resp = await _client.dio.post('/deposits', data: deposit.toJson());
    return MonthlyDeposit.fromJson(resp.data);
  }

  Future<MonthlyDeposit> update(String id, MonthlyDeposit deposit) async {
    final resp = await _client.dio.put('/deposits/$id', data: deposit.toJson());
    return MonthlyDeposit.fromJson(resp.data);
  }

  Future<void> delete(String id) async {
    await _client.dio.delete('/deposits/$id');
  }
}
