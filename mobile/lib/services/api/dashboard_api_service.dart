import 'api_client.dart';

class DashboardApiService {
  final _client = ApiClient();

  Future<Map<String, dynamic>> getStats() async {
    final resp = await _client.dio.get('/dashboard');
    return resp.data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> getMonthlyReport(int month, int year) async {
    final resp = await _client.dio.get('/reports/monthly', queryParameters: {
      'month': month,
      'year': year,
    });
    return resp.data as Map<String, dynamic>;
  }
}
