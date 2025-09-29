import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'AuthGate.dart';
import './SudokuGameScreen.dart';
import './HomeScreen.dart';
import './MenuButton.dart';
import './RegisterScreen.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase is already initialized, ignore
    print('Firebase is already initialized');
  }
  await Hive.initFlutter();
  runApp(const SudokuApp());
}

Future<User> ensureSignedIn() async {
  final auth = FirebaseAuth.instance;
  final current = auth.currentUser;
  if (current != null) return current;
  final cred = await auth.signInAnonymously();
  return cred.user!;
}
class SudokuApp extends StatelessWidget {
  const SudokuApp({super.key});

  // ====== YOUR THEME COLORS (unchanged) ======
  static const _bgLight = Color(0xFFF5F5F5);
  static const _bgDark = Color(0xFF1E1E1E);
  static const _board = Color(0xFFFFFFFF);
  static const _givenNum = Color(0xFF1A237E);
  static const _userNum = Color(0xFF1565C0);
  static const _noteNum = Color(0xFF757575);
  static const _errorNum = Color(0xFFD32F2F);
  static const _selected = Color(0xFFBBDEFB);
  static const _rowCol = Color(0xFFE3F2FD);
  static const _sameNum = Color(0xFFAED581);
  static const _primaryBtn = Color(0xFF1976D2);
  static const _secondaryBtn = Color(0xFF424242);
  static const _hintBtn = Color(0xFFFFB300);
  static const _winGreen = Color(0xFF4CAF50);
  static const _winOrange = Color(0xFFFF9800);
  static const _winBlue = Color(0xFF2196F3);

  ThemeData _lightTheme() => ThemeData(
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
        textStyle:
        const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
  );

  ThemeData _darkTheme() => ThemeData(
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
        textStyle:
        const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sudoku Puzzle',
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: _lightTheme(),
      darkTheme: _darkTheme(),
      themeMode: ThemeMode.system,

      // 🔐 Route based on Firebase Auth state (null = signed out)
      // home: StreamBuilder<User?>(
      //   stream: FirebaseAuth.instance.authStateChanges(),
      //   builder: (context, snap) {
      //     if (snap.connectionState == ConnectionState.waiting) {
      //       return const Scaffold(
      //         body: Center(child: CircularProgressIndicator()),
      //       );
      //     }
      //     final user = snap.data;
      //     if (user == null) {
      //       return const EntryScreen(); // show sign-in/guest screen
      //     }
      //     return const HomeScreen(); // already signed in
      //   },
      // ),
    );
  }
}

/// ===== ENTRY SCREEN (wired to Firebase Anonymous Sign-In) =====
class EntryScreen extends StatefulWidget {
  const EntryScreen({super.key});
  @override
  State<EntryScreen> createState() => EntryScreenState();
}

class EntryScreenState extends State<EntryScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  Future<void> _signInAnonymously() async {
    print("-- Working _signInAnonymously --");
    await FirebaseAuth.instance.signInAnonymously();
    // StreamBuilder above will navigate to HomeScreen automatically
  }

  Future<void> _signOut() async {
    await FirebaseAuth.instance.signOut();
  }

  bool _signingIn = false;

  Future<void> signInWithEmailPassword() async {
    final email = emailController.text.trim();
    final pass  = passwordController.text;

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter both email and password')),
      );
      return;
    }

    setState(() => _signingIn = true);
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: pass,
      );

      if (!mounted) return;
      // Go to your home screen on success
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    } on FirebaseAuthException catch (e) {
      final msg = switch (e.code) {
        'invalid-email'        => 'Invalid email address.',
        'user-disabled'        => 'This account is disabled.',
        'user-not-found'       => 'No account found for that email.',
        'wrong-password'       => 'Incorrect password.',
        'too-many-requests'    => 'Too many attempts. Try again later.',
        'network-request-failed' => 'Network error. Check your connection.',
        _                      => 'Sign in failed: ${e.code}',
      };
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    } catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Something went wrong. Please try again.')),
      );
    } finally {
      if (mounted) setState(() => _signingIn = false);
    }
  }




  @override
  Widget build(BuildContext context) {
    final cs = Theme
        .of(context)
        .colorScheme;
    final text = Theme
        .of(context)
        .textTheme;

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
                  // Header card
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
                        Icon(Icons.grid_4x4_rounded, size: 64,
                            color: cs.primary),
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

                  // Email/password
                  TextField(
                    controller: emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      hintText: 'Enter your password',
                      prefixIcon: Icon(Icons.lock),
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Sign in (placeholder)
                  MenuButton(
                    icon: _signingIn ? Icons.hourglass_empty : Icons.login,
                    label: _signingIn ? 'Signing in...' : 'Sign In',
                    onPressed: _signingIn ? null : signInWithEmailPassword,
                  ),
                  const SizedBox(height: 16),

                  // Anonymous (Guest) sign-in with Firebase
                  MenuButton(
                    icon: Icons.person_outline,
                    label: 'Continue as Guest',
                    onPressed: () async {
                      await _signInAnonymously(); // your method
                      if (!mounted) return;
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (
                            context) => const HomeScreen()),
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // --- "Don't have an account? Register" row ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't have an account? ",
                        style: text.bodyMedium,
                      ),
                      TextButton(
                        style: TextButton.styleFrom(
                          foregroundColor: cs.primary,
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                        ),
                        onPressed: () {
                          Navigator.push(
                              context,
                            MaterialPageRoute(builder: (_) => const RegisterScreen()),
                          );
                          Or: Navigator.pushNamed(context, '/register');
                        },
                        child: const Text('Register'),
                      ),
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
}


  /// (Optional) Your SignInScreen kept as-is; not used by the router above.
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
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const SudokuGameScreen()),
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
