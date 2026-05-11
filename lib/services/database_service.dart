import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

/// Central database connection owner.
/// Manages schema creation, migrations, and provides the [Database] reference.
/// Does NOT implement repository interfaces — those are handled by focused DAOs.
class DatabaseService {
  Database? _database;

  /// Database schema version
  static const int _dbVersion = 6;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_tracker_v2.db');

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Users table
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        fullName TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        passwordHash TEXT NOT NULL,
        salt TEXT NOT NULL DEFAULT '',
        createdAt TEXT NOT NULL
      )
    ''');

    // Expenses table — scoped to user
    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        userId TEXT NOT NULL,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        date TEXT NOT NULL,
        note TEXT,
        createdAt TEXT NOT NULL,
        type TEXT NOT NULL DEFAULT 'expense',
        incomeCategory TEXT,
        FOREIGN KEY (userId) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');

    // OTP codes table
    await db.execute('''
      CREATE TABLE otp_codes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        email TEXT NOT NULL,
        otpHash TEXT NOT NULL,
        expiresAt TEXT NOT NULL,
        isUsed INTEGER DEFAULT 0,
        attempts INTEGER DEFAULT 0,
        createdAt TEXT NOT NULL
      )
    ''');

    // Pending transactions table (auto-detected UPI payments)
    await db.execute('''
      CREATE TABLE pending_transactions (
        id TEXT PRIMARY KEY,
        user_id TEXT NOT NULL,
        amount REAL NOT NULL,
        merchant TEXT,
        category TEXT NOT NULL DEFAULT 'other',
        raw_notification TEXT,
        source_app TEXT,
        detected_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending'
      )
    ''');

    // Indexes for faster queries
    await db.execute('CREATE INDEX idx_expenses_userId ON expenses(userId)');
    await db.execute('CREATE INDEX idx_expenses_date ON expenses(date)');
    await db.execute('CREATE INDEX idx_otp_email ON otp_codes(email)');
    await db.execute('CREATE INDEX idx_pending_userId ON pending_transactions(user_id)');
    await db.execute('CREATE INDEX idx_pending_status ON pending_transactions(status)');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Migration: add userId column, salt column
      await db.execute(
          'ALTER TABLE expenses ADD COLUMN userId TEXT NOT NULL DEFAULT ""');
      await db.execute(
          'ALTER TABLE users ADD COLUMN salt TEXT NOT NULL DEFAULT ""');
    }
    if (oldVersion < 3) {
      // Migration: add pending_transactions table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS pending_transactions (
          id TEXT PRIMARY KEY,
          user_id TEXT NOT NULL,
          amount REAL NOT NULL,
          merchant TEXT,
          category TEXT NOT NULL DEFAULT 'other',
          raw_notification TEXT,
          source_app TEXT,
          detected_at TEXT NOT NULL,
          status TEXT NOT NULL DEFAULT 'pending'
        )
      ''');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_pending_userId ON pending_transactions(user_id)');
      await db.execute('CREATE INDEX IF NOT EXISTS idx_pending_status ON pending_transactions(status)');
    }
    if (oldVersion < 4) {
      // Migration: add type column to expenses (expense/income)
      await db.execute(
          "ALTER TABLE expenses ADD COLUMN type TEXT NOT NULL DEFAULT 'expense'");
    }
    if (oldVersion < 5) {
      // Migration: add incomeCategory column to expenses
      await db.execute(
          'ALTER TABLE expenses ADD COLUMN incomeCategory TEXT');
    }
    if (oldVersion < 6) {
      // Migration: add compound indexes for common query patterns
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_expenses_user_date ON expenses(userId, date DESC)');
      await db.execute(
          'CREATE INDEX IF NOT EXISTS idx_expenses_user_type ON expenses(userId, type)');
    }
  }

  /// Close the database
  Future<void> close() async {
    final db = await database;
    db.close();
    _database = null;
  }
}
