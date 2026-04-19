import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';

import 'chest.dart';
import 'game.dart';
import 'obstacle.dart';
import 'weapon.dart';

class BuiltGameMap {
  BuiltGameMap({
    required this.components,
    required this.solids,
    required this.playerSpawnPoint,
    required this.zombieBlockedAreas,
  });

  final List<Component> components;
  final List<SolidStructure> solids;
  final Vector2 playerSpawnPoint;
  final List<Rect> zombieBlockedAreas;
}

/// Builds a larger top-down arena with a central base, extra houses, roads,
/// trees and cover pieces spread across the world.
class GameMapBuilder {
  const GameMapBuilder();

  BuiltGameMap build() {
    final basePosition = Vector2(
      SurvivalGame.worldWidth * 0.35,
      SurvivalGame.worldHeight * 0.48,
    );
    final base = BaseZoneComponent(
      position: basePosition,
      size: Vector2(460, 440),
    );

    final solids = <SolidStructure>[base];
    final zombieBlockedAreas = <Rect>[];
    final components = <Component>[
      GrassGridGround(
        size: Vector2(SurvivalGame.worldWidth, SurvivalGame.worldHeight),
      ),
      ..._roadPlacements(),
      base,
    ];

    final obstacleDefinitions = <MapObstacleDefinition>[
      MapObstacleDefinition(
        type: ObstacleType.crate,
        offset: Vector2(280, -26),
        size: Vector2(82, 82),
        health: 12,
      ),
      MapObstacleDefinition(
        type: ObstacleType.crate,
        offset: Vector2(-286, 222),
        size: Vector2(86, 86),
        health: 12,
      ),
      MapObstacleDefinition(
        type: ObstacleType.crate,
        offset: Vector2(84, 298),
        size: Vector2(88, 88),
        health: 12,
      ),
      MapObstacleDefinition(
        type: ObstacleType.rock,
        offset: Vector2(-332, -214),
        size: Vector2(98, 90),
      ),
      MapObstacleDefinition(
        type: ObstacleType.rock,
        offset: Vector2(132, -306),
        size: Vector2(116, 98),
      ),
      MapObstacleDefinition(
        type: ObstacleType.rock,
        offset: Vector2(532, 22),
        size: Vector2(110, 94),
      ),
      MapObstacleDefinition(
        type: ObstacleType.bush,
        offset: Vector2(-450, -18),
        size: Vector2(112, 84),
      ),
      MapObstacleDefinition(
        type: ObstacleType.bush,
        offset: Vector2(-420, 190),
        size: Vector2(104, 80),
      ),
      MapObstacleDefinition(
        type: ObstacleType.wall,
        offset: Vector2(-30, -350),
        size: Vector2(250, 40),
      ),
      MapObstacleDefinition(
        type: ObstacleType.wall,
        offset: Vector2(8, 348),
        size: Vector2(260, 40),
      ),
      MapObstacleDefinition(
        type: ObstacleType.crate,
        offset: Vector2(146, 22),
        size: Vector2(80, 80),
        health: 12,
      ),
      MapObstacleDefinition(
        type: ObstacleType.rock,
        offset: Vector2(-590, 334),
        size: Vector2(130, 108),
      ),
      MapObstacleDefinition(
        type: ObstacleType.bush,
        offset: Vector2(718, -306),
        size: Vector2(124, 94),
      ),
      MapObstacleDefinition(
        type: ObstacleType.crate,
        offset: Vector2(726, 316),
        size: Vector2(92, 92),
        health: 12,
      ),
      MapObstacleDefinition(
        type: ObstacleType.wall,
        absolutePosition: Vector2(1430, 1460),
        size: Vector2(360, 42),
      ),
      MapObstacleDefinition(
        type: ObstacleType.wall,
        absolutePosition: Vector2(2290, 780),
        size: Vector2(310, 40),
      ),
      MapObstacleDefinition(
        type: ObstacleType.barrier,
        absolutePosition: Vector2(3130, 1880),
        size: Vector2(240, 52),
      ),
      MapObstacleDefinition(
        type: ObstacleType.rock,
        absolutePosition: Vector2(3880, 1120),
        size: Vector2(126, 104),
      ),
      MapObstacleDefinition(
        type: ObstacleType.crate,
        absolutePosition: Vector2(4030, 2280),
        size: Vector2(88, 88),
        health: 12,
      ),
      MapObstacleDefinition(
        type: ObstacleType.bush,
        absolutePosition: Vector2(4450, 890),
        size: Vector2(118, 88),
      ),
    ];

    for (final definition in obstacleDefinitions) {
      final obstacle = ObstacleComponent(
        position:
            definition.absolutePosition ?? basePosition + definition.offset!,
        size: definition.size,
        type: definition.type,
        health: definition.health,
      );
      components.add(obstacle);
      solids.add(obstacle);
    }

    for (final house in _housePlacements()) {
      final component = HouseComponent(
        position: house.position,
        size: house.size,
        palette: house.palette,
      );
      final walls = component.wallComponents;
      components.add(component);
      components.add(component.roofComponent);
      solids.addAll(walls);
      components.addAll(walls);
      zombieBlockedAreas.addAll(component.zombieDoorBlockerRects);

      for (final chest in house.buildChests()) {
        components.add(chest);
      }
    }

    for (final tree in _treePlacements()) {
      final component = TreeComponent(position: tree.position, size: tree.size);
      components.add(component);
      solids.add(component);
    }

    return BuiltGameMap(
      components: components,
      solids: solids,
      zombieBlockedAreas: zombieBlockedAreas,
      playerSpawnPoint: Vector2(basePosition.x + 330, basePosition.y + 28),
    );
  }

