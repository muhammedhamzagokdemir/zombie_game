import 'package:flutter/material.dart';

import '../game/game.dart';

class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({required this.game, super.key});

  static const String id = 'game-over';

  final SurvivalGame game;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: const Color(0xCC05080A),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xE61A2328),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFF4A6572), width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Game Over',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'You reached Wave ${game.currentWave}',
                  style: const TextStyle(
                    color: Color(0xFFCFD8DC),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: game.startGame,
                    child: const Text('Restart'),
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: game.returnToMainMenu,
                    child: const Text('Main Menu'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
