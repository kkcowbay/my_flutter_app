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
  String? selectedAvatar;
  List<Player> players = [];
  String? roomHost;

  VoidCallback? onRoomUpdate;
  VoidCallback? onError;
  VoidCallback? onJoined;
  VoidCallback? onReadyToggled;
  VoidCallback? onGameStart;
  CountdownCallback? onCountdown;
  GameResultCallback? onGameResult;
  RestartCallback? onRestartGame;
  Function(String playerName, String message)? onQuickMessage;

  void connect({required String url}) {
    if (_isConnected) return;
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _isConnected = true;

    _channel.stream.listen((message) {
      final data = json.decode(message);
      final type = data['type'];

      switch (type) {
        case 'room_update':
          players = (data['players'] as List)
              .map((p) => Player.fromJson(p))
              .toList();
          roomHost = data['host'];
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
        case 'quick_message':
          onQuickMessage?.call(data['playerName'], data['message']);
          break;
        default:
          break;
      }
    });
    print("✅ WebSocket 已連線: $url");
  }

  void joinRoom(String roomId, String playerName, String avatar) {
    this.roomId = roomId;
    this.playerName = playerName;
    selectedAvatar = avatar;

    final msg = json.encode({
      'type': 'join',
      'roomId': roomId,
      'playerName': playerName,
      'avatar': avatar,
    });

    _channel.sink.add(msg);
  }

  void toggleReady(bool ready) {
    final msg = json.encode({
      'type': 'toggle_ready',
      'roomId': roomId,
      'playerName': playerName,
      'ready': ready,
    });

    _channel.sink.add(msg);
  }

  void startGame() {
    final msg = json.encode({
      'type': 'start_game',
      'roomId': roomId,
      'playerName': playerName,
    });

    _channel.sink.add(msg);
  }

  void sendClick(double delta) {
    final msg = json.encode({
      'type': 'click',
      'roomId': roomId,
      'playerName': playerName,
      'delta': delta,
    });

    _channel.sink.add(msg);
  }

  void requestRestart() {
    final msg = json.encode({
      'type': 'restart_game',
      'roomId': roomId,
    });

    _channel.sink.add(msg);
  }

  void sendQuickMessage(String message) {
    final msg = json.encode({
      'type': 'send_quick_message',
      'roomId': roomId,
      'playerName': playerName,
      'message': message,
    });

    _channel.sink.add(msg);
  }

  void dispose() {
    _channel.sink.close();
    _isConnected = false;
  }
}

class Player {
  final String name;
  final bool ready;
  final String avatar;

  Player({required this.name, required this.ready, required this.avatar});

  factory Player.fromJson(Map<String, dynamic> json) {
    return Player(
      name: json['name'],
      ready: json['ready'],
      avatar: json['avatar'],
    );
  }
}
