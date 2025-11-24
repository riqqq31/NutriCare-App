class AppData {
  static final AppData _instance = AppData._internal();
  factory AppData() => _instance;
  AppData._internal();

  String nama = "";
  String gender = "Laki-laki"; // Default
  int usia = 25;
  double beratBadan = 0;
  double tinggiBadan = 0;
  String aktivitas = "Jarang Olahraga"; // Default
  
  int konsumsiKalori = 0;
  int targetKalori = 2000;
  
  List<Map<String, dynamic>> riwayatMakan = [];
}