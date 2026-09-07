import 'package:flutter_test/flutter_test.dart';

import 'package:eating_app/features/recipes/data/community_recipes_repository.dart';
import 'package:eating_app/main.dart';

void main() {
  testWidgets('App boots and shows the three main tabs', (tester) async {
    await tester.pumpWidget(
      MyApp(
        communityRecipesRepository:
            CommunityRecipesRepository(fetchRecipes: () async => []),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
  });
}
