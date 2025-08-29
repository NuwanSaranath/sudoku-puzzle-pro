import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sudoku_puzzle_pro/SudokuGameScreen.dart';

void main() => runApp(const SudokuApp());

class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});
  static const _bgLight = Color(0xFFF5F5F5); // Background
  static const _bgDark = Color(0xFF1E1E1E); // Dark Mode Background
  static const _board = Color(0xFFFFFFFF); // Sudoku Board card
  // Numbers
  static const _givenNum = Color(0xFF1A237E); // Dark Indigo
  static const _userNum = Color(0xFF1565C0); // Medium Blue
  static const _noteNum = Color(0xFF757575); // Gray
  static const _errorNum = Color(0xFFD32F2F); // Red
  // Highlights
  static const _selected = Color(0xFFBBDEFB); // Light Blue
  static const _rowCol = Color(0xFFE3F2FD); // Very Light Blue
  static const _sameNum = Color(0xFFAED581); // Soft Green
  // Buttons
  static const _primaryBtn = Color(0xFF1976D2); // Strong Blue
  static const _secondaryBtn = Color(0xFF424242); // Dark Gray
  static const _hintBtn = Color(0xFFFFB300); // Amber
  static const _disabledBtn = Color(0xFFBDBDBD); // Light Gray
  // Win accents (kept for future screens)
  static const _winGreen = Color(0xFF4CAF50);
  static const _winOrange = Color(0xFFFF9800);
  static const _winBlue = Color(0xFF2196F3);

  // Light & Dark themes
  ThemeData _lightTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _bgLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryBtn,
        brightness: Brightness.light,
        primary: _primaryBtn,
        onPrimary: Colors.white,
        secondary: _hintBtn,
        surface: _board,
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: _givenNum,
          letterSpacing: .5,
        ),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: _userNum),
        bodyMedium: TextStyle(color: _noteNum),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBtn,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  ThemeData _darkTheme() {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: _bgDark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryBtn,
        brightness: Brightness.dark,
        primary: _primaryBtn,
        onPrimary: Colors.white,
        secondary: _hintBtn,
        surface: const Color(0xFF2C2C2C),
      ),
      textTheme: const TextTheme(
        headlineMedium: TextStyle(
          fontWeight: FontWeight.w700,
          color: Colors.white,
          letterSpacing: .5,
        ),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        bodyMedium: TextStyle(color: _noteNum),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryBtn,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku Puzzle',
      debugShowCheckedModeBanner: false,
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: ThemeMode.system,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});

  @override
  State<EntryScreen> createState() => EntryScreenState();
}

class EntryScreenState extends State<EntryScreen> {
  bool isSignedIn = false; // Sign-in state
  bool isGuest = false; // Guest mode state

  // Controllers for email and password
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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

                  // Email & Password Fields
                  if (!isSignedIn && !isGuest) ...[
                    // Email Field
                    TextField(
                      controller: emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        hintText: 'Enter your email',
                        prefixIcon: Icon(Icons.email),
                        border: OutlineInputBorder(),
                        suffixIcon: emailController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  emailController.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Password Field
                    TextField(
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        hintText: 'Enter your password',
                        prefixIcon: Icon(Icons.lock),
                        border: OutlineInputBorder(),
                        suffixIcon: passwordController.text.isNotEmpty
                            ? IconButton(
                                icon: Icon(Icons.clear),
                                onPressed: () {
                                  passwordController.clear();
                                },
                              )
                            : null,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Forgot Password TextButton
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: Implement Forgot Password flow
                          // Navigate to the forgot password screen or show a dialog.
                        },
                        child: Text(
                          'Forgot Password?',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Sign In Button
                    _MenuButton(
                      icon: Icons.login,
                      label: 'Sign In',
                      onPressed: () {
                        setState(() {
                          isSignedIn = true;
                        });

                        // Navigate to HomeScreen (replace _HomeScreenState with HomeScreen widget)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const HomeScreen(),
                          ),
                        );
                      },
                    ),
                  ],

