import 'package:eating_app/core/text/ingredient_tokenizer.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lowercases and strips accents', () {
    expect(tokenizeIngredientText('Crème Brûlée'), ['creme', 'brulee']);
  });

  test('drops grammatical glue words but keeps state/prep words', () {
    expect(
      tokenizeIngredientText("Yogurt, Greek-style, ewe's milk"),
      ['yogurt', 'greek', 'ewe', 'milk'],
    );
    expect(tokenizeIngredientText('Egg, raw'), ['egg', 'raw']);
  });

  test('singularizes common plural forms', () {
    expect(tokenizeIngredientText('eggs'), ['egg']);
    expect(tokenizeIngredientText('tomatoes'), ['tomato']);
    expect(tokenizeIngredientText('berries'), ['berry']);
    expect(tokenizeIngredientText('leaves'), ['leaf']);
  });

  test('does not over-singularize words that only look plural', () {
    expect(tokenizeIngredientText('hummus'), ['hummus']);
    expect(tokenizeIngredientText('couscous'), ['couscous']);
  });

  test('splits hyphens and apostrophes as separators (and drops "style")', () {
    expect(tokenizeIngredientText("greek-style ewe's"), ['greek', 'ewe']);
  });
}
