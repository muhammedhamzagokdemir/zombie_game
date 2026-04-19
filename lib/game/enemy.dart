import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'game_balance.dart';
import 'game.dart';
import 'player.dart';
import 'poison_projectile.dart';

/// Zombie types for different enemy variations.
enum ZombieType { normal, poison, poisonShooter, tank }

abstract class ZombieEnemy extends CircleComponent
    with HasGameReference<SurvivalGame>, CollisionCallbacks {
  ZombieEnemy({
    required super.position,
    required super.radius,
    required this.moveSpeed,
    required this.maxHp,
    required this.contactDamage,
    required Paint paint,
    required this.type,
  }) : _hp = maxHp,
       super(anchor: Anchor.center, paint: paint);

  final ZombieType type;
  final double moveSpeed;
  final int maxHp;
  final int contactDamage;
  int _hp;

  int get hp => _hp;

  // Movement collision is slightly smaller than the rendered circle so
  // zombies slide around trees and buildings more naturally.
  double get blockingRadius => radius * 0.68;

  Rect blockingRectAt(Vector2 center) => Rect.fromCircle(
    center: Offset(center.x, center.y),
    radius: blockingRadius,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    // All zombies share the same collision behavior and only differ by stats.
    add(CircleHitbox(collisionType: CollisionType.active));
  }

  @override
  void update(double dt) {
    super.update(dt);

    final toPlayer = game.player.position - position;
    if (toPlayer.length2 == 0) {
      return;
    }

    final direction = toPlayer.normalized();
    final previousPosition = position.clone();
    position += direction * moveSpeed * dt;
    game.resolveZombieCollision(this, previousPosition);
    angle = math.atan2(direction.y, direction.x);
  }

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player && contactDamage > 0) {
      // Contact damage still uses the shared damage cooldown in the game.
      game.takeDamage(contactDamage);
    }
  }

  void takeHit(int amount) {
    _hp -= amount;
    if (_hp <= 0) {
      // Report the defeat to the wave system before removing the zombie.
      game.onEnemyKilled();
      removeFromParent();
    }
  }
}

class Enemy extends ZombieEnemy {
  Enemy({required super.position, required super.moveSpeed})
    : super(
        radius: 16,
        maxHp: 1,
        contactDamage: ZombieBalance.normalContactDamage,
        paint: Paint()..color = const Color(0xFFE53935),
        type: ZombieType.normal,
      );
}

/// Melee poison zombie that deals lower direct damage but also poisons the player.
class PoisonZombie extends ZombieEnemy {
  PoisonZombie({required super.position, required super.moveSpeed})
    : super(
        radius: 17,
        maxHp: 2,
        contactDamage: ZombieBalance.poisonContactDamage,
        paint: Paint()..color = const Color(0xFF7E57C2),
        type: ZombieType.poison,
      );

  @override
  void onCollisionStart(
    Set<Vector2> intersectionPoints,
    PositionComponent other,
  ) {
    super.onCollisionStart(intersectionPoints, other);

    if (other is Player) {
      other.applyPoison();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset(radius, radius);
    final glowPaint = Paint()
      ..color = const Color(0xFF66BB6A).withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    final corePaint = Paint()..color = const Color(0xFFA5D66F);
    canvas.drawCircle(center, radius + 3, glowPaint);
    canvas.drawCircle(center, radius * 0.28, corePaint);
  }
}

/// Green ranged zombie that throws poison projectiles at the player.
/// It still walks toward the player, but its main threat is the projectile.
class PoisonShooterZombie extends ZombieEnemy {
  PoisonShooterZombie({required super.position, required super.moveSpeed})
    : super(
        radius: 18,
        maxHp: 2,
        contactDamage: ZombieBalance.poisonShooterContactDamage,
        paint: Paint()..color = const Color(0xFF43A047),
        type: ZombieType.poisonShooter,
      );

  static const double projectileSpeed = 260;
  static const double fireInterval = 2.4;
  static const double attackRange = 900;
  double _fireTimer = 0;

  @override
  void update(double dt) {
    super.update(dt);

    _fireTimer += dt;

    final toPlayer = game.player.position - position;
    if (toPlayer.length2 == 0 || toPlayer.length2 > attackRange * attackRange) {
      return;
    }

    if (_fireTimer >= fireInterval) {
      _fireTimer = 0;
      _shootPoisonBall(toPlayer.normalized());
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset(radius, radius);
    final haloPaint = Paint()
      ..color = const Color(0xFF7CB342).withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, radius + 4, haloPaint);

    final corePaint = Paint()..color = const Color(0xFFA5D66F);
    canvas.drawCircle(center, radius * 0.35, corePaint);
  }

  void _shootPoisonBall(Vector2 direction) {
    final spawnOffset = direction * (radius + 10);
    game.world.add(
      PoisonProjectile(
        position: position + spawnOffset,
        direction: direction,
        speed: projectileSpeed,
      ),
    );
  }
}
