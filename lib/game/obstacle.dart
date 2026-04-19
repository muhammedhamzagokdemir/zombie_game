import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

import 'game.dart';

/// Visual types used to give the defense area a few distinct structures.
enum ObstacleType { wall, crate, rock, barrier, bush }

enum HousePalette { azure, slate, navy }

/// Shared base class for solid map structures that block movement and projectiles.
abstract class SolidStructure extends PositionComponent
    with CollisionCallbacks {
  SolidStructure({required super.position, required super.size, super.priority})
    : super(anchor: Anchor.center);

  // The visual size stays generous, but the collision box can be smaller.
  // This keeps movement around props smoother without removing hard cover.
  Vector2 get collisionBoxSize => size;

  Vector2 get collisionBoxOffset => Vector2.zero();

  Vector2 get _collisionBoxTopLeft => Vector2(
    (size.x - collisionBoxSize.x) / 2 + collisionBoxOffset.x,
    (size.y - collisionBoxSize.y) / 2 + collisionBoxOffset.y,
  );

  Rect get collisionRect => Rect.fromCenter(
    center: Offset(
      position.x + collisionBoxOffset.x,
      position.y + collisionBoxOffset.y,
    ),
    width: collisionBoxSize.x,
    height: collisionBoxSize.y,
  );

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(
      RectangleHitbox(
        size: collisionBoxSize,
        position: _collisionBoxTopLeft,
        collisionType: CollisionType.active,
      ),
    );
  }
}

/// Solid structure that blocks movement, bullets and poison projectiles.
/// The health field is optional for future destructible structures.
class ObstacleComponent extends SolidStructure {
  ObstacleComponent({
    required super.position,
    required super.size,
    required this.type,
    this.health,
  }) : super(priority: 20);

  final ObstacleType type;
  final int? health;

  @override
  Vector2 get collisionBoxSize {
    switch (type) {
      case ObstacleType.wall:
        if (size.x >= size.y) {
          return Vector2(size.x * 0.92, math.max(14, size.y * 0.58));
        }
        return Vector2(math.max(14, size.x * 0.58), size.y * 0.92);
      case ObstacleType.crate:
        return Vector2(size.x * 0.78, size.y * 0.78);
      case ObstacleType.rock:
        return Vector2(size.x * 0.7, size.y * 0.56);
      case ObstacleType.barrier:
        if (size.x >= size.y) {
          return Vector2(size.x * 0.88, math.max(12, size.y * 0.66));
        }
        return Vector2(math.max(12, size.x * 0.66), size.y * 0.88);
      case ObstacleType.bush:
        return Vector2(size.x * 0.58, size.y * 0.34);
    }
  }

