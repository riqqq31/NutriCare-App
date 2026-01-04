import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_helper.dart';

/// State class untuk user session
class UserState {
  final int? id;
  final String nama;
  final String gender;
  final int usia;
  final double beratBadan;
  final double tinggiBadan;
  final String aktivitas;
  final String tujuanDiet; // Cutting, Maintenance, Bulking
  final int targetKalori;
  final double targetProtein;
  final double targetKarbo;
  final double targetLemak;

  const UserState({
    this.id,
    this.nama = "",
    this.gender = "Laki-laki",
    this.usia = 25,
    this.beratBadan = 0,
    this.tinggiBadan = 0,
    this.aktivitas = "Jarang Olahraga",
    this.tujuanDiet = "Maintenance",
    this.targetKalori = 2000,
    this.targetProtein = 75,
    this.targetKarbo = 275,
    this.targetLemak = 67,
  });

  UserState copyWith({
    int? id,
    String? nama,
    String? gender,
    int? usia,
    double? beratBadan,
    double? tinggiBadan,
    String? aktivitas,
    String? tujuanDiet,
    int? targetKalori,
    double? targetProtein,
    double? targetKarbo,
    double? targetLemak,
  }) {
    return UserState(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      gender: gender ?? this.gender,
      usia: usia ?? this.usia,
      beratBadan: beratBadan ?? this.beratBadan,
      tinggiBadan: tinggiBadan ?? this.tinggiBadan,
      aktivitas: aktivitas ?? this.aktivitas,
      tujuanDiet: tujuanDiet ?? this.tujuanDiet,
      targetKalori: targetKalori ?? this.targetKalori,
      targetProtein: targetProtein ?? this.targetProtein,
      targetKarbo: targetKarbo ?? this.targetKarbo,
      targetLemak: targetLemak ?? this.targetLemak,
    );
  }
}

/// Notifier untuk manage user state
class UserNotifier extends StateNotifier<UserState> {
  UserNotifier() : super(const UserState());

  /// Login dan set user data dari database
  Future<bool> login(String username, String password) async {
    final userData = await DatabaseHelper.instance.loginUser(
      username,
      password,
    );

    if (userData != null) {
      double berat = (userData['berat'] ?? 0).toDouble();
      double tinggi = (userData['tinggi'] ?? 0).toDouble();
      int usia = userData['usia'] ?? 25;
      String gender = userData['gender'] ?? "Laki-laki";
      String aktivitas = userData['aktivitas'] ?? "Jarang Olahraga";
      String tujuanDiet = userData['tujuan_diet'] ?? "Maintenance";

      int baseTDEE = 2000;
      if (berat > 0 && tinggi > 0) {
        baseTDEE = _hitungTDEE(berat, tinggi, usia, gender, aktivitas);
      }

      // Adjust kalori berdasarkan tujuan diet
      int targetKalori = _adjustKaloriByGoal(baseTDEE, tujuanDiet);

      // Hitung target makro berdasarkan tujuan diet
      final makro = _hitungMakro(targetKalori, berat, tujuanDiet);

      state = UserState(
        id: userData['id'],
        nama: userData['nama'] ?? username,
        gender: gender,
        usia: usia,
        beratBadan: berat,
        tinggiBadan: tinggi,
        aktivitas: aktivitas,
        tujuanDiet: tujuanDiet,
        targetKalori: targetKalori,
        targetProtein: makro['protein']!,
        targetKarbo: makro['karbo']!,
        targetLemak: makro['lemak']!,
      );
      return true;
    }
    return false;
  }

