import 'dart:ui';

import 'package:flame/components.dart';

import 'game.dart';
import 'weapon.dart';

/// Loot chest placed inside houses.
/// It opens once and drops a ground weapon pickup into the world.
class ChestComponent extends PositionComponent
    with HasGameReference<SurvivalGame> {
  ChestComponent({required super.position, this.rewardWeapon})
    : super(size: Vector2(48, 38), anchor: Anchor.center, priority: 8);

  final Weapon? rewardWeapon;
  bool isOpened = false;
  String get interactionLabel => 'E ile aç';

  bool canInteract(Vector2 playerPosition) =>
      !isOpened && playerPosition.distanceTo(position) <= 74;

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final bodyPaint = Paint()
      ..color = isOpened ? const Color(0xFF8D6E63) : const Color(0xFFA97442);
    final trimPaint = Paint()
      ..color = const Color(0xFF4E342E)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final latchPaint = Paint()
      ..color = isOpened ? const Color(0xFFCFD8DC) : const Color(0xFFFFD54F);

    final baseRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, size.y * 0.32, size.x, size.y * 0.58),
      const Radius.circular(8),
    );
    canvas.drawRRect(baseRect, bodyPaint);
    canvas.drawRRect(baseRect, trimPaint);

    if (isOpened) {
      final lidPath = Path()
        ..moveTo(2, size.y * 0.35)
        ..lineTo(size.x * 0.14, 2)
        ..lineTo(size.x * 0.92, size.y * 0.18)
        ..lineTo(size.x - 2, size.y * 0.42)
        ..close();
      canvas.drawPath(lidPath, bodyPaint..color = const Color(0xFF8D6E63));
      canvas.drawPath(lidPath, trimPaint);

      final glowPaint = Paint()
        ..color = const Color(0xFFFFF59D).withValues(alpha: 0.28)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10);
      canvas.drawCircle(Offset(size.x / 2, size.y * 0.1), 16, glowPaint);
      return;
    }

    final lidRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.x, size.y * 0.45),
      const Radius.circular(8),
    );
    canvas.drawRRect(lidRect, bodyPaint..color = const Color(0xFFBF8B4C));
    canvas.drawRRect(lidRect, trimPaint);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.48),
        width: 10,
        height: 10,
      ),
      latchPaint,
    );
  }

  void open() {
    if (isOpened) {
      return;
    }

    isOpened = true;
    game.dropChestLoot(position.clone(), rewardWeapon: rewardWeapon);
  }

  void resetChest() {
    isOpened = false;
  }
}
