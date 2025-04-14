import 'package:flutter/material.dart';
import '../models/player_result.dart';

class ResultScreen extends StatelessWidget {
  final List<PlayerResult> results;
  final String selectedAvatar;

  const ResultScreen({
    super.key,
    required this.results,
    required this.selectedAvatar,
  });

  @override
  Widget build(BuildContext context) {
    results.sort((a, b) => a.rank.compareTo(b.rank));

    return Scaffold(
      appBar: AppBar(
        title: const Text('遊戲結果'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: results.length,
                itemBuilder: (context, index) {
                  final player = results[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: AssetImage('assets/avatars/${player.avatar}'),
                    ),
                    title: Text('${player.rank} 名: ${player.name}'),
                    subtitle: Text('時間: ${player.time.toStringAsFixed(5)} 秒'),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('再來一局'),
            ),
          ],
        ),
      ),
    );
  }
}
