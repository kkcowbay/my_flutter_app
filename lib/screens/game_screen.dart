import 'dart:async';
import 'package:flutter/material.dart';
import '../services/websocket_service.dart';
import '../models/player_result.dart';

class GameScreen extends StatefulWidget {
  final WebSocketService wsService;
  final String playerName;

  const GameScreen({
    Key? key,
    required this.wsService,
    required this.playerName,
  }) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double _countdown = 0;
  Timer? _countdownTimer;
  bool _hasClicked = false;
  bool _startCountdown = false;
  bool _canRestart = false;
  List<PlayerResult> _playerResults = [];
  String _countdownDisplay = '準備中...';

  @override
  void initState() {
    super.initState();

    widget.wsService.onCountdown = (time) {
      _startPreciseCountdown(time);
      setState(() {
        _startCountdown = true;
      });
    };

    widget.wsService.onGameResult = (data) {
      _handleGameResult(data);
    };

    widget.wsService.onRestartGame = () {
      _restartGame();
    };
  }

  void _startPreciseCountdown(double durationSeconds) {
    _countdown = durationSeconds;
    const tick = Duration(milliseconds: 10);
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(tick, (timer) {
      setState(() {
        _countdown -= 0.01;
        if (_countdown <= 0.00001) {
          _countdown = 0.00000;
          timer.cancel();
        }
        _countdownDisplay = _countdown > 0
            ? '倒數: ${_countdown.toStringAsFixed(2)}'
            : '倒數結束';
      });
    });
  }

  void _handleGameResult(dynamic data) {
    List<dynamic> resultList = data['results'];
    List<PlayerResult> results = resultList.map((item) {
      return PlayerResult(
        playerName: item['playerName'],
        time: double.parse(item['time'].toStringAsFixed(5)),
        isLate: item['isLate'],
        rank: item['rank'],
        notClicked: item['notClicked'] ?? false,
      );
    }).toList();

    results.sort((a, b) => a.rank.compareTo(b.rank));

    setState(() {
      _playerResults = results;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      _showResultDialog();
    });

    _showPodiumAnimation(results);
  }

  void _showResultDialog() {
    final playerName = widget.playerName;
    final result = _playerResults.firstWhere(
      (r) => r.playerName == playerName,
      orElse: () => PlayerResult.empty(),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('結果'),
        content: Text(
          result.notClicked
              ? '你未按下按鈕，記錄時間 +10.00000 秒'
              : '你的時間差是 ${result.time.toStringAsFixed(5)} 秒',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _canRestart = true;
              });
            },
            child: const Text('確定'),
          )
        ],
      ),
    );
  }

  void _showPodiumAnimation(List<PlayerResult> results) {
    final top3 = results.where((r) => r.rank <= 3 && !r.notClicked).toList();
    for (var r in top3) {
      debugPrint('🏆 第 ${r.rank} 名：${r.playerName}，秒數：${r.time}');
    }
  }

  void _restartGame() {
    setState(() {
      _hasClicked = false;
      _countdown = 0;
      _startCountdown = false;
      _playerResults.clear();
      _canRestart = false;
      _countdownDisplay = '準備中...';
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('遊戲開始'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: _startCountdown
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _countdownDisplay,
                    style: const TextStyle(fontSize: 32),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _hasClicked || _countdown <= 0
                        ? null
                        : () {
                            final delta = _countdown - 0;
                            widget.wsService.sendClick(delta);
                            setState(() {
                              _hasClicked = true;
                            });
                          },
                    child: const Text('按下按鈕'),
                  ),
                  const SizedBox(height: 24),
                  if (_canRestart)
                    ElevatedButton(
                      onPressed: _restartGame,
                      child: const Text('重新開始'),
                    )
                ],
              )
            : Center(
                child: Text(
                  _countdownDisplay,
                  style: const TextStyle(fontSize: 72),
                ),
              ),
      ),
    );
  }
}
