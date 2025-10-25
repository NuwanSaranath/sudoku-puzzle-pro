// import 'package:cloud_firestore/cloud_firestore.dart';
//
// class LeaderboardEntry {
//   final String uid;
//   final String name;
//   final int score;
//   final int timeMs;
//
//   LeaderboardEntry({required this.uid, required this.name, required this.score, required this.timeMs});
// }
//
// class UserStats {
//   final int bestScore;
//   final int fastestTimeMs;
//   final int rankByScore;
//
//   UserStats({required this.bestScore, required this.fastestTimeMs, required this.rankByScore});
// }
//
// class LeaderboardService {
//   final _db = FirebaseFirestore.instance;
//   Future<void> submitResult({
//     required String uid,
//     required String region,
//     required int score,
//     required int timeMs,
//   }) async {
//     final now = FieldValue.serverTimestamp();
//     final userRef = _db.collection('users').doc(uid);
//     final scoresRef = _db.collection('scores').doc();
//
//     await _db.runTransaction((tx) async {
//       tx.set(scoresRef, {
//         'uid': uid,
//         'region': region,
//         'score': score,
//         'timeMs': timeMs,
//         'createdAt': now,
//       });
//
//       final snap = await tx.get(userRef);
//       int bestScore = score;
//       int fastest = timeMs;
//
//       if (snap.exists) {
//         final d = snap.data()!;
//         final oldBest = (d['bestScore'] ?? -0x3fffffff) as int;
//         final oldFast = (d['fastestTimeMs'] ?? 1 << 30) as int;
//         bestScore = score > oldBest ? score : oldBest;
//         fastest   = timeMs < oldFast ? timeMs : oldFast;
//       }
//
//       tx.set(userRef, {
//         'bestScore': bestScore,
//         'fastestTimeMs': fastest,
//         'region': region,
//       }, SetOptions(merge: true));
//     });
//   }
//
//   Stream<List<LeaderboardEntry>> top10ByScore({String? region}) {
//     Query q = _db.collection('scores')
//         .orderBy('score', descending: true)
//         .limit(10);
//
//     if (region != null) {
//       q = q.where('region', isEqualTo: region);
//     }
//
//     return q.snapshots().asyncMap((snap) async {
//       final docs = snap.docs;
//       final userIds = docs.map((d) => d['uid'] as String).toSet().toList();
//       final usersSnap = await _db.collection('users')
//           .where(FieldPath.documentId, whereIn: userIds.isEmpty ? ['_dummy_'] : userIds)
//           .get();
//
//       final names = <String, String>{};
//       for (final u in usersSnap.docs) {
//         names[u.id] = (u.data()['displayName'] ?? 'Player') as String;
//       }
//
//       return docs.map((d) {
//         final uid = d['uid'] as String;
//         return LeaderboardEntry(
//           uid: uid,
//           name: names[uid] ?? 'Player',
//           score: (d['score'] as num).toInt(),
//           timeMs: (d['timeMs'] as num).toInt(),
//         );
//       }).toList();
//     });
//   }
//
//   Future<(int best, int fastest)> readUserAggregates(String uid) async {
//     final doc = await _db.collection('users').doc(uid).get();
//     final data = doc.data() ?? {};
//     return (
//     (data['bestScore'] ?? 0) as int,
//     (data['fastestTimeMs'] ?? 0) as int,
//     );
//   }
//
//   Future<int> rankByScore({
//     required int myBestScore,
//     String? region,
//   }) async {
//     Query q = _db.collection('scores').where('score', isGreaterThan: myBestScore);
//     if (region != null) q = q.where('region', isEqualTo: region);
//     final agg = await q.count().get();
//     return (agg.count ?? 0) + 1;
//   }
//
//   Future<UserStats> getUserStats({
//     required String uid,
//     required String? regionForLocal,
//   }) async {
//     final (best, fastest) = await readUserAggregates(uid);
//     final rank = await rankByScore(myBestScore: best, region: regionForLocal);
//     return UserStats(bestScore: best, fastestTimeMs: fastest, rankByScore: rank);
//   }
// }
