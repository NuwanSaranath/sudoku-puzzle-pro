import 'dart:async';
import 'package:flutter/material.dart';
import '../services/game_service.dart';
import '../services/firestore_service.dart';
import '../models/sudoku_model.dart';

class SudokuViewModel extends ChangeNotifier {
  final GameService _gameService = GameService();
  final FirestoreService _firestoreService = FirestoreService();

  late SudokuStats stats;
  Timer? _timer;

  SudokuViewModel() {
    stats = SudokuStats();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      stats.elapsedSeconds++;
      notifyListeners();
    });
  }

  void correctMove() {
    _gameService.correctMove(stats);
    notifyListeners();
  }

  void wrongMove() {
    _gameService.wrongMove(stats);
    notifyListeners();
  }

  void completeGame() async {
    await _firestoreService.submitBestResult(
      score: stats.score,
      timeMs: stats.elapsedSeconds,
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
