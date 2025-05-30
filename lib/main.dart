import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/ball_collector_game.dart';
import 'overlays/main_menu_overlay.dart';
import 'overlays/game_over_overlay.dart';
import 'overlays/pause_overlay.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); // Important for Flame & shared_preferences

  final game = BallCollectorGame();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GameWidget<BallCollectorGame>(
          game: game,
          overlayBuilderMap: {
            MainMenuOverlay.id: (context, game) => MainMenuOverlay(game: game),
            GameOverOverlay.id: (context, game) => GameOverOverlay(game: game),
            PauseOverlay.id: (context, game) => PauseOverlay(game: game),
          },
        ),
      ),
    ),
  );
}