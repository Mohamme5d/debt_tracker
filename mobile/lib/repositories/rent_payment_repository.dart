import 'package:sqflite/sqflite.dart';
import '../core/database/database_helper.dart';
import '../models/rent_payment.dart';

class RentPaymentRepository {
  final _db = DatabaseHelper();

  Future<List<RentPayment>> getAll() async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT rp.*, r.name AS renter_name, a.name AS apartment_name
      FROM rent_payments rp
      LEFT JOIN renters r ON rp.renter_id = r.id
      LEFT JOIN apartments a ON rp.apartment_id = a.id
      ORDER BY rp.payment_year DESC, rp.payment_month DESC, r.name ASC
    ''');
    return maps.map(RentPayment.fromMap).toList();
  }

  Future<List<RentPayment>> getByMonthYear(int month, int year) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT rp.*, r.name AS renter_name, a.name AS apartment_name
      FROM rent_payments rp
      LEFT JOIN renters r ON rp.renter_id = r.id
      LEFT JOIN apartments a ON rp.apartment_id = a.id
      WHERE rp.payment_month = ? AND rp.payment_year = ?
      ORDER BY a.name ASC, r.name ASC
    ''', [month, year]);
    return maps.map(RentPayment.fromMap).toList();
  }

  Future<List<RentPayment>> getByRenter(int renterId) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT rp.*, r.name AS renter_name, a.name AS apartment_name
      FROM rent_payments rp
      LEFT JOIN renters r ON rp.renter_id = r.id
      LEFT JOIN apartments a ON rp.apartment_id = a.id
      WHERE rp.renter_id = ?
      ORDER BY rp.payment_year ASC, rp.payment_month ASC
    ''', [renterId]);
    return maps.map(RentPayment.fromMap).toList();
  }

  Future<List<RentPayment>> getByApartment(int apartmentId) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT rp.*, r.name AS renter_name, a.name AS apartment_name
      FROM rent_payments rp
      LEFT JOIN renters r ON rp.renter_id = r.id
      LEFT JOIN apartments a ON rp.apartment_id = a.id
      WHERE rp.apartment_id = ?
      ORDER BY rp.payment_year ASC, rp.payment_month ASC, r.name ASC
    ''', [apartmentId]);
    return maps.map(RentPayment.fromMap).toList();
  }

  /// Returns the outstanding_after from the most recent payment before this month/year for a renter
  Future<double> getPreviousOutstanding(
      int renterId, int month, int year) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT outstanding_after
      FROM rent_payments
      WHERE renter_id = ?
        AND (payment_year < ? OR (payment_year = ? AND payment_month < ?))
      ORDER BY payment_year DESC, payment_month DESC
      LIMIT 1
    ''', [renterId, year, year, month]);
    if (maps.isEmpty) return 0.0;
    return (maps.first['outstanding_after'] as num).toDouble();
  }

  /// Returns the outstanding_after from the most recent payment before this month/year for an apartment
  Future<double> getPreviousOutstandingByApartment(
      int apartmentId, int month, int year) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT outstanding_after
      FROM rent_payments
      WHERE apartment_id = ?
        AND (payment_year < ? OR (payment_year = ? AND payment_month < ?))
      ORDER BY payment_year DESC, payment_month DESC
      LIMIT 1
    ''', [apartmentId, year, year, month]);
    if (maps.isEmpty) return 0.0;
    return (maps.first['outstanding_after'] as num).toDouble();
  }

  Future<int> insert(RentPayment payment) async {
    final db = await _db.database;
    return db.insert('rent_payments', payment.toMap());
  }

  Future<int> update(RentPayment payment) async {
    final db = await _db.database;
    return db.update('rent_payments', payment.toMap(),
        where: 'id = ?', whereArgs: [payment.id]);
  }

  Future<int> delete(int id) async {
    final db = await _db.database;
    return db.delete('rent_payments', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<RentPayment>> getRecent(int limit) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT rp.*, r.name AS renter_name, a.name AS apartment_name
      FROM rent_payments rp
      LEFT JOIN renters r ON rp.renter_id = r.id
      LEFT JOIN apartments a ON rp.apartment_id = a.id
      ORDER BY rp.payment_year DESC, rp.payment_month DESC, rp.created_at DESC
      LIMIT ?
    ''', [limit]);
    return maps.map(RentPayment.fromMap).toList();
  }

  Future<Map<String, double>> getMonthlySummary(int month, int year) async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT
        SUM(amount_paid) AS total_collected,
        SUM(outstanding_after) AS total_outstanding
      FROM rent_payments
      WHERE payment_month = ? AND payment_year = ?
    ''', [month, year]);
    final row = maps.first;
    return {
      'total_collected': (row['total_collected'] as num?)?.toDouble() ?? 0.0,
      'total_outstanding': (row['total_outstanding'] as num?)?.toDouble() ?? 0.0,
    };
  }

  Future<List<int>> getDistinctYears() async {
    final db = await _db.database;
    final maps = await db.rawQuery('''
      SELECT DISTINCT payment_year
      FROM rent_payments
      ORDER BY payment_year ASC
    ''');
    return maps.map((m) => m['payment_year'] as int).toList();
  }

  Future<List<Map<String, dynamic>>> getAllMonthlySummaries() async {
    final db = await _db.database;
    return db.rawQuery('''
      SELECT payment_year, payment_month,
             SUM(amount_paid) AS total_collected,
             SUM(rent_amount) AS total_rent
      FROM rent_payments
      GROUP BY payment_year, payment_month
      ORDER BY payment_year ASC, payment_month ASC
    ''');
  }

  /// Inserts a batch of payments in a transaction, skipping duplicates.
  /// Returns count of actually inserted records.
  Future<int> insertBatch(List<RentPayment> payments) async {
    final db = await _db.database;
    int inserted = 0;
    await db.transaction((txn) async {
      for (final p in payments) {
        try {
          await txn.insert('rent_payments', p.toMap(),
              conflictAlgorithm: ConflictAlgorithm.abort);
          inserted++;
        } on DatabaseException catch (e) {
          if (!e.isUniqueConstraintError()) rethrow;
          // skip duplicate
        }
      }
    });
    return inserted;
  }
}
