// 省略 import

class LobbyScreen extends StatefulWidget {
  final WebSocketService wsService;
  final String playerName;

  const LobbyScreen({Key? key, required this.wsService, required this.playerName})
      : super(key: key);

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  bool _isReady = false;

  void _toggleReady() {
    _isReady = !_isReady;
    widget.wsService.toggleReady(_isReady);
    setState(() {});
  }

  void _sendQuickMessage(String message) {
    widget.wsService.sendQuickMessage(message);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('等待其他玩家...')),
      body: Column(
        children: [
          // 這裡顯示玩家列表（略）
          ElevatedButton(
            onPressed: _toggleReady,
            child: Text(_isReady ? '取消準備' : '準備完成'),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(onPressed: () => _sendQuickMessage('加油'), child: const Text('加油')),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: () => _sendQuickMessage('準備好了'), child: const Text('準備好了')),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: () => _sendQuickMessage('再等一下'), child: const Text('再等一下')),
              const SizedBox(width: 10),
              ElevatedButton(onPressed: () => _sendQuickMessage('開始吧'), child: const Text('開始吧')),
            ],
          ),
        ],
      ),
    );
  }
}
