import 'dart:ui';

enum AmmoType {
  lightAmmo,
  mediumAmmo,
  heavyAmmo,
  shells,
  sniperAmmo,
  energyAmmo,
  bolts,
  poisonAmmo,
}

enum WeaponType {
  smg,
  assaultRifle,
  shotgun,
  autoShotgun,
  sniper,
  revolver,
  burstRifle,
  crossbow,
  energyRifle,
  plasmaGun,
  lmg,
  poisonLauncher,
  machinePistol,
  carbine,
  marksmanRifle,
  leverRifle,
  heavyShotgun,
  rotaryCannon,
  arcBlaster,
  gaussRifle,
  needleBurst,
  slugRifle,
}

enum WeaponRarity { common, rare, epic, legendary }

class Weapon {
  const Weapon({
    required this.type,
    required this.name,
    required this.summary,
    required this.rarity,
    required this.fireInterval,
    required this.damage,
    required this.projectileCount,
    required this.spreadRadians,
    required this.color,
    required this.bulletSpeed,
    required this.maxRange,
    required this.projectileRadius,
    required this.barrelLength,
    required this.barrelThickness,
    required this.bodyLength,
    required this.bodyThickness,
    required this.ammoType,
    required this.magazineSize,
    required this.maxReserveAmmo,
    required this.startingReserveAmmo,
    required this.reloadTime,
    this.barrelGap = 0,
    this.hasDualBarrel = false,
    this.hasScope = false,
    this.burstCount = 1,
    this.burstShotInterval = 0.05,
  });

  final WeaponType type;
  final String name;
  final String summary;
  final WeaponRarity rarity;
  final double fireInterval;
  final int damage;
  final int projectileCount;
  final double spreadRadians;
  final Color color;
  final double bulletSpeed;
  final double maxRange;
  final double projectileRadius;
  final double barrelLength;
  final double barrelThickness;
  final double bodyLength;
  final double bodyThickness;
  final AmmoType ammoType;
  final int magazineSize;
  final int maxReserveAmmo;
  final int startingReserveAmmo;
  final double reloadTime;
  final double barrelGap;
  final bool hasDualBarrel;
  final bool hasScope;
  final int burstCount;
  final double burstShotInterval;
}

String ammoTypeLabel(AmmoType ammoType) {
  switch (ammoType) {
    case AmmoType.lightAmmo:
      return 'Light';
    case AmmoType.mediumAmmo:
      return 'Medium';
    case AmmoType.heavyAmmo:
      return 'Heavy';
    case AmmoType.shells:
      return 'Shells';
    case AmmoType.sniperAmmo:
      return 'Sniper';
    case AmmoType.energyAmmo:
      return 'Energy';
    case AmmoType.bolts:
      return 'Bolts';
    case AmmoType.poisonAmmo:
      return 'Poison';
  }
}

int defaultAmmoPickupAmount(AmmoType ammoType) {
  switch (ammoType) {
    case AmmoType.lightAmmo:
      return 48;
    case AmmoType.mediumAmmo:
      return 36;
    case AmmoType.heavyAmmo:
      return 24;
    case AmmoType.shells:
      return 10;
    case AmmoType.sniperAmmo:
      return 8;
    case AmmoType.energyAmmo:
      return 30;
    case AmmoType.bolts:
      return 6;
    case AmmoType.poisonAmmo:
      return 8;
  }
}

Color ammoTypeColor(AmmoType ammoType) {
  switch (ammoType) {
    case AmmoType.lightAmmo:
      return const Color(0xFFB0BEC5);
    case AmmoType.mediumAmmo:
      return const Color(0xFF90A4AE);
    case AmmoType.heavyAmmo:
      return const Color(0xFFFFB74D);
    case AmmoType.shells:
      return const Color(0xFFFF8A65);
    case AmmoType.sniperAmmo:
      return const Color(0xFFCE93D8);
    case AmmoType.energyAmmo:
      return const Color(0xFF4DD0E1);
    case AmmoType.bolts:
      return const Color(0xFFA1887F);
    case AmmoType.poisonAmmo:
      return const Color(0xFF9CCC65);
  }
}

