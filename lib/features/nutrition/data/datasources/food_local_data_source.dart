import 'package:sqflite/sqflite.dart';

import '../../../../core/text/text_normalizer.dart';
import '../../../../core/units/unit.dart';
import '../models/food_model.dart';

const _foodColumns =
    'id, food_name, alim_nom_fr_no_comma, calories_kcal_100g, protein_g_100g, carbs_g_100g, fat_g_100g, fiber_g_100g';

/// Raw SQL access to the `foods` table. Three-pass search (prefix, then
/// substring, then word-order-independent) keeps ranking and the 5-result
/// cap fully under our control, while the `search_name` index makes the
/// prefix pass effectively instant.
class FoodLocalDataSource {
  const FoodLocalDataSource(this._db);

  final Database _db;

  Future<List<FoodModel>> search(String query, {int limit = 5}) async {
    final normalized = TextNormalizer.normalize(query);
    if (normalized.isEmpty) return const [];

    final prefixRows = await _db.rawQuery(
      '''
      SELECT $_foodColumns FROM foods
      WHERE search_name LIKE ? || '%'
      ORDER BY food_name COLLATE NOCASE
      LIMIT ?
      ''',
      [normalized, limit],
    );

    final results = prefixRows.map(FoodModel.fromMap).toList();
    if (results.length >= limit) return results;

    // Word-boundary substring match: requires a preceding space so "oeuf"
    // doesn't false-positive-match inside "boeuf" (beef). The leading-space
    // requirement also means this can never re-match a prefix-pass row
    // (those have no space before the match at position 0). Ranked by match
    // position (earlier = more relevant) rather than alphabetically, so a
    // plain "Egg, raw" (query near the front of its search_name) outranks a
    // dish that merely lists egg as one of several ingredients deep in a
    // long description.
    final substringRows = await _db.rawQuery(
      '''
      SELECT $_foodColumns FROM foods
      WHERE search_name LIKE '% ' || ? || '%'
      ORDER BY INSTR(search_name, ?), food_name COLLATE NOCASE
      LIMIT ?
      ''',
      [normalized, normalized, limit - results.length],
    );

    results.addAll(substringRows.map(FoodModel.fromMap));
    if (results.length >= limit) return results;

    // Word-order-independent fallback: CIQUAL names are noun-first ("Yogurt,
    // Greek-style, ..."), so a natural-order query like "greek yogurt" never
    // matches the first two passes. Require every query word to appear
    // somewhere in search_name (any order, plain substring so hyphenated
    // forms like "greek-style" still match "greek"), ranked alphabetically.
    // Single-word queries already got their best shot above, so this only
    // kicks in for multi-word queries still short on results.
    final words = normalized.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
    if (words.length > 1) {
      final matchedIds = results.map((food) => food.id).toSet();
      final whereClauses = List.filled(words.length, "search_name LIKE '%' || ? || '%'");
      final anyOrderRows = await _db.rawQuery(
        '''
        SELECT $_foodColumns FROM foods
        WHERE ${whereClauses.join(' AND ')}
        ORDER BY food_name COLLATE NOCASE
        LIMIT ?
        ''',
        [...words, limit - results.length],
      );
      results.addAll(
        anyOrderRows.map(FoodModel.fromMap).where((food) => !matchedIds.contains(food.id)),
      );
    }

    return results;
  }

  Future<FoodModel?> getById(int id) async {
    final rows = await _db.query(
      'foods',
      columns: [
        'id',
        'food_name',
        'alim_nom_fr_no_comma',
        'calories_kcal_100g',
        'protein_g_100g',
        'carbs_g_100g',
        'fat_g_100g',
        'fiber_g_100g',
      ],
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return FoodModel.fromMap(rows.first);
  }

  /// Ingredient-specific unit -> grams-per-unit overrides for [foodId]
  /// (e.g. `{tbsp: 13.6}` for olive oil), sourced from `food_unit_conversions`.
  /// Empty when the ingredient has none, meaning only universal weight units
  /// (g/kg/oz/lb) are usable for it.
  Future<Map<Unit, double>> getUnitConversions(int foodId) async {
    final rows = await _db.query(
      'food_unit_conversions',
      columns: ['unit', 'grams_per_unit'],
      where: 'food_id = ?',
      whereArgs: [foodId],
    );
    return {
      for (final row in rows)
        Unit.fromId(row['unit']! as String): (row['grams_per_unit']! as num).toDouble(),
    };
  }
}
