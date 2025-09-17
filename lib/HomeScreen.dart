import 'package:flutter/material.dart';
import './MenuButton.dart';
import './main.dart';
import './SudokuGameScreen.dart';
import './LegendDot.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  static const _secondaryBtn = Color(0xFF424242); // Dark Gray
  int _selectedIndex = 0;
  final List<List<TextEditingController>> _controllers = List.generate(
    9,
        (_) => List.generate(9, (_) => TextEditingController()),
  );
  // List of widgets for each tab
  List<Widget> get _widgetOptions => <Widget>[
    buildHomeScreenBody(), // Call the method here
    Text(
      'Search Tab',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
    Text(
      'Profile Tab',
      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // Change the selected tab
    });
  }

  Widget buildHomeScreenBody() {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Title / Logo area
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 18,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.grid_4x4_rounded,
                          size: 64,
                          color: cs.primary,
                        ),
                        const SizedBox(height: 12),
                        Text('Sudoku Puzzle', style: text.headlineMedium),
                        const SizedBox(height: 4),
                        Text(
                          'Sharpen your mind • Solve the grid',
                          style: text.bodyMedium,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Menu Buttons
                  MenuButton(
                    icon: Icons.add_card_rounded,
                    label: 'New Game',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SudokuGameScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  MenuButton(
                    icon: Icons.pause_circle_filled_rounded,
                    label: 'Continue Game',
                    onPressed: hasSavedGame
                        ? () {
                      // TODO: resume last saved puzzle
                    }
                        : null,
                  ),
                  const SizedBox(height: 16),
                  MenuButton(
                    icon: Icons.bar_chart_rounded,
                    label: 'Statistics',
                    onPressed: () {
                      // TODO: open stats screen
                    },
                  ),
                  const SizedBox(height: 16),
                  MenuButton(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    backgroundOverride: _secondaryBtn,
                    onPressed: () {
                      // TODO: open settings
                    },
                  ),

                  const SizedBox(height: 32),

                  // Legend (optional)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 10,
                    runSpacing: 10,
                    children: const [
                      // LegendDot(color: SudokuApp._givenNum, label: 'Given #'),
                      // LegendDot(color: SudokuApp._userNum, label: 'User #'),
                      // LegendDot(color: SudokuApp._errorNum, label: 'Error'),
                      // LegendDot(color: SudokuApp._selected, label: 'Selected'),
                      // LegendDot(color: SudokuApp._rowCol, label: 'Row/Col'),
                      // LegendDot(color: SudokuApp._sameNum, label: 'Same #'),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool hasSavedGame = false; // toggle to true when you implement persistence

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        title: Text('My App'), // Title of the AppBar
        backgroundColor: Colors.blue, // You can change the background color
        actions: [
          IconButton(
            icon: Icon(Icons.settings),
            onPressed: () {
              // Add your logic here
            },
          ),
        ],
      ),
      body: Center(
        child: _widgetOptions.elementAt(
          _selectedIndex,
        ), // Display content based on selected tab
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex, // Set the currently selected tab
        onTap: _onItemTapped, // Handle tab change
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
