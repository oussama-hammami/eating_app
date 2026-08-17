import 'package:eating_app/core/units/ingredient_text_parser.dart';
import 'package:eating_app/core/units/unit.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('unit parsing: recognized unit words', () {
    test('should_parse_200_g_rice_as_200_g', () {
      final result = parseIngredientText('200 g rice');
      expect(result.amount, 200);
      expect(result.unit, Unit.g);
      expect(result.name, 'rice');
    });

    // Documents ACTUAL behavior: the amount/unit regex requires whitespace
    // between the number and the unit word, so a no-space form like "200g"
    // is NOT recognized as amount=200/unit=g — the whole string falls back
    // to being treated as the ingredient name with no amount.
    test('should_not_parse_no_space_amount_unit_form_200g_as_a_quantity', () {
      final result = parseIngredientText('200g rice');
      expect(result.amount, isNull);
      expect(result.name, '200g rice');
    });

    test('should_parse_1_tablespoon_of_olive_oil', () {
      final result = parseIngredientText('1 tablespoon of olive oil');
      expect(result.amount, 1);
      expect(result.unit, Unit.tbsp);
      expect(result.name, 'olive oil');
    });

    test('should_parse_2_teaspoons_cinnamon', () {
      final result = parseIngredientText('2 teaspoons cinnamon');
      expect(result.amount, 2);
      expect(result.unit, Unit.tsp);
      expect(result.name, 'cinnamon');
    });

    test('should_parse_0_5_cup_flour_with_decimal_point', () {
      final result = parseIngredientText('0.5 cup flour');
      expect(result.amount, 0.5);
      expect(result.unit, Unit.cup);
    });

    test('should_parse_comma_decimal_as_french_locale_amount', () {
      final result = parseIngredientText('1,5 kg potatoes');
      expect(result.amount, 1.5);
      expect(result.unit, Unit.kg);
    });

    test('should_parse_fractional_amount_1_2_tsp', () {
      final result = parseIngredientText('1/2 tsp salt');
      expect(result.amount, 0.5);
      expect(result.unit, Unit.tsp);
    });

    test('should_parse_fl_oz_with_dot_and_spacing_variants', () {
      final result = parseIngredientText('8 fl. oz milk');
      expect(result.amount, 8);
      expect(result.unit, Unit.flOz);
    });

    test('should_parse_piece_unit_word', () {
      final result = parseIngredientText('3 pieces chicken breast');
      expect(result.amount, 3);
      expect(result.unit, Unit.piece);
    });
  });

  group('unit parsing: no recognized unit -> defaults to grams, keeps full text as name', () {
    test('should_default_unit_to_grams_when_no_unit_word_present', () {
      final result = parseIngredientText('2 eggs');
      // "eggs" is not a unit word (it's the food name) -> no unit recognized.
      expect(result.unit, Unit.g);
      expect(result.name, 'eggs');
    });

    test('should_treat_whole_text_as_name_when_no_leading_number', () {
      final result = parseIngredientText('a pinch of salt');
      expect(result.amount, isNull);
      expect(result.unit, Unit.g);
      expect(result.name, 'a pinch of salt');
    });

    test('should_return_empty_name_for_empty_input', () {
      final result = parseIngredientText('');
      expect(result.amount, isNull);
      expect(result.name, isEmpty);
    });

    test('should_treat_whitespace_only_input_as_empty', () {
      final result = parseIngredientText('   ');
      expect(result.name, isEmpty);
    });
  });

  group('unit parsing: malformed / unsupported input', () {
    test('should_not_parse_unsupported_unit_word_as_a_unit', () {
      // "scoops" isn't in the alias table -> should NOT silently become a
      // recognized unit; the whole remainder becomes the name, unit stays g.
      final result = parseIngredientText('2 scoops protein powder');
      expect(result.amount, 2);
      expect(result.unit, Unit.g);
      expect(result.name, 'scoops protein powder');
    });

    test('should_not_parse_non_numeric_leading_token_as_an_amount', () {
      final result = parseIngredientText('two eggs');
      expect(result.amount, isNull);
      expect(result.name, 'two eggs');
    });

    test('should_return_null_amount_for_malformed_fraction_with_zero_denominator', () {
      final result = parseIngredientText('1/0 tsp salt');
      expect(result.amount, isNull);
    });

    test('should_strip_leading_of_from_name', () {
      final result = parseIngredientText('200 g of flour');
      expect(result.name, 'flour');
    });
  });

  group('should_not_assume_1_ml_equals_1_gram (parser only extracts unit, not grams)', () {
    test('should_parse_ml_as_volume_category_not_weight', () {
      final result = parseIngredientText('250 ml milk');
      expect(result.unit.category, UnitCategory.volume);
      expect(result.unit, isNot(Unit.g));
    });
  });
}
