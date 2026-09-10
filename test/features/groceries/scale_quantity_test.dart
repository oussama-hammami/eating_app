import 'package:eating_app/features/groceries/domain/usecases/scale_quantity.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('scaleQuantity', () {
    test('scales a whole number amount', () {
      expect(scaleQuantity('200 g', 1.5), '300 g');
    });

    test('scales a decimal amount and trims trailing zeros', () {
      expect(scaleQuantity('100 g', 0.5), '50 g');
      expect(scaleQuantity('1.5 g', 2), '3 g');
    });

    test('scales a simple fraction amount', () {
      expect(scaleQuantity('1/2 cup', 2), '1 cup');
    });

    test('scales a mixed-number amount', () {
      expect(scaleQuantity('1 1/2 cup', 2), '3 cup');
    });

    test('keeps a fractional result with up to two decimal places', () {
      expect(scaleQuantity('1 g', 1.333), '1.33 g');
    });

    test('returns the amount alone when there is no unit', () {
      expect(scaleQuantity('4', 2), '8');
    });

    test('returns the input unchanged when factor is 1', () {
      expect(scaleQuantity('200 g', 1), '200 g');
    });

    test('returns non-numeric quantities unchanged', () {
      expect(scaleQuantity('a pinch', 2), 'a pinch');
      expect(scaleQuantity('to taste', 3), 'to taste');
    });

    test('returns an empty quantity unchanged', () {
      expect(scaleQuantity('', 2), '');
      expect(scaleQuantity('   ', 2), '');
    });

    test('trims surrounding whitespace before scaling', () {
      expect(scaleQuantity('  200 g  ', 2), '400 g');
    });
  });
}
