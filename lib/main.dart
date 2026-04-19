import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'game/game.dart';
import 'ui/character_select_overlay.dart';
import 'ui/game_over_overlay.dart';
import 'ui/main_menu_overlay.dart';
import 'ui/mobile_controls_overlay.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock the app to landscape so the game always uses a wide layout.
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  final game = SurvivalGame();

  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: ColoredBox(
          color: const Color(0xFF05080A),
          child: GameWidget(
            game: game,
            // Flutter overlays sit on top of Flame so mobile controls can
            // update game state without replacing the game engine.
            overlayBuilderMap: {
              MainMenuOverlay.id: (context, game) {
                return MainMenuOverlay(game: game as SurvivalGame);
              },
              CharacterSelectOverlay.id: (context, game) {
                return CharacterSelectOverlay(game: game as SurvivalGame);
              },
              GameOverOverlay.id: (context, game) {
                return GameOverOverlay(game: game as SurvivalGame);
              },
              MobileControlsOverlay.id: (context, game) {
                return MobileControlsOverlay(game: game as SurvivalGame);
              },
            },
            initialActiveOverlays: const [MainMenuOverlay.id],
          ),
        ),
      ),
    ),
  );
}
