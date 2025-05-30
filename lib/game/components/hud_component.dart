import 'package:flame/components.dart';
import 'package:flutter/painting.dart';
import '../ball_collector_game.dart';

class HudComponent extends PositionComponent with HasGameRef<BallCollectorGame> {
  late TextComponent _scoreText;
  late TextComponent _livesText;
  late TextComponent _levelText;
  late TextComponent _targetText;
  late TextComponent pauseButtonText; // Simple text-based pause button

  final TextStyle _textStyle = const TextStyle(fontSize: 20, color: Color(0xFFFFFFFF)); // White

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    _scoreText = TextComponent(
        text: 'Score: 0',
        textRenderer: TextPaint(style: _textStyle),
        anchor: Anchor.topLeft,
        position: Vector2(10, 10));

    _livesText = TextComponent(
        text: 'Lives: 3',
        textRenderer: TextPaint(style: _textStyle),
        anchor: Anchor.topRight,
        position: Vector2(gameRef.size.x - 10, 10));

    _levelText = TextComponent(
        text: 'Level: 1',
        textRenderer: TextPaint(style: _textStyle),
        anchor: Anchor.topCenter,
        position: Vector2(gameRef.size.x / 2, 10));
    
    _targetText = TextComponent(
        text: 'Target: 0/5',
        textRenderer: TextPaint(style: _textStyle),
        anchor: Anchor.topLeft,
        position: Vector2(10, 40)); // Below score

    pauseButtonText = TextComponent(
        text: 'II', // Pause symbol
        textRenderer: TextPaint(style: _textStyle.copyWith(fontSize: 28, fontWeight: FontWeight.bold)),
        anchor: Anchor.topRight,
        position: Vector2(gameRef.size.x - 10, 50)
    );


    addAll([_scoreText, _livesText, _levelText, _targetText, pauseButtonText]);
  }

  void updateScore(int score) => _scoreText.text = 'Score: $score';
  void updateLives(int lives) => _livesText.text = 'Lives: $lives';
  void updateLevel(int level) => _levelText.text = 'Level: $level';
  void updateTarget(int collected, int target) => _targetText.text = 'Target: $collected/$target';
  void updatePauseButton(bool isPaused) => pauseButtonText.text = isPaused ? '▶' : 'II'; // Play/Pause
}