class DatabaseSchema {
  static const int version = 5;
  static const String dbName = 'rent_manager.db';

  static const String createApartments = '''
    CREATE TABLE IF NOT EXISTS apartments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      address TEXT NOT NULL,
      description TEXT,
      notes TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    )
  ''';

  static const String createRenters = '''
    CREATE TABLE IF NOT EXISTS renters (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      phone TEXT,
      email TEXT,
      apartment_id INTEGER NOT NULL REFERENCES apartments(id) ON DELETE RESTRICT,
      monthly_rent REAL NOT NULL,
      start_date TEXT NOT NULL,
      is_active INTEGER NOT NULL DEFAULT 1,
      notes TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    )
  ''';

  static const String createRentPayments = '''
    CREATE TABLE IF NOT EXISTS rent_payments (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      renter_id INTEGER REFERENCES renters(id) ON DELETE CASCADE,
      apartment_id INTEGER NOT NULL REFERENCES apartments(id),
      payment_month INTEGER NOT NULL,
      payment_year INTEGER NOT NULL,
      rent_amount REAL NOT NULL,
      outstanding_before REAL NOT NULL DEFAULT 0.0,
      amount_paid REAL NOT NULL DEFAULT 0.0,
      outstanding_after REAL NOT NULL DEFAULT 0.0,
      is_vacant INTEGER NOT NULL DEFAULT 0,
      notes TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      UNIQUE(apartment_id, payment_month, payment_year)
    )
  ''';

  static const String createExpenses = '''
    CREATE TABLE IF NOT EXISTS expenses (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      description TEXT NOT NULL,
      amount REAL NOT NULL,
      expense_date TEXT NOT NULL,
      category TEXT,
      month INTEGER NOT NULL,
      year INTEGER NOT NULL,
      notes TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now'))
    )
  ''';

  static const String createMonthlyDeposits = '''
    CREATE TABLE IF NOT EXISTS monthly_deposits (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      deposit_month INTEGER NOT NULL,
      deposit_year INTEGER NOT NULL,
      amount REAL NOT NULL,
      notes TEXT,
      created_at TEXT NOT NULL DEFAULT (datetime('now')),
      UNIQUE(deposit_month, deposit_year)
    )
  ''';
}
