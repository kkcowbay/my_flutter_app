import 'package:flutter/material.dart';
import 'package:my_flutter_app/screens/lobby_screen.dart';
import 'package:my_flutter_app/services/websocket_service.dart';

class JoinGameScreen extends StatefulWidget {
  final WebSocketService wsService;

  const JoinGameScreen({super.key, required this.wsService});

  @override
  State<JoinGameScreen> createState() => _JoinGameScreenState();
}

class _JoinGameScreenState extends State<JoinGameScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _roomIdController = TextEditingController();
  String selectedAvatar = 'avatar1'; // 預設選第一個頭像

  @override
  void dispose() {
    _nameController.dispose();
    _roomIdController.dispose();
    super.dispose();
  }

  void _selectAvatar(String avatar) {
    setState(() {
      selectedAvatar = avatar;
    });
  }

  void _joinRoom() {
    final playerName = _nameController.text.trim();
    final roomId = _roomIdController.text.trim();

    if (playerName.isEmpty || roomId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('暱稱與賽局號碼皆不得為空')),
      );
      return;
    }

    if (roomId.length != 6 || int.tryParse(roomId) == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('賽局號碼需為6位半形數字 (000000-999999)')),
      );
      return;
    }

    widget.wsService.connect();
    widget.wsService.joinRoom(roomId, playerName, selectedAvatar);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LobbyScreen(
          wsService: widget.wsService,
          playerName: playerName,
          selectedAvatar: selectedAvatar,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('加入賽局')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Text(
              '選擇角色',
              style: TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildAvatarOption('avatar1'),
                const SizedBox(width: 16),
                _buildAvatarOption('avatar2'),
                const SizedBox(width: 16),
                _buildAvatarOption('avatar3'),
              ],
            ),
            const SizedBox(height: 24),
            const Text('你的暱稱'),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(hintText: '輸入你的暱稱'),
              maxLength: 10,
            ),
            const SizedBox(height: 16),
            const Text('賽局號碼（限6位數字）'),
            TextField(
              controller: _roomIdController,
              decoration: const InputDecoration(hintText: '輸入6位數字房號'),
              maxLength: 6,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _joinRoom,
              child: const Text('點我加入'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarOption(String avatarName) {
    final isSelected = selectedAvatar == avatarName;
    return GestureDetector(
      onTap: () => _selectAvatar(avatarName),
      child: CircleAvatar(
        radius: isSelected ? 36 : 30,
        backgroundImage: AssetImage('assets/avatars/$avatarName.png'),
        backgroundColor: isSelected ? Colors.blueAccent : Colors.grey[300],
      ),
    );
  }
}
