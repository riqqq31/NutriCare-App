class AppData {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal();

  // ID User yang lagi login (PENTING!)
  int? activeUserId;

  String nama = "";
  String gender = "Laki-laki";
  int usia = 25;
  double beratBadan = 0;
  double tinggiBadan = 0;
  String aktivitas = "Jarang Olahraga";

  int konsumsiKalori = 0;
  int targetKalori = 2000;

  List<Map<String, dynamic>> riwayatMakan = [];
}
