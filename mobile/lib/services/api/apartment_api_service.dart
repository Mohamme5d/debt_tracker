import '../../models/apartment.dart';
import 'api_client.dart';

class ApartmentApiService {
  final _client = ApiClient();

  Future<List<Apartment>> getAll() async {
    final resp = await _client.dio.get('/apartments');
    return (resp.data as List).map((e) => Apartment.fromJson(e)).toList();
  }

  Future<Apartment> create(Apartment apartment) async {
    final resp = await _client.dio.post('/apartments', data: apartment.toJson());
    return Apartment.fromJson(resp.data);
  }

  Future<Apartment> update(String id, Apartment apartment) async {
    final resp = await _client.dio.put('/apartments/$id', data: apartment.toJson());
    return Apartment.fromJson(resp.data);
  }

  Future<void> delete(String id) async {
    await _client.dio.delete('/apartments/$id');
  }
}
