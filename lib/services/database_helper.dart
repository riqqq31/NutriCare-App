import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('nutricare_v2.db');
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
    await db.execute('''
      CREATE TABLE master_makanan (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL,
        kalori INTEGER NOT NULL,
        protein REAL DEFAULT 0,
        karbo REAL DEFAULT 0,
        lemak REAL DEFAULT 0,
        porsi_desc TEXT
      )
    ''');

    // 3. Tabel RIWAYAT (Log Harian User)
    await db.execute('''
      CREATE TABLE riwayat (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        nama TEXT NOT NULL,
        kalori INTEGER NOT NULL,
        protein REAL,
        karbo REAL,
        lemak REAL,
        porsi REAL,
        waktu TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // Import CSV dataset
    await _importCsvToDatabase(db);
  }

  /// Import tabel.csv ke master_makanan
  Future<void> _importCsvToDatabase(Database db) async {
    try {
      // Baca file CSV dari assets
      final csvString = await rootBundle.loadString('assets/tabel.csv');

      // Parse CSV (delimiter = semicolon)
      List<List<dynamic>> csvData = const CsvToListConverter(
        fieldDelimiter: ';',
        eol: '\n',
      ).convert(csvString);

      // Skip header row (index 0)
      // Format: calories;proteins;fat;carbohydrate;name
      if (csvData.length > 1) {
        // Batch insert untuk performa
        Batch batch = db.batch();

        for (int i = 1; i < csvData.length; i++) {
          var row = csvData[i];
          if (row.length >= 5) {
            // Parse values - handle both int and double
            int kalori = _parseToInt(row[0]);
            double protein = _parseToDouble(row[1]);
            double lemak = _parseToDouble(row[2]);
            double karbo = _parseToDouble(row[3]);
            String nama = row[4].toString().trim();

            if (nama.isNotEmpty) {
              batch.insert('master_makanan', {
                'nama': nama,
                'kalori': kalori,
                'protein': protein,
                'karbo': karbo,
                'lemak': lemak,
                'porsi_desc': '1 Porsi (100g)',
              });
            }
          }
        }

        await batch.commit(noResult: true);
      }
    } catch (e) {
      // Fallback ke seed data jika CSV gagal
      await _seedData(db);
    }
  }

  int _parseToInt(dynamic value) {
    if (value is int) return value;
    if (value is double) return value.toInt();
    return int.tryParse(value.toString()) ?? 0;
  }

  double _parseToDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  Future<void> _seedData(Database db) async {
    List<Map<String, dynamic>> foods = [
      {
        'nama': 'Nasi Putih',
        'kalori': 204,
        'protein': 4.2,
        'karbo': 44.0,
        'lemak': 0.4,
        'porsi_desc': '1 Mangkok (150g)',
      },
      {
        'nama': 'Dada Ayam Rebus',
        'kalori': 165,
        'protein': 31.0,
        'karbo': 0.0,
        'lemak': 3.6,
        'porsi_desc': '100g',
      },
      {
        'nama': 'Telur Rebus',
        'kalori': 77,
        'protein': 6.3,
        'karbo': 0.6,
        'lemak': 5.3,
        'porsi_desc': '1 Butir Besar',
      },
      {
        'nama': 'Tempe Goreng',
        'kalori': 110,
        'protein': 6.0,
        'karbo': 8.0,
        'lemak': 7.0,
        'porsi_desc': '1 Potong Sedang',
      },
      {
        'nama': 'Tahu Goreng',
        'kalori': 35,
        'protein': 2.0,
        'karbo': 1.0,
        'lemak': 2.5,
        'porsi_desc': '1 Potong Kecil',
      },
      {
        'nama': 'Nasi Goreng Ayam',
        'kalori': 333,
        'protein': 13.0,
        'karbo': 42.0,
        'lemak': 12.0,
        'porsi_desc': '1 Piring',
      },
      {
        'nama': 'Mie Instan Goreng',
        'kalori': 380,
        'protein': 8.0,
        'karbo': 54.0,
        'lemak': 14.0,
        'porsi_desc': '1 Bungkus',
      },
      {
        'nama': 'Pisang',
        'kalori': 105,
        'protein': 1.3,
        'karbo': 27.0,
        'lemak': 0.4,
        'porsi_desc': '1 Buah Sedang',
      },
      {
        'nama': 'Susu Whey Protein',
        'kalori': 120,
        'protein': 24.0,
        'karbo': 3.0,
        'lemak': 1.0,
        'porsi_desc': '1 Scoop',
      },
      {
        'nama': 'Kopi Hitam (Gula)',
        'kalori': 35,
        'protein': 0.1,
        'karbo': 9.0,
        'lemak': 0.0,
        'porsi_desc': '1 Cangkir',
      },
    ];

    for (var f in foods) {
      await db.insert('master_makanan', f);
    }
  }

  // --- QUERY BUAT SEARCH ---
  Future<List<Map<String, dynamic>>> searchMakanan(String keyword) async {
    final db = await instance.database;
    return await db.query(
      'master_makanan',
      where: 'nama LIKE ?',
      whereArgs: ['%$keyword%'],
      limit: 20, // Limit results untuk performa
    );
  }

  // Sisanya (Login, Register, GetRiwayat) sama kayak sebelumnya
  Future<int> insertMakanan(Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert('riwayat', row);
  }

  // --- FITUR AKUN ---
  Future<int> registerUser(String username, String password) async {
    final db = await instance.database;
    try {
      return await db.insert('users', {
        'username': username,
        'password': password,
        'berat': 0,
        'tinggi': 0,
      });
    } catch (e) {
      return -1;
    }
  }

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
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  Future<int> updateProfile(int id, Map<String, dynamic> values) async {
    final db = await instance.database;
    return await db.update('users', values, where: 'id = ?', whereArgs: [id]);
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

  Future<int> deleteRiwayatByUser(int userId) async {
    final db = await instance.database;
    return await db.delete(
      'riwayat',
      where: 'user_id = ?',
      whereArgs: [userId],
    );
  }

  Future<List<Map<String, dynamic>>> getWeeklyStats(int userId) async {
    final db = await instance.database;
    return await db.rawQuery(
      '''
      SELECT SUBSTR(waktu, 1, 10) as tanggal, SUM(kalori) as total 
      FROM riwayat 
      WHERE user_id = ? GROUP BY tanggal ORDER BY tanggal DESC LIMIT 7
    ''',
      [userId],
    );
  }

  /// Get total count of master_makanan
  Future<int> getMasterMakananCount() async {
    final db = await instance.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM master_makanan',
    );
    return result.first['count'] as int? ?? 0;
  }
}
