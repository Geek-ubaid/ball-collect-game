// lib/overlays/main_menu_overlay.dart
import 'package:flutter/material.dart';
import '../game/ball_collector_game.dart';
import '../game/utils/highscore_manager.dart';

class MainMenuOverlay extends StatefulWidget {
  static const String id = 'MainMenuOverlay';
  final BallCollectorGame game;

  const MainMenuOverlay({super.key, required this.game});

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay> {
  int _highScore = 0;

  @override
  void initState() {
    super.initState();
    _loadHighScore();
  }

  Future<void> _loadHighScore() async {
    _highScore = await HighScoreManager.getHighScore();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Ball Collector', style: TextStyle(fontSize: 48, color: Colors.white)),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: () {
                widget.game.startGame();
              },
              child: const Text('Start Game', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 20),
            Text('High Score: $_highScore', style: const TextStyle(fontSize: 24, color: Colors.amber)),
          ],
        ),
      ),
    );
  }
}