  @override
  Vector2 get collisionBoxOffset {
    switch (type) {
      case ObstacleType.rock:
        return Vector2(0, size.y * 0.08);
      case ObstacleType.bush:
        return Vector2(0, size.y * 0.16);
      case ObstacleType.wall:
      case ObstacleType.crate:
      case ObstacleType.barrier:
        return Vector2.zero();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    switch (type) {
      case ObstacleType.wall:
        _renderWall(canvas);
      case ObstacleType.crate:
        _renderCrate(canvas);
      case ObstacleType.rock:
        _renderRock(canvas);
      case ObstacleType.barrier:
        _renderBarrier(canvas);
      case ObstacleType.bush:
        _renderBush(canvas);
    }
  }

  void _renderWall(Canvas canvas) {
    final fillPaint = Paint()..color = const Color(0xFF546E7A);
    final edgePaint = Paint()
      ..color = const Color(0xFFCFD8DC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final rect = size.toRect();
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      edgePaint,
    );

    final seamPaint = Paint()
      ..color = const Color(0xFF90A4AE)
      ..strokeWidth = 2;
    final step = size.x > size.y ? size.x / 4 : size.y / 4;
    for (double i = step; i < (size.x > size.y ? size.x : size.y); i += step) {
      if (size.x > size.y) {
        canvas.drawLine(Offset(i, 4), Offset(i, size.y - 4), seamPaint);
      } else {
        canvas.drawLine(Offset(4, i), Offset(size.x - 4, i), seamPaint);
      }
    }
  }

  void _renderCrate(Canvas canvas) {
    final outerPaint = Paint()..color = const Color(0xFF8D6E63);
    final innerPaint = Paint()..color = const Color(0xFFA98274);
    final linePaint = Paint()
      ..color = const Color(0xFFD7CCC8)
      ..strokeWidth = 3;
    final rect = size.toRect();
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(8)),
      outerPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(5), const Radius.circular(6)),
      innerPaint,
    );
    canvas.drawLine(Offset(8, 8), Offset(size.x - 8, size.y - 8), linePaint);
    canvas.drawLine(Offset(size.x - 8, 8), Offset(8, size.y - 8), linePaint);
  }

  void _renderRock(Canvas canvas) {
    final rockPaint = Paint()..color = const Color(0xFF78909C);
    final shinePaint = Paint()..color = const Color(0xFFB0BEC5);
    final path = Path()
      ..moveTo(size.x * 0.18, size.y * 0.78)
      ..lineTo(size.x * 0.1, size.y * 0.42)
      ..lineTo(size.x * 0.3, size.y * 0.12)
      ..lineTo(size.x * 0.7, size.y * 0.08)
      ..lineTo(size.x * 0.9, size.y * 0.36)
      ..lineTo(size.x * 0.82, size.y * 0.8)
      ..close();
    canvas.drawPath(path, rockPaint);
    canvas.drawCircle(
      Offset(size.x * 0.42, size.y * 0.38),
      size.x * 0.12,
      shinePaint,
    );
  }

  void _renderBarrier(Canvas canvas) {
    final basePaint = Paint()..color = const Color(0xFF607D8B);
    final panelPaint = Paint()..color = const Color(0xFF90A4AE);
    final edgePaint = Paint()
      ..color = const Color(0xFF37474F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final rect = size.toRect();
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      basePaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(6), const Radius.circular(8)),
      panelPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(12)),
      edgePaint,
    );
    final seamPaint = Paint()
      ..color = const Color(0xFFCFD8DC)
      ..strokeWidth = 2;
    if (size.x >= size.y) {
      canvas.drawLine(
        Offset(size.x * 0.2, size.y / 2),
        Offset(size.x * 0.8, size.y / 2),
        seamPaint,
      );
    } else {
      canvas.drawLine(
        Offset(size.x / 2, size.y * 0.2),
        Offset(size.x / 2, size.y * 0.8),
        seamPaint,
      );
    }
  }

  void _renderBush(Canvas canvas) {
    final shadowPaint = Paint()..color = const Color(0xFF1B5E20);
    final leafPaint = Paint()..color = const Color(0xFF43A047);
    final highlightPaint = Paint()..color = const Color(0xFF81C784);
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(size.x / 2, size.y * 0.6),
        width: size.x * 0.9,
        height: size.y * 0.55,
      ),
      shadowPaint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.35, size.y * 0.4),
      size.x * 0.22,
      leafPaint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.55, size.y * 0.34),
      size.x * 0.24,
      leafPaint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.72, size.y * 0.45),
      size.x * 0.2,
      leafPaint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.45, size.y * 0.32),
      size.x * 0.08,
      highlightPaint,
    );
  }
}

class HouseWallComponent extends SolidStructure {
  HouseWallComponent({required super.position, required super.size})
    : super(priority: 16);

  @override
  void render(Canvas canvas) {}
}

class HouseLayout {
  HouseLayout._({
    required this.bodyRect,
    required this.floorRect,
    required this.interiorRect,
    required this.doorwayRect,
    required this.topWallRect,
    required this.leftWallRect,
    required this.rightWallRect,
    required this.bottomLeftWallRect,
    required this.bottomRightWallRect,
    required this.zombieDoorBlockerRect,
    required this.wallThickness,
  });