                  // Google Sign-In Button
                  if (!isSignedIn && !isGuest) ...[
                    const SizedBox(height: 16),
                    _MenuButton(
                      icon: Icons.account_circle,
                      label: 'Sign in with Google',
                      onPressed: () {
                        // TODO: Implement Google Sign-In
                      },
                    ),
                  ],

                  const SizedBox(height: 16),

                  // Sign In / Sign Out buttons
                  isSignedIn
                      ? _MenuButton(
                          icon: Icons.exit_to_app,
                          label: 'Sign Out',
                          onPressed: () {
                            setState(() {
                              isSignedIn = false; // Log out
                            });
                          },
                        )
                      : isGuest
                      ? _MenuButton(
                          icon: Icons.exit_to_app,
                          label: 'Sign Out as Guest',
                          onPressed: () {
                            setState(() {
                              isGuest = false; // Log out as guest
                            });
                          },
                        )
                      : _MenuButton(
                          icon: Icons.account_circle,
                          label: 'Sign in as Guest',
                          onPressed: () {
                            setState(() {
                              isGuest = true; // Log in as guest
                            });
                          },
                        ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeScreenState extends State<HomeScreen> {
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
                  _MenuButton(
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
                  _MenuButton(
                    icon: Icons.pause_circle_filled_rounded,
                    label: 'Continue Game',
                    onPressed: hasSavedGame
                        ? () {
                            // TODO: resume last saved puzzle
                          }
                        : null,
                  ),
                  const SizedBox(height: 16),
                  _MenuButton(
                    icon: Icons.bar_chart_rounded,
                    label: 'Statistics',
                    onPressed: () {
                      // TODO: open stats screen
                    },
                  ),
                  const SizedBox(height: 16),
                  _MenuButton(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    backgroundOverride: SudokuApp._secondaryBtn,
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
                      _LegendDot(color: SudokuApp._givenNum, label: 'Given #'),
                      _LegendDot(color: SudokuApp._userNum, label: 'User #'),
                      _LegendDot(color: SudokuApp._errorNum, label: 'Error'),
                      _LegendDot(color: SudokuApp._selected, label: 'Selected'),
                      _LegendDot(color: SudokuApp._rowCol, label: 'Row/Col'),
                      _LegendDot(color: SudokuApp._sameNum, label: 'Same #'),
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

class _MenuButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final Color? backgroundOverride;

  const _MenuButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundOverride,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundOverride ?? theme.colorScheme.primary;

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: Icon(icon, size: 26),
        label: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(label),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: onPressed == null ? SudokuApp._disabledBtn : bg,
          foregroundColor: Colors.white,
          disabledForegroundColor: Colors.white,
          disabledBackgroundColor: SudokuApp._disabledBtn,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;
  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme.bodyMedium;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: text),
      ],
    );
  }
}