  List<Component> _roadPlacements() {
    return <Component>[
      RoadDecoration(
        position: Vector2(1100, 620),
        size: Vector2(1500, 160),
        rotation: 0.04,
      ),
      RoadDecoration(
        position: Vector2(2500, 1670),
        size: Vector2(1800, 170),
        rotation: -0.06,
      ),
      RoadDecoration(
        position: Vector2(3660, 1110),
        size: Vector2(220, 1180),
        rotation: 0.02,
      ),
      RoadDecoration(
        position: Vector2(1700, 2390),
        size: Vector2(1600, 150),
        rotation: 0.03,
      ),
    ];
  }

  List<HousePlacement> _housePlacements() {
    final placements = <HousePlacement>[
      HousePlacement(
        position: Vector2(560, 360),
        size: Vector2(230, 196),
        palette: HousePalette.slate,
        chestDefinitions: <ChestPlacement>[
          ChestPlacement(offset: Vector2(0, -18)),
        ],
      ),
      HousePlacement(
        position: Vector2(920, 1320),
        size: Vector2(260, 220),
        palette: HousePalette.azure,
        chestDefinitions: <ChestPlacement>[
          ChestPlacement(offset: Vector2(-34, -22)),
        ],
      ),
      HousePlacement(
        position: Vector2(1540, 410),
        size: Vector2(300, 240),
        palette: HousePalette.navy,
        chestDefinitions: <ChestPlacement>[
          ChestPlacement(offset: Vector2(48, -22)),
          ChestPlacement(offset: Vector2(-58, 6)),
        ],
      ),
      HousePlacement(
        position: Vector2(1820, 1520),
        size: Vector2(230, 190),
        palette: HousePalette.slate,
        chestDefinitions: <ChestPlacement>[
          ChestPlacement(offset: Vector2(0, -16)),
        ],
      ),
      HousePlacement(
        position: Vector2(2340, 620),
        size: Vector2(290, 236),
        palette: HousePalette.azure,
        chestDefinitions: <ChestPlacement>[
          ChestPlacement(offset: Vector2(54, -26)),
        ],
      ),
      HousePlacement(
        position: Vector2(2710, 1340),
        size: Vector2(340, 260),
        palette: HousePalette.navy,
        chestDefinitions: <ChestPlacement>[
          ChestPlacement(offset: Vector2(-72, -28)),
          ChestPlacement(offset: Vector2(70, -10)),
        ],
      ),
      HousePlacement(
        position: Vector2(3070, 420),
        size: Vector2(206, 170),
        palette: HousePalette.slate,
        chestDefinitions: <ChestPlacement>[
          ChestPlacement(offset: Vector2(0, -10)),
        ],
      ),
      HousePlacement(
        position: Vector2(3470, 1940),
        size: Vector2(320, 246),
        palette: HousePalette.azure,
        chestDefinitions: <ChestPlacement>[
          ChestPlacement(offset: Vector2(-48, -24)),
          ChestPlacement(offset: Vector2(52, -18)),
        ],
      ),
      HousePlacement(
        position: Vector2(4140, 760),
        size: Vector2(280, 226),
        palette: HousePalette.navy,
        chestDefinitions: <ChestPlacement>[
          ChestPlacement(offset: Vector2(28, -22)),
        ],
      ),
      HousePlacement(
        position: Vector2(4420, 2260),
        size: Vector2(250, 206),
        palette: HousePalette.slate,
        chestDefinitions: <ChestPlacement>[
          ChestPlacement(offset: Vector2(0, -16)),
        ],
      ),
      HousePlacement(
        position: Vector2(1180, 2340),
        size: Vector2(274, 224),
        palette: HousePalette.navy,
        chestDefinitions: <ChestPlacement>[
          ChestPlacement(offset: Vector2(40, -18)),
        ],
      ),
      HousePlacement(
        position: Vector2(520, 2060),
        size: Vector2(214, 172),
        palette: HousePalette.azure,
        chestDefinitions: <ChestPlacement>[
          ChestPlacement(offset: Vector2(0, -10)),
        ],
      ),
      HousePlacement(
        position: Vector2(2060, 2380),
        size: Vector2(244, 196),
        palette: HousePalette.slate,
        chestDefinitions: <ChestPlacement>[
          ChestPlacement(offset: Vector2(-26, -14)),
        ],
      ),
      HousePlacement(
        position: Vector2(3200, 2460),
        size: Vector2(368, 284),
        palette: HousePalette.azure,
        chestDefinitions: <ChestPlacement>[
          ChestPlacement(offset: Vector2(-58, -34)),
          ChestPlacement(offset: Vector2(62, -20)),
        ],
      ),
      HousePlacement(
        position: Vector2(3820, 1510),
        size: Vector2(218, 178),
        palette: HousePalette.slate,
        chestDefinitions: <ChestPlacement>[
          ChestPlacement(offset: Vector2(0, -12)),
        ],
      ),
      HousePlacement(
        position: Vector2(4310, 1600),
        size: Vector2(296, 232),
        palette: HousePalette.navy,
        chestDefinitions: <ChestPlacement>[
          ChestPlacement(offset: Vector2(-42, -24)),
          ChestPlacement(offset: Vector2(48, -8)),
        ],
      ),
    ];

    return _assignUniqueChestRewards(placements);
  }

