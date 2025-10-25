import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../services/connectivity_service.dart';
import '../models/user_model.dart';

class HomeViewModel extends ChangeNotifier {
  final FirestoreService _firestore = FirestoreService();
  final ConnectivityService _connectivity = ConnectivityService();

  Stream<DocumentSnapshot<Map<String, dynamic>>>? userStream;
  String? uid;
  int best = 0;
  int fastest = 0;
  bool isOnline = false;

  HomeViewModel() {
    _init();
  }

  Future<void> _init() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      uid = user.uid;
      userStream = _firestore.userStream(uid!);
    }
    isOnline = await _connectivity.isConnected();
    notifyListeners();
  }

  Future<int> getRank({bool local = false}) async {
    return _firestore.getUserRank(uid: uid, local: local);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> getTop10({bool local = false}) {
    return _firestore.getTop10(local: local);
  }
}
