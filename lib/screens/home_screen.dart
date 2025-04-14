import 'package:flutter/material.dart';
import 'package:my_flutter_app/screens/create_room_screen.dart';
import 'package:my_flutter_app/screens/join_game_screen.dart';
import 'package:my_flutter_app/screens/options_screen.dart';
import 'package:my_flutter_app/services/websocket_service.dart';

class HomeScreen extends StatelessWidget {
  final WebSocketService wsService;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.wsService,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Speed King'),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CreateRoomScreen(wsService: wsService),
                  ),
                );
              },
              child: const Text('創建賽局'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => JoinGameScreen(wsService: wsService),
                  ),
                );
              },
              child: const Text('加入賽局'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const OptionsScreen(),
                  ),
                );
              },
              child: const Text('更多選單'),
            ),
          ],
        ),
      ),
    );
  }
}
