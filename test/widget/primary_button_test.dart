import 'package:eating_app/core/theme/app_palette.dart';
import 'package:eating_app/core/theme/app_theme.dart';
import 'package:eating_app/widgets/common/primary_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) => MaterialApp(
      theme: AppTheme.light,
      home: Scaffold(body: child),
    );

void main() {
  group('PrimaryButton', () {
    testWidgets('renders its label', (tester) async {
      await tester.pumpWidget(
        _wrap(PrimaryButton(label: 'Générer la liste', onPressed: () {})),
      );

      expect(find.text('Générer la liste'), findsOneWidget);
    });

    testWidgets('invokes onPressed exactly once per tap', (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(
        _wrap(PrimaryButton(label: 'Ajouter au planning', onPressed: () => tapCount++)),
      );

      await tester.tap(find.text('Ajouter au planning'));
      await tester.pump();

      expect(tapCount, 1);
    });

    testWidgets('is disabled and inert when onPressed is null', (tester) async {
      await tester.pumpWidget(
        const _StatefulHarness(disabled: true),
      );

      final button = tester.widget<FilledButton>(find.byType(FilledButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('renders in the app-theme terracotta primary color', (tester) async {
      await tester.pumpWidget(
        _wrap(PrimaryButton(label: 'Générer la liste', onPressed: () {})),
      );

      final context = tester.element(find.byType(FilledButton));
      final resolvedStyle = Theme.of(context).filledButtonTheme.style!;
      final background = resolvedStyle.backgroundColor!.resolve({});
      // Asserted against the literal French-Culinary-Editorial spec color
      // (#D95D39), not AppPalette.terracotta itself — comparing against the
      // constant under test would pass even if that constant were wrong.
      expect(background, const Color(0xFFD95D39));
      expect(background, AppPalette.terracotta);
    });

    testWidgets('expands to fill width by default', (tester) async {
      await tester.pumpWidget(
        _wrap(PrimaryButton(label: 'Générer la liste', onPressed: () {})),
      );

      expect(find.byType(SizedBox), findsWidgets);
      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(of: find.byType(FilledButton), matching: find.byType(SizedBox)).first,
      );
      expect(sizedBox.width, double.infinity);
    });

    testWidgets('does not force full width when expand is false', (tester) async {
      await tester.pumpWidget(
        _wrap(PrimaryButton(label: 'Générer la liste', onPressed: () {}, expand: false)),
      );

      expect(
        find.ancestor(of: find.byType(FilledButton), matching: find.byType(SizedBox)),
        findsNothing,
      );
    });

    testWidgets('renders an icon before the label when provided', (tester) async {
      await tester.pumpWidget(
        _wrap(PrimaryButton(
          label: 'Générer la liste',
          onPressed: () {},
          icon: Icons.shopping_cart,
        )),
      );

      expect(find.byIcon(Icons.shopping_cart), findsOneWidget);
      expect(find.text('Générer la liste'), findsOneWidget);
    });
  });
}

class _StatefulHarness extends StatelessWidget {
  const _StatefulHarness({required this.disabled});

  final bool disabled;

  @override
  Widget build(BuildContext context) => _wrap(
        PrimaryButton(label: 'Générer la liste', onPressed: disabled ? null : () {}),
      );
}
