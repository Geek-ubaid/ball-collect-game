// lib/game/ball_collector_game.dart
import 'dart:async' as async_timer;
import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart' show Color, Colors, Offset, Rect; // For Rect, Offset
import 'components/ball_component.dart';
import 'components/bucket_component.dart';
import 'components/hud_component.dart';
import 'utils/game_colors.dart' as game_utils;
import 'utils/highscore_manager.dart';
import '../overlays/game_over_overlay.dart';
import '../overlays/main_menu_overlay.dart';
import '../overlays/pause_overlay.dart';

enum GameState { menu, playing, paused, gameOver }

class BallCollectorGame extends FlameGame
    with HasCollisionDetection, TapCallbacks { // Added TapCallbacks for pause
  int score = 0;
  int lives = 3;
  int level = 1;
  int correctBallsCollectedThisLevel = 0;
  int targetBallsForLevel = 5;
  int currentHighScore = 0;

  GameState gameState = GameState.menu;

  BucketComponent? _bucket; // <--- Make _bucket nullable
  late HudComponent _hud;
  final Random _random = Random();

  // Level settings
  double _ballBaseSpeed = 100.0; // pixels per second
  double _ballSpawnInterval = 1.5; // seconds
  List<Color> _availableBallColors = game_utils.gameColors.sublist(0, 3);
  final List<int> _levelTargets = [5, 7, 10, 12, 15]; // Target balls per level
  final double _ballRadius = 15.0;
  
  final double _bucketColorMatchSpawnChance = 0.40; // 40% chance for next ball to match bucket
  int _ballsSpawnedSinceLastMatch = 0;
  final int _forceMatchAfterXBalls = 4; // Guarantee a match if X non-matching balls have spawned

  async_timer.Timer? _ballSpawnTimerInstance; // Dart timer for spawning

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // camera.viewport = FixedAspectRatioViewport(aspectRatio: 9 / 16); // Example
    // camera.viewfinder.anchor = Anchor.topLeft;

    _hud = HudComponent(); // Initialize HUD
    add(_hud); // Add HUD so it's always visible
    
    currentHighScore = await HighScoreManager.getHighScore();
    _ballsSpawnedSinceLastMatch = 0; // Initialize
    showMainMenu(); // Start with the main menu
  }

  void showMainMenu() {
    gameState = GameState.menu;
    overlays.add(MainMenuOverlay.id);
    if (overlays.isActive(GameOverOverlay.id)) overlays.remove(GameOverOverlay.id);
    if (overlays.isActive(PauseOverlay.id)) overlays.remove(PauseOverlay.id);
    clearGameElements();
    paused = true; // Pause Flame's engine
  }

  void startGame() {
    if (overlays.isActive(MainMenuOverlay.id)) overlays.remove(MainMenuOverlay.id);
    if (overlays.isActive(GameOverOverlay.id)) overlays.remove(GameOverOverlay.id);
    if (overlays.isActive(PauseOverlay.id)) overlays.remove(PauseOverlay.id);
    paused = false; // Resume Flame's engine

    clearGameElements();

    gameState = GameState.playing;
    score = 0;
    lives = 3;
    level = 1;
    correctBallsCollectedThisLevel = 0;
    _ballsSpawnedSinceLastMatch = 0; // Reset for new game
    _updateLevelSettings(); // Sets targetBallsForLevel, speed, colors for level 1

    // Initialize Bucket
    final bucketSize = Vector2(80, 40);
    _bucket = BucketComponent(
      bucketColor: game_utils.getRandomGameColor(game_utils.gameColors), // Start with any of the 5 game colors
      position: Vector2(size.x / 2, size.y - bucketSize.y - 10),
      bucketSize: bucketSize,
    );
    add(_bucket!);

    // Update HUD
    _hud.updateScore(score);
    _hud.updateLives(lives);
    _hud.updateLevel(level);
    _hud.updateTarget(correctBallsCollectedThisLevel, targetBallsForLevel);
    _hud.updatePauseButton(false);

    _startBallSpawning();
  }

