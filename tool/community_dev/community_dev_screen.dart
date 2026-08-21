import 'dart:convert';
import 'dart:io';

import 'package:eating_app/core/theme/app_palette.dart';
import 'package:eating_app/core/units/ingredient_text_parser.dart';
import 'package:eating_app/features/nutrition/domain/usecases/food_matcher.dart';
import 'package:eating_app/features/nutrition/domain/usecases/nutrition_calculator.dart';
import 'package:eating_app/features/nutrition/presentation/providers/food_search_provider.dart';
import 'package:eating_app/features/recipes/domain/entities/ingredient.dart';
import 'package:eating_app/features/recipes/domain/entities/meal_type.dart';
import 'package:eating_app/features/recipes/domain/entities/recipe.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Where saved recipes are written — a real Dart source file, in the exact
/// shape as `communityBreakfastRecipes()` in main.dart, so "the database" is
/// literally app-native code (a `List<Recipe>`), not a bespoke storage format.
const _generatedFilePath = 'tool/community_dev/generated_community_recipes.dart';

const _generatedFileTemplate = '''
import 'package:eating_app/features/recipes/domain/entities/ingredient.dart';
import 'package:eating_app/features/recipes/domain/entities/meal_type.dart';
import 'package:eating_app/features/recipes/domain/entities/recipe.dart';

/// Recipes added via the community dev tool
/// (flutter run -d linux -t tool/community_dev/main.dart).
/// Appended to automatically by that tool — hand-edit only to delete an
/// entry; use the tool itself to add new ones so nutrition stays computed
/// by the same pipeline as the rest of the app.
List<Recipe> devGeneratedCommunityRecipes() => [
];
''';

/// Encodes [s] as a single-quoted Dart string literal, escaping backslash,
/// quote, `$`, and newline so generated source stays valid regardless of
/// what a recipe's name/description/quantity text contains.
String dartStringLiteral(String s) => "'"
    "${s.replaceAll('\\', '\\\\').replaceAll("'", "\\'").replaceAll('\$', '\\\$').replaceAll('\n', '\\n')}"
    "'";

String dartNumLiteral(double? d) => d == null ? 'null' : d.toStringAsFixed(2);

/// Serializes one [Recipe] as a Dart `Recipe(...)` literal, matching the
/// exact constructor `main.dart` already uses for `communityBreakfastRecipes()`.
String serializeRecipeAsDartLiteral(Recipe r) {
  final buf = StringBuffer()
    ..writeln('  Recipe(')
    ..writeln('    name: ${dartStringLiteral(r.name)},')
    ..writeln('    calories: ${r.calories},')
    ..writeln('    protein: ${r.protein},')
    ..writeln('    portions: ${r.portions},')
    ..writeln('    mealType: MealType.${r.mealType.name},')
    ..writeln('    description: ${dartStringLiteral(r.description)},')
    ..writeln('    ingredients: [');
  for (final i in r.ingredients) {
    buf
      ..writeln('      Ingredient(')
      ..writeln('        name: ${dartStringLiteral(i.name)},')
      ..writeln('        quantity: ${dartStringLiteral(i.quantity)},')
      ..writeln('        calories: ${dartNumLiteral(i.calories)},')
      ..writeln('        protein: ${dartNumLiteral(i.protein)},')
      ..writeln('        carbs: ${dartNumLiteral(i.carbs)},')
      ..writeln('        fat: ${dartNumLiteral(i.fat)},')
      ..writeln('        fiber: ${dartNumLiteral(i.fiber)},');
    if (i.needsConfirmation) buf.writeln('        needsConfirmation: true,');
    buf.writeln('      ),');
  }
  buf
    ..writeln('    ],')
    ..writeln('  ),');
  return buf.toString();
}

