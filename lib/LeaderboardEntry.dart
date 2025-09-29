import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardEntry {
  final String uid;
  final String name;     // displayName from users
  final int score;
  final int timeMs;

  LeaderboardEntry({required this.uid, required this.name, required this.score, required this.timeMs});
}

class UserStats {
  final int bestScore;
  final int fastestTimeMs;
  final int rankByScore; // 1-based

  UserStats({required this.bestScore, required this.fastestTimeMs, required this.rankByScore});
}

class LeaderboardService {
  final _db = FirebaseFirestore.instance;

  /// Write a finished game result and update cached aggregates on /users/{uid}
  Future<void> submitResult({
    required String uid,
    required String region, // e.g., "LK"
    required int score,
    required int timeMs,
  }) async {
    final now = FieldValue.serverTimestamp();
    final userRef = _db.collection('users').doc(uid);
    final scoresRef = _db.collection('scores').doc();

    await _db.runTransaction((tx) async {
      // 1) append score
      tx.set(scoresRef, {
        'uid': uid,
        'region': region,
        'score': score,
        'timeMs': timeMs,
        'createdAt': now,
      });

      // 2) update aggregates on user
      final snap = await tx.get(userRef);
      int bestScore = score;
      int fastest = timeMs;

      if (snap.exists) {
        final d = snap.data()!;
        final oldBest = (d['bestScore'] ?? -0x3fffffff) as int;
        final oldFast = (d['fastestTimeMs'] ?? 1 << 30) as int;
        bestScore = score > oldBest ? score : oldBest;
        fastest   = timeMs < oldFast ? timeMs : oldFast;
      }

      tx.set(userRef, {
        'bestScore': bestScore,
        'fastestTimeMs': fastest,
        // keep existing displayName/region if present; set if new:
        'region': region,
      }, SetOptions(merge: true));
    });
  }

  /// Top 10 by score. If region == null => global, else local to that region.
  Stream<List<LeaderboardEntry>> top10ByScore({String? region}) {
    Query q = _db.collection('scores')
        .orderBy('score', descending: true)
        .limit(10);

    if (region != null) {
      q = q.where('region', isEqualTo: region);
    }

    // join with users for displayName (client-side mini-join)
    return q.snapshots().asyncMap((snap) async {
      final docs = snap.docs;
      final userIds = docs.map((d) => d['uid'] as String).toSet().toList();

      // batch fetch user docs
      final usersSnap = await _db.collection('users')
          .where(FieldPath.documentId, whereIn: userIds.isEmpty ? ['_dummy_'] : userIds)
          .get();

      final names = <String, String>{};
      for (final u in usersSnap.docs) {
        names[u.id] = (u.data()['displayName'] ?? 'Player') as String;
      }

      return docs.map((d) {
        final uid = d['uid'] as String;
        return LeaderboardEntry(
          uid: uid,
          name: names[uid] ?? 'Player',
          score: (d['score'] as num).toInt(),
          timeMs: (d['timeMs'] as num).toInt(),
        );
      }).toList();
    });
  }

  /// Read cached bestScore & fastestTimeMs from /users/{uid}
  Future<(int best, int fastest)> readUserAggregates(String uid) async {
    final doc = await _db.collection('users').doc(uid).get();
    final data = doc.data() ?? {};
    return (
    (data['bestScore'] ?? 0) as int,
    (data['fastestTimeMs'] ?? 0) as int,
    );
  }

  /// Rank by score using Firestore count() aggregate:
  /// rank = count(users with score > myBest in scope) + 1
  Future<int> rankByScore({
    required int myBestScore,
    String? region, // null => global
  }) async {
    Query q = _db.collection('scores').where('score', isGreaterThan: myBestScore);
    if (region != null) q = q.where('region', isEqualTo: region);

    // Use aggregation query (count) — fast & cheap
    final agg = await q.count().get();
    return (agg.count ?? 0) + 1;
  }

  /// Build full user stats for a scope (local/global)
  Future<UserStats> getUserStats({
    required String uid,
    required String? regionForLocal, // pass region for local; null for global
  }) async {
    final (best, fastest) = await readUserAggregates(uid);
    final rank = await rankByScore(myBestScore: best, region: regionForLocal);
    return UserStats(bestScore: best, fastestTimeMs: fastest, rankByScore: rank);
  }
}
