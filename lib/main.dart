import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import 'core/database/app_database.dart';
import 'core/database/database_provider.dart';
import 'core/units/ingredient_text_parser.dart';
import 'core/units/unit.dart';
import 'features/meal_log/presentation/screens/food_diary_screen.dart';
import 'features/meal_log/presentation/widgets/quantity_dialog.dart' show unitLabel;
import 'features/nutrition/domain/entities/food.dart';
import 'features/nutrition/domain/repositories/food_repository.dart';
import 'features/nutrition/domain/usecases/food_matcher.dart';
import 'features/nutrition/domain/usecases/nutrition_calculator.dart';
import 'features/nutrition/presentation/providers/food_search_provider.dart';
import 'features/nutrition/presentation/widgets/ingredient_food_field.dart';
import 'l10n/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDatabase = await AppDatabase.open();

  runApp(
    ProviderScope(
      overrides: [databaseProvider.overrideWithValue(appDatabase.database)],
      child: const MyApp(),
    ),
  );
}

/// Light pastel kids palette: white, grey, peach, pink, cream.
class AppPalette {
  static const teal = Color(0xFFF5A9B8); // pink (primary accent)
  static const tealDark = Color(0xFFE8899E); // deeper pink
  static const yellow = Color(0xFFE9E6E3); // light pastel grey
  static const yellowDeep = Color(0xFFD8D3CE); // deeper grey
  static const orange = Color(0xFFFAC9A6); // peach
  static const orangeDeep = Color(0xFFF3A874); // deeper peach
  static const beige = Color(0xFFFFFBF3); // cream
  static const beigeDeep = Color(0xFFF0EAD8); // deeper cream
  static const ink = Color(0xFF5C5450); // warm grey
}

// TODO: Update once the GitHub Pages repo is created and published.
const String privacyPolicyUrl =
    'https://ohammami.github.io/my-food-this-week/privacy-policy.html';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppPalette.teal,
      brightness: Brightness.light,
      primary: AppPalette.tealDark,
      secondary: AppPalette.orangeDeep,
      tertiary: AppPalette.yellowDeep,
      surface: Colors.white,
    );

    return MaterialApp(
      title: 'My Food This Week',
      onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: colorScheme,
        scaffoldBackgroundColor: AppPalette.beige,
        fontFamily: 'Georgia',
        appBarTheme: const AppBarTheme(
          backgroundColor: AppPalette.beige,
          foregroundColor: AppPalette.ink,
          centerTitle: true,
          elevation: 0,
          titleTextStyle: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppPalette.ink,
            letterSpacing: 0.5,
          ),
        ),
        cardTheme: CardThemeData(
          color: Colors.white,
          elevation: 0,
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: AppPalette.beigeDeep, width: 1.5),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: AppPalette.orangeDeep,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(18)),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: AppPalette.orangeDeep,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppPalette.tealDark,
            side: const BorderSide(color: AppPalette.tealDark, width: 1.5),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            textStyle: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppPalette.tealDark,
          ),
        ),
        checkboxTheme: CheckboxThemeData(
          fillColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return AppPalette.tealDark;
            }
            return Colors.white;
          }),
          checkColor: const WidgetStatePropertyAll(Colors.white),
          side: const BorderSide(color: AppPalette.tealDark, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppPalette.beige,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppPalette.beigeDeep),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppPalette.beigeDeep),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppPalette.tealDark, width: 2),
          ),
          labelStyle: const TextStyle(color: AppPalette.ink),
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: AppPalette.beige,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          titleTextStyle: const TextStyle(
            color: AppPalette.ink,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
          contentTextStyle: const TextStyle(color: AppPalette.ink, fontSize: 15),
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: AppPalette.yellow,
          elevation: 8,
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(
              fontSize: 12,
              fontWeight: states.contains(WidgetState.selected)
                  ? FontWeight.w700
                  : FontWeight.w500,
              color: AppPalette.ink,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            return IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? AppPalette.orangeDeep
                  : AppPalette.ink.withValues(alpha: 0.5),
            );
          }),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: AppPalette.ink),
          bodyMedium: TextStyle(color: AppPalette.ink),
          titleMedium: TextStyle(color: AppPalette.ink, fontWeight: FontWeight.w700),
        ),
      ),
      home: const RootShell(),
    );
  }
}

class Ingredient {
  Ingredient({
    required this.name,
    required this.quantity,
    this.calories,
    this.protein,
    this.carbs,
    this.fat,
    this.fiber,
    this.matchConfidence,
    this.needsConfirmation = false,
  });

  final String name;
  final String quantity;

  /// Nutrition contributed by this ingredient (at its recipe quantity), when
  /// it was matched to a food item with known grams — null otherwise.
  final double? calories;
  final double? protein;
  final double? carbs;
  final double? fat;
  final double? fiber;

  /// How confident [FoodMatcher] was in the food match used to compute the
  /// nutrition above (null if no candidate was found at all).
  final double? matchConfidence;

  /// True when the best food match wasn't confident enough to auto-accept —
  /// nutrition fields are null in that case; a human should confirm which
  /// food was meant instead of trusting a silent guess.
  final bool needsConfirmation;
}

const _unitAliases = {
  'g': Unit.g, 'gram': Unit.g, 'grams': Unit.g,
  'kg': Unit.kg, 'kilogram': Unit.kg, 'kilograms': Unit.kg,
  'oz': Unit.oz, 'ounce': Unit.oz, 'ounces': Unit.oz,
  'lb': Unit.lb, 'lbs': Unit.lb, 'pound': Unit.lb, 'pounds': Unit.lb,
  'ml': Unit.ml, 'l': Unit.l, 'liter': Unit.l, 'liters': Unit.l,
  'tsp': Unit.tsp, 'teaspoon': Unit.tsp, 'teaspoons': Unit.tsp,
  'tbsp': Unit.tbsp, 'tablespoon': Unit.tbsp, 'tablespoons': Unit.tbsp,
  'cup': Unit.cup, 'cups': Unit.cup,
  'fl oz': Unit.flOz, 'fl_oz': Unit.flOz,
  'piece': Unit.piece, 'pieces': Unit.piece, '': Unit.g,
};

