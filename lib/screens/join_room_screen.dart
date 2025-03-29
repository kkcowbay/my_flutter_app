import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import 'game_screen.dart';

class JoinRoomScreen extends StatefulWidget {
  final WebSocketService wsService;

  const JoinRoomScreen({Key? key, required this.wsService}) : super(key: key);

  @override
  _JoinRoomScreenState createState() => _JoinRoomScreenState();
}

class _JoinRoomScreenState extends State<JoinRoomScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomController = TextEditingController();
  bool _hasJoined = false;

  @override
  void dispose() {
    _nameController.dispose();
    _roomController.dispose();
    super.dispose();
  }

  void _connectAndJoinRoom() {
    final playerName = _nameController.text.trim();
    final roomId = _roomController.text.trim();

    if (playerName.isEmpty || roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('請輸入玩家名稱與房間代碼')),
      );
      return;
    }

    widget.wsService.connect('ws://localhost:8080');
    widget.wsService.joinRoom(roomId, playerName);
    debugPrint("👤 嘗試加入房間: $roomId 名稱: $playerName");

    setState(() {
      _hasJoined = true;
    });

    // 避免多次註冊 onGameStart
    widget.wsService.onGameStart = () {
      debugPrint("🚀 遊戲開始，切換到 GameScreen");
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => GameScreen(
            wsService: widget.wsService,
            playerName: playerName,
          ),
        ),
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('加入房間')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: '玩家名稱'),
            ),
            TextField(
              controller: _roomController,
              decoration: const InputDecoration(labelText: '房間代碼'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _hasJoined ? null : _connectAndJoinRoom,
              child: const Text('加入房間'),
            ),
          ],
        ),
      ),
    );
  }
}
