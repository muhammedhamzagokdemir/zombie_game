import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../game/game.dart';

class MobileControlsOverlay extends StatelessWidget {
  const MobileControlsOverlay({required this.game, super.key});

  static const String id = 'mobile-controls';

  final SurvivalGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Stack(
          children: [
            Align(
              alignment: Alignment.bottomLeft,
              child: _MovementPad(game: game),
            ),
            Align(
              alignment: Alignment.bottomRight,
              child: _FirePad(game: game),
            ),
          ],
        ),
      ),
    );
  }
}

class _MovementPad extends StatelessWidget {
  const _MovementPad({required this.game});

  final SurvivalGame game;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 170,
      height: 170,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: _MovementButton(
              icon: Icons.keyboard_arrow_up,
              onPressedChanged: game.setMoveUp,
            ),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: _MovementButton(
              icon: Icons.keyboard_arrow_left,
              onPressedChanged: game.setMoveLeft,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: _MovementButton(
              icon: Icons.keyboard_arrow_right,
              onPressedChanged: game.setMoveRight,
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _MovementButton(
              icon: Icons.keyboard_arrow_down,
              onPressedChanged: game.setMoveDown,
            ),
          ),
        ],
      ),
    );
  }
}

class _MovementButton extends StatefulWidget {
  const _MovementButton({required this.icon, required this.onPressedChanged});

  final IconData icon;
  final ValueChanged<bool> onPressedChanged;

  @override
  State<_MovementButton> createState() => _MovementButtonState();
}

class _MovementButtonState extends State<_MovementButton> {
  int _activePointers = 0;

  void _setPressed(bool value) {
    widget.onPressedChanged(value);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.onPressedChanged(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPressed = _activePointers > 0;

    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (_) {
        _activePointers += 1;
        _setPressed(true);
      },
      onPointerUp: (_) {
        _activePointers = (_activePointers - 1).clamp(0, 999);
        _setPressed(_activePointers > 0);
      },
      onPointerCancel: (_) {
        _activePointers = 0;
        _setPressed(false);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: isPressed ? const Color(0xCC6B8A96) : const Color(0xAA2A3942),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFF95AAB3), width: 2),
        ),
        child: Icon(widget.icon, color: Colors.white, size: 30),
      ),
    );
  }
}

class _FirePad extends StatefulWidget {
  const _FirePad({required this.game});

  final SurvivalGame game;

  @override
  State<_FirePad> createState() => _FirePadState();
}

class _FirePadState extends State<_FirePad> {
  static const double _padSize = 150;
  static const double _thumbTravel = 40;

  int? _activePointerId;
  Offset _thumbOffset = Offset.zero;

  Offset get _center => const Offset(_padSize / 2, _padSize / 2);

  void _updateAim(Offset localPosition) {
    final rawOffset = localPosition - _center;
    final direction = Vector2(rawOffset.dx, rawOffset.dy);

    if (direction.length2 == 0) {
      return;
    }

    // Convert touch offset from the pad center into a normalized 360-degree
    // aim direction for the Flame game.
    direction.normalize();
    widget.game.setAimDirection(direction);
    widget.game.setFiring(true);

    final distance = math.min(rawOffset.distance, _thumbTravel);
    _thumbOffset = Offset(direction.x * distance, direction.y * distance);
    if (mounted) {
      setState(() {});
    }
  }

  void _stopFiring() {
    _activePointerId = null;
    _thumbOffset = Offset.zero;
    widget.game.setFiring(false);
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    widget.game.setFiring(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.opaque,
      onPointerDown: (event) {
        if (_activePointerId != null) {
          return;
        }

        _activePointerId = event.pointer;
        _updateAim(event.localPosition);
      },
      onPointerMove: (event) {
        if (_activePointerId != event.pointer) {
          return;
        }

        _updateAim(event.localPosition);
      },
      onPointerUp: (event) {
        if (_activePointerId == event.pointer) {
          _stopFiring();
        }
      },
      onPointerCancel: (event) {
        if (_activePointerId == event.pointer) {
          _stopFiring();
        }
      },
      child: SizedBox(
        width: _padSize,
        height: _padSize,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0x66354750),
            border: Border.all(color: const Color(0xFF95AAB3), width: 2),
          ),
          child: Stack(
            children: [
              const Center(
                child: Icon(
                  Icons.my_location_rounded,
                  color: Color(0xFFCFD8DC),
                  size: 30,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Transform.translate(
                  offset: _thumbOffset,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _activePointerId != null
                          ? const Color(0xCCFF7043)
                          : const Color(0x8877848D),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
