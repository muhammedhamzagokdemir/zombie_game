import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/painting.dart';

import 'game.dart';
import 'player.dart';
import 'weapon.dart';

/// Ground loot dropped by chests.
/// The player must walk close and press E to pick it up.
class WeaponPickupComponent extends PositionComponent
    with HasGameReference<SurvivalGame> {
  WeaponPickupComponent({required super.position, required this.weapon})
    : super(size: Vector2(62, 42), anchor: Anchor.center, priority: 9);

  final Weapon weapon;
  bool isCollected = false;
  double _hoverTime = 0;

  String get interactionLabel => 'E ile al: ${weapon.name}';

  bool canInteract(Player player) =>
      !isCollected && player.position.distanceTo(position) <= 82;

  @override
  void update(double dt) {
    super.update(dt);
    _hoverTime += dt;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final lift = math.sin(_hoverTime * 2.8) * 3;
    canvas.save();
    canvas.translate(0, lift);

    final rarityPaint = Paint()
      ..color = _rarityColor(weapon.rarity).withValues(alpha: 0.24);
    final shadowPaint = Paint()..color = const Color(0x9911181F);
    final framePaint = Paint()
      ..color = const Color(0xFFCFD8DC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final bodyPaint = Paint()..color = const Color(0xCC18232C);
    final weaponPaint = Paint()..color = weapon.color;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.82),
        width: size.x * 0.72,
        height: 10,
      ),
      shadowPaint,
    );

    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(4, 4, size.x - 8, size.y - 12),
      const Radius.circular(14),
    );
    canvas.drawRRect(cardRect, rarityPaint);
    canvas.drawRRect(cardRect, bodyPaint);
    canvas.drawRRect(cardRect, framePaint);

    final barrelRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.x * 0.62, size.y * 0.42),
        width: weapon.barrelLength.clamp(10, 26),
        height: weapon.barrelThickness.clamp(2, 8),
      ),
      const Radius.circular(4),
    );
    final bodyRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.x * 0.44, size.y * 0.42),
        width: weapon.bodyLength.clamp(10, 22),
        height: weapon.bodyThickness.clamp(4, 10),
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(bodyRect, weaponPaint);
    canvas.drawRRect(barrelRect, weaponPaint);

    if (weapon.hasDualBarrel) {
      final upper = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x * 0.64, size.y * 0.35),
          width: weapon.barrelLength.clamp(8, 24),
          height: weapon.barrelThickness.clamp(2, 6),
        ),
        const Radius.circular(4),
      );
      final lower = RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(size.x * 0.64, size.y * 0.49),
          width: weapon.barrelLength.clamp(8, 24),
          height: weapon.barrelThickness.clamp(2, 6),
        ),
        const Radius.circular(4),
      );
      canvas.drawRRect(upper, weaponPaint);
      canvas.drawRRect(lower, weaponPaint);
    }

    if (weapon.hasScope) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.x * 0.48, size.y * 0.29),
            width: weapon.bodyLength.clamp(8, 20) * 0.55,
            height: 4,
          ),
          const Radius.circular(2),
        ),
        Paint()..color = const Color(0xFF263238),
      );
    }

    final textPainter = TextPainter(
      text: TextSpan(
        text: weapon.name,
        style: const TextStyle(
          color: Color(0xFFFFFFFF),
          fontSize: 9,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
      maxLines: 1,
      ellipsis: '...',
    )..layout(maxWidth: size.x - 10);
    textPainter.paint(
      canvas,
      Offset((size.x - textPainter.width) / 2, size.y - 16),
    );

    canvas.restore();
  }

  void collect() {
    if (isCollected) {
      return;
    }

    isCollected = true;
    game.collectWeaponPickup(this);
  }

  static Color _rarityColor(WeaponRarity rarity) {
    switch (rarity) {
      case WeaponRarity.common:
        return const Color(0xFF90A4AE);
      case WeaponRarity.rare:
        return const Color(0xFF42A5F5);
      case WeaponRarity.epic:
        return const Color(0xFFAB47BC);
      case WeaponRarity.legendary:
        return const Color(0xFFFFB300);
    }
  }
}
