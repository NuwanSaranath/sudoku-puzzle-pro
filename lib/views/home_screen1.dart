// import 'package:flutter/material.dart';
// import '../viewModel/home_view_model.dart';
// import '../SudokuGameScreen.dart';
// import '../MenuButton.dart';
//
// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }
//
// class _HomeScreenState extends State<HomeScreen> {
//   final HomeViewModel _viewModel = HomeViewModel();
//   int _selectedIndex = 0;
//   static const _secondaryBtn = Color(0xFF424242);
//   bool hasSavedGame = false;
//
//   @override
//   void initState() {
//     super.initState();
//     // You can load necessary data here, e.g., high score, user data.
//     loadUserData();
//   }
//
//   Future<void> loadUserData() async {
//     var highScore = await _viewModel.getLocalHighScore();
//     // Set initial data or perform other logic.
//     setState(() {});
//   }
//
//   void _onItemTapped(int index) {
//     setState(() => _selectedIndex = index);
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Sudoku Xpert'),
//         backgroundColor: Colors.blue,
//         actions: [IconButton(icon: const Icon(Icons.settings), onPressed: () {})],
//       ),
//       body: _widgetOptions[_selectedIndex],  // Use the widget from the list based on selectedIndex
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _selectedIndex,
//         onTap: _onItemTapped,
//         items: const [
//           BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
//           BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Statistics'),
//           BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
//         ],
//       ),
//     );
//   }
//
//   List<Widget> get _widgetOptions => <Widget>[
//     buildHomeScreenBody(),
//     buildStatisticsUi(),
//     buildProfileUi(),
//   ];
//
//   // Example widget methods
//   Widget buildHomeScreenBody() {
//     final cs = Theme.of(context).colorScheme;
//     final text = Theme.of(context).textTheme;
//
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 420),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Container(
//                     padding: const EdgeInsets.all(20),
//                     decoration: BoxDecoration(
//                       color: cs.surface,
//                       borderRadius: BorderRadius.circular(20),
//                       boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 18, offset: const Offset(0, 8))],
//                     ),
//                     child: Column(
//                       children: [
//                         Icon(Icons.grid_4x4_rounded, size: 64, color: cs.primary),
//                         const SizedBox(height: 12),
//                         Text('Sudoku Puzzle', style: text.headlineMedium),
//                         const SizedBox(height: 4),
//                         Text('Sharpen your mind • Solve the grid', style: text.bodyMedium),
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 32),
//                   MenuButton(
//                     icon: Icons.add_card_rounded,
//                     label: 'New Game',
//                     onPressed: () {
//                       Navigator.push(context, MaterialPageRoute(builder: (context) => const SudokuGameScreen()));
//                     },
//                   ),
//                   const SizedBox(height: 16),
//                   MenuButton(
//                     icon: Icons.pause_circle_filled_rounded,
//                     label: 'Continue Game',
//                     onPressed: hasSavedGame ? () {} : null,
//                   ),
//                   const SizedBox(height: 16),
//                   MenuButton(
//                     icon: Icons.bar_chart_rounded,
//                     label: 'Statistics',
//                     onPressed: () => setState(() => _selectedIndex = 1),
//                   ),
//                   const SizedBox(height: 16),
//                   MenuButton(
//                     icon: Icons.settings_rounded,
//                     label: 'Settings',
//                     backgroundOverride: _secondaryBtn,
//                     onPressed: () {},
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget buildStatisticsUi() {
//     print("############# buildStatisticsUi");
//     loadHighScore();
//     final text = Theme.of(context).textTheme;
//     final cs = Theme.of(context).colorScheme;
//     const gap = 12.0;
//     final local = (selectedTab == 0);
//
//
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: ConstrainedBox(
//             constraints: const BoxConstraints(maxWidth: 420),
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   // Local / Global
//                   SegmentedButton<int>(
//                     segments: const [
//                       ButtonSegment(value: 0, icon: Icon(Icons.person_pin_circle_outlined), label: Text('Local')),
//                       ButtonSegment(value: 1, icon: Icon(Icons.public), label: Text('Global')),
//                     ],
//                     selected: {selectedTab},
//                     onSelectionChanged: (s) {
//                       HapticFeedback.selectionClick();
//                       setState(() => selectedTab = s.first);
//                     },
//                     showSelectedIcon: false,
//                     style: ButtonStyle(
//                       minimumSize: const WidgetStatePropertyAll(Size.fromHeight(44)),
//                       padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 14, vertical: 10)),
//                       backgroundColor: WidgetStateProperty.resolveWith((states) =>
//                       states.contains(WidgetState.selected) ? cs.primaryContainer : cs.surfaceVariant),
//                       foregroundColor: WidgetStateProperty.resolveWith((states) =>
//                       states.contains(WidgetState.selected) ? cs.onPrimaryContainer : cs.onSurfaceVariant),
//                       side: WidgetStateProperty.resolveWith((states) =>
//                           BorderSide(color: states.contains(WidgetState.selected) ? cs.primary : cs.outlineVariant, width: states.contains(WidgetState.selected) ? 1.6 : 1.0)),
//                       shape: const WidgetStatePropertyAll(
//                         RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
//                       ),
//                     ),
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   // --- Best Score + Fastest Time (from my user doc) ---
//                   StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
//                     stream: _meStream,
//                     builder: (context, snap) {
//
//                       if( isOnlien){
//                         final d = snap.data?.data() ?? {};
//                         if(best>_asInt(d['bestScore'], 0)){
//                           submitBestResult(score: best,timeMs: fast);
//                         }else{
//                           best = _asInt(d['bestScore'], 0);
//                           fast = _asInt(d['fastestTimeMs'], 1 << 30);
//                         }
//
//                       }
//
//
//                       return LayoutBuilder(
//                         builder: (context, constraints) {
//                           final w = (constraints.maxWidth - gap) / 2;
//                           return Row(
//                             children: [
//                               SizedBox(
//                                 width: w,
//                                 child: _StatCard(
//                                   icon: Icons.emoji_events_outlined,
//                                   title: 'Best Score',
//                                   value: _fmtScore(best),
//                                 ),
//                               ),
//                               const SizedBox(width: gap),
//                               SizedBox(
//                                 width: w,
//                                 child: _StatCard(
//                                   icon: Icons.timer_outlined,
//                                   title: 'Fastest Time',
//                                   value: _fmtMs(fast),
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                     },
//                   ),
//
//                   const SizedBox(height: 12),
//
//                   // --- Current Rank ---
//                   FutureBuilder<int>(
//                     future: rankByScoreOnly(local: selectedTab == 0), // 0 = Local, 1 = Global
//                     builder: (context, snap) {
//                       final rankText = (snap.hasData) ? '#${snap.data}' : '—';
//                       return LayoutBuilder(
//                         builder: (context, constraints) {
//                           final w = (constraints.maxWidth - gap) / 2;
//                           return Row(
//                             mainAxisAlignment: MainAxisAlignment.center,
//                             children: [
//                               SizedBox(
//                                 width: w,
//                                 child: _StatCard(
//                                   icon: Icons.stacked_bar_chart_outlined,
//                                   title: 'Rank',
//                                   value: rankText,
//                                 ),
//                               ),
//                             ],
//                           );
//                         },
//                       );
//                     },
//                   ),
//
//                   const SizedBox(height: 16),
//
//                   Text('Top 10', style: text.titleMedium),
//                   const SizedBox(height: 8),
//
//                   // --- Top 10 list ---
//                   Expanded(
//                     child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
//                       stream: _top10Stream(local),
//                       builder: (context, snap) {
//                         if (snap.connectionState == ConnectionState.waiting) {
//                           return const Center(child: CircularProgressIndicator());
//                         }
//                         final docs = snap.data?.docs ?? [];
//                         if (docs.isEmpty) {
//                           return const Center(child: Text('No players yet'));
//                         }
//                         return ListView.separated(
//                           itemCount: docs.length,
//                           separatorBuilder: (_, __) => const SizedBox(height: 6),
//                           itemBuilder: (context, i) {
//                             final d = docs[i].data();
//                             final name = (d['name'] as String?)?.trim().isNotEmpty == true
//                                 ? d['name'] as String
//                                 : 'Player';
//                             final score = _fmtScore(_asInt(d['bestScore'], 0));
//                             return _RankTile(rank: i + 1, name: name, score: score);
//                           },
//                         );
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//
//   }
//
//   Widget buildProfileUi() {
//     return const Center(child: Text('Profile Screen'));
//   }
//
//
// }
