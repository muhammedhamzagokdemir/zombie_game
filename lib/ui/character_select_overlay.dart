import 'package:flutter/material.dart';

import '../game/game.dart';

class CharacterSelectOverlay extends StatelessWidget {
  const CharacterSelectOverlay({required this.game, super.key});

  static const String id = 'character-select';

  final SurvivalGame game;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final compactMode = constraints.maxHeight < 540;
          final horizontalPadding = (constraints.maxWidth * 0.05).clamp(
            12.0,
            28.0,
          );
          final verticalPadding = (constraints.maxHeight * 0.035).clamp(
            10.0,
            24.0,
          );
          final cardSpacing = compactMode ? 12.0 : 16.0;

          return ColoredBox(
            color: const Color(0xB3000000),
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(
                horizontal: horizontalPadding,
                vertical: verticalPadding,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 900),
                    child: Container(
                      padding: EdgeInsets.all(compactMode ? 16 : 24),
                      decoration: BoxDecoration(
                        color: const Color(0xF019242A),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: const Color(0xFF4A6572),
                          width: 2,
                        ),
                      ),
                      child: LayoutBuilder(
                        builder: (context, innerConstraints) {
                          final availableWidth = innerConstraints.maxWidth;
                          final cardWidth = compactMode
                              ? ((availableWidth - cardSpacing) / 2).clamp(
                                  160.0,
                                  240.0,
                                )
                              : ((availableWidth - (cardSpacing * 2)) / 3)
                                    .clamp(180.0, 250.0);

                          return Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Character Select',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: compactMode ? 24 : 28,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: game.closeCharacterSelect,
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: compactMode ? 12 : 16),
                              Wrap(
                                alignment: WrapAlignment.center,
                                spacing: cardSpacing,
                                runSpacing: cardSpacing,
                                children: [
                                  for (final character
                                      in SurvivalGame.characters)
                                    SizedBox(
                                      width: cardWidth,
                                      child: _CharacterCard(
                                        character: character,
                                        isSelected:
                                            game.selectedCharacter == character,
                                        compactMode: compactMode,
                                        onTap: () {
                                          // The overlay writes the selected
                                          // character into Flame game state,
                                          // and Start Game later uses it.
                                          game.selectCharacter(character);
                                          game.closeCharacterSelect();
                                        },
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          );
                        },
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

class _CharacterCard extends StatelessWidget {
  const _CharacterCard({
    required this.character,
    required this.isSelected,
    required this.compactMode,
    required this.onTap,
  });

  final GameCharacter character;
  final bool isSelected;
  final bool compactMode;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.all(compactMode ? 14 : 18),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF304750) : const Color(0xFF202D34),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFFFC107)
                : const Color(0xFF4A6572),
            width: 2,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: compactMode ? 64 : 84,
                height: compactMode ? 64 : 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: character.bodyColor,
                ),
              ),
            ),
            SizedBox(height: compactMode ? 12 : 16),
            Text(
              character.name,
              style: TextStyle(
                color: Colors.white,
                fontSize: compactMode ? 18 : 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: compactMode ? 8 : 10),
            Text(
              'Move Speed: ${character.moveSpeed.toStringAsFixed(0)}',
              style: TextStyle(
                color: const Color(0xFFCFD8DC),
                fontSize: compactMode ? 13 : 14,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Fire Interval: ${character.fireInterval.toStringAsFixed(2)}s',
              style: TextStyle(
                color: const Color(0xFFCFD8DC),
                fontSize: compactMode ? 13 : 14,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