  factory HouseLayout.fromSize(Vector2 size, HousePalette palette) {
    final bodyRect = Rect.fromLTWH(10, 14, size.x - 24, size.y - 28);
    final doorwayFactor = switch (palette) {
      HousePalette.azure => 0.34,
      HousePalette.slate => 0.32,
      HousePalette.navy => 0.3,
    };
    final wallThickness = math.max(
      16.0,
      math.min(22.0, bodyRect.shortestSide * 0.11),
    );
    final doorwayWidth = math.max(
      74.0,
      math.min(104.0, bodyRect.width * doorwayFactor),
    );
    final floorInset = wallThickness - 2;
    final floorRect = bodyRect.deflate(floorInset);
    final interiorInset = 4.0;
    final interiorRect = Rect.fromLTWH(
      floorRect.left + interiorInset,
      floorRect.top + interiorInset,
      math.max(24.0, floorRect.width - (interiorInset * 2)),
      math.max(24.0, floorRect.height - (interiorInset * 2)),
    );
    final bottomSegmentWidth = math.max(
      28.0,
      (bodyRect.width - doorwayWidth) / 2,
    );
    final topWallRect = Rect.fromLTWH(
      bodyRect.left,
      bodyRect.top,
      bodyRect.width,
      wallThickness,
    );
    final leftWallRect = Rect.fromLTWH(
      bodyRect.left,
      bodyRect.top,
      wallThickness,
      bodyRect.height,
    );
    final rightWallRect = Rect.fromLTWH(
      bodyRect.right - wallThickness,
      bodyRect.top,
      wallThickness,
      bodyRect.height,
    );
    final bottomLeftWallRect = Rect.fromLTWH(
      bodyRect.left,
      bodyRect.bottom - wallThickness,
      bottomSegmentWidth,
      wallThickness,
    );
    final bottomRightWallRect = Rect.fromLTWH(
      bodyRect.right - bottomSegmentWidth,
      bodyRect.bottom - wallThickness,
      bottomSegmentWidth,
      wallThickness,
    );
    final doorwayRect = Rect.fromCenter(
      center: Offset(bodyRect.center.dx, bodyRect.bottom - (wallThickness / 2)),
      width: doorwayWidth,
      height: wallThickness + 8,
    );
    final zombieDoorBlockerRect = Rect.fromCenter(
      center: Offset(
        doorwayRect.center.dx,
        doorwayRect.center.dy + (wallThickness * 0.25),
      ),
      width: doorwayRect.width + 34,
      height: doorwayRect.height + 48,
    );

    return HouseLayout._(
      bodyRect: bodyRect,
      floorRect: floorRect,
      interiorRect: interiorRect,
      doorwayRect: doorwayRect,
      topWallRect: topWallRect,
      leftWallRect: leftWallRect,
      rightWallRect: rightWallRect,
      bottomLeftWallRect: bottomLeftWallRect,
      bottomRightWallRect: bottomRightWallRect,
      zombieDoorBlockerRect: zombieDoorBlockerRect,
      wallThickness: wallThickness,
    );
  }

  final Rect bodyRect;
  final Rect floorRect;
  final Rect interiorRect;
  final Rect doorwayRect;
  final Rect topWallRect;
  final Rect leftWallRect;
  final Rect rightWallRect;
  final Rect bottomLeftWallRect;
  final Rect bottomRightWallRect;
  final Rect zombieDoorBlockerRect;
  final double wallThickness;

  List<Rect> get wallRects => <Rect>[
    topWallRect,
    leftWallRect,
    rightWallRect,
    bottomLeftWallRect,
    bottomRightWallRect,
  ];
}

