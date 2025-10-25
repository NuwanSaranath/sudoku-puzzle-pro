import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodel/leaderboard_viewmodel.dart';

class LeaderboardView extends StatelessWidget {
  const LeaderboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<LeaderboardViewModel>();

    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: vm.isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: vm.entries.length,
        itemBuilder: (context, index) {
          final e = vm.entries[index];
          return ListTile(
            leading: Text('#${index + 1}'),
            title: Text(e.name),
            subtitle: Text('Score: ${e.score}, Time: ${e.timeMs}ms'),
          );
        },
      ),
    );
  }
}
