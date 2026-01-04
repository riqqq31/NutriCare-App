import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

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
    return await openDatabase(
      path,
      version: 5, // Version 5: Added database indexes for performance
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
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
        aktivitas TEXT,
        tujuan_diet TEXT
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

    // 4. Tabel FAVORITES (Makanan Favorit User)
    await db.execute('''
      CREATE TABLE favorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        nama TEXT NOT NULL,
        kalori INTEGER NOT NULL,
        protein REAL,
        karbo REAL,
        lemak REAL,
        porsi_desc TEXT,
        created_at TEXT NOT NULL,
        UNIQUE(user_id, nama),
        FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
      )
    ''');

    // 5. Tabel ARTICLES
    await db.execute('''
      CREATE TABLE articles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        read_time TEXT NOT NULL,
        image_url TEXT,
        is_featured INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    // Import CSV dataset
    await _importCsvToDatabase(db);

    // Seed articles
    await _seedArticles(db);

    // Create indexes for better query performance
    await _createIndexes(db);
  }

  /// Create database indexes for better query performance
  Future<void> _createIndexes(Database db) async {
    // Index for riwayat table - speeds up daily/weekly queries
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_riwayat_user_waktu ON riwayat(user_id, waktu)',
    );
    // Index for favorites table - speeds up user favorites lookup
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_favorites_user ON favorites(user_id)',
    );
    // Index for master_makanan search
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_master_nama ON master_makanan(nama)',
    );
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add favorites table for existing databases
      await db.execute('''
        CREATE TABLE IF NOT EXISTS favorites (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          nama TEXT NOT NULL,
          kalori INTEGER NOT NULL,
          protein REAL,
          karbo REAL,
          lemak REAL,
          porsi_desc TEXT,
          created_at TEXT NOT NULL,
          UNIQUE(user_id, nama),
          FOREIGN KEY (user_id) REFERENCES users (id) ON DELETE CASCADE
        )
      ''');
    }
    if (oldVersion < 3) {
      // Add articles table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS articles (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          title TEXT NOT NULL,
          description TEXT NOT NULL,
          content TEXT NOT NULL,
          category TEXT NOT NULL,
          read_time TEXT NOT NULL,
          image_url TEXT,
          is_featured INTEGER DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');
      await _seedArticles(db);
    }
    if (oldVersion < 4) {
      // Add tujuan_diet column to users table
      try {
        await db.execute(
          'ALTER TABLE users ADD COLUMN tujuan_diet TEXT DEFAULT "Maintenance"',
        );
      } catch (e) {
        // Ignore if column already exists
      }
    }
    if (oldVersion < 5) {
      // Add indexes for better query performance
      await _createIndexes(db);
    }
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
    } catch (e) {}
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

  /// Seed articles data
  Future<void> _seedArticles(Database db) async {
    final articles = [
      {
        'title': 'Panduan Meal Prep Mingguan yang Efektif & Hemat',
        'description':
            'Pelajari cara menyiapkan makanan sehat untuk satu minggu penuh hanya dalam 2 jam di hari Minggu.',
        'content':
            '''Meal prep atau persiapan makanan adalah strategi yang efektif untuk menjaga pola makan sehat sepanjang minggu. Dengan meal prep, Anda dapat menghemat waktu, uang, dan tetap konsisten dengan target nutrisi Anda.

## Langkah-langkah Meal Prep

1. **Perencanaan Menu** - Tentukan menu untuk 7 hari ke depan
2. **Belanja Cerdas** - Beli bahan sesuai kebutuhan, hindari pembelian impulsif
3. **Persiapan Bahan** - Cuci, potong, dan siapkan semua bahan
4. **Memasak Batch** - Masak protein, karbohidrat, dan sayuran dalam jumlah besar
5. **Pembagian Porsi** - Bagi makanan ke dalam container sesuai porsi

## Tips Sukses Meal Prep

- Investasikan pada container berkualitas yang tahan microwave
- Variasikan bumbu untuk menghindari kebosanan
- Simpan makanan dengan benar untuk menjaga kesegaran
- Mulai dengan 3-4 resep sederhana

Dengan konsistensi, meal prep akan menjadi kebiasaan yang mengubah gaya hidup Anda menjadi lebih sehat dan terorganisir.''',
        'category': 'NUTRISI',
        'read_time': '5 min baca',
        'image_url':
            'https://images.unsplash.com/photo-1512621776951-a57141f2eefd?w=800',
        'is_featured': 1,
        'created_at': DateTime.now().toString(),
      },
      {
        'title': 'Manfaat Tersembunyi Oatmeal untuk Kesehatan Jantung',
        'description':
            'Lebih dari sekedar serat, oatmeal mengandung antioksidan unik yang baik untuk jantung.',
        'content':
            '''Oatmeal telah lama dikenal sebagai sarapan sehat, tetapi manfaatnya jauh lebih besar dari yang banyak orang sadari. Selain kaya serat, oatmeal mengandung avenanthramides - antioksidan unik yang hanya ditemukan dalam gandum.

## Manfaat Oatmeal untuk Jantung

- **Menurunkan Kolesterol** - Beta-glucan dalam oatmeal terbukti menurunkan LDL
- **Mengontrol Tekanan Darah** - Avenanthramides membantu melebarkan pembuluh darah
- **Mengurangi Peradangan** - Antioksidan membantu melawan peradangan kronis
- **Mengatur Gula Darah** - Indeks glikemik rendah menjaga gula darah stabil

## Cara Konsumsi Terbaik

Pilih oatmeal tanpa gula tambahan dan hindari oatmeal instan yang sudah diproses. Tambahkan buah segar, kacang-kacangan, atau madu untuk rasa alami.''',
        'category': 'NUTRISI',
        'read_time': '3 min baca',
        'image_url':
            'https://images.unsplash.com/photo-1517673400267-0251440c45dc?w=400',
        'is_featured': 0,
        'created_at': DateTime.now().toString(),
      },
      {
        'title': '5 Pilihan Snack Rendah Kalori untuk Sore Hari',
        'description':
            'Atasi rasa lapar di sore hari tanpa merusak diet harianmu dengan opsi snack sehat ini.',
        'content':
            '''Rasa lapar di sore hari sering menjadi tantangan terbesar dalam menjaga pola makan sehat. Berikut 5 pilihan snack yang mengenyangkan namun rendah kalori:

## 1. Greek Yogurt dengan Buah (100-150 kcal)
Kaya protein untuk mengenyangkan lebih lama. Tambahkan buah segar untuk serat ekstra.

## 2. Sayuran dengan Hummus (80-120 kcal)
Wortel, mentimun, atau paprika dengan 2 sendok makan hummus.

## 3. Apel dengan Selai Kacang (150-180 kcal)
Kombinasi sempurna serat dan protein. Gunakan 1 sendok makan selai kacang alami.

## 4. Edamame (120 kcal per cangkir)
Kaya protein nabati dan mudah disiapkan. Cukup rebus atau kukus.

## 5. Telur Rebus (77 kcal per butir)
Snack klasik yang praktis dan mengenyangkan. Siapkan beberapa di awal minggu.''',
        'category': 'SNACK',
        'read_time': '4 min baca',
        'image_url':
            'https://images.unsplash.com/photo-1568702846914-96b305d2uj89?w=400',
        'is_featured': 0,
        'created_at': DateTime.now().toString(),
      },
      {
        'title': 'Teknik Memasak Ayam Agar Tetap Juicy dan Sehat',
        'description':
            'Hindari ayam kering dan hambar dengan teknik marinasi dan memasak yang tepat.',
        'content':
            '''Dada ayam adalah sumber protein favorit untuk diet sehat, tapi sering kali hasilnya kering dan hambar. Berikut teknik untuk mendapatkan ayam yang juicy dan lezat:

## Teknik Marinasi

1. **Brine Sederhana** - Rendam ayam dalam air garam (4 sdm garam per liter air) selama 30 menit
2. **Marinasi Yogurt** - Yogurt membantu melunakkan daging dan menambah kelembapan
3. **Marinasi Asam** - Jeruk nipis atau cuka membantu meresapkan bumbu

## Tips Memasak

- **Keluarkan dari kulkas 20 menit sebelum dimasak** - Suhu ruangan membantu memasak merata
- **Jangan terlalu sering membalik** - Biarkan satu sisi matang sempurna
- **Gunakan termometer daging** - Target suhu internal 74°C
- **Istirahatkan 5 menit** - Biarkan cairan terdistribusi sebelum dipotong

Dengan teknik ini, ayam Anda akan selalu juicy dan nikmat!''',
        'category': 'RESEP',
        'read_time': '7 min baca',
        'image_url':
            'https://images.unsplash.com/photo-1532550907401-a500c9a57435?w=400',
        'is_featured': 0,
        'created_at': DateTime.now().toString(),
      },
      {
        'title': 'Mengapa Melacak Makanan Bisa Mengubah Gaya Hidupmu',
        'description':
            'Data membuktikan konsistensi pencatatan berhubungan langsung dengan sukses diet.',
        'content':
            '''Studi menunjukkan bahwa orang yang mencatat makanan mereka secara konsisten 2x lebih berhasil mencapai target berat badan dibanding yang tidak. Mengapa demikian?

## Manfaat Melacak Makanan

### 1. Kesadaran Kalori
Banyak orang meremehkan asupan kalori harian mereka. Tracking membantu melihat gambaran nyata.

### 2. Identifikasi Pola
Apakah Anda makan berlebihan saat stress? Atau sering skip sarapan? Tracking mengungkap pola tersembunyi.

### 3. Akuntabilitas
Mengetahui bahwa Anda akan mencatat makanan membuat Anda berpikir dua kali sebelum makan.

### 4. Data untuk Penyesuaian
Dengan data yang akurat, Anda bisa menyesuaikan rencana makan dengan lebih presisi.

## Tips Tracking Efektif

- Catat segera setelah makan
- Jangan lupa snack dan minuman
- Gunakan aplikasi untuk mempermudah
- Review mingguan untuk evaluasi

Mulailah tracking hari ini dan lihat perubahan dalam 30 hari!''',
        'category': 'TIPS',
        'read_time': '6 min baca',
        'image_url':
            'https://images.unsplash.com/photo-1551288049-bebda4e38f71?w=400',
        'is_featured': 0,
        'created_at': DateTime.now().toString(),
      },
    ];

    for (var article in articles) {
      await db.insert('articles', article);
    }
  }

  // --- ARTICLE QUERIES ---

  /// Get all articles
  Future<List<Map<String, dynamic>>> getArticles({String? category}) async {
    final db = await instance.database;
    if (category != null && category != 'Semua') {
      return await db.query(
        'articles',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: 'created_at DESC',
      );
    }
    return await db.query('articles', orderBy: 'created_at DESC');
  }

  /// Get featured article
  Future<Map<String, dynamic>?> getFeaturedArticle() async {
    final db = await instance.database;
    final result = await db.query(
      'articles',
      where: 'is_featured = ?',
      whereArgs: [1],
      limit: 1,
    );
    return result.isNotEmpty ? result.first : null;
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
  /// Hash password menggunakan SHA-256 dengan salt
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode(password + salt);
    final hash = sha256.convert(bytes);
    return hash.toString();
  }

  /// Generate random salt untuk user baru
  String _generateSalt() {
    final random = DateTime.now().millisecondsSinceEpoch.toString();
    final bytes = utf8.encode(random);
    return sha256.convert(bytes).toString().substring(0, 16);
  }

  Future<int> registerUser(
    String username,
    String password, {
    String? nama,
  }) async {
    final db = await instance.database;
    try {
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(password, salt);
      return await db.insert('users', {
        'username': username,
        'nama': nama,
        'password': '$salt:$hashedPassword', // Format: salt:hash
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
    // Cari user berdasarkan username atau nama (untuk mendukung login via email atau username)
    final maps = await db.query(
      'users',
      where: 'username = ? OR nama = ?',
      whereArgs: [username, username],
    );

    if (maps.isEmpty) return null;

    final user = maps.first;
    final storedPassword = user['password'] as String;

    // Cek apakah password menggunakan format baru (salt:hash) atau lama (plain)
    if (storedPassword.contains(':')) {
      // Format baru: salt:hash
      final parts = storedPassword.split(':');
      final salt = parts[0];
      final storedHash = parts[1];
      final inputHash = _hashPassword(password, salt);

      if (inputHash == storedHash) return user;
    } else {
      // Format lama: plain text (untuk backward compatibility)
      if (storedPassword == password) return user;
    }

    return null;
  }

  Future<int> updateProfile(int id, Map<String, dynamic> values) async {
    final db = await instance.database;
    try {
      return await db.update('users', values, where: 'id = ?', whereArgs: [id]);
    } catch (e) {
      // Self-healing: Add column if it doesn't exist (for hot-reload support)
      if (e.toString().contains("no such column: tujuan_diet")) {
        await db.execute(
          'ALTER TABLE users ADD COLUMN tujuan_diet TEXT DEFAULT "Maintenance"',
        );
        return await db.update(
          'users',
          values,
          where: 'id = ?',
          whereArgs: [id],
        );
      }
      rethrow;
    }
  }

  /// Cari user berdasarkan username (untuk forgot password)
  Future<Map<String, dynamic>?> findUserByUsername(String username) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      where: 'username = ? OR nama = ?',
      whereArgs: [username, username],
    );
    if (maps.isNotEmpty) return maps.first;
    return null;
  }

  /// Update password user (dengan hashing)
  Future<bool> updatePassword(int userId, String newPassword) async {
    try {
      final db = await instance.database;
      final salt = _generateSalt();
      final hashedPassword = _hashPassword(newPassword, salt);
      await db.update(
        'users',
        {'password': '$salt:$hashedPassword'},
        where: 'id = ?',
        whereArgs: [userId],
      );
      return true;
    } catch (e) {
      return false;
    }
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

  /// Get riwayat by specific date (OPTIMIZED - filter at SQL level)
  Future<List<Map<String, dynamic>>> getRiwayatByDate(
    int userId,
    String date,
  ) async {
    final db = await instance.database;
    return await db.query(
      'riwayat',
      where: "user_id = ? AND waktu LIKE ?",
      whereArgs: [userId, '$date%'],
      orderBy: 'id DESC',
    );
  }

  /// Get daily stats summary for a specific date (OPTIMIZED - single query)
  Future<Map<String, dynamic>> getDailyStats(int userId, String date) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      '''
      SELECT 
        COALESCE(SUM(kalori), 0) as total_kalori,
        COALESCE(SUM(protein), 0) as total_protein,
        COALESCE(SUM(karbo), 0) as total_karbo,
        COALESCE(SUM(lemak), 0) as total_lemak,
        COUNT(*) as total_items
      FROM riwayat 
      WHERE user_id = ? AND waktu LIKE ?
    ''',
      [userId, '$date%'],
    );
    return result.isNotEmpty ? result.first : {};
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

  /// Get recent foods (makanan terakhir dimakan, unik berdasarkan nama)
  Future<List<Map<String, dynamic>>> getRecentFoods(
    int userId, {
    int limit = 10,
  }) async {
    final db = await instance.database;

    final result = await db.rawQuery(
      '''
      SELECT * FROM riwayat 
      WHERE id IN (
        SELECT MAX(id) 
        FROM riwayat 
        WHERE user_id = ? 
        GROUP BY nama
      )
      ORDER BY waktu DESC
      LIMIT ?
    ''',
      [userId, limit],
    );

    // Add default porsi_desc since it doesn't exist in riwayat table
    return result.map((row) {
      return {...row, 'porsi_desc': '1 Porsi'};
    }).toList();
  }

  /// Get favorite foods (makanan paling sering dimakan)
  Future<List<Map<String, dynamic>>> getTopFrequentFoods(
    int userId, {
    int limit = 10,
  }) async {
    final db = await instance.database;
    final result = await db.rawQuery(
      '''
      SELECT nama, 
             MAX(kalori) as kalori, 
             MAX(protein) as protein, 
             MAX(karbo) as karbo, 
             MAX(lemak) as lemak, 
             COUNT(nama) as freq 
      FROM riwayat
      WHERE user_id = ?
      GROUP BY nama
      ORDER BY freq DESC
      LIMIT ?
    ''',
      [userId, limit],
    );

    // Add default porsi_desc since it doesn't exist in riwayat table
    return result.map((row) {
      return {...row, 'porsi_desc': '1 Porsi'};
    }).toList();
  }

  // --- FAVORITES MANAGEMENT ---

  /// Add food to favorites
  Future<int> addToFavorites({
    required int userId,
    required String nama,
    required int kalori,
    required double protein,
    required double karbo,
    required double lemak,
    String? porsiDesc,
  }) async {
    final db = await instance.database;
    try {
      return await db.insert('favorites', {
        'user_id': userId,
        'nama': nama,
        'kalori': kalori,
        'protein': protein,
        'karbo': karbo,
        'lemak': lemak,
        'porsi_desc': porsiDesc ?? '1 Porsi',
        'created_at': DateTime.now().toString(),
      });
    } catch (e) {
      // Return -1 if already exists (UNIQUE constraint)
      return -1;
    }
  }

  /// Remove food from favorites
  Future<int> removeFromFavorites(int userId, String nama) async {
    final db = await instance.database;
    return await db.delete(
      'favorites',
      where: 'user_id = ? AND nama = ?',
      whereArgs: [userId, nama],
    );
  }

  /// Get all user favorites
  Future<List<Map<String, dynamic>>> getUserFavorites(int userId) async {
    final db = await instance.database;
    return await db.query(
      'favorites',
      where: 'user_id = ?',
      whereArgs: [userId],
      orderBy: 'created_at DESC',
    );
  }

  /// Check if food is in favorites
  Future<bool> isFavorite(int userId, String nama) async {
    final db = await instance.database;
    final result = await db.query(
      'favorites',
      where: 'user_id = ? AND nama = ?',
      whereArgs: [userId, nama],
      limit: 1,
    );
    return result.isNotEmpty;
  }
}