void clearGameElements() {
  // Remove all existing ball components
  children.whereType<BallComponent>().forEach((component) => component.removeFromParent());

  // If the bucket exists and is part of the game, remove it
  if (_bucket != null) { // Check if _bucket has been initialized
    if (children.contains(_bucket!)) { // Then check if it's actually a child
      _bucket!.removeFromParent();
    }
    _bucket = null; // Set to null after removal or if it wasn't a child but was initialized
  }
  _stopBallSpawning(); // Stop any active ball spawning timers
}
  void _updateLevelSettings() {
    // Ball speed increases (game gets harder)
    // The prompt said "slow down" but typically speed increases.
    // If "slow down" means *value* reduces, then `_ballBaseSpeed - (level -1) * X`
    _ballBaseSpeed = 100.0 + (level - 1) * 20.0;

    // Spawn interval decreases (more balls, harder)
    _ballSpawnInterval = max(0.5, 1.5 - (level - 1) * 0.15);

    // Color variance: "slow down" means *fewer* colors at lower levels (easier)
    if (level == 1) _availableBallColors = game_utils.gameColors.sublist(0, 3);
    else if (level == 2) _availableBallColors = game_utils.gameColors.sublist(0, 4);
    else _availableBallColors = game_utils.gameColors; // All 5

    targetBallsForLevel = _levelTargets[min(level - 1, _levelTargets.length - 1)];

    // Update HUD for level and target
    _hud.updateLevel(level);
    _hud.updateTarget(correctBallsCollectedThisLevel, targetBallsForLevel);
  }

  void _startBallSpawning() {
    _stopBallSpawning(); // Ensure any existing timer is stopped
    _ballSpawnTimerInstance = async_timer.Timer.periodic(Duration(milliseconds: (_ballSpawnInterval * 1000).toInt()), (timer) {
      if (gameState == GameState.playing && !paused) {
        _spawnBall();
      }
    });
  }

  void _stopBallSpawning() {
    _ballSpawnTimerInstance?.cancel();
    _ballSpawnTimerInstance = null;
  }

  void _spawnBall() {
    if (gameState != GameState.playing || _bucket == null) return; // Ensure bucket is initialized
        Color ballColor;

    // Smart spawning logic
    bool shouldForceMatch = _ballsSpawnedSinceLastMatch >= _forceMatchAfterXBalls;

    if (shouldForceMatch || _random.nextDouble() < _bucketColorMatchSpawnChance) {
      // Spawn a ball matching the bucket color
      ballColor = _bucket!.bucketColor;
      _ballsSpawnedSinceLastMatch = 0; // Reset counter
    } else {
      // Spawn a random color, but try to make it different from the bucket if possible
      // from the _availableBallColors for the current level.
      List<Color> spawnOptions = List.from(_availableBallColors); // Create a mutable copy
      if (spawnOptions.length > 1) { // Only try to exclude if there are other options
        spawnOptions.remove(_bucket!.bucketColor);
      }
      if (spawnOptions.isEmpty) { // Fallback if removing bucket color left no options (e.g. only 1 available color)
          ballColor = _bucket!.bucketColor;
      } else {
          ballColor = game_utils.getRandomGameColor(spawnOptions);
      }
      _ballsSpawnedSinceLastMatch++;
    }


    final initialX = _random.nextDouble() * (size.x - _ballRadius * 2) + _ballRadius;
    add(BallComponent(
      position: Vector2(initialX, -_ballRadius),
      ballColor: ballColor,
      velocity: Vector2(0, _ballBaseSpeed),
      radius: _ballRadius,
    ));
  }

  void handleBallCollected(BallComponent ball, BucketComponent bucket) {
    if (gameState != GameState.playing || _bucket == null) return; // <--- Add null check for _bucket

    if (ball.ballColor == bucket.bucketColor) {
      score += 10;
      correctBallsCollectedThisLevel++;
      _bucket!.changeColor(game_utils.getDifferentRandomGameColor(bucket.bucketColor, game_utils.gameColors));
      _ballsSpawnedSinceLastMatch = 0; // <--- RESET HERE
      if (correctBallsCollectedThisLevel >= targetBallsForLevel) {
        _levelUp();
      }
    } else {
      lives--;
      if (lives <= 0) _gameOver();
    }
    ball.removeFromParent();
    _hud.updateScore(score);
    _hud.updateLives(lives);
    _hud.updateTarget(correctBallsCollectedThisLevel, targetBallsForLevel);
  }

  void handleMissedBall(BallComponent ball) {
  if (gameState != GameState.playing || _bucket == null) return; // <--- Add null check for _bucket

    if (ball.ballColor == _bucket!.bucketColor) { // Missed a correct ball
      lives--;
      if (lives <= 0) _gameOver();
    }
    _hud.updateLives(lives);
    // Ball removes itself in its update method
  }

  void _levelUp() {
    level++;
    score += 50; // Level completion bonus
    correctBallsCollectedThisLevel = 0;
    _ballsSpawnedSinceLastMatch = 0; // <--- RESET HERE
    _updateLevelSettings(); // This also updates HUD for level and target
    _hud.updateScore(score);

    // Restart spawner with new interval
    _stopBallSpawning();
    _startBallSpawning();
  }

  void _gameOver() async {
    gameState = GameState.gameOver;
    paused = true; // Pause Flame engine
    _stopBallSpawning();
    await HighScoreManager.setHighScore(score);
    currentHighScore = await HighScoreManager.getHighScore(); // Refresh for display
    overlays.add(GameOverOverlay.id);
  }

  void togglePause() {
    if (gameState == GameState.playing) {
      gameState = GameState.paused;
      paused = true; // Pause Flame engine
      _ballSpawnTimerInstance?.cancel(); // Pause the Dart Timer
      overlays.add(PauseOverlay.id);
      _hud.updatePauseButton(true);
    } else if (gameState == GameState.paused) {
      resumeGame();
    }
  }

  void resumeGame() {
    if (gameState == GameState.paused) {
      gameState = GameState.playing;
      paused = false; // Resume Flame engine
      _startBallSpawning(); // Resume ball spawning
      if (overlays.isActive(PauseOverlay.id)) overlays.remove(PauseOverlay.id);
      _hud.updatePauseButton(false);
    }
  }

  @override
  void onTapDown(TapDownEvent event) {
    super.onTapDown(event);
    if (gameState == GameState.playing || gameState == GameState.paused) {
      // Define a tappable area for the pause button (e.g., around the HUD pause text)
      // This is a simplified hit detection for the text based pause button
      final pauseButtonArea = Rect.fromCenter(
        center: _hud.pauseButtonText.absolutePosition.toOffset() + _hud.pauseButtonText.size.toOffset() / 2,
        width: _hud.pauseButtonText.size.x + 20, // Add some padding
        height: _hud.pauseButtonText.size.y + 20
      );

      if (pauseButtonArea.contains(event.localPosition.toOffset())) {
        togglePause();
      }
    }
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Game-wide update logic if necessary
  }

  @override
  void onRemove() { // Clean up timers when the game widget is disposed
    _stopBallSpawning();
    super.onRemove();
  }
}