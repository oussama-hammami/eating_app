import 'package:eating_app/core/text/text_normalizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TextNormalizer.normalize', () {
    test('lowercases text', () {
      expect(TextNormalizer.normalize('APPLE'), 'apple');
    });

    test('strips common French accents', () {
      expect(TextNormalizer.normalize('Crème brûlée'), 'creme brulee');
      expect(TextNormalizer.normalize('Pâté'), 'pate');
      expect(TextNormalizer.normalize('Œuf'), 'oeuf');
    });

    test('is idempotent for plain ascii', () {
      expect(TextNormalizer.normalize('chicken breast'), 'chicken breast');
    });
  });
}
