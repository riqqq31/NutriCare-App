import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(
      'nutricare_v2.db',
    ); // Ganti nama biar refresh db baru
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. Tabel USERS (Data Akun + Profil)
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        nama TEXT,
        gender TEXT,
        usia INTEGER,
        berat REAL,
        tinggi REAL,
        aktivitas TEXT
      )
    ''');

    // 2. Tabel RIWAYAT (Ditambah kolom user_id)
    await db.execute('''
      CREATE TABLE riwayat (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        nama TEXT NOT NULL,
        kalori INTEGER NOT NULL,
        waktu TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');
  }

  // --- FITUR AKUN (Auth) ---

  // Daftar Akun Baru
  Future<int> registerUser(String username, String password) async {
    final db = await instance.database;
    try {
      return await db.insert('users', {
        'username': username,
        'password': password,
        // Profil dikosongin dulu (null/0)
        'berat': 0,
        'tinggi': 0,
      });
    } catch (e) {
      return -1; // -1 Artinya Gagal (Username udah kepake)
    }
  }

  // Login (Cek Username & Pass)
  Future<Map<String, dynamic>?> loginUser(
    String username,
    String password,
  ) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (maps.isNotEmpty) {
      return maps.first; // Balikin data usernya
    } else {
      return null; // Gagal login
    }
  }

  // Update Profil (Simpan BB, TB, dll)
  Future<int> updateProfile(int id, Map<String, dynamic> values) async {
    final db = await instance.database;
    return await db.update('users', values, where: 'id = ?', whereArgs: [id]);
  }

  // --- FITUR RIWAYAT MAKAN (Per User) ---

  Future<int> insertMakanan(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('riwayat', row);
  }

  Future<List<Map<String, dynamic>>> getRiwayatByUser(int userId) async {
    final db = await instance.database;
    return await db.query(
      'riwayat',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'id DESC',
    );
  }
}
