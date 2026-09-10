import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _loadArb(String path) =>
    jsonDecode(File(path).readAsStringSync()) as Map<String, dynamic>;

/// ARB metadata entries (`@key`, `@@locale`, ...) describe translations
/// rather than being translatable strings themselves.
bool _isTranslationKey(String key) => !key.startsWith('@');

void main() {
  final en = _loadArb('lib/l10n/app_en.arb');
  final fr = _loadArb('lib/l10n/app_fr.arb');
  final enKeys = en.keys.where(_isTranslationKey).toSet();
  final frKeys = fr.keys.where(_isTranslationKey).toSet();

  group('French localization (app_fr.arb) coverage', () {
    test('every English key has a matching French key', () {
      final missing = enKeys.difference(frKeys);
      expect(missing, isEmpty, reason: 'Missing French translations for: $missing');
    });

    test('has no orphan French keys absent from the English source', () {
      final orphaned = frKeys.difference(enKeys);
      expect(orphaned, isEmpty, reason: 'French keys with no English source: $orphaned');
    });

    test('no French translation value is empty', () {
      final empty = frKeys.where((k) => (fr[k] as String).trim().isEmpty).toList();
      expect(empty, isEmpty, reason: 'Empty French translations for: $empty');
    });

    test('declares fr as its locale', () {
      expect(fr['@@locale'], 'fr');
    });

    test('covers the required Weekly Planner strings', () {
      for (final key in [
        'mealTypeBreakfast',
        'mealTypeLunch',
        'mealTypeDinner',
        'mealTypeSnack',
        'plannerGenerateGroceries',
      ]) {
        expect(frKeys, contains(key));
        expect((fr[key] as String).trim(), isNotEmpty);
      }
      expect(fr['mealTypeBreakfast'], 'Petit-déjeuner');
      expect(fr['mealTypeLunch'], 'Déjeuner');
      expect(fr['mealTypeDinner'], 'Dîner');
    });

    test('covers the required Recipes/Groceries/Sharing screen titles', () {
      for (final key in ['recipesTitle', 'groceriesTitle', 'qrPayloadTooLargeError']) {
        expect(frKeys, contains(key));
        expect((fr[key] as String).trim(), isNotEmpty);
      }
    });

    test('placeholder-bearing strings keep the same placeholders as English', () {
      final placeholderPattern = RegExp(r'\{(\w+)\}');
      for (final key in enKeys) {
        final enPlaceholders = placeholderPattern.allMatches(en[key] as String).map((m) => m[1]).toSet();
        if (enPlaceholders.isEmpty) continue;
        final frPlaceholders = placeholderPattern.allMatches(fr[key] as String).map((m) => m[1]).toSet();
        expect(
          frPlaceholders,
          enPlaceholders,
          reason: 'Placeholder mismatch for "$key": en=$enPlaceholders fr=$frPlaceholders',
        );
      }
    });
  });
}