/// Splits a legacy free-text quantity like "2 cups" into a numeric amount
/// and its best-guess [Unit], falling back to the whole string as the
/// amount with [Unit.g] when no unit can be recognized.
(String amount, Unit unit) _parseLegacyQuantity(String raw) {
  final match = RegExp(r'^([\d.]+)\s*(.*)$').firstMatch(raw.trim());
  if (match == null) return (raw.trim(), Unit.g);
  final amount = match.group(1)!;
  final unitText = match.group(2)!.trim().toLowerCase();
  return (amount, _unitAliases[unitText] ?? Unit.g);
}

enum MealType {
  breakfast(Icons.free_breakfast_outlined),
  lunch(Icons.lunch_dining_outlined),
  dinner(Icons.dinner_dining_outlined),
  snack(Icons.cookie_outlined),
  drink(Icons.local_bar_outlined);

  const MealType(this.icon);

  final IconData icon;

  String label(AppLocalizations l10n) {
    switch (this) {
      case MealType.breakfast:
        return l10n.mealTypeBreakfast;
      case MealType.lunch:
        return l10n.mealTypeLunch;
      case MealType.dinner:
        return l10n.mealTypeDinner;
      case MealType.snack:
        return l10n.mealTypeSnack;
      case MealType.drink:
        return l10n.mealTypeDrink;
    }
  }
}

class Recipe {
  Recipe({
    required this.name,
    required this.calories,
    required this.protein,
    required this.portions,
    required this.ingredients,
    required this.description,
    required this.mealType,
    this.photoPath,
  }) : checkedIngredients = List.filled(ingredients.length, false);

  final String name;
  final int calories;
  final int protein;
  final int portions;
  final List<Ingredient> ingredients;
  final String description;
  final MealType mealType;
  final String? photoPath;
  final List<bool> checkedIngredients;
}

