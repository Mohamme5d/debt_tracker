import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'database_schema.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    if (kIsWeb) {
      // Web: uses databaseFactoryFfiWeb (set in main.dart)
      return openDatabase(
        DatabaseSchema.dbName,
        version: DatabaseSchema.version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, DatabaseSchema.dbName);
      return openDatabase(
        path,
        version: DatabaseSchema.version,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute(DatabaseSchema.createApartments);
    await db.execute(DatabaseSchema.createRenters);
    await db.execute(DatabaseSchema.createRentPayments);
    await db.execute(DatabaseSchema.createExpenses);
    await db.execute(DatabaseSchema.createMonthlyDeposits);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Recreate rent_payments: nullable renter_id, is_vacant, new UNIQUE
      await db.execute(
          'ALTER TABLE rent_payments RENAME TO rent_payments_v1');
      await db.execute(DatabaseSchema.createRentPayments);
      await db.execute('''
        INSERT OR IGNORE INTO rent_payments
          (id, renter_id, apartment_id, payment_month, payment_year,
           rent_amount, outstanding_before, amount_paid, outstanding_after,
           is_vacant, notes, created_at)
        SELECT id, renter_id, apartment_id, payment_month, payment_year,
               rent_amount, outstanding_before, amount_paid, outstanding_after,
               0, notes, created_at
        FROM rent_payments_v1
      ''');
      await db.execute('DROP TABLE rent_payments_v1');
      // Create tables that didn't exist in v1
      await db.execute(DatabaseSchema.createExpenses);
      await db.execute(DatabaseSchema.createMonthlyDeposits);
    }
    if (oldVersion < 3) {
      // Ensure expenses and monthly_deposits exist on devices already at v2
      await db.execute(DatabaseSchema.createExpenses);
      await db.execute(DatabaseSchema.createMonthlyDeposits);
    }
    if (oldVersion < 4) {
      // Seed historical expenses and deposits from 2023-Rents.xlsx
      await _seedHistoricalData(db);
    }
    if (oldVersion < 5) {
      // Seed 2025-2026 expenses and deposits from All sheet
      await _seed2025Data(db);
    }
  }

  Future<void> _seedHistoricalData(Database db) async {
    // Expenses: month, year, amount (from Excel 2023-Rents.xlsx)
    const expenses = [
      [5, 2023, 260000.0],
      [7, 2023, 25000.0],
      [8, 2023, 25000.0],
      [9, 2023, 75000.0],
      [10, 2023, 27500.0],
      [11, 2023, 25000.0],
      [12, 2023, 25000.0],
      [1, 2024, 25000.0],
      [2, 2024, 25000.0],
      [3, 2024, 148000.0],
      [4, 2024, 25000.0],
      [5, 2024, 25000.0],
      [6, 2024, 308000.0],
      [7, 2024, 25000.0],
      [8, 2024, 27500.0],
      [9, 2024, 25000.0],
      [10, 2024, 105000.0],
      [11, 2024, 111000.0],
      [12, 2024, 45000.0],
    ];

    // Deposits: month, year, amount
    const deposits = [
      [4, 2023, 193500.0],
      [5, 2023, 135500.0],
      [6, 2023, 25000.0],
      [7, 2023, 118000.0],
      [8, 2023, 222000.0],
      [9, 2023, 164500.0],
      [10, 2023, 274000.0],
      [11, 2023, 274000.0],
      [12, 2023, 274000.0],
      [1, 2024, 272000.0],
      [2, 2024, 281000.0],
      [3, 2024, 153500.0],
      [4, 2024, 271500.0],
      [5, 2024, 461500.0],
      [8, 2024, 350500.0],
      [9, 2024, 303000.0],
      [10, 2024, 303000.0],
      [11, 2024, 374000.0],
      [12, 2024, 387000.0],
    ];

    final now = DateTime.now().toIso8601String();

    for (final e in expenses) {
      final month = e[0] as int;
      final year = e[1] as int;
      final amount = e[2] as double;
      final existing = await db.query(
        'expenses',
        where: 'month = ? AND year = ?',
        whereArgs: [month, year],
        limit: 1,
      );
      if (existing.isEmpty) {
        final date =
            '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-01';
        await db.insert('expenses', {
          'description': 'مصاريف',
          'amount': amount,
          'expense_date': date,
          'month': month,
          'year': year,
          'notes': 'استيراد تاريخي',
          'created_at': now,
        });
      }
    }

    for (final d in deposits) {
      final month = d[0] as int;
      final year = d[1] as int;
      final amount = d[2] as double;
      await db.insert(
        'monthly_deposits',
        {
          'deposit_month': month,
          'deposit_year': year,
          'amount': amount,
          'notes': 'استيراد تاريخي',
          'created_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> _seed2025Data(Database db) async {
    // From All sheet: 1-2025 through 2-2026
    const expenses = [
      [1, 2025, 490000.0],
      [2, 2025, 284000.0],
      [3, 2025, 240000.0],
      [4, 2025, 418500.0],
      [5, 2025, 351500.0],
      [6, 2025, 160000.0],
      [7, 2025, 110500.0],
      [8, 2025, 110500.0],
      [9, 2025, 133000.0],
      [10, 2025, 70000.0],
      [11, 2025, 47000.0],
      [12, 2025, 45000.0],
      [1, 2026, 45000.0],
      [2, 2026, 320000.0],
    ];

    const deposits = [
      [2, 2025, 94500.0],
      [3, 2025, 193000.0],
      [6, 2025, 369500.0],
      [7, 2025, 398750.0],
      [8, 2025, 398750.0],
      [9, 2025, 371000.0],
      [10, 2025, 430050.0],
      [11, 2025, 432165.0],
      [12, 2025, 485940.0],
      [1, 2026, 432062.07],
      [2, 2026, 163000.0],
    ];

    final now = DateTime.now().toIso8601String();

    for (final e in expenses) {
      final month = e[0] as int;
      final year = e[1] as int;
      final amount = e[2] as double;
      final existing = await db.query(
        'expenses',
        where: 'month = ? AND year = ?',
        whereArgs: [month, year],
        limit: 1,
      );
      if (existing.isEmpty) {
        final date =
            '${year.toString().padLeft(4, '0')}-${month.toString().padLeft(2, '0')}-01';
        await db.insert('expenses', {
          'description': 'مصاريف',
          'amount': amount,
          'expense_date': date,
          'month': month,
          'year': year,
          'notes': 'استيراد تاريخي',
          'created_at': now,
        });
      }
    }

    for (final d in deposits) {
      final month = d[0] as int;
      final year = d[1] as int;
      final amount = d[2] as double;
      await db.insert(
        'monthly_deposits',
        {
          'deposit_month': month,
          'deposit_year': year,
          'amount': amount,
          'notes': 'استيراد تاريخي',
          'created_at': now,
        },
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
