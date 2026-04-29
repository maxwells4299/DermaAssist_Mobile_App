import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'brmms_database.db');

    return await openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            email TEXT NOT NULL UNIQUE,
            password TEXT NOT NULL
          )
        ''');
        await db.execute('''
          CREATE TABLE scans(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            user_id INTEGER NOT NULL,
            probability REAL NOT NULL,
            date TEXT NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE scans(
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              user_id INTEGER NOT NULL,
              probability REAL NOT NULL,
              date TEXT NOT NULL
            )
          ''');
        }
      },
    );
  }

  Future<void> saveScan(int userId, double probability, String date) async {
    final db = await database;
    await db.insert('scans', {
      'user_id': userId,
      'probability': probability,
      'date': date,
    });
  }

  Future<List<Map<String, dynamic>>> getUserScans(int userId) async {
    final db = await database;
    return await db.query(
      'scans',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'date DESC',
    );
  }

  Future<bool> registerUser({required String name, required String email, required String password}) async {
    final db = await database;
    try {
      await db.insert(
        'users',
        {'name': name, 'email': email, 'password': password},
        conflictAlgorithm: ConflictAlgorithm.abort, // Will fail if email exists
      );
      return true;
    } catch (e) {
      return false; // Registration failed (e.g., email already registered)
    }
  }

  Future<Map<String, dynamic>?> authenticateUser(String email, String password) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'users',
      where: 'email = ? AND password = ?',
      whereArgs: [email, password],
    );

    if (maps.isNotEmpty) {
      return maps.first;
    }
    return null; // Invalid credentials
  }
}
