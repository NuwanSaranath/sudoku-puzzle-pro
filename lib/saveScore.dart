import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';




Future<void> submitBestResult({required int score, int? timeMs,}) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return;

  final ref = FirebaseFirestore.instance.collection('users').doc(uid);

  await FirebaseFirestore.instance.runTransaction((tx) async {
    final snap = await tx.get(ref);
    final data = (snap.data() ?? {}) as Map<String, dynamic>;

    final oldBest = (data['bestScore'] ?? 0) as int;
    final oldFast = (data['fastestTimeMs'] ?? (1 << 30)) as int;
    final updates = <String, dynamic>{};

    if (score > oldBest) {
      updates['bestScore'] = score;
      updates['bestScoreAt'] = FieldValue.serverTimestamp();
    }
    if (timeMs != null && timeMs > 0 && timeMs < oldFast) {
      updates['fastestTimeMs'] = timeMs;
      updates['fastestTimeAt'] = FieldValue.serverTimestamp();
    }

    if (updates.isNotEmpty) {
      updates['updatedAt'] = FieldValue.serverTimestamp();
      tx.set(ref, updates, SetOptions(merge: true));
    }
  });
}

Future<void> saveHighScore(int score) async {
  var box = await Hive.openBox('highScores');
  box.put('highScore', score); // Save high score locally
}

Future<int> getHighScore() async {
  var box = await Hive.openBox('highScores');
  print("box.get('highScore', defaultValue: 0)");
  print(box.get('highScore', defaultValue: 0));
  return box.get('highScore', defaultValue: 0); // Get the saved high score (default to 0)
}
Future<bool> isConnected() async {
  print("isConnected.wifi");
  List<ConnectivityResult> results = await Connectivity().checkConnectivity();
  ConnectivityResult result = results.isNotEmpty ? results.first : ConnectivityResult.none;
  print("ConnectivityResult.mobile");
  print(ConnectivityResult.mobile);
  print("ConnectivityResult.wifi");
  print(ConnectivityResult.wifi);
  print("result");
  print(result);
  return result == ConnectivityResult.mobile || result == ConnectivityResult.wifi;
}


Future<void> syncHighScoreWithFirebase(int score) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return; // If the user is not logged in, exit

  final ref = FirebaseFirestore.instance.collection('users').doc(uid);

  // Run a transaction to update the Firestore document atomically
  await FirebaseFirestore.instance.runTransaction((tx) async {
    final snap = await tx.get(ref);
    final data = (snap.data() ?? {}) as Map<String, dynamic>;
    final oldBestScore = (data['highScore'] ?? 0) as int;

    if (score > oldBestScore) {
      tx.set(ref, {
        'highScore': score,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }
  });
}

Future<void> submitHighScore({required int score, int? timeMs,}) async {
  // Save high score locally (when offline)
  print("working submitHighScore");
  await saveHighScore(score);

  // Check if the device is online
  print("await isConnected()");
  if (await isConnected()) {
    // If online, sync with Firebase
    submitBestResult(score: score, timeMs: timeMs);
  } else {
    // Optionally show a message that the score will be saved when back online
    print("No internet connection. High score saved locally.");
  }
}

