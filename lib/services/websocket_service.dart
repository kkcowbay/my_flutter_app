import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef VoidCallback = void Function();
typedef CountdownCallback = void Function(double);
typedef GameResultCallback = void Function(dynamic);
typedef RestartCallback = void Function();

class WebSocketService {
  late WebSocketChannel _channel;
  bool _isConnected = false;

  String? playerName;
  String? roomId;

  VoidCallback? onRoomUpdate;
  VoidCallback? onError;
  VoidCallback? onJoined;
  VoidCallback? onReadyToggled;
  VoidCallback? onGameStart;
  CountdownCallback? onCountdown;
  GameResultCallback? onGameResult;
  RestartCallback? onRestartGame;

  void connect(String url) {
    if (_isConnected) return;
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _isConnected = true;

    _channel.stream.listen((message) {
      final data = json.decode(message);
      final type = data['type'];

      switch (type) {
        case 'room_update':
          onRoomUpdate?.call();
          break;
        case 'error':
          onError?.call();
          break;
        case 'joined':
          onJoined?.call();
          break;
        case 'ready_toggled':
          onReadyToggled?.call();
          break;
        case 'game_start':
          onGameStart?.call();
          break;
        case 'countdown':
          final seconds = (data['countdown'] as num).toDouble();
          onCountdown?.call(seconds);
          break;
        case 'game_result':
          onGameResult?.call(data);
          break;
        case 'restart_game':
          onRestartGame?.call();
          break;
        default:
          break;
      }
    });
    print("✅ WebSocket 已連線: $url");
  }

  void joinRoom(String roomId, String playerName) {
    this.roomId = roomId;
    this.playerName = playerName;

    final msg = json.encode({
      'type': 'join',
      'roomId': roomId,
      'playerName': playerName,
    });

    _channel.sink.add(msg);
    print("👤 傳送加入房間請求: $playerName 加入 $roomId");
  }

  void toggleReady(bool isReady) {
    final msg = json.encode({
      'type': 'toggle_ready',
      'playerName': playerName,
      'roomId': roomId,
      'ready': isReady,
    });

    _channel.sink.add(msg);
    print("🔄 傳送準備狀態: $playerName => $isReady");
  }

  void sendClick(double delta) {
    final msg = json.encode({
      'type': 'click',
      'playerName': playerName,
      'roomId': roomId,
      'delta': delta,
    });

    _channel.sink.add(msg);
    print("🖱️ 傳送按鈕點擊秒數: $delta");
  }

  void requestRestart() {
    final msg = json.encode({
      'type': 'restart_game',
      'roomId': roomId,
    });

    _channel.sink.add(msg);
    print("🔁 傳送重新開始請求");
  }

  void dispose() {
    _channel.sink.close();
    _isConnected = false;
  }
}
