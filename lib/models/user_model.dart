//
// class UserModel {
//   final String uid;
//   final String name;
//   final String email;
//   final String? location;
//   final int bestScore;
//   final int fastestTimeMs;
//
//   UserModel({
//     required this.uid,
//     required this.name,
//     required this.email,
//     this.location,
//     required this.bestScore,
//     required this.fastestTimeMs,
//   });
//
//   factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
//     return UserModel(
//       uid: uid,
//       name: data['name'] ?? '',
//       email: data['email'] ?? '',
//       location: data['location'],
//       bestScore: (data['bestScore'] ?? 0) as int,
//       fastestTimeMs: (data['fastestTimeMs'] ?? 0) as int,
//     );
//   }
// }
class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? location;
  final int bestScore;
  final int fastestTimeMs;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.location,
    required this.bestScore,
    required this.fastestTimeMs,
  });

  factory UserModel.fromMap(String uid, Map<String, dynamic> data) {
    return UserModel(
      uid: uid,
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      location: data['location'],
      bestScore: data['bestScore'] ?? 0,
      fastestTimeMs: data['fastestTimeMs'] ?? 0,
    );
  }
}