const Weapon weaponSmg = Weapon(
  type: WeaponType.smg,
  name: 'SMG',
  summary: 'Hizli atis, dusuk-orta hasar, kisa-orta menzil',
  rarity: WeaponRarity.common,
  fireInterval: 0.08,
  damage: 1,
  projectileCount: 1,
  spreadRadians: 0.07,
  color: Color(0xFFB0BEC5),
  bulletSpeed: 640,
  maxRange: 1040,
  projectileRadius: 4.5,
  barrelLength: 16,
  barrelThickness: 4,
  bodyLength: 15,
  bodyThickness: 8,
  ammoType: AmmoType.lightAmmo,
  magazineSize: 30,
  maxReserveAmmo: 180,
  startingReserveAmmo: 120,
  reloadTime: 1.35,
);

const Weapon weaponAssaultRifle = Weapon(
  type: WeaponType.assaultRifle,
  name: 'Assault Rifle',
  summary: 'Dengeli hasar, orta-yuksek menzil, sabit atis',
  rarity: WeaponRarity.common,
  fireInterval: 0.13,
  damage: 2,
  projectileCount: 1,
  spreadRadians: 0.035,
  color: Color(0xFF90A4AE),
  bulletSpeed: 760,
  maxRange: 1420,
  projectileRadius: 4.8,
  barrelLength: 22,
  barrelThickness: 4,
  bodyLength: 20,
  bodyThickness: 7,
  ammoType: AmmoType.mediumAmmo,
  magazineSize: 24,
  maxReserveAmmo: 144,
  startingReserveAmmo: 96,
  reloadTime: 1.65,
);

const Weapon weaponBurstRifle = Weapon(
  type: WeaponType.burstRifle,
  name: 'Burst Rifle',
  summary: 'Her tetikte 3 mermi, kontrollu salvolar',
  rarity: WeaponRarity.rare,
  fireInterval: 0.34,
  damage: 2,
  projectileCount: 1,
  spreadRadians: 0.025,
  color: Color(0xFF80CBC4),
  bulletSpeed: 780,
  maxRange: 1450,
  projectileRadius: 4.6,
  barrelLength: 22,
  barrelThickness: 4,
  bodyLength: 21,
  bodyThickness: 6,
  ammoType: AmmoType.mediumAmmo,
  magazineSize: 24,
  maxReserveAmmo: 132,
  startingReserveAmmo: 84,
  reloadTime: 1.8,
  burstCount: 3,
  burstShotInterval: 0.055,
);

const Weapon weaponRevolver = Weapon(
  type: WeaponType.revolver,
  name: 'Revolver',
  summary: 'Yavas ama guclu tekli atis',
  rarity: WeaponRarity.common,
  fireInterval: 0.32,
  damage: 3,
  projectileCount: 1,
  spreadRadians: 0.02,
  color: Color(0xFFB0BEC5),
  bulletSpeed: 700,
  maxRange: 1180,
  projectileRadius: 5,
  barrelLength: 14,
  barrelThickness: 5,
  bodyLength: 12,
  bodyThickness: 10,
  ammoType: AmmoType.heavyAmmo,
  magazineSize: 6,
  maxReserveAmmo: 48,
  startingReserveAmmo: 30,
  reloadTime: 1.75,
);

const Weapon weaponSniper = Weapon(
  type: WeaponType.sniper,
  name: 'Sniper',
  summary: 'Tek mermi, yuksek hasar, dusuk atis hizi',
  rarity: WeaponRarity.epic,
  fireInterval: 0.72,
  damage: 6,
  projectileCount: 1,
  spreadRadians: 0,
  color: Color(0xFFCFD8DC),
  bulletSpeed: 1180,
  maxRange: 2350,
  projectileRadius: 5.4,
  barrelLength: 34,
  barrelThickness: 4,
  bodyLength: 16,
  bodyThickness: 6,
  ammoType: AmmoType.sniperAmmo,
  magazineSize: 5,
  maxReserveAmmo: 30,
  startingReserveAmmo: 15,
  reloadTime: 2.45,
  hasScope: true,
);

