import '../models/sudoku_model.dart';

class GameService {
  void correctMove(SudokuStats stats) {
    stats.score += 50 + (10 * stats.streak);
    stats.streak++;
  }

  void wrongMove(SudokuStats stats) {
    stats.score = (stats.score - 25).clamp(0, 999999);
    stats.streak = 0;
    stats.wrongMoves++;
  }
}
