import 'package:flame/game.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zombie/game/game.dart';

void main() {
  testWidgets('renders the Flame game widget', (tester) async {
    await tester.pumpWidget(GameWidget(game: SurvivalGame()));

    expect(find.byType(GameWidget<SurvivalGame>), findsOneWidget);
  });
}
