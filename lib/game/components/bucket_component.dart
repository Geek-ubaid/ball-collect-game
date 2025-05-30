// lib/game/components/bucket_component.dart
import 'package:bucket_game/game/components/ball_component.dart';
import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart'; // For Paint, Color, Path
import '../ball_collector_game.dart';
// import 'ball_component.dart'; // Not directly used here, but good to keep if future interactions are complex

class BucketComponent extends PositionComponent // Changed from RectangleComponent
    with HasGameRef<BallCollectorGame>, DragCallbacks, CollisionCallbacks {
  Color bucketColor;
  late Path _bucketPath;
  late Paint _bucketPaint;
  final Vector2 bucketSize; // Store the intended size

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

    // Anchor is topCenter, so position.x is the center of the top edge.
    // Path coordinates are relative to the component's top-left origin (0,0 if anchor is topLeft).
    // Since anchor is topCenter, our (0,0) for path drawing is effectively the top-center of the component.
    // We need to adjust path coordinates relative to this (0,0) which is top-center.

    // Top-left of the bucket shape (relative to component's origin, which is its center-top)
    _bucketPath.moveTo(-topWidth / 2, 0);
    // Top-right
    _bucketPath.lineTo(topWidth / 2, 0);
    // Bottom-right
    _bucketPath.lineTo(bottomWidth / 2, height);
    // Bottom-left
    _bucketPath.lineTo(-bottomWidth / 2, height);
    _bucketPath.close(); // Close the path to form the shape
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // Use a PolygonHitbox for a trapezoidal shape if accuracy is critical
    // For simplicity, a RectangleHitbox matching the overall bounds is often sufficient
    // If using PolygonHitbox, vertices should match the _bucketPath points
    // For RectangleHitbox, it will cover the component's `size`.
    add(RectangleHitbox()); // This will use the component's overall 'size'
                            // For more precise collision with trapezoid, use PolygonHitbox:
    /*
    add(PolygonHitbox([
      Vector2(-size.x / 2, 0),             // Top-left
      Vector2(size.x / 2, 0),              // Top-right
      Vector2(size.x * 0.75 / 2, size.y),  // Bottom-right (adjust factor if bottomWidth changes)
      Vector2(-size.x * 0.75 / 2, size.y), // Bottom-left (adjust factor)
    ]));
    */
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas); // Good practice, though PositionComponent itself doesn't render
    canvas.drawPath(_bucketPath, _bucketPaint);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    if (gameRef.gameState == GameState.playing) {
      double newX = position.x + event.localDelta.x;
      double leftBound = size.x / 2; // Anchor is topCenter, so half width from edge
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