const Weapon weaponShotgun = Weapon(
  type: WeaponType.shotgun,
  name: 'Shotgun',
  summary: 'Cift namlu, yayili sacma, yakin mesafe',
  rarity: WeaponRarity.rare,
  fireInterval: 0.48,
  damage: 2,
  projectileCount: 6,
  spreadRadians: 0.46,
  color: Color(0xFFFFCC80),
  bulletSpeed: 540,
  maxRange: 720,
  projectileRadius: 5.2,
  barrelLength: 20,
  barrelThickness: 4,
  bodyLength: 14,
  bodyThickness: 10,
  ammoType: AmmoType.shells,
  magazineSize: 8,
  maxReserveAmmo: 40,
  startingReserveAmmo: 20,
  reloadTime: 2.05,
  barrelGap: 7,
  hasDualBarrel: true,
);

const Weapon weaponAutoShotgun = Weapon(
  type: WeaponType.autoShotgun,
  name: 'Auto Shotgun',
  summary: 'Daha hizli sacma atisi, yakin baski silahi',
  rarity: WeaponRarity.epic,
  fireInterval: 0.22,
  damage: 2,
  projectileCount: 4,
  spreadRadians: 0.34,
  color: Color(0xFFFFAB91),
  bulletSpeed: 560,
  maxRange: 760,
  projectileRadius: 5.1,
  barrelLength: 18,
  barrelThickness: 5,
  bodyLength: 18,
  bodyThickness: 11,
  ammoType: AmmoType.shells,
  magazineSize: 10,
  maxReserveAmmo: 48,
  startingReserveAmmo: 24,
  reloadTime: 2.3,
);

const Weapon weaponCrossbow = Weapon(
  type: WeaponType.crossbow,
  name: 'Crossbow',
  summary: 'Yavas ama sert, agir ok benzeri atis',
  rarity: WeaponRarity.epic,
  fireInterval: 0.58,
  damage: 4,
  projectileCount: 1,
  spreadRadians: 0.01,
  color: Color(0xFF8D6E63),
  bulletSpeed: 900,
  maxRange: 1780,
  projectileRadius: 5.6,
  barrelLength: 26,
  barrelThickness: 3.5,
  bodyLength: 18,
  bodyThickness: 6,
  ammoType: AmmoType.bolts,
  magazineSize: 1,
  maxReserveAmmo: 18,
  startingReserveAmmo: 8,
  reloadTime: 1.1,
);

const Weapon weaponEnergyRifle = Weapon(
  type: WeaponType.energyRifle,
  name: 'Energy Rifle',
  summary: 'Temiz, hizli enerji atislari',
  rarity: WeaponRarity.rare,
  fireInterval: 0.11,
  damage: 2,
  projectileCount: 1,
  spreadRadians: 0.018,
  color: Color(0xFF4DD0E1),
  bulletSpeed: 880,
  maxRange: 1520,
  projectileRadius: 5,
  barrelLength: 24,
  barrelThickness: 4,
  bodyLength: 20,
  bodyThickness: 7,
  ammoType: AmmoType.energyAmmo,
  magazineSize: 28,
  maxReserveAmmo: 140,
  startingReserveAmmo: 84,
  reloadTime: 1.7,
  hasScope: true,
);