/// Secondary buildings placed around the map.
/// They share the same chunky arcade style as the main base but use
/// different color palettes and sizes to make the world feel more alive.
class HouseComponent extends PositionComponent
    with HasGameReference<SurvivalGame> {
  HouseComponent({
    required super.position,
    required super.size,
    required this.palette,
  }) : super(anchor: Anchor.center, priority: -1);

  final HousePalette palette;
  late final HouseLayout layout = HouseLayout.fromSize(size, palette);
  late final List<HouseWallComponent> wallComponents = _buildWallComponents();
  late final HouseRoofComponent roofComponent = HouseRoofComponent(house: this);
  bool isPlayerInsideHouse = false;

  List<HouseWallComponent> buildWalls() => wallComponents;

  List<Rect> get zombieDoorBlockerRects => <Rect>[
    _worldRectFromLocal(layout.zombieDoorBlockerRect),
  ];

  Rect get interiorRect => _worldRectFromLocal(layout.interiorRect);

  List<HouseWallComponent> _buildWallComponents() {
    final localCenter = size / 2;
    return layout.wallRects
        .map((wallRect) {
          final wallCenter = wallRect.center;
          return HouseWallComponent(
            position:
                position +
                Vector2(
                  wallCenter.dx - localCenter.x,
                  wallCenter.dy - localCenter.y,
                ),
            size: Vector2(wallRect.width, wallRect.height),
          );
        })
        .toList(growable: false);
  }

  Rect _worldRectFromLocal(Rect localRect) {
    return localRect.translate(
      position.x - (size.x / 2),
      position.y - (size.y / 2),
    );
  }

  @override
  void update(double dt) {
    super.update(dt);

    // The interior trigger is a simple playable rectangle inside the walls.
    // When the player enters it, the separate roof overlay is hidden.
    final isInside = interiorRect.contains(
      Offset(game.player.position.x, game.player.position.y),
    );
    if (isPlayerInsideHouse == isInside) {
      return;
    }

    isPlayerInsideHouse = isInside;
    roofComponent.isHidden = isInside;
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final colors = _houseColorsForPalette(palette);
    final wallPaint = Paint()..color = colors.body;
    final sidePaint = Paint()..color = colors.side;
    final floorPaint = Paint()..color = const Color(0xFFBEDA98);
    final borderPaint = Paint()
      ..color = colors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final trimPaint = Paint()
      ..color = colors.trim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final windowPaint = Paint()..color = const Color(0xFFE1F5FE);
    final doorwayPaint = Paint()..color = const Color(0xFF7CB342);

    canvas.drawRRect(
      RRect.fromRectAndRadius(layout.bodyRect, const Radius.circular(18)),
      wallPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(layout.floorRect, const Radius.circular(12)),
      floorPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(layout.bodyRect, const Radius.circular(18)),
      borderPaint,
    );

    final topShadow = Rect.fromLTWH(
      layout.bodyRect.left + 10,
      layout.bodyRect.top + 6,
      layout.bodyRect.width - 28,
      14,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(topShadow, const Radius.circular(8)),
      sidePaint,
    );

    final leftWindow = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        layout.bodyRect.left + 18,
        layout.bodyRect.top + 28,
        layout.bodyRect.width * 0.16,
        layout.bodyRect.height * 0.16,
      ),
      const Radius.circular(8),
    );
    final rightWindow = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        layout.bodyRect.right - 18 - layout.bodyRect.width * 0.16,
        layout.bodyRect.top + 28,
        layout.bodyRect.width * 0.16,
        layout.bodyRect.height * 0.16,
      ),
      const Radius.circular(8),
    );
    canvas.drawRRect(leftWindow, windowPaint);
    canvas.drawRRect(leftWindow, trimPaint);
    canvas.drawRRect(rightWindow, windowPaint);
    canvas.drawRRect(rightWindow, trimPaint);

    final leftBottomWall = RRect.fromRectAndRadius(
      layout.bottomLeftWallRect,
      const Radius.circular(8),
    );
    final rightBottomWall = RRect.fromRectAndRadius(
      layout.bottomRightWallRect,
      const Radius.circular(8),
    );
    canvas.drawRRect(leftBottomWall, wallPaint);
    canvas.drawRRect(leftBottomWall, trimPaint);
    canvas.drawRRect(rightBottomWall, wallPaint);
    canvas.drawRRect(rightBottomWall, trimPaint);

    final doorwayRect = RRect.fromRectAndRadius(
      layout.doorwayRect.deflate(3),
      const Radius.circular(8),
    );
    canvas.drawRRect(doorwayRect, doorwayPaint);
    canvas.drawLine(
      Offset(doorwayRect.left + 8, doorwayRect.center.dy),
      Offset(doorwayRect.right - 8, doorwayRect.center.dy),
      trimPaint,
    );
  }
}

/// Tree obstacle used as natural cover around the arena.
/// Different sizes keep the placement from feeling too regular.
class TreeComponent extends SolidStructure {
  TreeComponent({required super.position, required super.size})
    : super(priority: 14);

  @override
  Vector2 get collisionBoxSize =>
      Vector2(math.max(20, size.x * 0.24), math.max(24, size.y * 0.24));