  List<HousePlacement> _assignUniqueChestRewards(
    List<HousePlacement> placements,
  ) {
    var chestIndex = 0;
    final assignedPlacements = <HousePlacement>[];

    for (final placement in placements) {
      final assignedChests = placement.chestDefinitions
          .map((definition) {
            if (chestIndex >= chestWeaponPool.length) {
              throw StateError(
                'Chest weapon pool yetersiz: $chestIndex sandik icin ${chestWeaponPool.length} silah var.',
              );
            }

            final rewardWeapon = chestWeaponPool[chestIndex];
            chestIndex += 1;
            return ChestPlacement(
              offset: definition.offset,
              rewardWeapon: rewardWeapon,
            );
          })
          .toList(growable: false);

      assignedPlacements.add(
        placement.copyWith(chestDefinitions: assignedChests),
      );
    }

    return assignedPlacements;
  }

  List<TreePlacement> _treePlacements() {
    return <TreePlacement>[
      TreePlacement(position: Vector2(320, 170), size: Vector2(86, 106)),
      TreePlacement(position: Vector2(270, 280), size: Vector2(92, 114)),
      TreePlacement(position: Vector2(340, 1320), size: Vector2(96, 118)),
      TreePlacement(position: Vector2(460, 1430), size: Vector2(82, 102)),
      TreePlacement(position: Vector2(1180, 220), size: Vector2(88, 108)),
      TreePlacement(position: Vector2(1260, 320), size: Vector2(104, 124)),
      TreePlacement(position: Vector2(1030, 1540), size: Vector2(94, 114)),
      TreePlacement(position: Vector2(1180, 1640), size: Vector2(84, 104)),
      TreePlacement(position: Vector2(1870, 220), size: Vector2(92, 112)),
      TreePlacement(position: Vector2(2030, 290), size: Vector2(98, 118)),
      TreePlacement(position: Vector2(2140, 1520), size: Vector2(90, 110)),
      TreePlacement(position: Vector2(2240, 1410), size: Vector2(100, 122)),
      TreePlacement(position: Vector2(2470, 330), size: Vector2(86, 106)),
      TreePlacement(position: Vector2(2820, 790), size: Vector2(96, 116)),
      TreePlacement(position: Vector2(2930, 930), size: Vector2(88, 110)),
      TreePlacement(position: Vector2(3040, 1090), size: Vector2(104, 124)),
      TreePlacement(position: Vector2(3110, 1360), size: Vector2(92, 114)),
      TreePlacement(position: Vector2(1880, 980), size: Vector2(86, 104)),
      TreePlacement(position: Vector2(3360, 520), size: Vector2(88, 108)),
      TreePlacement(position: Vector2(3520, 620), size: Vector2(102, 120)),
      TreePlacement(position: Vector2(3660, 2050), size: Vector2(90, 110)),
      TreePlacement(position: Vector2(3860, 2140), size: Vector2(108, 126)),
      TreePlacement(position: Vector2(3990, 940), size: Vector2(94, 114)),
      TreePlacement(position: Vector2(4220, 1040), size: Vector2(98, 120)),
      TreePlacement(position: Vector2(4440, 820), size: Vector2(92, 112)),
      TreePlacement(position: Vector2(4580, 2120), size: Vector2(96, 118)),
      TreePlacement(position: Vector2(4700, 2280), size: Vector2(90, 112)),
      TreePlacement(position: Vector2(760, 2340), size: Vector2(88, 106)),
      TreePlacement(position: Vector2(920, 2480), size: Vector2(98, 118)),
      TreePlacement(position: Vector2(1520, 2520), size: Vector2(94, 112)),
      TreePlacement(position: Vector2(1760, 2620), size: Vector2(104, 122)),
      TreePlacement(position: Vector2(2480, 2500), size: Vector2(92, 110)),
      TreePlacement(position: Vector2(2760, 2660), size: Vector2(102, 120)),
    ];
  }
}

