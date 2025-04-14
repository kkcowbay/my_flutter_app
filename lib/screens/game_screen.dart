import 'dart:async';
import 'package:flutter/material.dart';
import '../services/websocket_service.dart';

class GameScreen extends StatefulWidget {
  final WebSocketService wsService;
  final String playerName;

  const GameScreen({
    super.key,
    required this.wsService,
    required this.playerName,
  });

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  double countdown = 5.5;
  bool gameEnded = false;
  bool clicked = false;
  Timer? timer;
  Timer? afterCountdownTimer;
  bool showStartCountdown = true;
  int startCountdown = 3;

  @override
  void initState() {
    super.initState();
    startStartCountdown();
  }

  void startStartCountdown() {
    Timer.periodic(const Duration(seconds: 1), (t) {
      if (startCountdown > 1) {
        setState(() {
          startCountdown--;
        });
      } else {
        t.cancel();
        setState(() {
          showStartCountdown = false;
        });
        startCountdownTimer();
      }
    });
  }

  void startCountdownTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 10), (t) {
      setState(() {
        countdown -= 0.01;
      });
      if (countdown <= 0) {
        t.cancel();
        countdown = 0;
        startAfterCountdownTimer();
      }
    });
  }

  void startAfterCountdownTimer() {
    afterCountdownTimer = Timer.periodic(const Duration(milliseconds: 10), (t) {
      setState(() {
        countdown += 0.01;
      });
      if (countdown >= 10.0 && !gameEnded) {
        t.cancel();
        sendResult();
      }
    });
  }

  void sendResult() {
    if (!clicked) {
      widget.wsService.sendClick(10.0);
    }
    setState(() {
      gameEnded = true;
    });
  }

  void handleClick() {
    if (!clicked && !showStartCountdown) {
      widget.wsService.sendClick(countdown);
      setState(() {
        clicked = true;
      });
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    afterCountdownTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: countdown > 5.5 ? Colors.black : Colors.white,
      body: Center(
        child: showStartCountdown
            ? Text(
                '$startCountdown',
                style: const TextStyle(
                  fontSize: 96,
                  fontWeight: FontWeight.bold,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    countdown.toStringAsFixed(2),
                    style: TextStyle(
                      fontSize: 64,
                      fontWeight: FontWeight.bold,
                      color: countdown <= 0 ? Colors.red : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 48),
                  ElevatedButton(
                    onPressed: handleClick,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 24,
                      ),
                      backgroundColor: clicked ? Colors.grey : Colors.blue,
                    ),
                    child: Text(
                      clicked ? "已點擊" : "點我！",
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