  @override
  Vector2 get collisionBoxOffset => Vector2(0, size.y * 0.22);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final center = Offset(size.x / 2, size.y / 2);
    final shadowPaint = Paint()..color = const Color(0xFF1B5E20);
    final leafPaint = Paint()..color = const Color(0xFF43A047);
    final highlightPaint = Paint()..color = const Color(0xFF81C784);
    final trunkPaint = Paint()..color = const Color(0xFF795548);
    final outlinePaint = Paint()
      ..color = const Color(0xFF245126)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(center.dx, center.dy + size.y * 0.1),
        width: size.x * 0.84,
        height: size.y * 0.36,
      ),
      shadowPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, size.y * 0.72),
          width: size.x * 0.16,
          height: size.y * 0.24,
        ),
        const Radius.circular(6),
      ),
      trunkPaint,
    );

    final circles = <({Offset center, double radius})>[
      (center: Offset(size.x * 0.34, size.y * 0.42), radius: size.x * 0.19),
      (center: Offset(size.x * 0.52, size.y * 0.3), radius: size.x * 0.23),
      (center: Offset(size.x * 0.7, size.y * 0.44), radius: size.x * 0.19),
      (center: Offset(size.x * 0.48, size.y * 0.5), radius: size.x * 0.22),
    ];

    for (final circle in circles) {
      canvas.drawCircle(circle.center, circle.radius, leafPaint);
      canvas.drawCircle(circle.center, circle.radius, outlinePaint);
    }

    canvas.drawCircle(
      Offset(size.x * 0.43, size.y * 0.27),
      size.x * 0.08,
      highlightPaint,
    );
    canvas.drawCircle(
      Offset(size.x * 0.62, size.y * 0.36),
      size.x * 0.06,
      highlightPaint,
    );
  }
}

class _HouseColors {
  const _HouseColors({
    required this.body,
    required this.side,
    required this.roof,
    required this.border,
    required this.trim,
  });

  final Color body;
  final Color side;
  final Color roof;
  final Color border;
  final Color trim;
}

_HouseColors _houseColorsForPalette(HousePalette palette) {
  switch (palette) {
    case HousePalette.azure:
      return const _HouseColors(
        body: Color(0xFF64B5F6),
        side: Color(0xFF1E88E5),
        roof: Color(0xFFBBDEFB),
        border: Color(0xFF0D47A1),
        trim: Color(0xFFE3F2FD),
      );
    case HousePalette.slate:
      return const _HouseColors(
        body: Color(0xFFB0BEC5),
        side: Color(0xFF78909C),
        roof: Color(0xFFECEFF1),
        border: Color(0xFF37474F),
        trim: Color(0xFFFAFAFA),
      );
    case HousePalette.navy:
      return const _HouseColors(
        body: Color(0xFF5C6BC0),
        side: Color(0xFF3949AB),
        roof: Color(0xFF9FA8DA),
        border: Color(0xFF1A237E),
        trim: Color(0xFFE8EAF6),
      );
  }
}

/// Roof overlay that can be hidden while the player is inside the house.
/// It has no collision; only the house wall segments are solid.
class HouseRoofComponent extends PositionComponent
    with HasGameReference<SurvivalGame> {
  HouseRoofComponent({required this.house})
    : super(
        position: house.position,
        size: house.size,
        anchor: Anchor.center,
        priority: 30,
      );

  final HouseComponent house;
  bool isHidden = false;

  @override
  void update(double dt) {
    super.update(dt);
    position = house.position;
    size = house.size;
  }

  @override
  void render(Canvas canvas) {
    if (isHidden) {
      return;
    }

    super.render(canvas);

    final colors = _houseColorsForPalette(house.palette);
    final bodyRect = house.layout.bodyRect;
    final sideRect = Rect.fromLTWH(
      bodyRect.left + 14,
      bodyRect.bottom - 6,
      bodyRect.width,
      18,
    );
    final rightFace = Path()
      ..moveTo(bodyRect.right, bodyRect.top + 12)
      ..lineTo(bodyRect.right + 14, bodyRect.top + 24)
      ..lineTo(bodyRect.right + 14, bodyRect.bottom + 12)
      ..lineTo(bodyRect.right, bodyRect.bottom + 2)
      ..close();

    final bodyPaint = Paint()..color = colors.body;
    final sidePaint = Paint()..color = colors.side;
    final roofPaint = Paint()..color = colors.roof;
    final borderPaint = Paint()
      ..color = colors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final trimPaint = Paint()
      ..color = colors.trim
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final windowPaint = Paint()..color = const Color(0xFFE1F5FE);

    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(18)),
      bodyPaint,
    );
    canvas.drawRect(sideRect, sidePaint);
    canvas.drawPath(rightFace, sidePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(bodyRect, const Radius.circular(18)),
      borderPaint,
    );
    canvas.drawRect(sideRect, borderPaint);
    canvas.drawPath(rightFace, borderPaint);

    final roofRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(
          bodyRect.center.dx - bodyRect.width * 0.08,
          bodyRect.top + bodyRect.height * 0.34,
        ),
        width: bodyRect.width * 0.52,
        height: bodyRect.height * 0.28,
      ),
      const Radius.circular(14),
    );
    canvas.drawRRect(roofRect, roofPaint);
    canvas.drawRRect(roofRect, trimPaint);

    final windowWidth = bodyRect.width * 0.16;
    final windowHeight = bodyRect.height * 0.18;
    for (final dx in <double>[
      bodyRect.left + 22,
      bodyRect.right - 22 - windowWidth,
    ]) {
      final windowRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(dx, bodyRect.top + 26, windowWidth, windowHeight),
        const Radius.circular(8),
      );
      canvas.drawRRect(windowRect, windowPaint);
      canvas.drawRRect(windowRect, trimPaint);
    }

    final doorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(bodyRect.center.dx, bodyRect.bottom - 24),
        width: bodyRect.width * 0.18,
        height: bodyRect.height * 0.24,
      ),
      const Radius.circular(10),
    );
    canvas.drawRRect(doorRect, Paint()..color = colors.side);
    canvas.drawRRect(doorRect, trimPaint);
  }
}

