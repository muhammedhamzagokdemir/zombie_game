import 'package:flutter/material.dart';

import '../game/game.dart';

class MainMenuOverlay extends StatelessWidget {
  const MainMenuOverlay({required this.game, super.key});

  static const String id = 'main-menu';

  final SurvivalGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final shortestSide = constraints.biggest.shortestSide;
          final horizontalPadding = (constraints.maxWidth * 0.06).clamp(
            16.0,
            32.0,
          );
          final verticalPadding = (constraints.maxHeight * 0.04).clamp(
            12.0,
            28.0,
          );
          final contentSpacing = (constraints.maxHeight * 0.035).clamp(
            12.0,
            24.0,
          );
          final titleFontSize = shortestSide < 420 ? 28.0 : 34.0;

          return ColoredBox(
            color: const Color(0xCC05080A),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: Container(
                      padding: EdgeInsets.all(shortestSide < 420 ? 20 : 28),
                      decoration: BoxDecoration(
                        color: const Color(0xE61A2328),
                        borderRadius: BorderRadius.circular(28),
                        border: Border.all(
                          color: const Color(0xFF4A6572),
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Zombie Survival',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: titleFontSize,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: contentSpacing),
                          _MenuButton(
                            label: 'Start Game',
                            onPressed: game.startGame,
                          ),
                          SizedBox(height: contentSpacing * 0.5),
                          _MenuButton(
                            label: 'Character Select',
                            onPressed: game.openCharacterSelect,
                            isSecondary: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.label,
    required this.onPressed,
    this.isSecondary = false,
  });

  final String label;
  final VoidCallback onPressed;
  final bool isSecondary;

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.sizeOf(context).height;
    final buttonHeight = screenHeight < 420 ? 52.0 : 60.0;
    final fontSize = screenHeight < 420 ? 18.0 : 20.0;

    return SizedBox(
      width: double.infinity,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: isSecondary
              ? const Color(0xFF3A4F59)
              : const Color(0xFFEF6C57),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.w700),
        ),
        child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
      ),
    );
  }
}
