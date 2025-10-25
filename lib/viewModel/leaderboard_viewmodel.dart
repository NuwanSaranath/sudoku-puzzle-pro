import 'package:flutter/foundation.dart';
import '../models/leaderboard_models.dart';
import '../services/leaderboard_service.dart';

class LeaderboardViewModel extends ChangeNotifier {
  final LeaderboardService _service = LeaderboardService();

  List<LeaderboardEntry> _entries = [];
  List<LeaderboardEntry> get entries => _entries;

  UserStats? _userStats;
  UserStats? get userStats => _userStats;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadTop10({String? region}) async {
    _isLoading = true;
    notifyListeners();

    _service.top10ByScore(region: region).listen((data) {
      _entries = data;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> submitScore({
    required String uid,
    required String region,
    required int score,
    required int timeMs,
  }) async {
    await _service.submitResult(
      uid: uid,
      region: region,
      score: score,
      timeMs: timeMs,
    );
  }

  Future<void> loadUserStats({
    required String uid,
    required String? region,
  }) async {
    _userStats = await _service.getUserStats(
      uid: uid,
      regionForLocal: region,
    );
    notifyListeners();
  }
}
