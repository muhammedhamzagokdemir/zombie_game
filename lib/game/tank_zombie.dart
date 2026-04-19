import 'dart:ui';

import 'enemy.dart';
import 'game_balance.dart';

class TankZombie extends ZombieEnemy {
  TankZombie({required super.position, required super.moveSpeed})
    : super(
        radius: 28,
        maxHp: 10,
        contactDamage: ZombieBalance.tankContactDamage,
        paint: Paint()..color = const Color(0xFF8E24AA),
        type: ZombieType.tank,
      );
}