/// Community-contributed breakfast recipes shown in the Community tab.
/// Calories/protein/carbs/fat/fiber are left at 0/null here — the Community
/// tab computes them on load by running each ingredient through the same
/// food-matching + [_ingredientNutrition] pipeline used when a user adds a
/// recipe by hand.
List<Recipe> communityBreakfastRecipes() => [
  Recipe(
    name: 'High-Protein Greek Yogurt Pancakes',
    calories: 0,
    protein: 0,
    portions: 1,
    mealType: MealType.breakfast,
    description: '',
    ingredients: [
      Ingredient(name: 'oat raw', quantity: '40 g'),
      Ingredient(name: 'yogurt greek', quantity: '120 g'),
      Ingredient(name: 'egg raw', quantity: '2 piece'),
      Ingredient(name: 'vanilla pod', quantity: '0.5 tsp'),
      Ingredient(name: 'cinnamon', quantity: '0.5 tsp'),
      Ingredient(name: 'blueberry raw', quantity: '50 g'),
      Ingredient(name: 'honey', quantity: '1 tsp'),
    ],
  ),
  Recipe(
    name: 'Cottage Cheese Protein Pancakes',
    calories: 0,
    protein: 0,
    portions: 1,
    mealType: MealType.breakfast,
    description: '',
    ingredients: [
      Ingredient(name: 'oat raw', quantity: '40 g'),
      Ingredient(name: 'fresh cream cheese petit-suisse type plain', quantity: '100 g'),
      Ingredient(name: 'egg raw', quantity: '1 piece'),
      Ingredient(name: 'sodium bicarbonate', quantity: '0.25 tsp'),
      Ingredient(name: 'honey', quantity: '0.5 tsp'),
      Ingredient(name: 'cinnamon', quantity: '0.25 tsp'),
      Ingredient(name: 'blueberry raw', quantity: '50 g'),
      Ingredient(name: 'yogurt greek', quantity: '30 g'),
    ],
  ),
  Recipe(
    name: 'Greek Yogurt Overnight Oats',
    calories: 0,
    protein: 0,
    portions: 1,
    mealType: MealType.breakfast,
    description: '',
    ingredients: [
      Ingredient(name: 'oat raw', quantity: '50 g'),
      Ingredient(name: 'yogurt greek', quantity: '150 g'),
      Ingredient(name: 'milk semi-skimmed', quantity: '100 ml'),
      Ingredient(name: 'chia seed', quantity: '10 g'),
      Ingredient(name: 'banana flesh without skin raw', quantity: '60 g'),
      Ingredient(name: 'blueberry raw', quantity: '50 g'),
      Ingredient(name: 'cinnamon', quantity: '0.5 tsp'),
    ],
  ),
  Recipe(
    name: 'Cottage Cheese & Greek Yogurt Breakfast Bowl',
    calories: 0,
    protein: 0,
    portions: 1,
    mealType: MealType.breakfast,
    description: '',
    ingredients: [
      Ingredient(name: 'fresh cream cheese petit-suisse type plain', quantity: '110 g'),
      Ingredient(name: 'yogurt greek', quantity: '90 g'),
      Ingredient(name: 'almond peeled', quantity: '14 g'),
      Ingredient(name: 'walnut kernel', quantity: '14 g'),
      Ingredient(name: 'chia seed', quantity: '6 g'),
      Ingredient(name: 'strawberry raw', quantity: '50 g'),
      Ingredient(name: 'cinnamon', quantity: ''),
    ],
  ),
  Recipe(
    name: 'Cottage Cheese Egg Bake',
    calories: 0,
    protein: 0,
    portions: 1,
    mealType: MealType.breakfast,
    description: '',
    ingredients: [
      Ingredient(name: 'egg raw', quantity: '2 piece'),
      Ingredient(name: 'fresh cream cheese petit-suisse type plain', quantity: '100 g'),
      Ingredient(name: 'spinach raw', quantity: '30 g'),
      Ingredient(name: 'tomato raw', quantity: '50 g'),
      Ingredient(name: 'Parmesan', quantity: '10 g'),
      Ingredient(name: 'bread multigrain', quantity: '40 g'),
      Ingredient(name: 'black pepper', quantity: ''),
      Ingredient(name: 'herbes de provence', quantity: ''),
    ],
  ),
  Recipe(
    name: 'High-Protein Egg White Oatmeal',
    calories: 0,
    protein: 0,
    portions: 1,
    mealType: MealType.breakfast,
    description: '',
    ingredients: [
      Ingredient(name: 'oat raw', quantity: '40 g'),
      Ingredient(name: 'milk semi-skimmed', quantity: '150 ml'),
      Ingredient(name: 'egg white', quantity: '100 g'),
      Ingredient(name: 'vanilla pod', quantity: '0.5 tsp'),
      Ingredient(name: 'cinnamon', quantity: '0.5 tsp'),
      Ingredient(name: 'raspberry raw', quantity: '50 g'),
      Ingredient(name: 'peanut butter', quantity: '10 g'),
    ],
  ),
  Recipe(
    name: 'Greek Yogurt Scrambled Eggs',
    calories: 0,
    protein: 0,
    portions: 1,
    mealType: MealType.breakfast,
    description: '',
    ingredients: [
      Ingredient(name: 'egg raw', quantity: '3 piece'),
      Ingredient(name: 'yogurt greek', quantity: '60 g'),
      Ingredient(name: 'spinach raw', quantity: '30 g'),
      Ingredient(name: 'tomato raw', quantity: '50 g'),
      Ingredient(name: 'bread multigrain', quantity: '40 g'),
      Ingredient(name: 'chive', quantity: '5 g'),
      Ingredient(name: 'black pepper', quantity: ''),
    ],
  ),
  Recipe(
    name: 'Apple & Peanut Butter Protein Overnight Oats',
    calories: 0,
    protein: 0,
    portions: 1,
    mealType: MealType.breakfast,
    description: '',
    ingredients: [
      Ingredient(name: 'oat raw', quantity: '40 g'),
      Ingredient(name: 'yogurt greek', quantity: '100 g'),
      Ingredient(name: 'milk semi-skimmed', quantity: '100 ml'),
      Ingredient(name: 'hemp seed', quantity: '10 g'),
      Ingredient(name: 'chia seed', quantity: '5 g'),
      Ingredient(name: 'peanut butter', quantity: '15 g'),
      Ingredient(name: 'apple flesh and skin raw', quantity: '75 g'),
      Ingredient(name: 'maple syrup', quantity: '1 tsp'),
      Ingredient(name: 'cinnamon', quantity: ''),
    ],
  ),
  Recipe(
    name: 'Protein Baked Cinnamon Oats',
    calories: 0,
    protein: 0,
    portions: 1,
    mealType: MealType.breakfast,
    description: '',
    ingredients: [
      Ingredient(name: 'oat raw', quantity: '40 g'),
      Ingredient(name: 'yogurt greek', quantity: '100 g'),
      Ingredient(name: 'egg white', quantity: '100 g'),
      Ingredient(name: 'chia seed', quantity: '5 g'),
      Ingredient(name: 'hemp seed', quantity: '5 g'),
      Ingredient(name: 'cinnamon', quantity: '0.5 tsp'),
      Ingredient(name: 'sugar brown', quantity: '0.5 tsp'),
      Ingredient(name: 'yogurt greek', quantity: '30 g'),
      Ingredient(name: 'berries', quantity: '50 g'),
    ],
  ),
  Recipe(
    name: 'Cottage Cheese Overnight Oats',
    calories: 0,
    protein: 0,
    portions: 1,
    mealType: MealType.breakfast,
    description: '',
    ingredients: [
      Ingredient(name: 'oat raw', quantity: '40 g'),
      Ingredient(name: 'fresh cream cheese petit-suisse type plain', quantity: '100 g'),
      Ingredient(name: 'milk semi-skimmed', quantity: '100 ml'),
      Ingredient(name: 'banana flesh without skin raw', quantity: '60 g'),
      Ingredient(name: 'chia seed', quantity: '10 g'),
      Ingredient(name: 'cinnamon', quantity: '0.5 tsp'),
      Ingredient(name: 'maple syrup', quantity: '1 tsp'),
      Ingredient(name: 'berries', quantity: '50 g'),
    ],
  ),
];

/// Computes a [Recipe]'s ingredient-level and total nutrition by running
/// each ingredient through the full audited pipeline: concept-level food
/// matching ([FoodMatcher]), then unit conversion, then per-100g scaling
/// ([calculateIngredientNutrition]) — the same pipeline the add-recipe
/// dialog uses when a user picks a food and types a quantity. Every
/// ingredient's full audit trail is printed via [debugPrint] so a wrong or
/// missing value can always be traced back to exactly why.
Future<Recipe> _withComputedNutrition(
  FoodRepository foodRepository,
  FoodMatcher matcher,
  Recipe recipe,
) async {
  final debugRows = <IngredientCalculationDebug>[];

  for (final ingredient in recipe.ingredients) {
    if (ingredient.name.trim().isEmpty) {
      continue;
    }
    final (amountText, unit) = _parseLegacyQuantity(ingredient.quantity);
    final amount = double.tryParse(amountText);
    debugRows.add(
      await calculateIngredientNutrition(
        repository: foodRepository,
        matcher: matcher,
        ingredientName: ingredient.name,
        amount: amount,
        unit: unit,
      ),
    );
  }

  debugPrint('--- nutrition audit: ${recipe.name} ---');
  for (final row in debugRows) {
    debugPrint(row.toDebugRow());
  }

  final totals = computeRecipeTotals(debugRows, servings: recipe.portions);
  if (totals.incompleteIngredients.isNotEmpty) {
    debugPrint(
      '${recipe.name}: totals are a partial sum — '
      'no confident nutrition for: ${totals.incompleteIngredients.join(', ')}',
    );
  }

  final computedIngredients = debugRows
      .map(
        (row) => Ingredient(
          name: row.ingredientEntered,
          quantity: row.amount == null ? '' : '${row.amount} ${row.unit.id}',
          calories: row.calories,
          protein: row.protein,
          carbs: row.carbs,
          fat: row.fat,
          fiber: row.fiber,
          matchConfidence: row.matchConfidence,
          needsConfirmation: row.needsConfirmation,
        ),
      )
      .toList();

  return Recipe(
    name: recipe.name,
    calories: totals.totalCalories.round(),
    protein: totals.totalProtein.round(),
    portions: recipe.portions,
    ingredients: computedIngredients,
    description: recipe.description,
    mealType: recipe.mealType,
    photoPath: recipe.photoPath,
  );
}