const Weapon weaponPlasmaGun = Weapon(
  type: WeaponType.plasmaGun,
  name: 'Plasma Gun',
  summary: 'Yavas ama genis plazma atislari',
  rarity: WeaponRarity.legendary,
  fireInterval: 0.26,
  damage: 4,
  projectileCount: 1,
  spreadRadians: 0.03,
  color: Color(0xFFE040FB),
  bulletSpeed: 620,
  maxRange: 1280,
  projectileRadius: 6.6,
  barrelLength: 20,
  barrelThickness: 6,
  bodyLength: 18,
  bodyThickness: 10,
  ammoType: AmmoType.energyAmmo,
  magazineSize: 14,
  maxReserveAmmo: 70,
  startingReserveAmmo: 42,
  reloadTime: 1.95,
);

const Weapon weaponLmg = Weapon(
  type: WeaponType.lmg,
  name: 'LMG',
  summary: 'Yuksek atis hacmi, agir ama uzun surekli baski',
  rarity: WeaponRarity.rare,
  fireInterval: 0.07,
  damage: 2,
  projectileCount: 1,
  spreadRadians: 0.06,
  color: Color(0xFF90A4AE),
  bulletSpeed: 720,
  maxRange: 1560,
  projectileRadius: 4.8,
  barrelLength: 24,
  barrelThickness: 5,
  bodyLength: 24,
  bodyThickness: 9,
  ammoType: AmmoType.mediumAmmo,
  magazineSize: 60,
  maxReserveAmmo: 240,
  startingReserveAmmo: 120,
  reloadTime: 3.1,
);

const Weapon weaponPoisonLauncher = Weapon(
  type: WeaponType.poisonLauncher,
  name: 'Poison Launcher',
  summary: 'Yavas toksik kapsul, agir vurus',
  rarity: WeaponRarity.legendary,
  fireInterval: 0.44,
  damage: 5,
  projectileCount: 1,
  spreadRadians: 0.025,
  color: Color(0xFF7CB342),
  bulletSpeed: 500,
  maxRange: 1200,
  projectileRadius: 7,
  barrelLength: 18,
  barrelThickness: 7,
  bodyLength: 18,
  bodyThickness: 11,
  ammoType: AmmoType.poisonAmmo,
  magazineSize: 6,
  maxReserveAmmo: 24,
  startingReserveAmmo: 12,
  reloadTime: 2.35,
);

const Weapon weaponMachinePistol = Weapon(
  type: WeaponType.machinePistol,
  name: 'Machine Pistol',
  summary: 'Cep boy hizli atis, kisa menzilli yakin baski',
  rarity: WeaponRarity.common,
  fireInterval: 0.06,
  damage: 1,
  projectileCount: 1,
  spreadRadians: 0.09,
  color: Color(0xFFA5D6A7),
  bulletSpeed: 610,
  maxRange: 920,
  projectileRadius: 4.2,
  barrelLength: 14,
  barrelThickness: 4,
  bodyLength: 13,
  bodyThickness: 8,
  ammoType: AmmoType.lightAmmo,
  magazineSize: 24,
  maxReserveAmmo: 160,
  startingReserveAmmo: 96,
  reloadTime: 1.2,
);

const Weapon weaponCarbine = Weapon(
  type: WeaponType.carbine,
  name: 'Carbine',
  summary: 'Hafif recoil, hizli hedef degisimi, temiz orta menzil',
  rarity: WeaponRarity.common,
  fireInterval: 0.1,
  damage: 2,
  projectileCount: 1,
  spreadRadians: 0.024,
  color: Color(0xFFFFF59D),
  bulletSpeed: 820,
  maxRange: 1500,
  projectileRadius: 4.7,
  barrelLength: 24,
  barrelThickness: 4,
  bodyLength: 18,
  bodyThickness: 7,
  ammoType: AmmoType.mediumAmmo,
  magazineSize: 26,
  maxReserveAmmo: 156,
  startingReserveAmmo: 104,
  reloadTime: 1.5,
);

