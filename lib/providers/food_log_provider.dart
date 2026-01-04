import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/database_helper.dart';
import 'user_provider.dart';

/// State class untuk food log (riwayat makan)
class FoodLogState {
  final int konsumsiKalori;
  final double protein;
  final double karbo;
  final double lemak;
  final List<Map<String, dynamic>> riwayatMakan;
  final bool isLoading;

  const FoodLogState({
    this.konsumsiKalori = 0,
    this.protein = 0,
    this.karbo = 0,
    this.lemak = 0,
    this.riwayatMakan = const [],
    this.isLoading = false,
  });

  FoodLogState copyWith({
    int? konsumsiKalori,
    double? protein,
    double? karbo,
    double? lemak,
    List<Map<String, dynamic>>? riwayatMakan,
    bool? isLoading,
  }) {
    return FoodLogState(
      konsumsiKalori: konsumsiKalori ?? this.konsumsiKalori,
      protein: protein ?? this.protein,
      karbo: karbo ?? this.karbo,
      lemak: lemak ?? this.lemak,
      riwayatMakan: riwayatMakan ?? this.riwayatMakan,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

/// Notifier untuk manage food log state
class FoodLogNotifier extends StateNotifier<FoodLogState> {
  final Ref ref;

  FoodLogNotifier(this.ref) : super(const FoodLogState());

  /// Load riwayat makan dari database untuk hari ini (OPTIMIZED)
  Future<void> loadTodayData() async {
    final userId = ref.read(userProvider).id;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);

    String todayDate = DateTime.now().toString().substring(0, 10);

    // Use optimized query - filter at SQL level, not in Dart
    final dataList = await DatabaseHelper.instance.getRiwayatByDate(
      userId,
      todayDate,
    );

    int totalKalori = 0;
    double totalProtein = 0;
    double totalKarbo = 0;
    double totalLemak = 0;

    for (var item in dataList) {
      totalKalori += (item['kalori'] as int);
      totalProtein += (item['protein'] as num?)?.toDouble() ?? 0;
      totalKarbo += (item['karbo'] as num?)?.toDouble() ?? 0;
      totalLemak += (item['lemak'] as num?)?.toDouble() ?? 0;
    }

    state = FoodLogState(
      konsumsiKalori: totalKalori,
      protein: totalProtein,
      karbo: totalKarbo,
      lemak: totalLemak,
      riwayatMakan: dataList,
      isLoading: false,
    );
  }

  /// Load riwayat makan untuk tanggal spesifik (OPTIMIZED)
  Future<void> loadDataByDate(DateTime date) async {
    final userId = ref.read(userProvider).id;
    if (userId == null) return;

    state = state.copyWith(isLoading: true);

    String targetDate = date.toString().substring(0, 10);

    // Use optimized query - filter at SQL level, not in Dart
    final dataList = await DatabaseHelper.instance.getRiwayatByDate(
      userId,
      targetDate,
    );

    int totalKalori = 0;
    double totalProtein = 0;
    double totalKarbo = 0;
    double totalLemak = 0;

    for (var item in dataList) {
      totalKalori += (item['kalori'] as int);
      totalProtein += (item['protein'] as num?)?.toDouble() ?? 0;
      totalKarbo += (item['karbo'] as num?)?.toDouble() ?? 0;
      totalLemak += (item['lemak'] as num?)?.toDouble() ?? 0;
    }

    state = FoodLogState(
      konsumsiKalori: totalKalori,
      protein: totalProtein,
      karbo: totalKarbo,
      lemak: totalLemak,
      riwayatMakan: dataList,
      isLoading: false,
    );
  }

  /// Tambah makanan baru ke riwayat
  Future<void> addFood({
    required String nama,
    required int kalori,
    required double protein,
    required double karbo,
    required double lemak,
    required double porsi,
  }) async {
    final userId = ref.read(userProvider).id;
    if (userId == null) return;

    Map<String, dynamic> row = {
      'user_id': userId,
      'nama': nama,
      'kalori': kalori,
      'protein': protein,
      'karbo': karbo,
      'lemak': lemak,
      'porsi': porsi,
      'waktu': DateTime.now().toString(),
    };

    await DatabaseHelper.instance.insertMakanan(row);

    // Update state langsung (reactive!)
    state = state.copyWith(
      konsumsiKalori: state.konsumsiKalori + kalori,
      protein: state.protein + protein,
      karbo: state.karbo + karbo,
      lemak: state.lemak + lemak,
      riwayatMakan: [row, ...state.riwayatMakan],
    );
  }

  /// Hapus semua riwayat makan user
  Future<void> clearHistory() async {
    final userId = ref.read(userProvider).id;
    if (userId == null) return;

    await DatabaseHelper.instance.deleteRiwayatByUser(userId);

    state = const FoodLogState();
  }

  /// Reset state (untuk logout)
  void reset() {
    state = const FoodLogState();
  }
}

/// Provider untuk food log state
final foodLogProvider = StateNotifierProvider<FoodLogNotifier, FoodLogState>((
  ref,
) {
  return FoodLogNotifier(ref);
});

/// Provider untuk weekly stats (chart data)
final weeklyStatsProvider = FutureProvider<List<double>>((ref) async {
  final userId = ref.watch(userProvider).id;
  if (userId == null) return List.filled(7, 0.0);

  // Watch foodLogProvider untuk trigger refresh saat ada perubahan
  ref.watch(foodLogProvider);

  final stats = await DatabaseHelper.instance.getWeeklyStats(userId);

  List<double> data = List.filled(7, 0.0);
  DateTime now = DateTime.now();

  for (int i = 0; i < 7; i++) {
    DateTime dateToCheck = now.subtract(Duration(days: i));
    String formattedDate = dateToCheck.toString().substring(0, 10);

    for (var row in stats) {
      if (row['tanggal'] == formattedDate) {
        data[6 - i] = (row['total'] as num).toDouble();
      }
    }
  }

  return data;
});
