import '../../models/expense.dart';
import 'api_client.dart';

class ExpenseApiService {
  final _client = ApiClient();

  Future<List<Expense>> getAll({int? month, int? year}) async {
    final resp = await _client.dio.get('/expenses', queryParameters: {
      if (month != null) 'month': month,
      if (year != null) 'year': year,
    });
    return (resp.data as List).map((e) => Expense.fromJson(e)).toList();
  }

  Future<Expense> create(Expense expense) async {
    final resp = await _client.dio.post('/expenses', data: expense.toJson());
    return Expense.fromJson(resp.data);
  }

  Future<Expense> update(String id, Expense expense) async {
    final resp = await _client.dio.put('/expenses/$id', data: expense.toJson());
    return Expense.fromJson(resp.data);
  }

  Future<void> delete(String id) async {
    await _client.dio.delete('/expenses/$id');
  }
}
