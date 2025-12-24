import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    // Naikkan versi ke 2 atau ganti nama file biar tabel baru ke-load
    _database = await _initDB('nutricare_v4_macros.db'); 
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

    // 2. Tabel MAKANAN MASTER (Dataset/Kamus Makanan)
    // Ini buat Search Bar nanti
    await db.execute('''
      CREATE TABLE master_makanan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        kalori INTEGER NOT NULL,
        protein REAL DEFAULT 0,
        karbo REAL DEFAULT 0,
        lemak REAL DEFAULT 0,
        porsi_desc TEXT -- misal: "1 Piring", "1 Potong"
      )
    ''');

    // 3. Tabel RIWAYAT (Log Harian User)
    // Sekarang nyimpen Macros juga
    await db.execute('''
      CREATE TABLE riwayat (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        nama TEXT NOT NULL,
        kalori INTEGER NOT NULL,
        protein REAL,
        karbo REAL,
        lemak REAL,
        porsi REAL, -- Berapa porsi yang dimakan (misal 1.5)
        waktu TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // --- SEED DATA (DATASET AWAL) ---
    // Biar search bar lu gak kosong melompong
    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    List<Map<String, dynamic>> foods = [
      {'nama': 'Nasi Putih', 'kalori': 204, 'protein': 4.2, 'karbo': 44.0, 'lemak': 0.4, 'porsi_desc': '1 Mangkok (150g)'},
      {'nama': 'Dada Ayam Rebus', 'kalori': 165, 'protein': 31.0, 'karbo': 0.0, 'lemak': 3.6, 'porsi_desc': '100g'},
      {'nama': 'Telur Rebus', 'kalori': 77, 'protein': 6.3, 'karbo': 0.6, 'lemak': 5.3, 'porsi_desc': '1 Butir Besar'},
      {'nama': 'Tempe Goreng', 'kalori': 110, 'protein': 6.0, 'karbo': 8.0, 'lemak': 7.0, 'porsi_desc': '1 Potong Sedang'},
      {'nama': 'Tahu Goreng', 'kalori': 35, 'protein': 2.0, 'karbo': 1.0, 'lemak': 2.5, 'porsi_desc': '1 Potong Kecil'},
      {'nama': 'Nasi Goreng Ayam', 'kalori': 333, 'protein': 13.0, 'karbo': 42.0, 'lemak': 12.0, 'porsi_desc': '1 Piring'},
      {'nama': 'Mie Instan Goreng', 'kalori': 380, 'protein': 8.0, 'karbo': 54.0, 'lemak': 14.0, 'porsi_desc': '1 Bungkus'},
      {'nama': 'Pisang', 'kalori': 105, 'protein': 1.3, 'karbo': 27.0, 'lemak': 0.4, 'porsi_desc': '1 Buah Sedang'},
      {'nama': 'Susu Whey Protein', 'kalori': 120, 'protein': 24.0, 'karbo': 3.0, 'lemak': 1.0, 'porsi_desc': '1 Scoop'},
      {'nama': 'Kopi Hitam (Gula)', 'kalori': 35, 'protein': 0.1, 'karbo': 9.0, 'lemak': 0.0, 'porsi_desc': '1 Cangkir'},
    ];

    for (var f in foods) {
      await db.insert('master_makanan', f);
    }
  }

  // --- QUERY BARU BUAT SEARCH ---
  Future<List<Map<String, dynamic>>> searchMakanan(String keyword) async {
    final db = await instance.database;
    return await db.query(
      'master_makanan',
      where: 'nama LIKE ?',
      whereArgs: ['%$keyword%'], // Mencari yang mengandung kata kunci
    );
  }

  // Sisanya (Login, Register, GetRiwayat) sama kayak sebelumnya...
  // Tapi update insertMakanan biar nerima macros
  Future<int> insertMakanan(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('riwayat', row);
  }

  // ... (Paste fungsi login/register/getRiwayat/deleteRiwayat yang lama di sini) ...
  // Kalau mau cepet, copas aja fungsi lama lu di bawah _seedData ini.
  
  // --- FITUR AKUN (Copy dari yang lama) ---
  Future<int> registerUser(String username, String password) async {
    final db = await instance.database;
    try {
      return await db.insert('users', {
        'username': username, 'password': password, 'berat': 0, 'tinggi': 0,
      });
    } catch (e) { return -1; }
  }

  Future<Map<String, dynamic>?> loginUser(String username, String password) async {
    final db = await instance.database;
    final maps = await db.query('users', where: 'username = ? AND password = ?', whereArgs: [username, password]);
    if (maps.isNotEmpty) return maps.first;
    return null;
  }
  
  Future<int> updateProfile(int id, Map<String, dynamic> values) async {
    final db = await instance.database;
    return await db.update('users', values, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<Map<String, dynamic>>> getRiwayatByUser(int userId) async {
    final db = await instance.database;
    return await db.query('riwayat', where: 'user_id = ?', whereArgs: [userId], orderBy: 'id DESC');
  }

  Future<int> deleteRiwayatByUser(int userId) async {
    final db = await instance.database;
    return await db.delete('riwayat', where: 'user_id = ?', whereArgs: [userId]);
  }

  Future<List<Map<String, dynamic>>> getWeeklyStats(int userId) async {
    final db = await instance.database;
    return await db.rawQuery('''
      SELECT SUBSTR(waktu, 1, 10) as tanggal, SUM(kalori) as total 
      FROM riwayat 
      WHERE user_id = ? GROUP BY tanggal ORDER BY tanggal DESC LIMIT 7
    ''', [userId]);
  }
}