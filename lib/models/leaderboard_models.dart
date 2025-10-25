class LeaderboardEntry {
  final String uid;
  final String name;
  final int score;
  final int timeMs;

  LeaderboardEntry({
    required this.uid,
    required this.name,
    required this.score,
    required this.timeMs,
  });
}

class UserStats {
  final int bestScore;
  final int fastestTimeMs;
  final int rankByScore;

  UserStats({
    required this.bestScore,
    required this.fastestTimeMs,
    required this.rankByScore,
  });
}
