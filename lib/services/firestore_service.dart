import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  Stream<DocumentSnapshot<Map<String, dynamic>>> userStream(String uid) {
    return _db.collection('users').doc(uid).snapshots();
  }

  Future<void> submitBestResult({required int score, required int timeMs}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final ref = _db.collection('users').doc(uid);

    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final data = snap.data() ?? {};
      final oldBest = (data['bestScore'] ?? 0) as int;
      final oldFast = (data['fastestTimeMs'] ?? 999999) as int;

      final updates = <String, dynamic>{};
      if (score > oldBest) updates['bestScore'] = score;
      if (timeMs < oldFast) updates['fastestTimeMs'] = timeMs;
      if (updates.isNotEmpty) {
        updates['updatedAt'] = FieldValue.serverTimestamp();
        tx.set(ref, updates, SetOptions(merge: true));
      }
    });
  }

  Future<int> getUserRank({String? uid, bool local = false}) async {
    if (uid == null) return 0;
    final users = _db.collection('users');
    final userSnap = await users.doc(uid).get();
    final score = userSnap['bestScore'] ?? 0;
    final location = userSnap['location'];

    Query query = local
        ? users.where('location', isEqualTo: location)
        : users;
    final higher = await query.where('bestScore', isGreaterThan: score).count().get();
    return (higher.count ?? 0) + 1;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTop10({bool local = false}) {
    return _db.collection('users').orderBy('bestScore', descending: true).limit(10).snapshots();
  }
}
