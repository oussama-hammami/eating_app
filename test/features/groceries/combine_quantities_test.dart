import 'package:eating_app/features/groceries/domain/usecases/combine_quantities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('combineQuantities', () {
    test('sums matching numeric quantities with the same unit', () {
      expect(combineQuantities(['2 cups', '1 cups']), '3 cups');
    });

    test('sums decimal quantities with the same unit', () {
      expect(combineQuantities(['1.5 kg', '2.5 kg']), '4 kg');
    });

    test('concatenates mismatched units with " + "', () {
      expect(combineQuantities(['2 cups', '200 g']), '2 cups + 200 g');
    });

    test('concatenates plain text without leading numbers', () {
      expect(combineQuantities(['pinch', 'dash']), 'pinch + dash');
    });

    test('returns an empty string for an empty list', () {
      expect(combineQuantities([]), '');
    });

    test('returns the single item unchanged for a single-item list', () {
      expect(combineQuantities(['1 tbsp']), '1 tbsp');
    });
  });
}