// class SudokuGameScreen extends StatefulWidget {
//   const SudokuGameScreen({super.key});
//
//   @override
//   _SudokuGameScreenState createState() => _SudokuGameScreenState();
// }
//
// class _SudokuGameScreenState extends State<SudokuGameScreen> {
//   // List to hold controllers for each cell in the 9x9 grid
//   final List<List<TextEditingController>> _controllers = List.generate(
//     9,
//     (_) => List.generate(9, (_) => TextEditingController()),
//   );
//
//   @override
//   void dispose() {
//     // Dispose the controllers to avoid memory leaks
//     for (var row in _controllers) {
//       for (var controller in row) {
//         controller.dispose();
//       }
//     }
//     super.dispose();
//   }
//
//   // This method will create the Sudoku grid using TextFields
//   Widget buildSudokuGrid() {
//     return Scaffold(
//
//       body: SafeArea(
//         child: Container(
//           padding: EdgeInsets.all(5),
//           // alignment: Alignment.center,
//           color: SudokuApp._bgLight,
//           child: Column(
//             children: [
//               Container(
//                 padding: EdgeInsets.only(
//                   top: 10,
//                   bottom: 10
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text("Easy",
//                       style: TextStyle(
//                         fontSize: 25,
//                         color: Colors.black,
//                         fontWeight: FontWeight.bold
//                       ),
//                     ),
//                     Text("01:30",
//                       style: TextStyle(
//                           fontSize: 25,
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold
//                       ),)
//                   ],
//                 ),
//               ),
//               Container(
//                 padding: EdgeInsets.all(3),
//                 width: double.maxFinite,
//                 // height: 400,
//                 color: Colors.grey.shade700,
//                 child: GridView.builder(
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 3,
//                     crossAxisSpacing: 3,
//                     mainAxisSpacing: 3,
//                     childAspectRatio: 1,
//                   ),
//                   physics: ScrollPhysics(),
//                   itemCount: 9,
//                   shrinkWrap: true,
//                   itemBuilder: (buildContext, index) {
//                     return Container(
//                       color: Colors.grey.shade400,
//                       alignment: Alignment.center,
//                       child: GridView.builder(
//                         gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                           crossAxisCount: 3,
//                           crossAxisSpacing: 3,
//                           mainAxisSpacing: 3,
//                           childAspectRatio: 1,
//                         ),
//                         physics: ScrollPhysics(),
//                         itemCount: 9,
//                         shrinkWrap: true,
//                         itemBuilder: (buildContext, index) {
//                           return Container(
//                             // color: Colors.white,
//                             color: Colors.white,
//                             alignment: Alignment.center,
//                             child: Text(
//                               "${index + 1}",
//                               style: TextStyle(
//                                 color: Colors.black,
//                                 fontSize: 25,
//                                 fontWeight: FontWeight.w400
//                               ),
//                             ),
//                           );
//                         },
//                       ),
//                     );
//                   },
//                 ),
//               ),
//               Container(
//                 height: 70,
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                   children: [
//                     Container(
//                       // height: 70,
//                       // width: 20,
//                       child:Icon(
//                         Icons.undo,
//                         size: 50,
//                       ),
//                     ),
//                     Container(
//                       // height: 70,
//                       // width: 20,
//                       child:Icon(
//                         Icons.edit,
//                         size: 50,
//                       ),
//                     ),
//                     Container(
//                       // height: 70,
//                       // width: 20,
//                       child:Icon(
//                         Icons.delete ,
//                         size: 50,
//                       ),
//                     ),
//                     Container(
//                       // height: 70,
//                       // width: 20,
//                       child:Icon(
//                         Icons.lightbulb_outline,
//                         size: 50,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//
//               Container(
//                 // color: Colors.black,
//                 padding: EdgeInsets.only(
//                     left: 2.0,
//                     top: 10.0,
//                     right: 2.0,
//                     bottom: 20.0
//                 ),
//                 width: double.infinity,
//                 child: GridView.builder(
//
//                   gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 9,
//                     crossAxisSpacing: 3,
//                     mainAxisSpacing: 3,
//                     childAspectRatio: 0.7,
//                   ),
//                   physics: ScrollPhysics(),
//                   itemCount: 9,
//                   shrinkWrap: true,
//                   itemBuilder: (buildContext, index) {
//                     return Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                         boxShadow: [
//                           BoxShadow(
//                             color: Colors.black.withOpacity(0.2),
//                             blurRadius: 10,
//                             offset: Offset(0, 4),
//                           ),
//                         ],
//                       ),
//
//                       alignment: Alignment.center,
//                       child: Text(
//                         "${index + 1}",
//                         style: TextStyle(
//                             color: Colors.black,
//                             fontSize: 25,
//                             fontWeight: FontWeight.w400
//                         ),
//                       ),
//                     );
//                   },
//                 ),
//               ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text("New Sudoku Game")),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             // Wrap the GridView with Expanded to give it space
//             Expanded(child: buildSudokuGrid()),
//             const SizedBox(height: 20),
//             const Text("Here you will display the 9x9 grid and controls"),
//           ],
//         ),
//       ),
//     );
//   }
// }

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sign In')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                // Handle sign-in logic here (e.g., validate credentials)
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SudokuGameScreen(),
                  ),
                );
              },
              child: const Text('Sign In'),
            ),
          ],
        ),
      ),
    );
  }
}
