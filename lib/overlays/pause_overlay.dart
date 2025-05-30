// lib/overlays/pause_overlay.dart
import 'package:flutter/material.dart';
import '../game/ball_collector_game.dart';

class PauseOverlay extends StatelessWidget {
  static const String id = 'PauseOverlay';
  final BallCollectorGame game;

  const PauseOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black.withOpacity(0.5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Paused', style: TextStyle(fontSize: 48, color: Colors.white)),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () => game.resumeGame(),
              child: const Text('Resume', style: TextStyle(fontSize: 24)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => game.showMainMenu(),
              child: const Text('Main Menu'),
            ),
          ],
        ),
      ),
    );
  }
}