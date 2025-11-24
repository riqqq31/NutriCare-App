class AppData {
  // Singleton sederhana untuk menyimpan data sementara
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal();

  String nama = "";
  double beratBadan = 0;
  double tinggiBadan = 0;
  
  // Dummy data konsumsi hari ini
  int targetKalori = 2150; // Contoh hasil hitung BMR nanti
  int konsumsiKalori = 0;
  List<Map<String, dynamic>> riwayatMakan = [];

  void updateProfil(String n, double bb, double tb) {
    nama = n;
    beratBadan = bb;
    tinggiBadan = tb;
    // Simulasi hitung BMR sederhana untuk prototype
    targetKalori = (10 * bb + 6.25 * tb - 5 * 25 + 5).toInt(); 
  }

  void tambahMakan(String makanan, int kalori) {
    riwayatMakan.add({
      'makanan': makanan,
      'kalori': kalori,
      'waktu': DateTime.now().toString().substring(11, 16),
    });
    konsumsiKalori += kalori;
  }

 
}