/// Large blue building in the arena center-left.
/// It is also a solid structure, so it works as a major cover object.
class BaseZoneComponent extends SolidStructure {
  BaseZoneComponent({required super.position, required super.size})
    : super(priority: 10);

  @override
  Vector2 get collisionBoxSize => Vector2(size.x * 0.88, size.y * 0.88);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    final topRect = Rect.fromLTWH(12, 12, size.x - 34, size.y - 34);
    final sideRect = Rect.fromLTWH(
      topRect.left + 18,
      topRect.bottom - 4,
      topRect.width,
      22,
    );
    final rightFace = Path()
      ..moveTo(topRect.right, topRect.top + 12)
      ..lineTo(topRect.right + 18, topRect.top + 26)
      ..lineTo(topRect.right + 18, topRect.bottom + 18)
      ..lineTo(topRect.right, topRect.bottom + 2)
      ..close();

    final topPaint = Paint()..color = const Color(0xFF42A5F5);
    final sidePaint = Paint()..color = const Color(0xFF1565C0);
    final roofPaint = Paint()..color = const Color(0xFF90CAF9);
    final borderPaint = Paint()
      ..color = const Color(0xFF0D47A1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    final hatchPaint = Paint()
      ..color = const Color(0xFFE3F2FD).withValues(alpha: 0.55)
      ..strokeWidth = 3;

    canvas.drawRRect(
      RRect.fromRectAndRadius(topRect, const Radius.circular(24)),
      topPaint,
    );
    canvas.drawRect(sideRect, sidePaint);
    canvas.drawPath(rightFace, sidePaint);
    canvas.drawRRect(
      RRect.fromRectAndRadius(topRect, const Radius.circular(24)),
      borderPaint,
    );
    canvas.drawRect(sideRect, borderPaint);
    canvas.drawPath(rightFace, borderPaint);

    final roofPanel = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(topRect.center.dx - 24, topRect.center.dy - 20),
        width: topRect.width * 0.46,
        height: topRect.height * 0.34,
      ),
      const Radius.circular(18),
    );
    canvas.drawRRect(roofPanel, roofPaint);
    canvas.drawRRect(roofPanel, borderPaint..strokeWidth = 4);

    final connectorPaint = Paint()..color = const Color(0xFF64B5F6);
    final connectorBorder = Paint()
      ..color = const Color(0xFF0D47A1)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final connectorRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(topRect.right - 8, topRect.center.dy + 56),
        width: 88,
        height: 54,
      ),
      const Radius.circular(16),
    );
    canvas.drawRRect(connectorRect, connectorPaint);
    canvas.drawRRect(connectorRect, connectorBorder);

    for (double x = roofPanel.left + 22; x < roofPanel.right - 10; x += 30) {
      canvas.drawLine(
        Offset(x, roofPanel.top + 14),
        Offset(x + 18, roofPanel.bottom - 14),
        hatchPaint,
      );
    }

    final entryPaint = Paint()..color = const Color(0xFFBBDEFB);
    final entryRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(topRect.center.dx - 96, topRect.bottom - 40),
        width: 86,
        height: 56,
      ),
      const Radius.circular(14),
    );
    canvas.drawRRect(entryRect, entryPaint);
    canvas.drawRRect(entryRect, connectorBorder);
  }
}
