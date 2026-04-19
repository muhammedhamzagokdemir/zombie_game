import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'game_balance.dart';
import 'game.dart';
import 'weapon.dart';

class Player extends PositionComponent
    with HasGameReference<SurvivalGame>, CollisionCallbacks {
  Player({required super.position})
    : super(size: Vector2.all(36), anchor: Anchor.center);

  final Paint _bodyPaint = Paint();
  final Paint _gunPaint = Paint()..color = const Color(0xFFECEFF1);
  int health = PlayerBalance.maxHealth;
  int get maxHealth => PlayerBalance.maxHealth;
  double get collisionRadius => size.x * 0.28;

  // Poison system: when hit by poison zombie, player takes damage over time.
  bool isPoisoned = false;
  bool isInsidePoisonArea = false; // True when player is inside a poison puddle
  double poisonTimer = 0; // Total poison duration (5 seconds)
  double poisonTickTimer = 0; // Time between poison damage ticks (1 second)
  int _poisonAreaContacts = 0;

  Vector2 get muzzlePosition {
    final offset = Vector2(size.x * 0.5 + game.selectedWeapon.barrelLength, 0)
      ..rotate(angle);
    return position + offset;
  }

  Rect blockingRectAt(Vector2 center) => Rect.fromCircle(
    center: Offset(center.x, center.y),
    radius: collisionRadius,
  );

  @override
  Future<void> onLoad() async {
    // The hitbox defines the area used for collisions.
    add(
      CircleHitbox(
        radius: collisionRadius,
        position: size / 2,
        anchor: Anchor.center,
        collisionType: CollisionType.passive,
      ),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Poison damage system: while poisoned, take 1 damage every second for 5 seconds.
    if (isPoisoned) {
      poisonTimer -= dt;
      poisonTickTimer -= dt;

      // Deal poison damage every tick interval
      // 2x damage when inside poison puddle, 1x damage when outside
      if (poisonTickTimer <= 0) {
        final damage = isInsidePoisonArea
            ? PlayerBalance.poisonPuddleTickDamage
            : PlayerBalance.poisonTickDamage;
        game.takeDamage(damage, ignoreCooldown: true);
        poisonTickTimer = PlayerBalance.poisonTickInterval;
      }

      // Poison effect ends when timer runs out
      if (poisonTimer <= 0) {
        isPoisoned = false;
        poisonTimer = 0;
        poisonTickTimer = 0;
      }
    }

    final direction = Vector2.zero();

    if (game.moveUp) {
      direction.y -= 1;
    }
    if (game.moveDown) {
      direction.y += 1;
    }
    if (game.moveLeft) {
      direction.x -= 1;
    }
    if (game.moveRight) {
      direction.x += 1;
    }

    // Keep keyboard support alongside mobile buttons.
    direction.add(game.keyboardMovementInput);

    if (direction.length2 > 1) {
      direction.normalize();
    }

    final previousPosition = position.clone();
    position += direction * game.selectedCharacter.moveSpeed * dt;
    _keepInsideScreen();
    game.resolveObstacleCollision(this, previousPosition);
    _keepInsideScreen();

    // Player rotation follows the shared aim direction.
    // Desktop updates it from the mouse cursor, mobile updates it from the
    // right-side fire pad overlay, and the player uses the same vector for both.
    if (game.aimDirection.length2 > 0) {
      angle = math.atan2(game.aimDirection.y, game.aimDirection.x);
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Apply purple tint when poisoned
    if (isPoisoned) {
      _bodyPaint.color = Color.lerp(
        game.selectedCharacter.bodyColor,
        const Color(0xFF9C27B0),
        0.6,
      )!;
    } else {
      _bodyPaint.color = game.selectedCharacter.bodyColor;
    }
    canvas.drawCircle(Offset(size.x / 2, size.y / 2), size.x / 2, _bodyPaint);

    // Draw poison glow effect when poisoned
    if (isPoisoned) {
      final glowPaint = Paint()
        ..color = const Color(0xFF9C27B0).withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(
        Offset(size.x / 2, size.y / 2),
        size.x / 2 + 4,
        glowPaint,
      );
    }

    _gunPaint.color = game.selectedWeapon.color;
    _renderWeapon(canvas);
  }

  /// Apply poison effect to the player.
  /// Re-applying poison refreshes the timer, but does not stack extra ticks.
  void applyPoison() {
    isPoisoned = true;
    poisonTimer = PlayerBalance.poisonDuration;
    poisonTickTimer = PlayerBalance.poisonTickInterval;
  }

  /// Called by poison puddles when the player enters the area.
  /// A counter is used so overlapping puddles still keep the flag true.
  void enterPoisonArea() {
    _poisonAreaContacts += 1;
    isInsidePoisonArea = true;
  }

  /// Called by poison puddles when the player exits the area.
  void exitPoisonArea() {
    _poisonAreaContacts = math.max(0, _poisonAreaContacts - 1);
    isInsidePoisonArea = _poisonAreaContacts > 0;
  }

  /// Clear all poison-related state when the run resets.
  void resetStatusEffects() {
    health = maxHealth;
    isPoisoned = false;
    isInsidePoisonArea = false;
    poisonTimer = 0;
    poisonTickTimer = 0;
    _poisonAreaContacts = 0;
  }

  int takeDamage(int amount) {
    health = math.max(0, health - amount);
    return health;
  }

  int heal(int amount) {
    health = math.min(maxHealth, health + amount);
    return health;
  }

  void _keepInsideScreen() {
    final halfWidth = size.x / 2;
    final halfHeight = size.y / 2;

    position.x = position.x
        .clamp(halfWidth, SurvivalGame.worldWidth - halfWidth)
        .toDouble();
    position.y = position.y
        .clamp(halfHeight, SurvivalGame.worldHeight - halfHeight)
        .toDouble();
  }

  void _renderWeapon(Canvas canvas) {
    final weapon = game.selectedWeapon;
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.x / 2 + weapon.bodyLength * 0.28, 0),
        width: weapon.bodyLength,
        height: weapon.bodyThickness,
      ),
      Radius.circular(weapon.bodyThickness / 2),
    );
    canvas.drawRRect(bodyRect, _gunPaint);

    final accentPaint = Paint()..color = const Color(0xFF263238);

    if (weapon.hasDualBarrel) {
      for (final barrelOffset in <double>[
        -weapon.barrelGap / 2,
        weapon.barrelGap / 2,
      ]) {
        final barrelRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(
              size.x / 2 + weapon.barrelLength * 0.55,
              barrelOffset,
            ),
            width: weapon.barrelLength,
            height: weapon.barrelThickness,
          ),
          Radius.circular(weapon.barrelThickness / 2),
        );
        canvas.drawRRect(barrelRect, _gunPaint);
      }
      final stockRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x / 2 - weapon.bodyLength * 0.1, 0),
          width: weapon.bodyLength * 0.45,
          height: weapon.bodyThickness * 0.65,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(stockRect, accentPaint);
      return;
    }

    if (weapon.type == WeaponType.autoShotgun ||
        weapon.type == WeaponType.heavyShotgun ||
        weapon.type == WeaponType.slugRifle) {
      final pumpRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x / 2 + weapon.barrelLength * 0.36, 0),
          width: weapon.barrelLength * 0.42,
          height: weapon.bodyThickness * 0.72,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(pumpRect, accentPaint);
    }

    if (weapon.type == WeaponType.revolver) {
      final cylinder = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x / 2 + 4, 0),
          width: weapon.bodyThickness * 0.95,
          height: weapon.bodyThickness * 0.95,
        ),
        Radius.circular(weapon.bodyThickness / 2),
      );
      canvas.drawRRect(cylinder, accentPaint);
    }

    if (weapon.type == WeaponType.crossbow) {
      final stringPaint = Paint()
        ..color = const Color(0xFF4E342E)
        ..strokeWidth = 2.4;
      final crossbarCenter = Offset(size.x / 2 + weapon.barrelLength * 0.64, 0);
      final crossbarPaint = Paint()
        ..color = weapon.color
        ..strokeWidth = 4;
      final barrelRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x / 2 + weapon.barrelLength * 0.48, 0),
          width: weapon.barrelLength,
          height: weapon.barrelThickness,
        ),
        Radius.circular(weapon.barrelThickness / 2),
      );
      canvas.drawRRect(barrelRect, _gunPaint);
      canvas.drawLine(
        Offset(crossbarCenter.dx, -weapon.bodyThickness * 0.9),
        Offset(crossbarCenter.dx, weapon.bodyThickness * 0.9),
        crossbarPaint,
      );
      canvas.drawLine(
        Offset(size.x / 2 + weapon.bodyLength * 0.1, 0),
        Offset(crossbarCenter.dx, -weapon.bodyThickness * 0.9),
        stringPaint,
      );
      canvas.drawLine(
        Offset(size.x / 2 + weapon.bodyLength * 0.1, 0),
        Offset(crossbarCenter.dx, weapon.bodyThickness * 0.9),
        stringPaint,
      );
      return;
    }

    final barrelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.x / 2 + weapon.barrelLength * 0.55, 0),
        width: weapon.barrelLength,
        height: weapon.barrelThickness,
      ),
      Radius.circular(weapon.barrelThickness / 2),
    );
    canvas.drawRRect(barrelRect, _gunPaint);

    if (weapon.type == WeaponType.smg ||
        weapon.type == WeaponType.machinePistol) {
      final magRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x / 2 + weapon.bodyLength * 0.12, 6),
          width: weapon.bodyLength * 0.22,
          height: weapon.bodyThickness * 0.85,
        ),
        const Radius.circular(3),
      );
      canvas.drawRRect(magRect, accentPaint);
    }

    if (weapon.type == WeaponType.assaultRifle ||
        weapon.type == WeaponType.burstRifle ||
        weapon.type == WeaponType.lmg ||
        weapon.type == WeaponType.carbine ||
        weapon.type == WeaponType.marksmanRifle ||
        weapon.type == WeaponType.leverRifle ||
        weapon.type == WeaponType.gaussRifle ||
        weapon.type == WeaponType.needleBurst ||
        weapon.type == WeaponType.slugRifle ||
        weapon.type == WeaponType.rotaryCannon) {
      final magRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x / 2 + weapon.bodyLength * 0.14, 6),
          width: weapon.bodyLength * 0.24,
          height: weapon.bodyThickness,
        ),
        const Radius.circular(4),
      );
      final stockRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x / 2 - weapon.bodyLength * 0.16, 0),
          width: weapon.bodyLength * 0.34,
          height: weapon.bodyThickness * 0.6,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(magRect, accentPaint);
      canvas.drawRRect(stockRect, accentPaint);
    }

    if (weapon.type == WeaponType.lmg ||
        weapon.type == WeaponType.rotaryCannon) {
      final boxMag = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x / 2 + weapon.bodyLength * 0.08, 8),
          width: weapon.bodyLength * 0.38,
          height: weapon.bodyThickness * 1.1,
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(boxMag, accentPaint);
    }

    if (weapon.type == WeaponType.rotaryCannon) {
      for (final barrelOffset in <double>[-4, 0, 4]) {
        final clusterRect = RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(
              size.x / 2 + weapon.barrelLength * 0.72,
              barrelOffset.toDouble(),
            ),
            width: weapon.barrelLength * 0.42,
            height: weapon.barrelThickness * 0.42,
          ),
          const Radius.circular(2),
        );
        canvas.drawRRect(clusterRect, accentPaint);
      }
    }

    if (weapon.type == WeaponType.burstRifle ||
        weapon.type == WeaponType.needleBurst) {
      final railRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x / 2 + weapon.bodyLength * 0.25, -4.5),
          width: weapon.bodyLength * 0.52,
          height: 3.5,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(railRect, accentPaint);
    }

    if (weapon.type == WeaponType.energyRifle ||
        weapon.type == WeaponType.plasmaGun ||
        weapon.type == WeaponType.poisonLauncher ||
        weapon.type == WeaponType.arcBlaster) {
      final coreColor = weapon.type == WeaponType.energyRifle
          ? const Color(0xFF80DEEA)
          : weapon.type == WeaponType.plasmaGun
          ? const Color(0xFFEA80FC)
          : weapon.type == WeaponType.poisonLauncher
          ? const Color(0xFFAED581)
          : const Color(0xFF80DEEA);
      canvas.drawCircle(
        Offset(size.x / 2 + weapon.bodyLength * 0.2, 0),
        weapon.bodyThickness * 0.32,
        Paint()..color = coreColor,
      );
    }

    if (weapon.hasScope) {
      final scopeRect = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x / 2 + weapon.bodyLength * 0.42, -5),
          width: weapon.bodyLength * 0.5,
          height: 4,
        ),
        const Radius.circular(2),
      );
      canvas.drawRRect(scopeRect, accentPaint);
    }
  }
}