class GroceryItem {
  GroceryItem({required this.name, required this.rawQuantities, this.checked = false});

  final String name;
  final List<String> rawQuantities;
  bool checked;

  String get displayQuantity => combineQuantities(rawQuantities);
}

/// Combines quantity strings like "2 cups" + "1 cups" into "3 cups".
/// Quantities that don't share a numeric+unit format are kept as separate
/// entries joined with "+".
String combineQuantities(List<String> quantities) {
  final quantityPattern = RegExp(r'^([\d.]+)\s*(.*)$');
  double? numericAmount;
  String? unit;
  final extras = <String>[];

  for (final raw in quantities) {
    final quantity = raw.trim();
    if (quantity.isEmpty) continue;
    final match = quantityPattern.firstMatch(quantity);
    if (match != null) {
      final amount = double.tryParse(match.group(1)!);
      final matchedUnit = match.group(2)!.trim().toLowerCase();
      if (amount != null && (unit == null || unit == matchedUnit)) {
        unit = matchedUnit;
        numericAmount = (numericAmount ?? 0) + amount;
        continue;
      }
    }
    extras.add(quantity);
  }

  final parts = <String>[];
  if (numericAmount != null) {
    final amountText = numericAmount == numericAmount.roundToDouble()
        ? numericAmount.toInt().toString()
        : numericAmount.toString();
    parts.add(unit!.isEmpty ? amountText : '$amountText $unit');
  }
  parts.addAll(extras);
  return parts.join(' + ');
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _tabIndex = 0;
  final List<Recipe> _recipes = [];
  final List<GroceryItem> _groceries = [];

  int _groceryResetSignal = 0;

  void _addRecipe(Recipe recipe) {
    setState(() {
      _recipes.add(recipe);
    });
  }

  void _updateRecipe(int index, Recipe recipe) {
    setState(() {
      _recipes[index] = recipe;
    });
  }

  void _deleteRecipe(int index) {
    setState(() {
      _recipes.removeAt(index);
    });
  }

  void _resetGroceries() {
    setState(() {
      _groceries.clear();
      _groceryResetSignal++;
    });
  }

  void _addToGroceries(List<Recipe> selectedRecipes) {
    final rawQuantitiesByKey = <String, List<String>>{};
    final displayNameByKey = <String, String>{};
    final order = <String>[];

    for (final item in _groceries) {
      final key = item.name.trim().toLowerCase();
      order.add(key);
      displayNameByKey[key] = item.name;
      rawQuantitiesByKey[key] = List.of(item.rawQuantities);
    }

    for (final recipe in selectedRecipes) {
      for (final ingredient in recipe.ingredients) {
        final key = ingredient.name.trim().toLowerCase();
        if (key.isEmpty) continue;
        if (!order.contains(key)) order.add(key);
        displayNameByKey[key] = ingredient.name.trim();
        rawQuantitiesByKey.putIfAbsent(key, () => []).add(ingredient.quantity.trim());
      }
    }

    final existingCheckedByKey = {
      for (final item in _groceries) item.name.trim().toLowerCase(): item.checked,
    };

    setState(() {
      _groceries
        ..clear()
        ..addAll(order.map((key) {
          return GroceryItem(
            name: displayNameByKey[key]!,
            rawQuantities: rawQuantitiesByKey[key]!,
            checked: existingCheckedByKey[key] ?? false,
          );
        }));
      _tabIndex = 1;
    });
  }

  void _generateGroceries(List<Recipe> selectedRecipes) {
    final rawQuantitiesByKey = <String, List<String>>{};
    final displayNameByKey = <String, String>{};
    final order = <String>[];

    for (final recipe in selectedRecipes) {
      for (final ingredient in recipe.ingredients) {
        final key = ingredient.name.trim().toLowerCase();
        if (key.isEmpty) continue;
        if (!order.contains(key)) order.add(key);
        displayNameByKey[key] = ingredient.name.trim();
        rawQuantitiesByKey.putIfAbsent(key, () => []).add(ingredient.quantity.trim());
      }
    }

    setState(() {
      _groceries
        ..clear()
        ..addAll(order.map((key) {
          return GroceryItem(
            name: displayNameByKey[key]!,
            rawQuantities: rawQuantitiesByKey[key]!,
          );
        }));
      _tabIndex = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: [
          RecipesTab(
            recipes: _recipes,
            onAddRecipe: _addRecipe,
            onUpdateRecipe: _updateRecipe,
            onDeleteRecipe: _deleteRecipe,
            onAddToGroceries: _addToGroceries,
            onGenerateGroceries: _generateGroceries,
            groceryResetSignal: _groceryResetSignal,
          ),
          GroceriesTab(
            items: _groceries,
            onChanged: () => setState(() {}),
            onReset: _resetGroceries,
          ),
          const FoodDiaryScreen(),
          const CommunityTab(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.restaurant_menu),
            label: AppLocalizations.of(context)!.navRecipes,
          ),
          NavigationDestination(
            icon: const Icon(Icons.shopping_cart),
            label: AppLocalizations.of(context)!.navGroceries,
          ),
          NavigationDestination(
            icon: const Icon(Icons.local_dining),
            label: AppLocalizations.of(context)!.navDiary,
          ),
          NavigationDestination(
            icon: const Icon(Icons.groups_outlined),
            label: AppLocalizations.of(context)!.navCommunity,
          ),
        ],
      ),
    );
  }
}