const Weapon weaponMarksmanRifle = Weapon(
  type: WeaponType.marksmanRifle,
  name: 'Marksman Rifle',
  summary: 'Yari otomatik, sert orta-uzun menzil atislari',
  rarity: WeaponRarity.rare,
  fireInterval: 0.24,
  damage: 4,
  projectileCount: 1,
  spreadRadians: 0.012,
  color: Color(0xFFB39DDB),
  bulletSpeed: 980,
  maxRange: 1900,
  projectileRadius: 5.1,
  barrelLength: 30,
  barrelThickness: 4,
  bodyLength: 20,
  bodyThickness: 7,
  ammoType: AmmoType.sniperAmmo,
  magazineSize: 12,
  maxReserveAmmo: 48,
  startingReserveAmmo: 24,
  reloadTime: 2.0,
  hasScope: true,
);

const Weapon weaponLeverRifle = Weapon(
  type: WeaponType.leverRifle,
  name: 'Lever Rifle',
  summary: 'Ritmik ama sert vuran tekli atis',
  rarity: WeaponRarity.rare,
  fireInterval: 0.28,
  damage: 4,
  projectileCount: 1,
  spreadRadians: 0.016,
  color: Color(0xFFBC8F6F),
  bulletSpeed: 860,
  maxRange: 1580,
  projectileRadius: 4.9,
  barrelLength: 28,
  barrelThickness: 4,
  bodyLength: 19,
  bodyThickness: 7,
  ammoType: AmmoType.heavyAmmo,
  magazineSize: 8,
  maxReserveAmmo: 56,
  startingReserveAmmo: 32,
  reloadTime: 1.9,
);

const Weapon weaponHeavyShotgun = Weapon(
  type: WeaponType.heavyShotgun,
  name: 'Heavy Shotgun',
  summary: 'Az ama agir sacma, sert yakin alan durdurma',
  rarity: WeaponRarity.epic,
  fireInterval: 0.58,
  damage: 3,
  projectileCount: 8,
  spreadRadians: 0.32,
  color: Color(0xFFFF8A65),
  bulletSpeed: 600,
  maxRange: 860,
  projectileRadius: 5.6,
  barrelLength: 24,
  barrelThickness: 5,
  bodyLength: 19,
  bodyThickness: 11,
  ammoType: AmmoType.shells,
  magazineSize: 6,
  maxReserveAmmo: 30,
  startingReserveAmmo: 14,
  reloadTime: 2.55,
  barrelGap: 8,
  hasDualBarrel: true,
);

const Weapon weaponRotaryCannon = Weapon(
  type: WeaponType.rotaryCannon,
  name: 'Rotary Cannon',
  summary: 'Agir namlu, sabit kalinca hizla alan tarar',
  rarity: WeaponRarity.legendary,
  fireInterval: 0.05,
  damage: 2,
  projectileCount: 1,
  spreadRadians: 0.08,
  color: Color(0xFFFF7043),
  bulletSpeed: 760,
  maxRange: 1460,
  projectileRadius: 5.1,
  barrelLength: 28,
  barrelThickness: 6,
  bodyLength: 24,
  bodyThickness: 10,
  ammoType: AmmoType.mediumAmmo,
  magazineSize: 72,
  maxReserveAmmo: 252,
  startingReserveAmmo: 144,
  reloadTime: 3.35,
);

const Weapon weaponArcBlaster = Weapon(
  type: WeaponType.arcBlaster,
  name: 'Arc Blaster',
  summary: 'Parlak enerji darbeleri, sabit ve hizli atis',
  rarity: WeaponRarity.epic,
  fireInterval: 0.12,
  damage: 3,
  projectileCount: 1,
  spreadRadians: 0.014,
  color: Color(0xFF80DEEA),
  bulletSpeed: 930,
  maxRange: 1640,
  projectileRadius: 5.2,
  barrelLength: 23,
  barrelThickness: 5,
  bodyLength: 19,
  bodyThickness: 8,
  ammoType: AmmoType.energyAmmo,
  magazineSize: 20,
  maxReserveAmmo: 110,
  startingReserveAmmo: 60,
  reloadTime: 1.75,
  hasScope: true,
);

