import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'game_balance.dart';
import 'game.dart';
import 'obstacle.dart';
import 'player.dart';
import 'poison_puddle.dart';

/// Green poison ball fired by the ranged poison zombie.
/// On player hit it applies poison, spawns a puddle, then disappears.
class PoisonProjectile extends CircleComponent
    with HasGameReference<SurvivalGame>, CollisionCallbacks {
  PoisonProjectile({
    required super.position,
    required Vector2 direction,
    required this.speed,
  }) : direction = direction.clone(),
       super(
         radius: 8,
         anchor: Anchor.center,
         paint: Paint()..color = const Color(0xFF7CB342),
       ) {
    if (this.direction.length2 == 0) {
      this.direction.setValues(1, 0);
    } else {
      this.direction.normalize();
    }
  }

  static const double maxDistance = 1200;
  static const double offScreenMargin = 40;

  final Vector2 direction;
  final double speed;
  double _distanceTravelled = 0;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(CircleHitbox(collisionType: CollisionType.active));
  }

  @override
  void update(double dt) {
    super.update(dt);

    final travelStep = speed * dt;
    position += direction * travelStep;
    _distanceTravelled += travelStep;

    final outsideX =
        position.x < -offScreenMargin ||
        position.x > SurvivalGame.worldWidth + offScreenMargin;
    final outsideY =
        position.y < -offScreenMargin ||
        position.y > SurvivalGame.worldHeight + offScreenMargin;

    if (outsideX || outsideY || _distanceTravelled >= maxDistance) {
      removeFromParent();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset(radius, radius);
    final glowPaint = Paint()
      ..color = const Color(0xFF9CCC65).withValues(alpha: 0.45)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    canvas.drawCircle(center, radius + 3, glowPaint);

    final corePaint = Paint()..color = const Color(0xFFD4E157);
    canvas.drawCircle(center, radius * 0.45, corePaint);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is SolidStructure) {
      removeFromParent();
      return;
    }

    if (other is! Player) {
      return;
    }

    // The projectile only applies poison on hit.
    // Ongoing poison damage is handled by the player over time.
    game.takeDamage(ZombieBalance.poisonProjectileImpactDamage);
    other.applyPoison();
    game.world.add(PoisonPuddle(position: position.clone()));
    removeFromParent();
  }
}
