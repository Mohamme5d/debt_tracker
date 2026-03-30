import '../../models/rent_contract.dart';
import 'api_client.dart';

class RentContractApiService {
  final _client = ApiClient();

  Future<List<RentContract>> getAll() async {
    final resp = await _client.dio.get('/contracts');
    return (resp.data as List).map((e) => RentContract.fromJson(e)).toList();
  }

  Future<RentContract> create(RentContract contract) async {
    final resp = await _client.dio.post('/contracts', data: contract.toJson());
    return RentContract.fromJson(resp.data);
  }

  Future<RentContract> update(String id, RentContract contract) async {
    final resp = await _client.dio.put('/contracts/$id', data: contract.toJson());
    return RentContract.fromJson(resp.data);
  }

  Future<void> delete(String id) async {
    await _client.dio.delete('/contracts/$id');
  }
}
