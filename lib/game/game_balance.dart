class PlayerBalance {
  const PlayerBalance._();

  static const int maxHealth = 100;
  static const double damageCooldown = 0.75;
  static const double poisonDuration = 5.0;
  static const double poisonTickInterval = 1.0;
  static const int poisonTickDamage = 1;
  static const int poisonPuddleTickDamage = 2;
}

class ZombieBalance {
  const ZombieBalance._();

  static const int normalContactDamage = 7;
  static const int poisonContactDamage = 5;
  static const int poisonShooterContactDamage = 6;
  static const int poisonProjectileImpactDamage = 8;
  static const int tankContactDamage = 18;
}