  /// Update profile setelah input profil
  Future<void> updateProfile({
    required String nama,
    required String gender,
    required int usia,
    required double beratBadan,
    required double tinggiBadan,
    required String aktivitas,
    required String tujuanDiet,
  }) async {
    if (state.id == null) return;

    int baseTDEE = _hitungTDEE(
      beratBadan,
      tinggiBadan,
      usia,
      gender,
      aktivitas,
    );

    // Adjust kalori berdasarkan tujuan diet
    int targetKalori = _adjustKaloriByGoal(baseTDEE, tujuanDiet);

    // Hitung target makro berdasarkan tujuan diet
    final makro = _hitungMakro(targetKalori, beratBadan, tujuanDiet);

    await DatabaseHelper.instance.updateProfile(state.id!, {
      'nama': nama,
      'gender': gender,
      'usia': usia,
      'berat': beratBadan,
      'tinggi': tinggiBadan,
      'aktivitas': aktivitas,
      'tujuan_diet': tujuanDiet,
    });

    state = state.copyWith(
      nama: nama,
      gender: gender,
      usia: usia,
      beratBadan: beratBadan,
      tinggiBadan: tinggiBadan,
      aktivitas: aktivitas,
      tujuanDiet: tujuanDiet,
      targetKalori: targetKalori,
      targetProtein: makro['protein'],
      targetKarbo: makro['karbo'],
      targetLemak: makro['lemak'],
    );
  }

  /// Logout - reset state
  void logout() {
    state = const UserState();
  }

  /// Cek apakah profil sudah lengkap
  bool get isProfileComplete => state.beratBadan > 0 && state.tinggiBadan > 0;

  /// Hitung TDEE (Total Daily Energy Expenditure)
  int _hitungTDEE(
    double berat,
    double tinggi,
    int usia,
    String gender,
    String aktivitas,
  ) {
    double bmr = (10 * berat) + (6.25 * tinggi) - (5 * usia);
    if (gender == "Laki-laki") {
      bmr += 5;
    } else {
      bmr -= 161;
    }

    double factor = 1.2;
    if (aktivitas.contains("Ringan")) factor = 1.375;
    if (aktivitas.contains("Sedang")) factor = 1.55;
    if (aktivitas.contains("Berat")) factor = 1.725;

    return (bmr * factor).toInt();
  }

  /// Adjust kalori berdasarkan tujuan diet
  int _adjustKaloriByGoal(int baseTDEE, String tujuanDiet) {
    switch (tujuanDiet) {
      case "Cutting":
        return baseTDEE - 500; // Defisit 500 kcal
      case "Bulking":
        return baseTDEE + 500; // Surplus 500 kcal
      default:
        return baseTDEE; // Maintenance
    }
  }

  /// Hitung target makro berdasarkan tujuan diet
  /// Cutting: Protein 2.0g/kg (preserve muscle)
  /// Maintenance: Protein 1.6g/kg
  /// Bulking: Protein 1.8g/kg
  Map<String, double> _hitungMakro(
    int totalKalori,
    double beratBadan,
    String tujuanDiet,
  ) {
    // Protein per kg berat badan berdasarkan goal
    double proteinPerKg;
    switch (tujuanDiet) {
      case "Cutting":
        proteinPerKg = 2.0; // Higher protein to preserve muscle
        break;
      case "Bulking":
        proteinPerKg = 1.8;
        break;
      default:
        proteinPerKg = 1.6; // Maintenance
    }

    double protein = (beratBadan * proteinPerKg).roundToDouble();
    double proteinKcal = protein * 4;

    // Lemak tetap 25-30% kalori
    double lemakKcal = totalKalori * 0.25;
    double lemak = (lemakKcal / 9).roundToDouble();

    // Karbo = sisa kalori setelah protein dan lemak
    double karboKcal = totalKalori - proteinKcal - lemakKcal;
    double karbo = (karboKcal / 4).roundToDouble();

    // Pastikan karbo tidak negatif
    if (karbo < 50) karbo = 50;

    return {'protein': protein, 'karbo': karbo, 'lemak': lemak};
  }
}

/// Provider untuk user state
final userProvider = StateNotifierProvider<UserNotifier, UserState>((ref) {
  return UserNotifier();
});