class MapObstacleDefinition {
  const MapObstacleDefinition({
    required this.type,
    this.offset,
    this.absolutePosition,
    required this.size,
    this.health,
  });

  final ObstacleType type;
  final Vector2? offset;
  final Vector2? absolutePosition;
  final Vector2 size;
  final int? health;
}

class HousePlacement {
  const HousePlacement({
    required this.position,
    required this.size,
    required this.palette,
    this.chestDefinitions = const <ChestPlacement>[],
  });

  final Vector2 position;
  final Vector2 size;
  final HousePalette palette;
  final List<ChestPlacement> chestDefinitions;

  HousePlacement copyWith({List<ChestPlacement>? chestDefinitions}) {
    return HousePlacement(
      position: position,
      size: size,
      palette: palette,
      chestDefinitions: chestDefinitions ?? this.chestDefinitions,
    );
  }

  List<ChestComponent> buildChests() {
    return chestDefinitions.map((definition) {
      return ChestComponent(
        position: position + definition.offset,
        rewardWeapon: definition.rewardWeapon,
      );
    }).toList();
  }
}

class TreePlacement {
  const TreePlacement({required this.position, required this.size});

  final Vector2 position;
  final Vector2 size;
}

class ChestPlacement {
  const ChestPlacement({required this.offset, this.rewardWeapon});

