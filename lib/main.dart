// lib/main.dart
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
    MaterialApp( // MaterialApp needed for overlay's Material widgets
      debugShowCheckedModeBanner: false,
      home: Scaffold( // Scaffold provides a base for GameWidget
        body: GameWidget<BallCollectorGame>(
          game: game,
          overlayBuilderMap: {
            MainMenuOverlay.id: (context, game) => MainMenuOverlay(game: game),
            GameOverOverlay.id: (context, game) => GameOverOverlay(game: game),
            PauseOverlay.id: (context, game) => PauseOverlay(game: game),
          },
          // No initialActiveOverlays, game logic will show MainMenuOverlay
        ),
      ),
    ),
  );
}