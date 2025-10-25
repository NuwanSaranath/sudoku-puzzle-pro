import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
// import 'widgets/HomeScreen.dart';
// import 'widgets/saveScore.dart';
import '../saveScore.dart';
import '../views/home_screen.dart';

enum Difficulty { easy, medium, hard }

class SudokuGameScreen extends StatefulWidget {
  const SudokuGameScreen({super.key});

  @override
  _SudokuGameScreenState createState() => _SudokuGameScreenState();
}

class _StatRow extends StatelessWidget {
  final String label;
  final String value;

  const _StatRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
        Text(
          value,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _SudokuGameScreenState extends State<SudokuGameScreen> {
  // Boards
  late List<List<int>> permenentSudokuGrid; // full solved board
  late List<List<int>> _sudokuGrid; // playable board (with zeros)

  // Given map (cells that are clues and cannot be edited)
  late List<List<bool>> _isGiven;

  // Locked cells
  late List<List<bool>> _isLocked;

  // Selection
  int? _selRow; // 0..8
  int? _selCol; // 0..8

  // Conflict highlights
  final Set<String> _conflictCells = {}; // store as "r,c"

  // Colors
  static const Color kBoardBg = Color(0xFFF5F5F5);
  static const Color kCellBg = Colors.white;
  static const Color kSelected = Color(0xFFBBDEFB);
  static const Color kHighlight = Color(0xFFE3F2FD);
  static const Color kErrorBg = Color(0x33D32F2F);
  static const Color kGivenText = Color(0xFF1A237E);
  static const Color kUserText = Color(0xFF1565C0);
  int _remainingChances = 3;
  double _progressValue = 1.0;
  late Timer _timer;
  int _elapsedSeconds = 0;

  String _key(int r, int c) => '$r,$c';

  bool _sameBlock(int r1, int c1, int r2, int c2) =>
      (r1 ~/ 3 == r2 ~/ 3) && (c1 ~/ 3 == c2 ~/ 3);
  int _score = 0;
  int _streak = 0; // correct-in-a-row streak
  int _wrongMoves = 0;
  int _hintsUsed = 0; // if you add a Hint feature
  DateTime? _lastCorrectAt; // for speed bonus if you want
  Difficulty _difficulty = Difficulty.easy; // default

  @override
  void initState() {
    super.initState();

    // 1) Build a solved grid once.
    permenentSudokuGrid = _generateSudokuSolution();

    // 2) Make a deep copy into the playable grid and remove numbers.
    _sudokuGrid = _deepCopy(permenentSudokuGrid);
    _removeNumbers(_sudokuGrid, cluesCount: 70);

    // 3) Mark "givens" so we can prevent editing.
    _isGiven = List.generate(
      9,
      (i) => List.generate(9, (j) => _sudokuGrid[i][j] != 0),
    );

    // 4) Initialize locked cells (starting all as false)
    _isLocked = List.generate(9, (i) => List.filled(9, false));
    _startTimer();
  }

  // ====== Generation helpers ======

  List<List<int>> _deepCopy(List<List<int>> src) =>
      List.generate(9, (i) => List<int>.from(src[i]));

  List<List<int>> _generateSudokuSolution() {
    final grid = List.generate(9, (_) => List.filled(9, 0));
    _fillGrid(grid);
    return grid;
  }

  bool _fillGrid(List<List<int>> grid) {
    for (int row = 0; row < 9; row++) {
      for (int col = 0; col < 9; col++) {
        if (grid[row][col] == 0) {
          final numbers = List.generate(9, (i) => i + 1)..shuffle();
          for (final num in numbers) {
            if (_isValid(grid, row, col, num)) {
              grid[row][col] = num;
              if (_fillGrid(grid)) return true;
              grid[row][col] = 0; // backtrack
            }
          }
          return false; // no valid number found
        }
      }
    }
    return true; // filled correctly
  }

  bool _isValid(List<List<int>> grid, int row, int col, int num) {
    // Row
    for (int i = 0; i < 9; i++) {
      if (grid[row][i] == num) return false;
    }
    // Column
    for (int i = 0; i < 9; i++) {
      if (grid[i][col] == num) return false;
    }
    // Block
    final startRow = (row ~/ 3) * 3;
    final startCol = (col ~/ 3) * 3;
    for (int i = startRow; i < startRow + 3; i++) {
      for (int j = startCol; j < startCol + 3; j++) {
        if (grid[i][j] == num) return false;
      }
    }
    return true;
  }

  void _removeNumbers(List<List<int>> grid, {required int cluesCount}) {
    // remove (81 - cluesCount) cells randomly
    // NOTE: cluesCount must be at least 17 for a valid Sudoku (not enforcing uniqueness here).
    final toRemove = 81 - cluesCount;
    int removed = 0;
    final rand = Random();

    while (removed < toRemove) {
      final row = rand.nextInt(9); // 0..8
      final col = rand.nextInt(9); // 0..8
      if (grid[row][col] != 0) {
        grid[row][col] = 0;
        removed++;
      }
    }
  }

  // ====== Conflict detection ======

  List<Point<int>> _conflictsFor(int r, int c, int num) {
    final List<Point<int>> out = [];
    // row
    for (int j = 0; j < 9; j++) {
      if (j == c) continue;
      if (_sudokuGrid[r][j] == num) out.add(Point(r, j));
    }
    // column
    for (int i = 0; i < 9; i++) {
      if (i == r) continue;
      if (_sudokuGrid[i][c] == num) out.add(Point(i, c));
    }
    // block
    final br = (r ~/ 3) * 3;
    final bc = (c ~/ 3) * 3;
    for (int i = br; i < br + 3; i++) {
      for (int j = bc; j < bc + 3; j++) {
        if (i == r && j == c) continue;
        if (_sudokuGrid[i][j] == num) out.add(Point(i, j));
      }
    }
    return out;
  }

  // Updates chances and progress bar when a chance is used
  void useChance() {
    if (_remainingChances > 0) {
      setState(() {
        _remainingChances--;
        _progressValue =
            _remainingChances / 3; // Update progress based on remaining chances
      });
    } else {
      showGameOverDialog();
    }
  }

  // Method to start the timer
  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedSeconds++; // Increment time every second
      });
    });
  }

  // Convert seconds to MM:SS format
  String get _formattedTime {
    int minutes = _elapsedSeconds ~/ 60;
    int seconds = _elapsedSeconds % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  void _resumeGame() {
    // Unpause timers, re-enable input, etc.
  }

  void _grantExtraChancesAndResume(int n) {
    setState(() => _remainingChances += n);
    useChance();
    Navigator.of(context).pop(); // close the dialog
    // _resumeGame();                         // continue playing
  }

  double get _diffMult {
    switch (_difficulty) {
      case Difficulty.easy:
        return 1.0;
      case Difficulty.medium:
        return 1.5;
      case Difficulty.hard:
        return 2.0;
    }
  }

  void _applyCorrectMoveScore() {
    // Base points per correct cell
    int base = 50;

    // Streak bonus: +20 per streak step, capped at +100
    int streakBonus = (20 * _streak).clamp(0, 100);

    // Optional speed bonus if last correct was within 8 seconds
    int speedBonus = 0;
    if (_lastCorrectAt != null) {
      final dt = DateTime.now().difference(_lastCorrectAt!);
      if (dt.inSeconds <= 8) speedBonus = 10;
    }

    int gained = ((base + streakBonus + speedBonus) * _diffMult).round();

    setState(() {
      _score += gained;
      _streak += 1;
      _lastCorrectAt = DateTime.now();
    });
  }

  void _applyWrongMovePenalty() {
    // Penalty for a wrong entry
    int penalty = (25 * _diffMult).round();

    setState(() {
      _score = (_score - penalty).clamp(0, 1 << 31);
      _streak = 0;
      _wrongMoves += 1;
    });
  }

  void _applyHintPenalty() {
    int penalty = (50 * _diffMult).round();
    setState(() {
      _score = (_score - penalty).clamp(0, 1 << 31);
      _hintsUsed += 1;
      _streak = 0;
    });
  }

  bool _isBoardComplete() {
    for (var row in _sudokuGrid) {
      for (var v in row) {
        if (v == 0) return false;
      }
    }
    return true;
  }

  _goToMainMenu() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => HomeScreen()),
      (route) => false, // clear back stack
    );
  }

  void _applyCompletionBonusAndShowWin() {
    // Time bonus: up to 10 minutes (600s). Faster = more points.
    int timeBonus = (600 - _elapsedSeconds).clamp(0, 600); // 0..600
    // Lives bonus: reward remaining chances
    int livesBonus = _remainingChances * 100;
    // Clean play bonus: fewer wrong moves = better
    int cleanBonus = (200 - (20 * _wrongMoves)).clamp(0, 200);
    // Base completion
    int base = 500;

    int gained = ((base + timeBonus + livesBonus + cleanBonus) * _diffMult)
        .round();

    setState(() {
      _score += gained;
    });

    submitHighScore(score: _score, timeMs: _elapsedSeconds);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        titlePadding: const EdgeInsets.only(top: 16, left: 20, right: 20),
        contentPadding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
        actionsPadding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        title: Row(
          children: const [
            Icon(Icons.emoji_events, size: 28, color: Colors.amber),
            SizedBox(width: 10),
            Expanded(
              child: Text(
                'You Win!',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 22),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatRow(label: 'Final Score', value: '$_score'),
            const SizedBox(height: 6),
            _StatRow(label: 'Time', value: _formattedTime),
            const SizedBox(height: 6),
            _StatRow(label: 'Wrong Moves', value: '$_wrongMoves'),
            const SizedBox(height: 6),
            _StatRow(label: 'Hints Used', value: '$_hintsUsed'),
          ],
        ),
        actions: [
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FractionallySizedBox(
                widthFactor: 0.9,
                child: TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const SudokuGameScreen()));// implement your new puzzle
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'New Game',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const SizedBox(height: 8),
              FractionallySizedBox(
                widthFactor: 0.9,
                child: TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _goToMainMenu(); // optional: navigate to your menu screen
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:Colors.green.shade600,
                    foregroundColor: Colors.black87,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Main Menu',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ====== UI ======

  // Show Game Over dialog
  void showGameOverDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Center(
            child: Text(
              "Game Over!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24,
                color: Colors.blue.shade800, // Blue theme for title
              ),
            ),
          ),
          content: const Text(
            "You've used all your chances.",
            textAlign: TextAlign.center, // Center content
            style: TextStyle(fontSize: 18, color: Colors.black),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          actionsPadding: const EdgeInsets.all(10),
          actions: [
            Container(
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,

                children: [
                  FractionallySizedBox(
                    widthFactor: 0.9, // 80% of parent width
                    child: TextButton(
                      onPressed: () => _grantExtraChancesAndResume(4),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Continue with 3 Chances",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FractionallySizedBox(
                    widthFactor: 0.9, // 80% width
                    child: TextButton(
                      onPressed: () {},
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        foregroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Restart",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  FractionallySizedBox(
                    widthFactor: 0.9, // 80% width
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                        // Exit logic
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.grey.shade400,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "New Game",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  // Optional: Reset the game
  void _resetGame() {
    setState(() {
      _elapsedSeconds = 0;
      _remainingChances = 3;
      _progressValue = 1.0;
      _sudokuGrid = List.generate(9, (i) => List.generate(9, (j) => 0));
      _isLocked = List.generate(9, (i) => List.generate(9, (j) => false));
      _conflictCells.clear();
      _selRow = null;
      _selCol = null;
      _startTimer(); // Restart timer if needed
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Sudoku Game")),
      body: SafeArea(
        child: Container(
          color: kBoardBg,
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              // Top row (difficulty/timer)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Easy",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      "Score: $_score",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                child: Column(
                  children: [
                    // Display chances as a progress bar
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: [
                          Text(
                            "Remaining Chances: $_remainingChances",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          LinearProgressIndicator(
                            value: _progressValue,
                            minHeight: 10,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Board
              _buildBoard(),

              const SizedBox(height: 12),

              // Controls (dummy icons)
              SizedBox(
                height: 60,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: const [
                    Icon(Icons.undo, size: 36),
                    Icon(Icons.edit, size: 36),
                    Icon(Icons.delete, size: 36),
                    Icon(Icons.lightbulb_outline, size: 36),
                  ],
                ),
              ),

              // Keypad (1..9)
              _buildKeypad(),
            ],
          ),
        ),
      ),
    );
  }

  // Board rendering (9x9 grid)
  Widget _buildBoard() {
    return Container(
      padding: const EdgeInsets.all(3),
      color: Colors.grey.shade700,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 3,
          mainAxisSpacing: 3,
          childAspectRatio: 1,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        // 9 blocks
        shrinkWrap: true,
        itemBuilder: (context, blockIndex) {
          final blockRow = blockIndex ~/ 3; // 0..2
          final blockCol = blockIndex % 3; // 0..2

          return Container(
            color: Colors.grey.shade400,
            alignment: Alignment.center,
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 3,
                mainAxisSpacing: 3,
                childAspectRatio: 1,
              ),
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 9,
              // cells in block
              shrinkWrap: true,
              itemBuilder: (context, cellIndex) {
                final localRow = cellIndex ~/ 3;
                final localCol = cellIndex % 3;

                // GLOBAL coords
                final r = blockRow * 3 + localRow;
                final c = blockCol * 3 + localCol;

                // Background priority: selected > conflict > row/col/block > normal
                Color bg = kCellBg;

                if (_selRow != null && _selCol != null) {
                  if (r == _selRow && c == _selCol) {
                    bg = kSelected;
                  } else if (r == _selRow ||
                      c == _selCol ||
                      _sameBlock(r, c, _selRow!, _selCol!)) {
                    bg = kHighlight;
                  }
                }
                if (_conflictCells.contains(_key(r, c))) {
                  bg = kErrorBg;
                }

                final value = _sudokuGrid[r][c];
                final isGiven = _isGiven[r][c];

                return GestureDetector(
                  onTap: () {
                    if (_sudokuGrid[r][c] == 0) {
                      setState(() {
                        _selRow = r;
                        _selCol = c;
                        _conflictCells
                            .clear(); // Clear conflict cells when selecting a new cell
                      });
                    }
                  },
                  child: Container(
                    color: bg,
                    alignment: Alignment.center,
                    child: Text(
                      value == 0 ? "" : "$value",
                      style: TextStyle(
                        color: _conflictCells.contains(_key(r, c))
                            ? Colors.red
                            : (isGiven ? kGivenText : kUserText),
                        fontSize: 22,
                        fontWeight: isGiven ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Helper method to generate a unique key for a cell
  //   String _key(int r, int c) => "$r-$c";

  // Highlight all conflicting cells in row, column, and 3x3 square
  void _highlightConflicts(int row, int col, int wrongNumber) {
    _conflictCells.clear();

    // Add the wrong cell itself
    _conflictCells.add(_key(row, col));

    // Highlight row and column
    for (int i = 0; i < 9; i++) {
      if (_sudokuGrid[row][i] == wrongNumber) _conflictCells.add(_key(row, i));
      if (_sudokuGrid[i][col] == wrongNumber) _conflictCells.add(_key(i, col));
    }

    // Highlight 3x3 square
    int startRow = (row ~/ 3) * 3;
    int startCol = (col ~/ 3) * 3;
    for (int r = startRow; r < startRow + 3; r++) {
      for (int c = startCol; c < startCol + 3; c++) {
        if (_sudokuGrid[r][c] == wrongNumber) _conflictCells.add(_key(r, c));
      }
    }
  }

  Widget _buildKeypad() {
    return Container(
      padding: const EdgeInsets.only(left: 2, top: 10, right: 2, bottom: 12),
      width: double.infinity,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 9,
          crossAxisSpacing: 6,
          mainAxisSpacing: 6,
          childAspectRatio: 0.9,
        ),
        physics: const NeverScrollableScrollPhysics(),
        itemCount: 9,
        shrinkWrap: true,
        itemBuilder: (context, index) {
          final num = index + 1;
          return GestureDetector(
            onTap: () {
              if (_selRow == null || _selCol == null) return;

              final r = _selRow!;
              final c = _selCol!;

              // Don't allow editing a given or locked cell
              if (_isGiven[r][c] || _isLocked[r][c]) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Can't change a given or locked cell"),
                  ),
                );
                return;
              }

              // Validate selected number with the permanent grid (full solved board)
              final correctNumber = permenentSudokuGrid[r][c];

              if (num == correctNumber) {
                // Correct number, update the player's grid
                setState(() {
                  _sudokuGrid[r][c] = num;
                  _isLocked[r][c] = true; // Lock the cell after a valid number
                  _conflictCells.clear(); // Clear any conflict highlights
                });

                _applyCorrectMoveScore();

                // Check completion
                if (_isBoardComplete()) {
                  _applyCompletionBonusAndShowWin();
                }
              } else {
                // Incorrect number
                useChance();
                _applyWrongMovePenalty();
                setState(() {
                  _highlightConflicts(r, c, num); // Highlight all conflicts
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Incorrect number")),
                );
              }
            },
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              alignment: Alignment.center,
              child: Text(
                "$num",
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
