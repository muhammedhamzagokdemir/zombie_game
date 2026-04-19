import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame/text.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../ui/character_select_overlay.dart';
import '../ui/game_over_overlay.dart';
import '../ui/main_menu_overlay.dart';
import '../ui/mobile_controls_overlay.dart';
import 'bullet.dart';
import 'chest.dart';
import 'enemy.dart';
import 'game_balance.dart';
import 'inventory.dart';
import 'map_builder.dart';
import 'obstacle.dart';
import 'player.dart';
import 'poison_projectile.dart';
import 'poison_puddle.dart';
import 'tank_zombie.dart';
import 'weapon.dart';
import 'weapon_pickup.dart';

class GameCharacter {
  const GameCharacter({
    required this.name,
    required this.bodyColor,
    required this.moveSpeed,
    required this.fireInterval,
  });

  final String name;
  final Color bodyColor;
  final double moveSpeed;
  final double fireInterval;
}

class SurvivalGame extends FlameGame
    with
        HasCollisionDetection,
        KeyboardEvents,
        TapCallbacks,
        MouseMovementDetector {
  SurvivalGame()
    : super(
        camera: CameraComponent.withFixedResolution(
          width: gameWidth,
          height: gameHeight,
        ),
      );

  static const double gameWidth = 1280;
  static const double gameHeight = 720;
  static const double worldWidth = 4800;
  static const double worldHeight = 3000;

  static const List<GameCharacter> characters = [
    GameCharacter(
      name: 'Scout',
      bodyColor: Color(0xFF4FC3F7),
      moveSpeed: 270,
      fireInterval: 0.18,
    ),
    GameCharacter(
      name: 'Ranger',
      bodyColor: Color(0xFF66BB6A),
      moveSpeed: 230,
      fireInterval: 0.14,
    ),
    GameCharacter(
      name: 'Heavy',
      bodyColor: Color(0xFFFFA726),
      moveSpeed: 190,
      fireInterval: 0.11,
    ),
  ];

  static const List<Weapon> weapons = weaponCatalog;
  static const Weapon starterWeapon = weaponSmg;

  final math.Random _random = math.Random();
  final Paint _backgroundPaint = Paint()..color = const Color(0xFF101820);
  final List<SolidStructure> obstacles = <SolidStructure>[];
  final List<Rect> zombieBlockedAreas = <Rect>[];
  final PlayerInventory inventory = PlayerInventory();
  final List<Weapon> _availableChestWeapons = <Weapon>[];
  final Set<WeaponType> _claimedChestWeaponTypes = <WeaponType>{};
  final Player player = Player(
    position: Vector2(worldWidth / 2, worldHeight / 2),
  );
  final Set<LogicalKeyboardKey> _keysPressed = <LogicalKeyboardKey>{};

  late Vector2 playerSpawnPoint;
  late final TextComponent<TextPaint> waveText = TextComponent<TextPaint>(
    text: 'Wave 1',
    position: Vector2(10, 10),
    priority: 200,
    textRenderer: _hudText(const Color(0xFFFFF59D)),
  );
  late final TextComponent<TextPaint> healthText = TextComponent<TextPaint>(
    text: 'HP: 100/100',
    position: Vector2(10, 32),
    priority: 200,
    textRenderer: _hudText(const Color(0xFFFFFFFF)),
  );
  late final TextComponent<TextPaint> inventoryText = TextComponent<TextPaint>(
    text: '',
    position: Vector2(gameWidth - 12, 12),
    anchor: Anchor.topRight,
    priority: 200,
    textRenderer: TextPaint(
      style: const TextStyle(
        color: Color(0xFFE3F2FD),
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.4,
      ),
    ),
  );
  late final TextComponent<TextPaint> interactionText =
      TextComponent<TextPaint>(
        text: '',
        position: Vector2(gameWidth / 2, gameHeight - 28),
        anchor: Anchor.bottomCenter,
        priority: 210,
        textRenderer: TextPaint(
          style: const TextStyle(
            color: Color(0xFFFFFFFF),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
      );

  bool moveUp = false;
  bool moveDown = false;
  bool moveLeft = false;
  bool moveRight = false;
  bool isFiring = false;
  bool isGameStarted = false;
  final Vector2 aimDirection = Vector2(1, 0);

  Vector2? mousePosition;
  bool isMouseButtonDown = false;
  bool useMouseAiming = false;

  GameCharacter selectedCharacter = characters[0];
  ChestComponent? _nearbyChest;
  WeaponPickupComponent? _nearbyPickup;

  int currentWave = 1;
  int enemiesRemaining = 0;
  int enemiesToSpawn = 0;
  double _enemySpawnTimer = 0;
  double _enemySpawnInterval = 0.8;
  double _fireCooldown = 0;
  int _queuedBurstShots = 0;
  double _burstShotTimer = 0;
  Vector2 _queuedBurstDirection = Vector2.zero();
  Weapon? _queuedBurstWeapon;
  double _damageCooldown = 0;
  bool _isGameOver = false;

  Weapon get selectedWeapon => inventory.activeWeapon ?? starterWeapon;

  Rect get playArea => const Rect.fromLTWH(0, 0, worldWidth, worldHeight);

  Vector2 get keyboardMovementInput {
    final movement = Vector2.zero();

    if (_keysPressed.contains(LogicalKeyboardKey.keyW) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowUp)) {
      movement.y -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyS) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowDown)) {
      movement.y += 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyA) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowLeft)) {
      movement.x -= 1;
    }
    if (_keysPressed.contains(LogicalKeyboardKey.keyD) ||
        _keysPressed.contains(LogicalKeyboardKey.arrowRight)) {
      movement.x += 1;
    }

    return movement;
  }

  @override
  Color backgroundColor() => const Color(0x00000000);

  @override
  Future<void> onLoad() async {
    camera.follow(player, snap: true);

    final builtMap = const GameMapBuilder().build();
    playerSpawnPoint = builtMap.playerSpawnPoint.clone();
    obstacles
      ..clear()
      ..addAll(builtMap.solids);
    zombieBlockedAreas
      ..clear()
      ..addAll(builtMap.zombieBlockedAreas);
    for (final component in builtMap.components) {
      await world.add(component);
    }

    _resetChestLootPool();
    inventory.initialize(starterWeapon);
    player.position = playerSpawnPoint.clone();
    await world.add(player);
    await camera.viewport.add(waveText);
    await camera.viewport.add(healthText);
    await camera.viewport.add(inventoryText);
    await camera.viewport.add(interactionText);
    updateHealthUI();
    updateInventoryUI();
    _setInteractionPrompt('');

    pauseEngine();
  }

  @override
  KeyEventResult onKeyEvent(
    KeyEvent event,
    Set<LogicalKeyboardKey> keysPressed,
  ) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.keyE) {
        tryInteract();
      } else if (event.logicalKey == LogicalKeyboardKey.digit1) {
        selectInventorySlot(0);
      } else if (event.logicalKey == LogicalKeyboardKey.digit2) {
        selectInventorySlot(1);
      } else if (event.logicalKey == LogicalKeyboardKey.digit3) {
        selectInventorySlot(2);
      }
    }

    _keysPressed
      ..clear()
      ..addAll(keysPressed);
    return KeyEventResult.handled;
  }

  @override
  void onMouseMove(PointerHoverInfo info) {
    final screenPosition = Vector2(
      info.eventPosition.global.x,
      info.eventPosition.global.y,
    );
    mousePosition = camera.globalToLocal(screenPosition);
    useMouseAiming = true;
  }

  @override
  void onTapDown(TapDownEvent event) {
    isMouseButtonDown = true;
    useMouseAiming = true;
  }

  @override
  void onTapUp(TapUpEvent event) {
    isMouseButtonDown = false;
  }

  @override
  void onTapCancel(TapCancelEvent event) {
    isMouseButtonDown = false;
  }

  Vector2 getMouseAimDirection() {
    if (mousePosition == null) {
      return aimDirection;
    }

    final direction = mousePosition! - player.position;
    if (direction.length2 == 0) {
      return aimDirection;
    }
    return direction.normalized();
  }

  @override
  void update(double dt) {
    super.update(dt);

    _updateInteractionState();

    if (!isGameStarted || _isGameOver) {
      return;
    }

    _fireCooldown = math.max(0, _fireCooldown - dt);
    _damageCooldown = math.max(0, _damageCooldown - dt);

    if (_queuedBurstShots > 0 && _queuedBurstWeapon != null) {
      _burstShotTimer -= dt;
      if (_burstShotTimer <= 0) {
        _spawnWeaponShot(_queuedBurstWeapon!, _queuedBurstDirection);
        _queuedBurstShots -= 1;
        if (_queuedBurstShots > 0) {
          _burstShotTimer = _queuedBurstWeapon!.burstShotInterval;
        } else {
          _queuedBurstWeapon = null;
        }
      }
    }

    if (useMouseAiming && mousePosition != null) {
      aimDirection.setFrom(getMouseAimDirection());
    }

    if (enemiesToSpawn > 0) {
      _enemySpawnTimer += dt;
      if (_enemySpawnTimer >= _enemySpawnInterval) {
        _enemySpawnTimer = 0;
        spawnWaveEnemies();
      }
    } else if (enemiesRemaining == 0) {
      startNextWave();
    }

    final shouldFire =
        (isFiring || isMouseButtonDown) &&
        _fireCooldown <= 0 &&
        aimDirection.length2 > 0;
    if (shouldFire) {
      _fireWeapon(aimDirection);
      _fireCooldown = selectedWeapon.fireInterval;
    }
  }

  @override
  void render(Canvas canvas) {
    canvas.drawRect(Rect.fromLTWH(0, 0, size.x, size.y), _backgroundPaint);
    super.render(canvas);
  }

  void setMoveUp(bool value) => moveUp = value;

  void setMoveDown(bool value) => moveDown = value;

  void setMoveLeft(bool value) => moveLeft = value;

  void setMoveRight(bool value) => moveRight = value;

  void setFiring(bool value) {
    isFiring = value;
    if (!value) {
      _fireCooldown = 0;
    }
  }

  void setAimDirection(Vector2 direction) {
    if (direction.length2 == 0) {
      return;
    }

    aimDirection
      ..setFrom(direction)
      ..normalize();
    useMouseAiming = false;
  }

  void openCharacterSelect() {
    overlays.add(CharacterSelectOverlay.id);
  }

  void closeCharacterSelect() {
    overlays.remove(CharacterSelectOverlay.id);
  }

  void selectCharacter(GameCharacter character) {
    selectedCharacter = character;
  }

  void startGame() {
    overlays.remove(MainMenuOverlay.id);
    overlays.remove(CharacterSelectOverlay.id);
    overlays.remove(GameOverOverlay.id);
    overlays.add(MobileControlsOverlay.id);

    _resetGameState();
    startWave();
    isGameStarted = true;
    resumeEngine();
  }

  void takeDamage(int amount, {bool ignoreCooldown = false}) {
    if (!isGameStarted || _isGameOver) {
      return;
    }

    if (!ignoreCooldown && _damageCooldown > 0) {
      return;
    }

    player.takeDamage(amount);
    updateHealthUI();
    if (!ignoreCooldown) {
      _damageCooldown = PlayerBalance.damageCooldown;
    }

    if (player.health == 0) {
      onPlayerDeath();
    }
  }

  void heal(int amount) {
    if (!isGameStarted || _isGameOver) {
      return;
    }

    player.heal(amount);
    updateHealthUI();
  }

  void dropChestLoot(Vector2 origin, {Weapon? rewardWeapon}) {
    final weapon = _consumeUniqueChestWeapon(
      preferred: rewardWeapon,
      excluding: selectedWeapon,
    );
    final dropOffset = Vector2((_random.nextDouble() - 0.5) * 44, -24);
    world.add(
      WeaponPickupComponent(position: origin + dropOffset, weapon: weapon),
    );
  }

  void collectWeaponPickup(WeaponPickupComponent pickup) {
    final result = inventory.addWeapon(pickup.weapon);
    updateInventoryUI();
    _queuedBurstShots = 0;
    _queuedBurstWeapon = null;
    _fireCooldown = 0;
    pickup.removeFromParent();

    if (result.action == InventoryAddAction.replaced &&
        result.previousWeapon != null) {
      // Replacing the active slot keeps the new gun immediately usable.
      selectInventorySlot(result.slotIndex);
      return;
    }
    selectInventorySlot(result.slotIndex);
  }

  void selectInventorySlot(int index) {
    if (!inventory.selectSlot(index)) {
      return;
    }

    _queuedBurstShots = 0;
    _queuedBurstWeapon = null;
    _fireCooldown = 0;
    updateInventoryUI();
  }

  void tryInteract() {
    if (_nearbyPickup != null) {
      _nearbyPickup!.collect();
      _nearbyPickup = null;
      _setInteractionPrompt('');
      return;
    }

    if (_nearbyChest != null) {
      _nearbyChest!.open();
      _nearbyChest = null;
      _setInteractionPrompt('');
    }
  }

  void onEnemyKilled() {
    if (!isGameStarted || _isGameOver) {
      return;
    }

    enemiesRemaining = math.max(0, enemiesRemaining - 1);
  }

  void _resetGameState() {
    moveUp = false;
    moveDown = false;
    moveLeft = false;
    moveRight = false;
    isFiring = false;
    isGameStarted = false;
    _isGameOver = false;
    currentWave = 1;
    enemiesRemaining = 0;
    enemiesToSpawn = 0;
    _enemySpawnTimer = 0;
    _enemySpawnInterval = 0.8;
    _fireCooldown = 0;
    _queuedBurstShots = 0;
    _burstShotTimer = 0;
    _queuedBurstDirection.setZero();
    _queuedBurstWeapon = null;
    _damageCooldown = 0;
    _resetChestLootPool();
    inventory.initialize(starterWeapon);
    aimDirection.setValues(1, 0);
    player.resetStatusEffects();
    updateInventoryUI();
    _setInteractionPrompt('');

    mousePosition = null;
    isMouseButtonDown = false;
    useMouseAiming = false;

    updateHealthUI();

    player.position = playerSpawnPoint.clone();
    player.angle = 0;
    camera.viewfinder.position = player.position.clone();

    _clearCombatEntities();
    waveText.text = 'Wave $currentWave';
  }

  void startWave() {
    final normalEnemyCount = 4 + ((currentWave - 1) * 2);
    final hasTankZombie = currentWave % 10 == 0;

    waveText.text = 'Wave $currentWave';
    enemiesToSpawn = normalEnemyCount;
    enemiesRemaining = normalEnemyCount + (hasTankZombie ? 1 : 0);
    _enemySpawnTimer = 0;
    _enemySpawnInterval = math.max(0.22, 0.8 - (currentWave * 0.02));

    if (hasTankZombie) {
      _spawnTankZombie();
    }
  }

  void spawnWaveEnemies() {
    if (enemiesToSpawn <= 0) {
      return;
    }

    enemiesToSpawn -= 1;
    final moveSpeed = 85 + (currentWave * 2.5);
    final roll = _random.nextDouble();

    if (roll < 0.18) {
      world.add(
        PoisonShooterZombie(
          position: _randomSpawnPosition(),
          moveSpeed: moveSpeed * 0.88,
        ),
      );
      return;
    }

    if (roll < 0.38) {
      world.add(
        PoisonZombie(
          position: _randomSpawnPosition(),
          moveSpeed: moveSpeed * 0.95,
        ),
      );
      return;
    }

    world.add(Enemy(position: _randomSpawnPosition(), moveSpeed: moveSpeed));
  }

  void startNextWave() {
    currentWave += 1;
    startWave();
  }

  void _spawnTankZombie() {
    final moveSpeed = 62 + (currentWave * 1.1);
    world.add(
      TankZombie(position: _randomSpawnPosition(), moveSpeed: moveSpeed),
    );
  }

  Vector2 _randomSpawnPosition() {
    if (size.x <= 0 || size.y <= 0) {
      return Vector2.zero();
    }

    final visibleWorldRect = camera.visibleWorldRect;
    const spawnMargin = 60.0;
    late final Vector2 spawnPosition;
    final side = _random.nextInt(4);

    switch (side) {
      case 0:
        spawnPosition = Vector2(
          visibleWorldRect.left + _random.nextDouble() * visibleWorldRect.width,
          visibleWorldRect.top - spawnMargin,
        );
      case 1:
        spawnPosition = Vector2(
          visibleWorldRect.right + spawnMargin,
          visibleWorldRect.top + _random.nextDouble() * visibleWorldRect.height,
        );
      case 2:
        spawnPosition = Vector2(
          visibleWorldRect.left + _random.nextDouble() * visibleWorldRect.width,
          visibleWorldRect.bottom + spawnMargin,
        );
      default:
        spawnPosition = Vector2(
          visibleWorldRect.left - spawnMargin,
          visibleWorldRect.top + _random.nextDouble() * visibleWorldRect.height,
        );
    }

    return spawnPosition;
  }

  void _fireWeapon(Vector2 direction) {
    if (selectedWeapon.burstCount <= 1) {
      _spawnWeaponShot(selectedWeapon, direction);
      return;
    }

    _queuedBurstWeapon = selectedWeapon;
    _queuedBurstDirection = direction.normalized();
    _spawnWeaponShot(_queuedBurstWeapon!, _queuedBurstDirection);
    _queuedBurstShots = selectedWeapon.burstCount - 1;
    _burstShotTimer = selectedWeapon.burstShotInterval;
  }

  void _spawnWeaponShot(Weapon weapon, Vector2 direction) {
    final projectileCount = weapon.projectileCount;
    final spread = weapon.spreadRadians;

    for (var i = 0; i < projectileCount; i++) {
      final shotDirection = direction.clone();
      if (projectileCount > 1) {
        final t = projectileCount == 1 ? 0.5 : i / (projectileCount - 1);
        final rotation = (t - 0.5) * spread;
        shotDirection.rotate(rotation);
      } else if (spread > 0) {
        final randomOffset = (_random.nextDouble() - 0.5) * spread;
        shotDirection.rotate(randomOffset);
      }

      world.add(
        Bullet(
          position: player.muzzlePosition,
          direction: shotDirection,
          damage: weapon.damage,
          speed: weapon.bulletSpeed,
          maxDistance: weapon.maxRange,
          color: weapon.color,
          radius: weapon.projectileRadius,
        ),
      );
    }
  }

  void updateHealthUI() {
    healthText.text = 'HP: ${player.health}/${player.maxHealth}';
  }

  void updateInventoryUI() {
    final lines = <String>[];
    for (var i = 0; i < inventory.slots.length; i++) {
      final slot = inventory.slots[i];
      final prefix = i == inventory.activeIndex ? '>' : ' ';
      lines.add('$prefix${slot.label}: ${slot.weapon?.name ?? 'Bos'}');
    }
    inventoryText.text = lines.join('\n');
  }

  void resolveObstacleCollision(
    PositionComponent component,
    Vector2 previousPosition,
  ) {
    _resolveCollisionRects(
      component: component,
      previousPosition: previousPosition,
      staticRects: obstacles.map((obstacle) => obstacle.collisionRect),
    );
  }

  void resolveZombieCollision(
    PositionComponent component,
    Vector2 previousPosition,
  ) {
    _resolveCollisionRects(
      component: component,
      previousPosition: previousPosition,
      staticRects: <Rect>[
        ...obstacles.map((obstacle) => obstacle.collisionRect),
        ...zombieBlockedAreas,
      ],
    );
  }

  void _resolveCollisionRects({
    required PositionComponent component,
    required Vector2 previousPosition,
    required Iterable<Rect> staticRects,
  }) {
    var componentRect = _blockingRectFor(component, component.position);
    final previousRect = _blockingRectFor(component, previousPosition);

    for (final obstacleRect in staticRects) {
      if (!componentRect.overlaps(obstacleRect)) {
        continue;
      }

      final halfWidth = componentRect.width / 2;
      final halfHeight = componentRect.height / 2;

      if (previousRect.bottom <= obstacleRect.top) {
        component.position.y = obstacleRect.top - halfHeight;
      } else if (previousRect.top >= obstacleRect.bottom) {
        component.position.y = obstacleRect.bottom + halfHeight;
      } else if (previousRect.right <= obstacleRect.left) {
        component.position.x = obstacleRect.left - halfWidth;
      } else if (previousRect.left >= obstacleRect.right) {
        component.position.x = obstacleRect.right + halfWidth;
      } else {
        final pushLeft = (componentRect.right - obstacleRect.left).abs();
        final pushRight = (obstacleRect.right - componentRect.left).abs();
        final pushUp = (componentRect.bottom - obstacleRect.top).abs();
        final pushDown = (obstacleRect.bottom - componentRect.top).abs();
        final minPush = math.min(
          math.min(pushLeft, pushRight),
          math.min(pushUp, pushDown),
        );

        if (minPush == pushLeft) {
          component.position.x = obstacleRect.left - halfWidth;
        } else if (minPush == pushRight) {
          component.position.x = obstacleRect.right + halfWidth;
        } else if (minPush == pushUp) {
          component.position.y = obstacleRect.top - halfHeight;
        } else {
          component.position.y = obstacleRect.bottom + halfHeight;
        }
      }

      componentRect = _blockingRectFor(component, component.position);
    }
  }

  void onPlayerDeath() {
    if (_isGameOver) {
      return;
    }

    _isGameOver = true;
    isFiring = false;
    overlays.remove(MobileControlsOverlay.id);
    overlays.add(GameOverOverlay.id);
    pauseEngine();
  }

  void returnToMainMenu() {
    overlays.remove(MobileControlsOverlay.id);
    overlays.remove(CharacterSelectOverlay.id);
    overlays.remove(GameOverOverlay.id);
    overlays.add(MainMenuOverlay.id);

    _resetGameState();
    pauseEngine();
  }

  void _clearCombatEntities() {
    for (final enemy in world.children.whereType<ZombieEnemy>().toList()) {
      enemy.removeFromParent();
    }
    for (final bullet in world.children.whereType<Bullet>().toList()) {
      bullet.removeFromParent();
    }
    for (final projectile
        in world.children.whereType<PoisonProjectile>().toList()) {
      projectile.removeFromParent();
    }
    for (final puddle in world.children.whereType<PoisonPuddle>().toList()) {
      puddle.removeFromParent();
    }
    for (final pickup
        in world.children.whereType<WeaponPickupComponent>().toList()) {
      pickup.removeFromParent();
    }
    for (final chest in world.children.whereType<ChestComponent>()) {
      chest.resetChest();
    }
  }

  void _updateInteractionState() {
    ChestComponent? nearestChest;
    WeaponPickupComponent? nearestPickup;
    var bestChestDistance = double.infinity;
    var bestPickupDistance = double.infinity;

    for (final chest in world.children.whereType<ChestComponent>()) {
      if (!chest.canInteract(player.position)) {
        continue;
      }

      final distance = chest.position.distanceToSquared(player.position);
      if (distance < bestChestDistance) {
        bestChestDistance = distance;
        nearestChest = chest;
      }
    }

    for (final pickup in world.children.whereType<WeaponPickupComponent>()) {
      if (!pickup.canInteract(player)) {
        continue;
      }

      final distance = pickup.position.distanceToSquared(player.position);
      if (distance < bestPickupDistance) {
        bestPickupDistance = distance;
        nearestPickup = pickup;
      }
    }

    _nearbyChest = nearestChest;
    _nearbyPickup = nearestPickup;

    if (_nearbyPickup != null) {
      _setInteractionPrompt(_nearbyPickup!.interactionLabel);
      return;
    }
    if (_nearbyChest != null) {
      _setInteractionPrompt(_nearbyChest!.interactionLabel);
      return;
    }
    _setInteractionPrompt('');
  }

  void _setInteractionPrompt(String text) {
    interactionText.text = text;
  }

  Rect _rectFromCenter(Vector2 position, Vector2 size) {
    return Rect.fromCenter(
      center: Offset(position.x, position.y),
      width: size.x,
      height: size.y,
    );
  }

  Rect _blockingRectFor(PositionComponent component, Vector2 position) {
    if (component is Player) {
      return component.blockingRectAt(position);
    }
    if (component is ZombieEnemy) {
      return component.blockingRectAt(position);
    }
    return _rectFromCenter(position, component.size);
  }

  void _resetChestLootPool() {
    _claimedChestWeaponTypes.clear();
    _availableChestWeapons
      ..clear()
      ..addAll(chestWeaponPool);
  }

  Weapon _consumeUniqueChestWeapon({Weapon? preferred, Weapon? excluding}) {
    if (preferred != null &&
        !_claimedChestWeaponTypes.contains(preferred.type)) {
      _claimedChestWeaponTypes.add(preferred.type);
      _availableChestWeapons.removeWhere(
        (weapon) => weapon.type == preferred.type,
      );
      return preferred;
    }

    final candidatePool = _availableChestWeapons
        .where(
          (weapon) =>
              !_claimedChestWeaponTypes.contains(weapon.type) &&
              weapon.type != excluding?.type,
        )
        .toList(growable: false);

    if (candidatePool.isNotEmpty) {
      final picked = candidatePool[_random.nextInt(candidatePool.length)];
      _claimedChestWeaponTypes.add(picked.type);
      _availableChestWeapons.removeWhere(
        (weapon) => weapon.type == picked.type,
      );
      return picked;
    }

    if (_availableChestWeapons.isNotEmpty) {
      final fallback = _availableChestWeapons.removeLast();
      _claimedChestWeaponTypes.add(fallback.type);
      return fallback;
    }

    return preferred ?? excluding ?? starterWeapon;
  }

  static TextPaint _hudText(Color color) {
    return TextPaint(
      style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w700),
    );
  }
}
