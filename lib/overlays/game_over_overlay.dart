// lib/overlays/game_over_overlay.dart
import 'package:flutter/material.dart';
import '../game/ball_collector_game.dart';

class GameOverOverlay extends StatelessWidget {
  static const String id = 'GameOverOverlay';
  final BallCollectorGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.7),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Game Over', style: TextStyle(fontSize: 48, color: Colors.redAccent)),
            const SizedBox(height: 20),
            Text('Your Score: ${game.score}', style: const TextStyle(fontSize: 32, color: Colors.white)),
            Text('Level: ${game.level}', style: const TextStyle(fontSize: 24, color: Colors.white70)),
            const SizedBox(height: 10),
            Text('High Score: ${game.currentHighScore}', style: const TextStyle(fontSize: 28, color: Colors.amber)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => game.startGame(),
                  child: const Text('Play Again'),
                ),
                const SizedBox(width: 20),
                ElevatedButton(
                  onPressed: () => game.showMainMenu(),
                  child: const Text('Main Menu'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}