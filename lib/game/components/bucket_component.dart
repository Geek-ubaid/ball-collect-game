import 'package:bucket_game/game/components/ball_component.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart'; // For Paint, Color, Path
import '../ball_collector_game.dart';

class BucketComponent extends PositionComponent
    with HasGameRef<BallCollectorGame>, DragCallbacks, CollisionCallbacks {
  Color bucketColor;
  late Path _bucketPath;
  late Paint _bucketPaint;
  final Vector2 bucketSize; 

  BucketComponent({
    required this.bucketColor,
    required super.position,
    required this.bucketSize, // Pass size as Vector2
  }) : super(size: bucketSize, anchor: Anchor.topCenter) { // Use passed size for the component
    _bucketPaint = Paint()..color = bucketColor;
    _createBucketPath();
  }

  void _createBucketPath() {
    _bucketPath = Path();
    // Make the top wider than the bottom for a trapezoidal bucket shape
    final topWidth = size.x;
    final bottomWidth = size.x * 0.75; // Bottom is 75% of top width
    final height = size.y;

    // Top-left of the bucket shape (relative to component's origin, which is its center-top)
    _bucketPath.moveTo(-topWidth / 2, 0);
    // Top-right
    _bucketPath.lineTo(topWidth / 2, 0);
    // Bottom-right
    _bucketPath.lineTo(bottomWidth / 2, height);
    // Bottom-left
    _bucketPath.lineTo(-bottomWidth / 2, height);
    _bucketPath.close();
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(RectangleHitbox()); // This will use the component's overall 'size'
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.drawPath(_bucketPath, _bucketPaint);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (gameRef.gameState == GameState.playing) {
      double newX = position.x + event.localDelta.x;
      double leftBound = size.x / 2; 
      double rightBound = gameRef.size.x - (size.x / 2);
      position.x = newX.clamp(leftBound, rightBound);
    }
  }

  void changeColor(Color newColor) {
    bucketColor = newColor;
    _bucketPaint.color = newColor;
  }

  @override
  void onCollisionStart(Set<Vector2> intersectionPoints, PositionComponent other) {
    super.onCollisionStart(intersectionPoints, other);
    if (other is BallComponent) { // Ensure other is BallComponent
      gameRef.handleBallCollected(other, this);
    }
  }
}