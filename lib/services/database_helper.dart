import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nutricare_v3.db'); // Versi 3 biar fresh
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    // 1. Tabel USERS
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

    // 2. Tabel RIWAYAT (Ada kolom user_id & waktu)
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

  // --- FITUR AKUN ---
  Future<int> registerUser(String username, String password) async {
    final db = await instance.database;
    try {
      return await db.insert('users', {
        'username': username,
        'password': password,
        'berat': 0, 'tinggi': 0,
      });
    } catch (e) {
      return -1;
    }
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<int> updateProfile(int id, Map<String, dynamic> values) async {
    final db = await instance.database;
    return await db.update('users', values, where: 'id = ?', whereArgs: [id]);
  }

  // --- FITUR MAKANAN ---
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
      orderBy: 'id DESC', // Yang baru dimakan paling atas
    );
  }

  // Hapus data cuma punya user tertentu
  Future<int> deleteRiwayatByUser(int userId) async {
    final db = await instance.database;
    return await db.delete(
      'riwayat',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  // [BARU] Ambil total kalori per hari untuk 7 hari terakhir
  Future<List<Map<String, dynamic>>> getWeeklyStats(int userId) async {
    final db = await instance.database;
    
    // Query SQL: Ambil tanggal (YYYY-MM-DD), jumlahkan kalori, 
    // filter berdasarkan user_id, grup berdasarkan tanggal, ambil 7 terbaru.
    return await db.rawQuery('''
      SELECT SUBSTR(waktu, 1, 10) as tanggal, SUM(kalori) as total 
      FROM riwayat 
      WHERE user_id = ? 
      GROUP BY tanggal 
      ORDER BY tanggal DESC 
      LIMIT 7
    ''', [userId]);
  }
}