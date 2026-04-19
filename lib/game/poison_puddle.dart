import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'player.dart';

/// Poison puddle left behind by poison projectiles.
/// It does not deal damage directly. Instead it marks the player as being
/// inside poison so the player's own poison tick can switch to 2x damage.
class PoisonPuddle extends PositionComponent with CollisionCallbacks {
  PoisonPuddle({required super.position})
    : super(size: Vector2.all(80), anchor: Anchor.center);

  static const double duration = 5.0; // Total lifetime

  double _lifetimeTimer = duration;
  Player? _playerInside;

  final Paint _puddlePaint = Paint()
    ..color = const Color(0xFF2E7D32).withValues(alpha: 0.62);

  final Paint _outlinePaint = Paint()
    ..color = const Color(0xFFB2FF59)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 3;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Add a circular hitbox for collision detection
    add(
      CircleHitbox(
        radius: size.x / 2,
        position: size / 2,
        anchor: Anchor.center,
        collisionType: CollisionType.active,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    _lifetimeTimer -= dt;

    if (_lifetimeTimer <= 0) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset(size.x / 2, size.y / 2);
    final radius = size.x / 2;

    final glowPaint = Paint()
      ..color = const Color(0xFF43A047).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
    canvas.drawCircle(center, radius + 5, glowPaint);

    canvas.drawCircle(center, radius, _puddlePaint);
    canvas.drawCircle(center, radius, _outlinePaint);

    final bubblePaint = Paint()
      ..color = const Color(0xFFCCFF90).withValues(alpha: 0.45);
    for (int i = 0; i < 3; i++) {
      final bubbleOffset = Offset(
        center.dx + math.cos(i * 2.1) * radius * 0.4,
        center.dy + math.sin(i * 2.1) * radius * 0.4,
      );
      canvas.drawCircle(bubbleOffset, 8, bubblePaint);
    }
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player) {
      _playerInside = other;
      other.enterPoisonArea();
    }
  }

  @override
  void onCollisionEnd(PositionComponent other) {
    super.onCollisionEnd(other);

    if (other is Player) {
      if (identical(_playerInside, other)) {
        _playerInside = null;
      }
      other.exitPoisonArea();
    }
  }

  @override
  void onRemove() {
    // If the puddle expires while the player is still inside, clear that area
    // contact so poison damage returns to normal outside the puddle.
    _playerInside?.exitPoisonArea();
    _playerInside = null;
    super.onRemove();
  }
}
