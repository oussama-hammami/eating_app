import 'package:flutter_test/flutter_test.dart';

import 'package:eating_app/main.dart';

void main() {
  testWidgets('App boots and shows the three main tabs', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Recipes'), findsOneWidget);
    expect(find.text('Groceries'), findsOneWidget);
    expect(find.text('Community'), findsOneWidget);
  });
}
