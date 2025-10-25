class SudokuStats {
  int score;
  int streak;
  int wrongMoves;
  int hintsUsed;
  int elapsedSeconds;
  int remainingChances;

  SudokuStats({
    this.score = 0,
    this.streak = 0,
    this.wrongMoves = 0,
    this.hintsUsed = 0,
    this.elapsedSeconds = 0,
    this.remainingChances = 3,
  });
}