const Weapon weaponGaussRifle = Weapon(
  type: WeaponType.gaussRifle,
  name: 'Gauss Rifle',
  summary: 'Cok hizli cekirdek, delici hissi veren uzak atis',
  rarity: WeaponRarity.legendary,
  fireInterval: 0.42,
  damage: 6,
  projectileCount: 1,
  spreadRadians: 0.004,
  color: Color(0xFFB2EBF2),
  bulletSpeed: 1320,
  maxRange: 2400,
  projectileRadius: 5.4,
  barrelLength: 36,
  barrelThickness: 3.5,
  bodyLength: 18,
  bodyThickness: 6,
  ammoType: AmmoType.sniperAmmo,
  magazineSize: 4,
  maxReserveAmmo: 20,
  startingReserveAmmo: 10,
  reloadTime: 2.8,
  hasScope: true,
);

const Weapon weaponNeedleBurst = Weapon(
  type: WeaponType.needleBurst,
  name: 'Needle Burst',
  summary: 'Pembe mikro salvo, hizli ve kontrollu burst',
  rarity: WeaponRarity.rare,
  fireInterval: 0.3,
  damage: 2,
  projectileCount: 1,
  spreadRadians: 0.02,
  color: Color(0xFFF48FB1),
  bulletSpeed: 840,
  maxRange: 1440,
  projectileRadius: 4.6,
  barrelLength: 22,
  barrelThickness: 4,
  bodyLength: 19,
  bodyThickness: 7,
  ammoType: AmmoType.energyAmmo,
  magazineSize: 21,
  maxReserveAmmo: 126,
  startingReserveAmmo: 63,
  reloadTime: 1.85,
  burstCount: 4,
  burstShotInterval: 0.05,
);

const Weapon weaponSlugRifle = Weapon(
  type: WeaponType.slugRifle,
  name: 'Slug Rifle',
  summary: 'Tek agir slug, orta menzilde net darbe',
  rarity: WeaponRarity.epic,
  fireInterval: 0.36,
  damage: 5,
  projectileCount: 1,
  spreadRadians: 0.01,
  color: Color(0xFFDCE775),
  bulletSpeed: 880,
  maxRange: 1500,
  projectileRadius: 5.5,
  barrelLength: 26,
  barrelThickness: 5,
  bodyLength: 20,
  bodyThickness: 9,
  ammoType: AmmoType.heavyAmmo,
  magazineSize: 5,
  maxReserveAmmo: 35,
  startingReserveAmmo: 20,
  reloadTime: 2.15,
);

const List<Weapon> weaponCatalog = <Weapon>[
  weaponSmg,
  weaponAssaultRifle,
  weaponBurstRifle,
  weaponRevolver,
  weaponSniper,
  weaponShotgun,
  weaponAutoShotgun,
  weaponCrossbow,
  weaponEnergyRifle,
  weaponPlasmaGun,
  weaponLmg,
  weaponPoisonLauncher,
  weaponMachinePistol,
  weaponCarbine,
  weaponMarksmanRifle,
  weaponLeverRifle,
  weaponHeavyShotgun,
  weaponRotaryCannon,
  weaponArcBlaster,
  weaponGaussRifle,
  weaponNeedleBurst,
  weaponSlugRifle,
];

const List<Weapon> chestWeaponPool = <Weapon>[
  weaponAssaultRifle,
  weaponBurstRifle,
  weaponRevolver,
  weaponSniper,
  weaponShotgun,
  weaponAutoShotgun,
  weaponCrossbow,
  weaponEnergyRifle,
  weaponPlasmaGun,
  weaponLmg,
  weaponPoisonLauncher,
  weaponMachinePistol,
  weaponCarbine,
  weaponMarksmanRifle,
  weaponLeverRifle,
  weaponHeavyShotgun,
  weaponRotaryCannon,
  weaponArcBlaster,
  weaponGaussRifle,
  weaponNeedleBurst,
  weaponSlugRifle,
];
