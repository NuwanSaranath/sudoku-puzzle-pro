// import '../model//user_model.dart';
//
// class HomeViewModel {
//   final UserModel _userModel = UserModel();
//   int selectedTab = 0; // 0 = Local, 1 = Global
//   bool isOnlien = false;
//   bool isStatic = true;
//
//   // Stream user data
//   Future<Map<String, dynamic>> getUserData() async {
//     return await _userModel.getUserData();
//   }
//
//   // Fetch high score
//   Future<int> getLocalHighScore() async {
//     return await _userModel.getLocalHighScore();
//   }
//
//   // Save high score to Hive
//   Future<void> saveHighScore(int score) async {
//     await _userModel.saveHighScore(score);
//   }
//
//   // Fetch user's rank
//   Future<int> getRank({required bool local}) async {
//     return await _userModel.getRank(local: local);
//   }
//
//   // Fetch user's best score and fastest time
//   Future<Map<String, dynamic>> getUserScores() async {
//     return await _userModel.getUserScores();
//   }
// }