class RecipesTab extends ConsumerStatefulWidget {
  const RecipesTab({
    super.key,
    required this.recipes,
    required this.onAddRecipe,
    required this.onUpdateRecipe,
    required this.onDeleteRecipe,
    required this.onAddToGroceries,
    required this.onGenerateGroceries,
    required this.groceryResetSignal,
  });

  final List<Recipe> recipes;
  final void Function(Recipe recipe) onAddRecipe;
  final void Function(int index, Recipe recipe) onUpdateRecipe;
  final void Function(int index) onDeleteRecipe;
  final void Function(List<Recipe> selectedRecipes) onAddToGroceries;
  final void Function(List<Recipe> selectedRecipes) onGenerateGroceries;
  final int groceryResetSignal;

  @override
  ConsumerState<RecipesTab> createState() => _RecipesTabState();
}

class _RecipesTabState extends ConsumerState<RecipesTab> {
  final Set<int> _expandedIndexes = {};
  final Set<int> _selectedIndexes = {};

  @override
  void didUpdateWidget(covariant RecipesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groceryResetSignal != widget.groceryResetSignal) {
      setState(() {
        _selectedIndexes.clear();
      });
    }
  }

  void _addToGroceries() {
    final selectedRecipes = _selectedIndexes.map((i) => widget.recipes[i]).toList();
    widget.onAddToGroceries(selectedRecipes);
    setState(() {
      _selectedIndexes.clear();
    });
  }

  Future<void> _generateGroceries() async {
    final selectedRecipes = _selectedIndexes.map((i) => widget.recipes[i]).toList();
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.generateGroceriesConfirmTitle),
        content: Text(l10n.generateGroceriesConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.auto_awesome),
            label: Text(l10n.generate),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    widget.onGenerateGroceries(selectedRecipes);
    setState(() {
      _selectedIndexes.clear();
    });
  }

  Future<void> _deleteRecipe(int index) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.deleteRecipeConfirmTitle),
        content: Text(l10n.deleteRecipeConfirmMessage(widget.recipes[index].name)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.delete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      setState(() {
        _selectedIndexes.remove(index);
        _expandedIndexes.remove(index);
      });
      widget.onDeleteRecipe(index);
    }
  }

  Future<String?> _pickRecipePhoto(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined, color: AppPalette.tealDark),
              title: Text(l10n.takeAPhoto),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppPalette.tealDark),
              title: Text(l10n.chooseFromLibrary),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return null;

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 85);
    return picked?.path;
  }

  Future<void> _openAddRecipeDialog({int? editIndex}) async {
    final l10n = AppLocalizations.of(context)!;
    final existing = editIndex != null ? widget.recipes[editIndex] : null;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final caloriesController =
        TextEditingController(text: existing != null ? existing.calories.toString() : '0');
    final proteinController =
        TextEditingController(text: existing != null ? existing.protein.toString() : '0');
    final portionsController =
        TextEditingController(text: existing != null ? existing.portions.toString() : '1');
    final descriptionController = TextEditingController(text: existing?.description ?? '');
    String? photoPath = existing?.photoPath;
    MealType mealType = existing?.mealType ?? MealType.breakfast;
    // Each row is a single free-text description ("1 tablespoon of olive
    // oil"), parsed live by IngredientFoodField into amount/unit/name and
    // matched against the food DB. ingredientAmounts/Units/Foods track that
    // parsed state per row, kept in sync via onMatchChanged.
    final ingredientNameControllers = existing != null && existing.ingredients.isNotEmpty
        ? existing.ingredients.map((i) {
            final (amountText, unit) = _parseLegacyQuantity(i.quantity);
            final prefix = amountText.isEmpty ? '' : '$amountText ${unitLabel(l10n, unit)} ';
            return TextEditingController(text: '$prefix${i.name}');
          }).toList()
        : <TextEditingController>[TextEditingController()];
    final ingredientAmounts = existing != null && existing.ingredients.isNotEmpty
        ? existing.ingredients
            .map((i) => double.tryParse(_parseLegacyQuantity(i.quantity).$1))
            .toList()
        : <double?>[null];
    final ingredientUnits = existing != null && existing.ingredients.isNotEmpty
        ? existing.ingredients.map((i) => _parseLegacyQuantity(i.quantity).$2).toList()
        : <Unit>[Unit.g];
    final ingredientFoods =
        List<Food?>.filled(ingredientNameControllers.length, null, growable: true);
    // Cached per-row calculation, refreshed by recalculateNutrition whenever
    // a row's food/amount/unit changes. The save handler reads straight from
    // this cache instead of recomputing (which would need to be async).
    final ingredientNutritionCache =
        List<IngredientNutrition?>.filled(ingredientNameControllers.length, null, growable: true);
    final foodRepository = ref.read(foodRepositoryProvider);

    Future<void> recalculateNutrition(StateSetter setDialogState) async {
      final previews = List<IngredientNutrition?>.filled(ingredientFoods.length, null);
      var totalCalories = 0.0;
      var totalProtein = 0.0;
      for (var i = 0; i < ingredientFoods.length; i++) {
        final food = ingredientFoods[i];
        final amount = ingredientAmounts[i];
        if (food == null || amount == null) continue;
        final unit = ingredientUnits[i];

        final nutrition = await calculateKnownIngredientNutrition(
          repository: foodRepository,
          food: food,
          amount: amount,
          unit: unit,
        );
        previews[i] = nutrition;
        if (nutrition.calories != null) totalCalories += nutrition.calories!;
        if (nutrition.protein != null) totalProtein += nutrition.protein!;
      }
      setDialogState(() {
        ingredientNutritionCache
          ..clear()
          ..addAll(previews);
        caloriesController.text = totalCalories.round().toString();
        proteinController.text = totalProtein.round().toString();
      });
    }

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(existing != null ? l10n.editRecipeTitle : l10n.addRecipeTitle),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            final path = await _pickRecipePhoto(dialogContext);
                            if (path != null) {
                              setDialogState(() => photoPath = path);
                            }
                          },
                          child: Container(
                            width: 120,
                            height: 120,
                            decoration: BoxDecoration(
                              color: AppPalette.beige,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppPalette.beigeDeep, width: 1.5),
                              image: photoPath != null
                                  ? DecorationImage(
                                      image: FileImage(File(photoPath!)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: photoPath == null
                                ? const Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 32,
                                    color: AppPalette.tealDark,
                                  )
                                : Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: GestureDetector(
                                        onTap: () => setDialogState(() => photoPath = null),
                                        child: const CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: AppPalette.ink,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(labelText: l10n.mealName),
                      ),
                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(l10n.mealType, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 8),
                      DropdownButtonFormField<MealType>(
                        initialValue: mealType,
                        decoration: const InputDecoration(border: OutlineInputBorder()),
                        items: MealType.values.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(type.icon, size: 18, color: AppPalette.tealDark),
                                const SizedBox(width: 8),
                                Text(type.label(l10n)),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (type) {
                          if (type != null) setDialogState(() => mealType = type);
                        },
                      ),
                      const SizedBox(height: 16),
                      Text(l10n.ingredients, style: const TextStyle(fontWeight: FontWeight.bold)),
                      ...ingredientNameControllers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final descriptionController = entry.value;
                        final matchedFood = ingredientFoods[index];
                        final nutrition = ingredientNutritionCache[index];
                        final languageCode = Localizations.localeOf(dialogContext).languageCode;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    IngredientFoodField(
                                      controller: descriptionController,
                                      label: l10n.ingredientN(index + 1),
                                      onMatchChanged: (match) {
                                        setDialogState(() {
                                          ingredientAmounts[index] = match.amount;
                                          ingredientUnits[index] = match.unit;
                                          ingredientFoods[index] = match.food;
                                        });
                                        recalculateNutrition(setDialogState);
                                      },
                                    ),
                                    if (matchedFood != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 4, left: 4),
                                        child: Text(
                                          nutrition?.calories != null && nutrition?.protein != null
                                              ? '${matchedFood.displayName(languageCode)} • '
                                                  '${l10n.caloriesKcalChip(nutrition!.calories!.round())} • '
                                                  '${l10n.proteinGChip(nutrition.protein!.round())}'
                                              : l10n.ingredientNutritionUnknown,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppPalette.tealDark,
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: ingredientNameControllers.length > 1
                                    ? () {
                                        setDialogState(() {
                                          ingredientNameControllers.removeAt(index);
                                          ingredientAmounts.removeAt(index);
                                          ingredientUnits.removeAt(index);
                                          ingredientFoods.removeAt(index);
                                        });
                                        recalculateNutrition(setDialogState);
                                      }
                                    : null,
                              ),
                            ],
                          ),
                        );
                      }),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton.icon(
                          onPressed: () {
                            setDialogState(() {
                              ingredientNameControllers.add(TextEditingController());
                              ingredientAmounts.add(null);
                              ingredientUnits.add(Unit.g);
                              ingredientFoods.add(null);
                              ingredientNutritionCache.add(null);
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: Text(l10n.addIngredient),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: caloriesController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(labelText: l10n.caloriesKcal),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: proteinController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(labelText: l10n.proteinG),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: portionsController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: InputDecoration(labelText: l10n.portions),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: l10n.preparationDescription,
                          alignLabelWithHint: true,
                          border: const OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.cancel),
                ),
                FilledButton.icon(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final ingredients = <Ingredient>[];
                    for (var i = 0; i < ingredientNameControllers.length; i++) {
                      final rawText = ingredientNameControllers[i].text.trim();
                      if (rawText.isEmpty) continue;
                      final parsed = parseIngredientText(rawText);
                      if (parsed.name.isEmpty) continue;
                      final unit = ingredientUnits[i];
                      final amount = ingredientAmounts[i];
                      final nutrition = ingredientNutritionCache[i];
                      ingredients.add(
                        Ingredient(
                          name: parsed.name,
                          quantity: amount == null
                              ? ''
                              : '${formatIngredientAmount(amount)} ${unitLabel(l10n, unit)}',
                          calories: nutrition?.calories,
                          protein: nutrition?.protein,
                          carbs: nutrition?.carbs,
                          fat: nutrition?.fat,
                          fiber: nutrition?.fiber,
                        ),
                      );
                    }

                    final recipe = Recipe(
                      name: name,
                      calories: int.tryParse(caloriesController.text.trim()) ?? 0,
                      protein: int.tryParse(proteinController.text.trim()) ?? 0,
                      portions: int.tryParse(portionsController.text.trim()) ?? 1,
                      ingredients: ingredients,
                      description: descriptionController.text.trim(),
                      mealType: mealType,
                      photoPath: photoPath,
                    );
                    if (editIndex != null) {
                      widget.onUpdateRecipe(editIndex, recipe);
                    } else {
                      widget.onAddRecipe(recipe);
                    }
                    Navigator.of(dialogContext).pop();
                  },
                  icon: Icon(editIndex != null ? Icons.save : Icons.add),
                  label: Text(editIndex != null ? l10n.save : l10n.add),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showIngredientNutrition(Ingredient ingredient) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          ingredient.quantity.isEmpty
              ? ingredient.name
              : '${ingredient.name} (${ingredient.quantity})',
        ),
        content: ingredient.calories != null &&
                ingredient.protein != null &&
                ingredient.carbs != null &&
                ingredient.fat != null &&
                ingredient.fiber != null
            ? Text(
                '${l10n.caloriesKcalChip(ingredient.calories!.round())} • '
                '${l10n.proteinGChip(ingredient.protein!.round())} • '
                '${l10n.carbsGChip(ingredient.carbs!.round())} • '
                '${l10n.fatGChip(ingredient.fat!.round())} • '
                '${l10n.fiberGChip(ingredient.fiber!.round())}',
              )
            : Text(
                ingredient.needsConfirmation
                    ? l10n.ingredientNeedsConfirmation
                    : l10n.ingredientNutritionUnknown,
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _openRecipeDetailsDialog(Recipe recipe, int index) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Expanded(child: Text(recipe.name)),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined),
                    color: AppPalette.tealDark,
                    tooltip: l10n.editRecipe,
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _openAddRecipeDialog(editIndex: index);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: AppPalette.orangeDeep,
                    tooltip: l10n.deleteRecipe,
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _deleteRecipe(index);
                    },
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (recipe.photoPath != null) ...[
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: Image.file(
                            File(recipe.photoPath!),
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      _StatChip(
                        icon: recipe.mealType.icon,
                        label: recipe.mealType.label(l10n),
                        color: AppPalette.tealDark,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.recipeStatsLine(recipe.calories, recipe.protein, recipe.portions),
                      ),
                      const SizedBox(height: 16),
                      if (recipe.ingredients.isNotEmpty) ...[
                        Text(l10n.ingredients, style: const TextStyle(fontWeight: FontWeight.bold)),
                        ...recipe.ingredients.asMap().entries.map((entry) {
                          final i = entry.key;
                          final ingredient = entry.value;
                          return GestureDetector(
                            onLongPress: () => _showIngredientNutrition(ingredient),
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                ingredient.quantity.isEmpty
                                    ? ingredient.name
                                    : '${ingredient.name} — ${ingredient.quantity}',
                              ),
                              value: recipe.checkedIngredients[i],
                              onChanged: (checked) {
                                setDialogState(() {
                                  recipe.checkedIngredients[i] = checked ?? false;
                                });
                                setState(() {});
                              },
                            ),
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                      if (recipe.description.isNotEmpty) ...[
                        Text(l10n.preparation, style: const TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 4),
                        Text(recipe.description),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.close),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showPrivacyPolicyDialog(BuildContext context, AppLocalizations l10n) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.privacyPolicyTitle),
        content: Text(l10n.privacyPolicyBody),
        actions: [
          TextButton(
            onPressed: () =>
                launchUrl(Uri.parse(privacyPolicyUrl), mode: LaunchMode.externalApplication),
            child: Text(l10n.privacyPolicyViewFull),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.privacyPolicyClose),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recipes = widget.recipes;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.recipesTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            tooltip: l10n.privacyPolicyTitle,
            onPressed: () => _showPrivacyPolicyDialog(context, l10n),
          ),
        ],
      ),
      body: recipes.isEmpty
          ? _EmptyState(
              icon: Icons.restaurant_menu,
              message: l10n.recipesEmpty,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                final isExpanded = _expandedIndexes.contains(index);
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    children: [
                      ListTile(
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Checkbox(
                              value: _selectedIndexes.contains(index),
                              onChanged: (checked) {
                                setState(() {
                                  if (checked ?? false) {
                                    _selectedIndexes.add(index);
                                  } else {
                                    _selectedIndexes.remove(index);
                                  }
                                });
                              },
                            ),
                            if (recipe.photoPath != null)
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  File(recipe.photoPath!),
                                  width: 44,
                                  height: 44,
                                  fit: BoxFit.cover,
                                ),
                              ),
                          ],
                        ),
                        title: Text(
                          recipe.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Wrap(
                            spacing: 8,
                            children: [
                              _StatChip(
                                icon: recipe.mealType.icon,
                                label: recipe.mealType.label(l10n),
                                color: AppPalette.tealDark,
                              ),
                              _StatChip(
                                icon: Icons.local_fire_department,
                                label: l10n.caloriesKcalChip(recipe.calories),
                                color: AppPalette.orangeDeep,
                              ),
                              _StatChip(
                                icon: Icons.fitness_center,
                                label: l10n.proteinGChip(recipe.protein),
                                color: AppPalette.tealDark,
                              ),
                              _StatChip(
                                icon: Icons.people_outline,
                                label: l10n.portionsChip(recipe.portions),
                                color: AppPalette.ink,
                              ),
                            ],
                          ),
                        ),
                        onTap: () => _openRecipeDetailsDialog(recipe, index),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              color: AppPalette.tealDark,
                              tooltip: l10n.editRecipe,
                              onPressed: () => _openAddRecipeDialog(editIndex: index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: AppPalette.orangeDeep,
                              tooltip: l10n.deleteRecipe,
                              onPressed: () => _deleteRecipe(index),
                            ),
                            IconButton(
                              icon: AnimatedRotation(
                                turns: isExpanded ? 0.5 : 0,
                                duration: const Duration(milliseconds: 200),
                                child: const Icon(Icons.keyboard_arrow_down),
                              ),
                              onPressed: () {
                                setState(() {
                                  if (isExpanded) {
                                    _expandedIndexes.remove(index);
                                  } else {
                                    _expandedIndexes.add(index);
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      if (isExpanded) ...[
                        if (recipe.ingredients.isNotEmpty)
                          ...recipe.ingredients.asMap().entries.map((entry) {
                            final i = entry.key;
                            final ingredient = entry.value;
                            return CheckboxListTile(
                              title: Text(
                                ingredient.quantity.isEmpty
                                    ? ingredient.name
                                    : '${ingredient.name} — ${ingredient.quantity}',
                              ),
                              value: recipe.checkedIngredients[i],
                              onChanged: (checked) {
                                setState(() {
                                  recipe.checkedIngredients[i] = checked ?? false;
                                });
                              },
                            );
                          }),
                        if (recipe.description.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(recipe.description),
                            ),
                          ),
                      ],
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddRecipeDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _selectedIndexes.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _addToGroceries,
                        icon: const Icon(Icons.add_shopping_cart),
                        label: Text(l10n.addToGroceriesCount(_selectedIndexes.length)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _generateGroceries,
                        icon: const Icon(Icons.auto_awesome),
                        label: Text(l10n.generateGroceries),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Read-only browse screen for community-contributed recipes. Nutrition is
/// computed on load (not hardcoded) by running each ingredient through the
/// same food-matching + calculation pipeline the add-recipe dialog uses.
class CommunityTab extends ConsumerStatefulWidget {
  const CommunityTab({super.key});

  @override
  ConsumerState<CommunityTab> createState() => _CommunityTabState();
}

class _CommunityTabState extends ConsumerState<CommunityTab> {
  List<Recipe>? _recipes;

  @override
  void initState() {
    super.initState();
    _loadRecipes();
  }

  Future<void> _loadRecipes() async {
    final foodRepository = ref.read(foodRepositoryProvider);
    final matcher = FoodMatcher(foodRepository);
    final computed = <Recipe>[];
    for (final recipe in communityBreakfastRecipes()) {
      computed.add(await _withComputedNutrition(foodRepository, matcher, recipe));
    }
    if (!mounted) return;
    setState(() => _recipes = computed);
  }

  void _showIngredientNutrition(Ingredient ingredient) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(
          ingredient.quantity.isEmpty
              ? ingredient.name
              : '${ingredient.name} (${ingredient.quantity})',
        ),
        content: ingredient.calories != null &&
                ingredient.protein != null &&
                ingredient.carbs != null &&
                ingredient.fat != null &&
                ingredient.fiber != null
            ? Text(
                '${l10n.caloriesKcalChip(ingredient.calories!.round())} • '
                '${l10n.proteinGChip(ingredient.protein!.round())} • '
                '${l10n.carbsGChip(ingredient.carbs!.round())} • '
                '${l10n.fatGChip(ingredient.fat!.round())} • '
                '${l10n.fiberGChip(ingredient.fiber!.round())}',
              )
            : Text(
                ingredient.needsConfirmation
                    ? l10n.ingredientNeedsConfirmation
                    : l10n.ingredientNutritionUnknown,
              ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
        ],
      ),
    );
  }

  void _openRecipeDetailsDialog(Recipe recipe) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(recipe.name),
              content: SizedBox(
                width: 400,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _StatChip(
                        icon: recipe.mealType.icon,
                        label: recipe.mealType.label(l10n),
                        color: AppPalette.tealDark,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        l10n.recipeStatsLine(recipe.calories, recipe.protein, recipe.portions),
                      ),
                      const SizedBox(height: 16),
                      if (recipe.ingredients.isNotEmpty) ...[
                        Text(
                          l10n.ingredients,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        ...recipe.ingredients.asMap().entries.map((entry) {
                          final i = entry.key;
                          final ingredient = entry.value;
                          return GestureDetector(
                            onLongPress: () => _showIngredientNutrition(ingredient),
                            child: CheckboxListTile(
                              contentPadding: EdgeInsets.zero,
                              title: Text(
                                ingredient.quantity.isEmpty
                                    ? ingredient.name
                                    : '${ingredient.name} — ${ingredient.quantity}',
                              ),
                              value: recipe.checkedIngredients[i],
                              onChanged: (checked) {
                                setDialogState(() {
                                  recipe.checkedIngredients[i] = checked ?? false;
                                });
                              },
                            ),
                          );
                        }),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: Text(l10n.close),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final recipes = _recipes;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.communityTitle)),
      body: recipes == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(l10n.communityLoadingNutrition),
                ],
              ),
            )
          : recipes.isEmpty
              ? _EmptyState(icon: Icons.groups_outlined, message: l10n.communityEmpty)
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: ListTile(
                        title: Text(
                          recipe.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Wrap(
                            spacing: 8,
                            children: [
                              _StatChip(
                                icon: recipe.mealType.icon,
                                label: recipe.mealType.label(l10n),
                                color: AppPalette.tealDark,
                              ),
                              _StatChip(
                                icon: Icons.local_fire_department,
                                label: l10n.caloriesKcalChip(recipe.calories),
                                color: AppPalette.orangeDeep,
                              ),
                              _StatChip(
                                icon: Icons.fitness_center,
                                label: l10n.proteinGChip(recipe.protein),
                                color: AppPalette.tealDark,
                              ),
                              _StatChip(
                                icon: Icons.people_outline,
                                label: l10n.portionsChip(recipe.portions),
                                color: AppPalette.ink,
                              ),
                            ],
                          ),
                        ),
                        onTap: () => _openRecipeDetailsDialog(recipe),
                      ),
                    );
                  },
                ),
    );
  }
}

