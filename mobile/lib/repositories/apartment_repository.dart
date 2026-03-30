import '../core/database/database_helper.dart';
import '../models/apartment.dart';

class ApartmentRepository {
  final _db = DatabaseHelper();

  Future<List<Apartment>> getAll() async {
    final db = await _db.database;
    final maps = await db.query('apartments', orderBy: 'name ASC');
    return maps.map(Apartment.fromMap).toList();
  }

  Future<Apartment?> getById(int id) async {
    final db = await _db.database;
    final maps = await db.query('apartments', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return Apartment.fromMap(maps.first);
  }

  Future<int> insert(Apartment apartment) async {
    final db = await _db.database;
    return db.insert('apartments', apartment.toMap());
  }

  Future<int> update(Apartment apartment) async {
    final db = await _db.database;
    return db.update('apartments', apartment.toMap(),
        where: 'id = ?', whereArgs: [apartment.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('apartments', where: 'id = ?', whereArgs: [id]);
  }
}
