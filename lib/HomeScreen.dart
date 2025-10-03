import 'dart:ui' show FontFeature;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show HapticFeedback;

import 'package:firebase_auth/firebase_auth.dart';
import './saveScore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import './MenuButton.dart';
import './SudokuGameScreen.dart';
import 'package:hive/hive.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ====== STATE ======
  Stream<DocumentSnapshot<Map<String, dynamic>>>? _meStream;
  String? _uid;
  int selectedTab = 0; // 0 = Local, 1 = Global
  static const _secondaryBtn = Color(0xFF424242);
  int _selectedIndex = 0;
  bool hasSavedGame = false;
  int localHighScore = 0;
  int fast = 0;
  int best = 0;
  bool isOnlien = false;
  bool isStatic = true;
  // local-region detection
  String? _regionField; // 'country' or 'location'
  String? _regionValue; // e.g. 'LK' or 'United States'

  // ====== LIFECYCLE ======
  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    _uid = user?.uid;

    if (_uid != null) {
      _meStream = FirebaseFirestore.instance.collection('users').doc(_uid!).snapshots();

      print("_meStream");
      _meStream!.listen(
            (snap) {

          final data = snap.data();
          print(data?["location"]);
          debugPrint('meStream doc id: ${snap.id}, exists: ${snap.exists}');
          debugPrint('meStream data: $data'); // full map
          debugPrint('AUTH uid=${FirebaseAuth.instance.currentUser?.uid}');
          debugPrint('STREAM path=users/$_uid');
          debugPrint('name: ${data?['name']}'); // example single field
        },
        onError: (e) => debugPrint('meStream error: $e'),
      );
      _loadRegionFromMyDoc();
    }

    // If login state can change while this screen is mounted:
    FirebaseAuth.instance.authStateChanges().listen((u) {
      setState(() {
        _uid = u?.uid;
        _meStream = (u == null)
            ? null
            : FirebaseFirestore.instance.collection('users').doc(u.uid).snapshots();
      });
      _loadRegionFromMyDoc();
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadHighScore();
    });
    // loadHighScore();
  }
  Future<void> loadHighScore() async {
    best  = await getLocalHighScore(); // Hive function
    // setState(() {}); // trigger rebuild
  }
  Future<int> getLocalHighScore() async {
    var box = await Hive.openBox('highScores');
    return box.get('highScore', defaultValue: 0);
  }
  Future<void> _loadRegionFromMyDoc() async {
    final uid = _uid;
    if (uid == null) return;
    final snap = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final d = snap.data() ?? {};

    // Prefer 'country' if present; else use 'location'
    final location = (d['location'] as String?)?.trim();

    // setState(() {
    //    if (location != null && location.isNotEmpty) {
    //     _regionField = 'location';
    //     _regionValue = location;
    //   } else {
    //     _regionField = null;
    //     _regionValue = null;
    //   }
    // });
  }

  // ====== FORMAT HELPERS ======
  int _asInt(dynamic v, int fallback) {
    if (v is int) return v;
    if (v is double) return v.toInt();
    if (v is String) return int.tryParse(v) ?? fallback;
    return fallback;
  }

  String _fmtScore(num n)  {
    int highScore = localHighScore ;
    final s;
    if(highScore>n){
      s = n.toInt().toString();
    }else{
      s = n.toInt().toString();
    }

    return s.replaceAllMapped(RegExp(r'\B(?=(\d{3})+(?!\d))'), (m) => ',');
  }

  String _fmtMs(int? ms) {
    if (ms == null || ms >= (1 << 30)) return '—';
    final totalSec = ms ;
    final mm = (totalSec ~/ 60).toString().padLeft(2, '0');
    final ss = (totalSec % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }

  // ====== RANK & LEADERBOARD ======
  Future<int> _myRankByBestScore({required bool local}) async {
    final uid = _uid;
    if (uid == null) return 0;

    final users = FirebaseFirestore.instance.collection('users');

    // my stats
    final me = await users.doc(uid).get();
    final md = me.data() ?? {};
    final myScore = _asInt(md['bestScore'], 0);
    final myTime = _asInt(md['fastestTimeMs'], 1 << 30);

    // base query (optional local filter)
    Query<Map<String, dynamic>> base = users;
    if (local && _regionField != null && _regionValue != null) {
      base = base.where(_regionField!, isEqualTo: _regionValue);
    }

    final higherSnap = await base.where('bestScore', isGreaterThan: myScore).count().get();
    final tieSnap = await base
        .where('bestScore', isEqualTo: myScore)
        .where('fastestTimeMs', isLessThan: myTime)
        .count()
        .get();

    final h = higherSnap.count ?? 0;
    final t = tieSnap.count ?? 0;
    return h + t + 1;
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _top10Stream(bool local) {
    _regionField="location";
    final users = FirebaseFirestore.instance.collection('users');
    final q = (local && _regionField != null && _regionValue != null)
        ? users.where(_regionField!, isEqualTo: _regionValue)
        : users;

    // Best Score desc, tiebreak fastest time asc
    return q
        .orderBy('bestScore', descending: true)
        .limit(10)
        .snapshots();
  }

  // ====== UI ======
  List<Widget> get _widgetOptions => <Widget>[
    buildHomeScreenBody(),
    buildStatisticsUi(),
    buildProfileUi(),
  ];

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
  }

  Widget buildProfileUi() {
    setState(() {

    });
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final text = theme.textTheme;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 36,
                        backgroundColor: cs.primaryContainer,
                        child: Icon(Icons.person, size: 36, color: cs.onPrimaryContainer),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                          stream: _meStream,
                          builder: (context, snap) {
                            final d = snap.data?.data() ?? {};
                            final name = (d['name'] as String?) ?? '';
                            final email = (d['email'] as String?) ?? '';
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name, style: text.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
                                const SizedBox(height: 4),
                                Text(email, style: text.bodyMedium),
                              ],
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  ElevatedButton.icon(
                    onPressed: _confirmLogout,
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Log out'),
                    style: ButtonStyle(
                      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(48)),
                      textStyle: WidgetStatePropertyAll(
                        text.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      backgroundColor: WidgetStateProperty.resolveWith(
                            (states) => states.contains(WidgetState.disabled) ? cs.surfaceVariant : cs.error,
                      ),
                      foregroundColor: WidgetStatePropertyAll(cs.onError),
                      overlayColor: WidgetStatePropertyAll(cs.onError.withOpacity(0.08)),
                      shape: const WidgetStatePropertyAll(
                        RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(14))),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout() async {
    final cs = Theme.of(context).colorScheme;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You will be signed out of SudokuXpert.'),
        actions: [
          TextButton(onPressed: () =>
              Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(
            style: ButtonStyle(backgroundColor: WidgetStatePropertyAll(cs.error), foregroundColor: WidgetStatePropertyAll(cs.onError)),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (result == true) _handleLogout();
  }

   void _handleLogout() async {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Signed out')));
    setState(() => _selectedIndex = 0);
    await Hive.deleteBoxFromDisk('highScores');

  }

  Widget buildHomeScreenBody() {
    setState(() {

    });
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
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: cs.surface,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 8))],
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.grid_4x4_rounded, size: 64, color: cs.primary),
                        const SizedBox(height: 12),
                        Text('Sudoku Puzzle', style: text.headlineMedium),
                        const SizedBox(height: 4),
                        Text('Sharpen your mind • Solve the grid', style: text.bodyMedium),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),
                  MenuButton(
                    icon: Icons.add_card_rounded,
                    label: 'New Game',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const SudokuGameScreen()));
                    },
                  ),
                  const SizedBox(height: 16),
                  MenuButton(
                    icon: Icons.pause_circle_filled_rounded,
                    label: 'Continue Game',
                    onPressed: hasSavedGame ? () {} : null,
                  ),
                  const SizedBox(height: 16),
                  MenuButton(
                    icon: Icons.bar_chart_rounded,
                    label: 'Statistics',
                    onPressed: () => setState(() => _selectedIndex = 1),
                  ),
                  const SizedBox(height: 16),
                  MenuButton(
                    icon: Icons.settings_rounded,
                    label: 'Settings',
                    backgroundOverride: _secondaryBtn,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<bool> isConnected() async {
    List<ConnectivityResult> results = await Connectivity().checkConnectivity();
    ConnectivityResult result = results.isNotEmpty ? results.first : ConnectivityResult.none;
    return result == ConnectivityResult.mobile || result == ConnectivityResult.wifi;
  }

  Future<int> rankByScoreOnly({bool local = false}) async {
    print("rankByScoreOnly");
    print(local);
    isOnlien = await isConnected();
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return 0;

    final users = FirebaseFirestore.instance.collection('users');

    // my score (and region)
    final me = await users.doc(uid).get();
    final d = me.data() ?? {};
    final myScore = _asInt(d['bestScore'], 0);
    Query<Map<String, dynamic>> q = users;
    final db = FirebaseFirestore.instance;
    if (await isConnected()) {
      if (local) {
        final agg = await db
            .collection('users')
            .where('location', isEqualTo: d['location'])
            .where('bestScore', isGreaterThan: myScore)
            .count()
            .get();
        print("local");
        print(agg.count);

        return (agg.count ?? 0) + 1;
      } else {
        final agg = await db
            .collection('users')
            .where('bestScore', isGreaterThan: myScore)
            .count()
            .get();
        print("global");
        print(agg.count);
        return (agg.count ?? 0) + 1;
      }
    } else {
      return 0;
    }
  }

    Widget buildStatisticsUi() {
    print("############# buildStatisticsUi");
    loadHighScore();
    final text = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    const gap = 12.0;
    final local = (selectedTab == 0);


    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Local / Global
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, icon: Icon(Icons.person_pin_circle_outlined), label: Text('Local')),
                      ButtonSegment(value: 1, icon: Icon(Icons.public), label: Text('Global')),
                    ],
                    selected: {selectedTab},
                    onSelectionChanged: (s) {
                      HapticFeedback.selectionClick();
                      setState(() => selectedTab = s.first);
                    },
                    showSelectedIcon: false,
                    style: ButtonStyle(
                      minimumSize: const WidgetStatePropertyAll(Size.fromHeight(44)),
                      padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
                      backgroundColor: WidgetStateProperty.resolveWith((states) =>
                      states.contains(WidgetState.selected) ? cs.primaryContainer : cs.surfaceVariant),
                      foregroundColor: WidgetStateProperty.resolveWith((states) =>
                      states.contains(WidgetState.selected) ? cs.onPrimaryContainer : cs.onSurfaceVariant),
                      side: WidgetStateProperty.resolveWith((states) =>
                          BorderSide(color: states.contains(WidgetState.selected) ? cs.primary : cs.outlineVariant, width: states.contains(WidgetState.selected) ? 1.6 : 1.0)),
                      shape: const WidgetStatePropertyAll(
                        RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // --- Best Score + Fastest Time (from my user doc) ---
                  StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                    stream: _meStream,
                    builder: (context, snap) {

                      if( isOnlien){
                        final d = snap.data?.data() ?? {};
                        if(best>_asInt(d['bestScore'], 0)){
                          submitBestResult(score: best,timeMs: fast);
                        }else{
                          best = _asInt(d['bestScore'], 0);
                          fast = _asInt(d['fastestTimeMs'], 1 << 30);
                        }

                      }


                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final w = (constraints.maxWidth - gap) / 2;
                          return Row(
                            children: [
                              SizedBox(
                                width: w,
                                child: _StatCard(
                                  icon: Icons.emoji_events_outlined,
                                  title: 'Best Score',
                                  value: _fmtScore(best),
                                ),
                              ),
                              const SizedBox(width: gap),
                              SizedBox(
                                width: w,
                                child: _StatCard(
                                  icon: Icons.timer_outlined,
                                  title: 'Fastest Time',
                                  value: _fmtMs(fast),
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 12),

                  // --- Current Rank ---
                  FutureBuilder<int>(
                    future: rankByScoreOnly(local: selectedTab == 0), // 0 = Local, 1 = Global
                    builder: (context, snap) {
                      final rankText = (snap.hasData) ? '#${snap.data}' : '—';
                      return LayoutBuilder(
                        builder: (context, constraints) {
                          final w = (constraints.maxWidth - gap) / 2;
                          return Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: w,
                                child: _StatCard(
                                  icon: Icons.stacked_bar_chart_outlined,
                                  title: 'Rank',
                                  value: rankText,
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),

                  const SizedBox(height: 16),

                  Text('Top 10', style: text.titleMedium),
                  const SizedBox(height: 8),

                  // --- Top 10 list ---
                  Expanded(
                    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: _top10Stream(local),
                      builder: (context, snap) {
                        if (snap.connectionState == ConnectionState.waiting) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        final docs = snap.data?.docs ?? [];
                        if (docs.isEmpty) {
                          return const Center(child: Text('No players yet'));
                        }
                        return ListView.separated(
                          itemCount: docs.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 6),
                          itemBuilder: (context, i) {
                            final d = docs[i].data();
                            final name = (d['name'] as String?)?.trim().isNotEmpty == true
                                ? d['name'] as String
                                : 'Player';
                            final score = _fmtScore(_asInt(d['bestScore'], 0));
                            return _RankTile(rank: i + 1, name: name, score: score);
                          },
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );

  }

  @override
  Widget build(BuildContext context) {
    // Only build widgets when needed
    if (_widgetOptions[_selectedIndex] == null) {
      switch (_selectedIndex) {
        case 0:
          isStatic=true;
          // _widgetOptions[_selectedIndex] ;
          break;
        case 1:
          print("isStatic");
        print(isStatic);
          if(isStatic==true){
            isStatic=false;
            print("isStatic 2");
            print(isStatic);
            _widgetOptions[_selectedIndex] ;
          }
          break;
        case 2:
          isStatic=true;
          // _widgetOptions[_selectedIndex] ;
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sudoku Xpert'),
        backgroundColor: Colors.blue,
        actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () {})],
      ),
      body: _widgetOptions[_selectedIndex]!, // Use the cached widget
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statistic'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

// ====== PRESENTATION WIDGETS ======

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _StatCard({super.key, required this.icon, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 8))],
        border: Border.all(color: cs.outlineVariant, width: 0.8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 28, color: cs.primary),
          const SizedBox(height: 8),
          Text(title, style: text.labelLarge),
          const SizedBox(height: 6),
          Text(value, style: text.headlineSmall?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _RankTile extends StatelessWidget {
  final int rank;
  final String name;
  final String score;

  const _RankTile({super.key, required this.rank, required this.name, required this.score});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant, width: 0.8),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: cs.primaryContainer,
            child: Text('$rank', style: text.labelLarge?.copyWith(fontWeight: FontWeight.w700)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(name, style: text.titleMedium, overflow: TextOverflow.ellipsis)),
          Text(score, style: text.titleMedium?.copyWith(fontFeatures: const [FontFeature.tabularFigures()])),
        ],
      ),
    );
  }
}
int _asInt(dynamic v, int fb) {
  if (v is int) return v;
  if (v is num) return v.toInt();
  if (v is String) return int.tryParse(v) ?? fb;
  return fb;
}