/// Inserts the serialized form of [recipes] into [content] — a generated
/// Dart source file whose `List<Recipe> ... => [ ... ];` literal ends with
/// the last `];` in the file — just before that closing bracket. Pure
/// string logic, kept separate from file IO so it's directly testable.
String insertRecipesIntoGeneratedSource(String content, List<Recipe> recipes) {
  final closingIndex = content.lastIndexOf('];');
  if (closingIndex == -1) {
    throw StateError('Could not find closing "];" in generated recipes source');
  }
  final insertion = recipes.map(serializeRecipeAsDartLiteral).join();
  return content.substring(0, closingIndex) + insertion + content.substring(closingIndex);
}

/// Dev-only tool: import recipes into the community database from JSON,
/// using the app's own food-matching + nutrition pipeline (`FoodMatcher`,
/// `calculateIngredientNutrition`), building the app's own `Recipe`/
/// `Ingredient` objects and appending them as Dart source to
/// [_generatedFilePath]. Only reachable when launched via its own entrypoint
/// (`tool/community_dev/main.dart`) — never part of the shipped app.
class CommunityDevScreen extends ConsumerStatefulWidget {
  const CommunityDevScreen({super.key});

  @override
  ConsumerState<CommunityDevScreen> createState() => _CommunityDevScreenState();
}

class _CommunityDevScreenState extends ConsumerState<CommunityDevScreen> {
  final _jsonImportController = TextEditingController();
  String? _jsonImportError;

