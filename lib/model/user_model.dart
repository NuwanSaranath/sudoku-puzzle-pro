// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:hive/hive.dart';
//
// // A class for managing user data, rank, and high scores
// class UserModel {
//   String? _uid;
//   int bestScore = 0;
//   int fast = 0;
//
//   UserModel() {
//     final user = FirebaseAuth.instance.currentUser;
//     _uid = user?.uid;
//   }
//
//   // Fetch user data from Firestore
//   Future<Map<String, dynamic>> getUserData() async {
//     final users = FirebaseFirestore.instance.collection('users');
//     final userData = await users.doc(_uid).get();
//     return userData.data() ?? {};
//   }
//
//   // Fetch local high score from Hive
//   Future<int> getLocalHighScore() async {
//     var box = await Hive.openBox('highScores');
//     return box.get('highScore', defaultValue: 0);
//   }
//
//   // Save high score to Hive
//   Future<void> saveHighScore(int score) async {
//     var box = await Hive.openBox('highScores');
//     await box.put('highScore', score);
//   }
//
//   // Fetch user's best score and fastest time
//   Future<Map<String, dynamic>> getUserScores() async {
//     final data = await getUserData();
//     return {
//       'bestScore': data['bestScore'] ?? 0,
//       'fastestTime': data['fastestTimeMs'] ?? 0,
//     };
//   }
//
//   // Fetch rank based on the best score
//   Future<int> getRank({required bool local}) async {
//     final users = FirebaseFirestore.instance.collection('users');
//     final me = await users.doc(_uid).get();
//     final userData = me.data() ?? {};
//     final myScore = userData['bestScore'] ?? 0;
//
//     Query<Map<String, dynamic>> base = users;
//     if (local) {
//       base = base.where('location', isEqualTo: userData['location']);
//     }
//
//     final higherSnap = await base.where('bestScore', isGreaterThan: myScore).count().get();
//     final tieSnap = await base.where('bestScore', isEqualTo: myScore).where('fastestTimeMs', isLessThan: myScore).count().get();
//
//     final higher = higherSnap.count ?? 0;
//     final tie = tieSnap.count ?? 0;
//
//     return higher + tie + 1;
//   }
// }
