import 'package:eating_app/widgets/common/nutri_score_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Official Santé Publique France Nutri-Score scale colors.
const _officialColors = {
  NutriScoreGrade.a: Color(0xFF038141),
  NutriScoreGrade.b: Color(0xFF85BB2F),
  NutriScoreGrade.c: Color(0xFFFECB02),
  NutriScoreGrade.d: Color(0xFFEE8100),
  NutriScoreGrade.e: Color(0xFFE63E11),
};

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('NutriScoreBadge', () {
    for (final grade in NutriScoreGrade.values) {
      testWidgets('renders official Nutri-Score color for grade ${grade.name}', (tester) async {
        await tester.pumpWidget(_wrap(NutriScoreBadge(grade: grade)));

        final container = tester.widget<Container>(find.byType(Container));
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, _officialColors[grade]);
      });
    }

    testWidgets('full label shows "Nutri-Score" plus the letter', (tester) async {
      await tester.pumpWidget(_wrap(const NutriScoreBadge(grade: NutriScoreGrade.a)));

      expect(find.text('Nutri-Score A'), findsOneWidget);
    });

    testWidgets('compact label shows only the letter', (tester) async {
      await tester.pumpWidget(
        _wrap(const NutriScoreBadge(grade: NutriScoreGrade.e, compact: true)),
      );

      expect(find.text('E'), findsOneWidget);
      expect(find.text('Nutri-Score E'), findsNothing);
    });

    testWidgets('uses dark text on the yellow grade-C badge for contrast', (tester) async {
      await tester.pumpWidget(_wrap(const NutriScoreBadge(grade: NutriScoreGrade.c)));

      final text = tester.widget<Text>(find.text('Nutri-Score C'));
      expect(text.style!.color, Colors.black87);
    });

    testWidgets('uses white text on non-yellow grades', (tester) async {
      await tester.pumpWidget(_wrap(const NutriScoreBadge(grade: NutriScoreGrade.a)));

      final text = tester.widget<Text>(find.text('Nutri-Score A'));
      expect(text.style!.color, Colors.white);
    });

    testWidgets('compact mode uses tighter padding than full mode', (tester) async {
      await tester.pumpWidget(_wrap(const NutriScoreBadge(grade: NutriScoreGrade.b, compact: true)));
      final compactPadding =
          (tester.widget<Container>(find.byType(Container)).padding as EdgeInsets).horizontal;

      await tester.pumpWidget(_wrap(const NutriScoreBadge(grade: NutriScoreGrade.b)));
      final fullPadding =
          (tester.widget<Container>(find.byType(Container)).padding as EdgeInsets).horizontal;

      expect(compactPadding, lessThan(fullPadding));
    });
  });
}
