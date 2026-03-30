import '../../models/renter.dart';
import 'api_client.dart';

class RenterApiService {
  final _client = ApiClient();

  Future<List<Renter>> getAll() async {
    final resp = await _client.dio.get('/renters');
    return (resp.data as List).map((e) => Renter.fromJson(e)).toList();
  }

  Future<Renter> create(Renter renter) async {
    final resp = await _client.dio.post('/renters', data: renter.toJson());
    return Renter.fromJson(resp.data);
  }

  Future<Renter> update(String id, Renter renter) async {
    final resp = await _client.dio.put('/renters/$id', data: renter.toJson());
    return Renter.fromJson(resp.data);
  }

  Future<void> delete(String id) async {
    await _client.dio.delete('/renters/$id');
  }
}