  // Session-only: recipes added since this tool was launched. The real,
  // durable record is the generated Dart file itself — recipes from earlier
  // sessions aren't re-parsed back into objects here (see _existingCountInFile).
  final List<Recipe> _saved = [];
  // Parallel to _saved: the JSON's own nutrition_per_serving, kept only for
  // on-screen comparison against the app-computed totals. Not part of the
  // Recipe model, so it isn't persisted.
  final List<Map<String, double?>?> _savedProvided = [];
  int _existingCountInFile = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _readExistingCount();
  }

  @override
  void dispose() {
    _jsonImportController.dispose();
    super.dispose();
  }

  Future<void> _readExistingCount() async {
    final file = File(_generatedFilePath);
    var count = 0;
    if (await file.exists()) {
      final content = await file.readAsString();
      count = RegExp(r'Recipe\(').allMatches(content).length;
    }
    if (!mounted) return;
    setState(() {
      _existingCountInFile = count;
      _loading = false;
    });
  }

  Future<File> _ensureGeneratedFile() async {
    final file = File(_generatedFilePath);
    if (!await file.exists()) {
      await file.create(recursive: true);
      await file.writeAsString(_generatedFileTemplate);
    }
    return file;
  }

  Future<void> _appendToGeneratedFile(List<Recipe> recipes) async {
    final file = await _ensureGeneratedFile();
    final content = await file.readAsString();
    final updated = insertRecipesIntoGeneratedSource(content, recipes);
    await file.writeAsString(updated);
  }

  Future<void> _wipeDatabase() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Wipe community DB?'),
        content: Text(
          'This resets $_generatedFilePath back to an empty list, permanently deleting '
          '$_existingCountInFile previously-generated recipe(s) plus the ${_saved.length} '
          'added this session. This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.delete_forever),
            label: const Text('Wipe everything'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    final file = await _ensureGeneratedFile();
    await file.writeAsString(_generatedFileTemplate);
    setState(() {
      _saved.clear();
      _savedProvided.clear();
      _existingCountInFile = 0;
    });
  }

  MealType _parseMealType(String? category) {
    if (category == null) return MealType.breakfast;
    for (final type in MealType.values) {
      if (type.name.toLowerCase() == category.trim().toLowerCase()) return type;
    }
    return MealType.breakfast;
  }

  /// Lets the user pick a `.json` file from disk and loads its contents
  /// into the paste box, ready for [_importFromJson] to process.
  Future<void> _pickJsonFile() async {
    setState(() => _jsonImportError = null);
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    final path = result?.files.single.path;
    if (path == null) return;

    try {
      final content = await File(path).readAsString();
      setState(() => _jsonImportController.text = content);
    } catch (e) {
      setState(() => _jsonImportError = 'Could not read file: $e');
    }
  }

  /// Imports one or many recipes from JSON in the
  /// `{category, name, ingredients, preparation, nutrition_per_serving}`
  /// shape, running every ingredient through the app's own [FoodMatcher] +
  /// [calculateIngredientNutrition] pipeline, building real [Recipe]/
  /// [Ingredient] objects, then appending them to the generated Dart file.
  /// The JSON's own `nutrition_per_serving` is kept only in [_savedProvided]
  /// for on-screen comparison — it is never fed into the calculation, and
  /// it is not part of the [Recipe] model, so it isn't persisted.
  Future<void> _importFromJson() async {
    setState(() => _jsonImportError = null);
    final List<dynamic> entries;
    try {
      final decoded = jsonDecode(_jsonImportController.text);
      entries = decoded is List ? decoded : [decoded];
    } catch (e) {
      setState(() => _jsonImportError = 'Invalid JSON: $e');
      return;
    }

    final foodRepository = ref.read(foodRepositoryProvider);
    final matcher = FoodMatcher(foodRepository);
    final imported = <Recipe>[];
    final importedProvided = <Map<String, double?>?>[];

    for (final entry in entries) {
      final map = entry as Map<String, dynamic>;
      final name = (map['name'] as String?)?.trim() ?? '';
      if (name.isEmpty) continue;

      final ingredientLines = (map['ingredients'] as List? ?? const [])
          .map((i) => i.toString())
          .toList();
      final preparation = (map['preparation'] as List? ?? const [])
          .map((i) => i.toString())
          .toList();
      final nutritionJson = map['nutrition_per_serving'] as Map<String, dynamic>?;

      final ingredients = <Ingredient>[];
      var totalCalories = 0.0, totalProtein = 0.0;
      for (final line in ingredientLines) {
        final parsed = parseIngredientText(line);
        if (parsed.name.trim().isEmpty) continue;
        final calc = await calculateIngredientNutrition(
          repository: foodRepository,
          matcher: matcher,
          ingredientName: parsed.name,
          amount: parsed.amount,
          unit: parsed.unit,
        );
        ingredients.add(
          Ingredient(
            name: parsed.name,
            quantity: parsed.amount == null
                ? ''
                : '${formatIngredientAmount(parsed.amount!)} ${parsed.unit.id}',
            calories: calc.calories,
            protein: calc.protein,
            carbs: calc.carbs,
            fat: calc.fat,
            fiber: calc.fiber,
            matchConfidence: calc.matchConfidence,
            needsConfirmation: calc.needsConfirmation,
          ),
        );
        totalCalories += calc.calories ?? 0;
        totalProtein += calc.protein ?? 0;
      }

      imported.add(
        Recipe(
          name: name,
          calories: totalCalories.round(),
          protein: totalProtein.round(),
          portions: 1,
          ingredients: ingredients,
          description: preparation.join('\n'),
          mealType: _parseMealType(map['category'] as String?),
        ),
      );
      importedProvided.add(
        nutritionJson == null
            ? null
            : {
                'calories': (nutritionJson['calories_kcal'] as num?)?.toDouble(),
                'protein': (nutritionJson['protein_g'] as num?)?.toDouble(),
                'carbs': (nutritionJson['carbs_g'] as num?)?.toDouble(),
                'fat': (nutritionJson['fat_g'] as num?)?.toDouble(),
                'fiber': (nutritionJson['fiber_g'] as num?)?.toDouble(),
              },
      );
    }

    if (imported.isEmpty) {
      setState(() => _jsonImportError = 'No valid recipes found in that JSON.');
      return;
    }

    await _appendToGeneratedFile(imported);
    setState(() {
      _saved.insertAll(0, imported);
      _savedProvided.insertAll(0, importedProvided);
      _jsonImportController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import community recipes (dev)')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppPalette.orange.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Dev-only tool, run separately from the app. Recipes are appended as real '
              'Dart Recipe(...) source to $_generatedFilePath — the same model the app '
              'itself uses, no separate storage format.',
              style: const TextStyle(fontSize: 12),
            ),
          ),
          const SizedBox(height: 16),
          const Text('Import recipes from JSON', style: TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          TextField(
            controller: _jsonImportController,
            maxLines: 10,
            decoration: const InputDecoration(
              labelText: 'Paste JSON (one recipe object, or an array of them)',
              border: OutlineInputBorder(),
            ),
          ),
          if (_jsonImportError != null)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(_jsonImportError!, style: const TextStyle(color: Colors.red)),
            ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              TextButton.icon(
                onPressed: _pickJsonFile,
                icon: const Icon(Icons.folder_open),
                label: const Text('Choose file...'),
              ),
              const SizedBox(width: 8),
              TextButton.icon(
                onPressed: _importFromJson,
                icon: const Icon(Icons.upload_file),
                label: const Text('Import & save to community DB'),
              ),
            ],
          ),
          const Divider(height: 32),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Saved this session (${_saved.length})'
                  '${_existingCountInFile > 0 ? ' • $_existingCountInFile already in $_generatedFilePath' : ''}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ),
              TextButton.icon(
                onPressed: _wipeDatabase,
                icon: const Icon(Icons.delete_forever, color: Colors.red),
                label: const Text('Wipe all', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (_loading)
            const Center(child: CircularProgressIndicator())
          else if (_saved.isEmpty)
            const Text('Nothing added this session yet.')
          else
            ..._saved.asMap().entries.map((entry) {
              final recipe = entry.value;
              final provided = _savedProvided[entry.key];
              final needsReview = recipe.ingredients.where((i) => i.needsConfirmation).toList();
              final carbs = recipe.ingredients.fold(0.0, (sum, i) => sum + (i.carbs ?? 0));
              final fat = recipe.ingredients.fold(0.0, (sum, i) => sum + (i.fat ?? 0));
              final fiber = recipe.ingredients.fold(0.0, (sum, i) => sum + (i.fiber ?? 0));
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ExpansionTile(
                  title: Text(recipe.name),
                  subtitle: Text(
                    '${recipe.mealType.name} • '
                    '${recipe.calories} kcal • '
                    '${recipe.protein}g protein • '
                    '${recipe.portions} portion(s)'
                    '${needsReview.isNotEmpty ? ' • ⚠ ${needsReview.length} need review' : ''}',
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (recipe.description.isNotEmpty) ...[
                            Text(recipe.description),
                            const SizedBox(height: 8),
                          ],
                          Text(
                            'App: ${recipe.calories} kcal • '
                            '${recipe.protein}g protein • '
                            '${carbs.round()}g carbs • '
                            '${fat.round()}g fat • '
                            '${fiber.round()}g fiber',
                          ),
                          if (provided != null)
                            Text(
                              'JSON: ${provided['calories']?.round() ?? '-'} kcal • '
                              '${provided['protein']?.round() ?? '-'}g protein • '
                              '${provided['carbs']?.round() ?? '-'}g carbs • '
                              '${provided['fat']?.round() ?? '-'}g fat • '
                              '${provided['fiber']?.round() ?? '-'}g fiber',
                              style: const TextStyle(color: AppPalette.tealDark),
                            ),
                          if (needsReview.isNotEmpty) ...[
                            const SizedBox(height: 8),
                            Text(
                              'Needs review (excluded from totals above):',
                              style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                            ),
                            ...needsReview.map(
                              (i) => Text(
                                '⚠ ${i.name}'
                                '${i.quantity.isEmpty ? '' : ' — ${i.quantity}'}',
                                style: TextStyle(color: Colors.orange.shade800, fontSize: 12),
                              ),
                            ),
                          ],
                          const SizedBox(height: 8),
                          ...recipe.ingredients.map((i) => Text(
                                '• ${i.name}'
                                '${i.quantity.isEmpty ? '' : ' — ${i.quantity}'}'
                                '${i.calories != null ? ' (${i.calories!.round()} kcal)' : ''}',
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}
