import '../core/database/database_helper.dart';
import '../models/renter.dart';

class RenterRepository {
  final _db = DatabaseHelper();

  Future<List<Renter>> getAll() async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT r.*, a.name AS apartment_name
      FROM renters r
      LEFT JOIN apartments a ON r.apartment_id = a.id
      ORDER BY r.name ASC
    ''');
    return maps.map(Renter.fromMap).toList();
  }

  Future<List<Renter>> getActive() async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT r.*, a.name AS apartment_name
      FROM renters r
      LEFT JOIN apartments a ON r.apartment_id = a.id
      WHERE r.is_active = 1
      ORDER BY r.name ASC
    ''');
    return maps.map(Renter.fromMap).toList();
  }

  Future<List<Renter>> getByApartment(int apartmentId) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT r.*, a.name AS apartment_name
      FROM renters r
      LEFT JOIN apartments a ON r.apartment_id = a.id
      WHERE r.apartment_id = ?
      ORDER BY r.name ASC
    ''', [apartmentId]);
    return maps.map(Renter.fromMap).toList();
  }

  Future<Renter?> getById(int id) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT r.*, a.name AS apartment_name
      FROM renters r
      LEFT JOIN apartments a ON r.apartment_id = a.id
      WHERE r.id = ?
    ''', [id]);
    if (maps.isEmpty) return null;
    return Renter.fromMap(maps.first);
  }

  Future<int> insert(Renter renter) async {
    final db = await _db.database;
    return db.insert('renters', renter.toMap());
  }

  Future<int> update(Renter renter) async {
    final db = await _db.database;
    return db.update('renters', renter.toMap(),
        where: 'id = ?', whereArgs: [renter.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('renters', where: 'id = ?', whereArgs: [id]);
  }
}
