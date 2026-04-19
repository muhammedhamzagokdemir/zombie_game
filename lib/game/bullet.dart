import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'enemy.dart';
import 'game.dart';
import 'obstacle.dart';

class Bullet extends CircleComponent
    with HasGameReference<SurvivalGame>, CollisionCallbacks {
  Bullet({
    required super.position,
    required Vector2 direction,
    required this.damage,
    required this.speed,
    required this.maxDistance,
    required Color color,
    required double radius,
  }) : direction = direction.clone(),
       super(
         radius: radius,
         anchor: Anchor.center,
         paint: Paint()..color = color,
       ) {
    // Normalize the direction vector so bullets travel at consistent speed.
    // The direction comes from the aiming system (mouse on desktop, joystick on mobile).
    // Formula: position += direction * speed * dt
    if (this.direction.length2 == 0) {
      this.direction.setValues(1, 0);
    } else {
      this.direction.normalize();
    }
  }

  final Vector2 direction;
  final int damage;
  final double speed;
  final double maxDistance;
  double _distanceTravelled = 0;
  static const double offScreenMargin = 32;

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // Bullets only need to collide with active hitboxes, such as enemies.
    add(CircleHitbox(collisionType: CollisionType.passive));
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
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is ZombieEnemy) {
      other.takeHit(damage);
      removeFromParent();
      return;
    }

    if (other is SolidStructure) {
      removeFromParent();
    }
  }
}