class GroceriesTab extends StatelessWidget {
  const GroceriesTab({
    super.key,
    required this.items,
    required this.onChanged,
    required this.onReset,
  });

  final List<GroceryItem> items;
  final VoidCallback onChanged;
  final VoidCallback onReset;

  Future<void> _confirmReset(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.resetGroceriesConfirmTitle),
        content: Text(l10n.resetGroceriesConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.restart_alt),
            label: Text(l10n.reset),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onReset();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.groceriesTitle),
        actions: items.isEmpty
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.restart_alt),
                  tooltip: l10n.resetGroceries,
                  onPressed: () => _confirmReset(context),
                ),
              ],
      ),
      body: items.isEmpty
          ? _EmptyState(
              icon: Icons.shopping_basket_outlined,
              message: l10n.groceriesEmpty,
            )
          : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: CheckboxListTile(
                    title: Text(
                      item.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        decoration: item.checked ? TextDecoration.lineThrough : null,
                        color: item.checked
                            ? AppPalette.ink.withValues(alpha: 0.4)
                            : AppPalette.ink,
                      ),
                    ),
                    subtitle: item.displayQuantity.isEmpty
                        ? null
                        : Text(
                            item.displayQuantity,
                            style: const TextStyle(color: AppPalette.tealDark),
                          ),
                    value: item.checked,
                    activeColor: AppPalette.tealDark,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (checked) {
                      item.checked = checked ?? false;
                      onChanged();
                    },
                  ),
                );
              },
            ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              color: AppPalette.yellow,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: AppPalette.tealDark),
          ),
          const SizedBox(height: 20),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppPalette.ink,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}