  final Vector2 offset;
  final Weapon? rewardWeapon;
}

class RoadDecoration extends PositionComponent {
  RoadDecoration({
    required super.position,
    required super.size,
    required this.rotation,
  }) : super(anchor: Anchor.center, priority: -15);

  final double rotation;

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);
    canvas.rotate(rotation);
    canvas.translate(-size.x / 2, -size.y / 2);

    final bodyPaint = Paint()..color = const Color(0x664A5B60);
    final edgePaint = Paint()
      ..color = const Color(0x33788C93)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    final stripePaint = Paint()
      ..color = const Color(0x55DCE775)
      ..strokeWidth = 2;

    final rect = RRect.fromRectAndRadius(
      size.toRect(),
      const Radius.circular(28),
    );
    canvas.drawRRect(rect, bodyPaint);
    canvas.drawRRect(rect, edgePaint);

    for (double x = 32; x < size.x - 16; x += 52) {
      canvas.drawLine(
        Offset(x, size.y * 0.52),
        Offset(math.min(size.x - 20, x + 26), size.y * 0.52),
        stripePaint,
      );
    }

    canvas.restore();
  }
}

/// Bright grass background with thin grid lines and a few lighter patches.
class GrassGridGround extends PositionComponent {
  GrassGridGround({required super.size}) : super(priority: -20);

  final Paint _grassPaint = Paint()..color = const Color(0xFF83CF55);
  final Paint _gridPaint = Paint()
    ..color = const Color(0xFF6FB64A)
    ..strokeWidth = 1;
  final Paint _borderPaint = Paint()
    ..color = const Color(0xFF4C8E35)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 6;
  final Paint _patchPaint = Paint()
    ..color = const Color(0xFF9BDE6C).withValues(alpha: 0.6);

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    canvas.drawRect(size.toRect(), _grassPaint);

    const cellSize = 64.0;
    for (double x = 0; x <= size.x; x += cellSize) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.y), _gridPaint);
    }
    for (double y = 0; y <= size.y; y += cellSize) {
      canvas.drawLine(Offset(0, y), Offset(size.x, y), _gridPaint);
    }

    final patches = <Rect>[
      const Rect.fromLTWH(180, 140, 180, 120),
      const Rect.fromLTWH(760, 260, 230, 140),
      const Rect.fromLTWH(1410, 860, 260, 150),
      const Rect.fromLTWH(2190, 420, 220, 140),
      const Rect.fromLTWH(2700, 1120, 250, 150),
      const Rect.fromLTWH(3580, 1980, 300, 180),
      const Rect.fromLTWH(4180, 920, 260, 150),
      const Rect.fromLTWH(950, 2360, 280, 170),
    ];

    for (final patch in patches) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(patch, const Radius.circular(36)),
        _patchPaint,
      );
    }

    final dotPaint = Paint()..color = const Color(0xFF73BE4E);
    for (double x = 18; x < size.x; x += 96) {
      for (double y = 26; y < size.y; y += 96) {
        canvas.drawCircle(
          Offset(x + (math.sin(x * 0.03) * 6), y + (math.cos(y * 0.03) * 6)),
          2.4,
          dotPaint,
        );
      }
    }

    canvas.drawRect(size.toRect(), _borderPaint);
  }
}
