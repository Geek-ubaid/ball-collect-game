import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import '../ball_collector_game.dart'; // To access game logic

class BallComponent extends CircleComponent with HasGameRef<BallCollectorGame>, CollisionCallbacks {
  Vector2 velocity;
  final Color ballColor;

  BallComponent({
    required super.position,
    required this.ballColor,
    required this.velocity,
    required double radius,
  }) : super(radius: radius, anchor: Anchor.center, paint: Paint()..color = ballColor);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox());
  }

  @override
  void update(double dt) {
    super.update(dt);
    position.y += velocity.y * dt;
    position.x += velocity.x * dt; // If you want horizontal movement too

    // Remove if off-screen (bottom)
    if (position.y - radius > gameRef.size.y) {
      gameRef.handleMissedBall(this);
      removeFromParent();
    }
  }
}