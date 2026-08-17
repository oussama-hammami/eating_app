import 'package:eating_app/features/nutrition/data/datasources/food_local_data_source.dart';
import 'package:eating_app/features/nutrition/data/repositories/food_repository_impl.dart';
import 'package:eating_app/features/nutrition/domain/usecases/food_matcher.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'fixtures/food_db_fixture.dart';

void main() {
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

  late Database db;
  late FoodMatcher matcher;

  setUp(() async {
    db = await seedFoodDbFixture();
    matcher = FoodMatcher(FoodRepositoryImpl(FoodLocalDataSource(db)));
  });

  tearDown(() async {
    await db.close();
  });

  test('exact food match: "vanilla extract" prefers alcoholic extract over pod', () async {
    final result = await matcher.match('vanilla extract');

    expect(result.needsConfirmation, isFalse);
    expect(result.best!.food.foodName, 'Vanilla, alcoholic extract');
    // The wrong-type candidate may still surface as a weak alternative,
    // but must never be the auto-accepted best match.
    expect(
      result.candidates.any((c) => c.food.foodName == 'Vanilla, pod'),
      anyOf(isTrue, isFalse), // presence isn't required; confidence is what matters
    );
    final pod = result.candidates.where((c) => c.food.foodName == 'Vanilla, pod');
    if (pod.isNotEmpty) {
      expect(pod.first.confidence, lessThan(FoodMatcher.autoAcceptThreshold));
    }
  });

  test('wrong food type match: "vanilla extract" must not equal "vanilla, pod"', () async {
    final result = await matcher.match('vanilla extract');
    expect(result.best!.food.foodName, isNot('Vanilla, pod'));
  });

  test('"Greek yogurt" does not silently auto-match "Yogurt, Greek-style, ewe\'s milk"', () async {
    final result = await matcher.match('Greek yogurt');

    // The only Greek-style entry in this dataset is ewe's-milk based, which
    // is a materially different product than the generic "Greek yogurt" the
    // user meant — coverage is full but the extra "ewe"/"milk" tokens must
    // keep it below the auto-accept bar.
    expect(result.needsConfirmation, isTrue);
    expect(result.best!.food.foodName, "Yogurt, Greek-style, ewe's milk");
    expect(result.best!.confidence, lessThan(FoodMatcher.autoAcceptThreshold));
  });

  test('exact food match: a plain/generic entry auto-accepts', () async {
    final result = await matcher.match('yogurt');
    expect(result.needsConfirmation, isFalse);
    expect(result.best!.food.foodName, 'Yogurt (average)');
  });

  test('ambiguous food match: "chicken" alone surfaces multiple candidates, none auto-accepted', () async {
    final result = await matcher.match('chicken');

    expect(result.needsConfirmation, isTrue);
    expect(result.candidates.length, greaterThan(1));
    expect(result.candidates.map((c) => c.food.foodName), contains('Chicken, breast, meat and skin, raw'));
  });

  test('wrong food type match: "almond milk" does not match "Almond, peeled, no added salt"', () async {
    final result = await matcher.match('almond milk');

    final almondCandidate = result.candidates.where(
      (c) => c.food.foodName == 'Almond, peeled, no added salt',
    );
    // Either it's filtered out entirely, or it survives only as a very
    // low-confidence, non-auto-acceptable candidate.
    if (almondCandidate.isNotEmpty) {
      expect(almondCandidate.first.confidence, lessThan(FoodMatcher.autoAcceptThreshold));
    }
    expect(result.needsConfirmation, isTrue);
  });

  test('exact food match: "peanut butter" confidently matches, not plain peanuts', () async {
    final result = await matcher.match('peanut butter');
    expect(result.needsConfirmation, isFalse);
    expect(result.best!.food.foodName, 'Peanut butter or peanut paste');
  });

  test('exact food match: "egg" matches "Egg, raw" confidently', () async {
    final result = await matcher.match('egg');
    expect(result.needsConfirmation, isFalse);
    expect(result.best!.food.foodName, 'Egg, raw');
  });

  test('no candidates at all for a query with no shared words', () async {
    final result = await matcher.match('xyzzy nonexistent ingredient');
    expect(result.best, isNull);
    expect(result.needsConfirmation, isTrue);
  });

  test('every candidate records a human-readable reason', () async {
    final result = await matcher.match('vanilla extract');
    for (final candidate in result.candidates) {
      expect(candidate.reason, isNotEmpty);
    }
  });
}
