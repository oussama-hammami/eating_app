import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'core/database/app_database.dart';
import 'core/database/database_provider.dart';
import 'features/meal_log/presentation/screens/food_diary_screen.dart';
import 'features/nutrition/presentation/widgets/ingredient_food_field.dart';

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
      title: 'Eating App',
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
  Ingredient({required this.name, required this.quantity});

  final String name;
  final String quantity;
}

class Recipe {
  Recipe({
    required this.name,
    required this.calories,
    required this.protein,
    required this.portions,
    required this.ingredients,
    required this.description,
    this.photoPath,
  }) : checkedIngredients = List.filled(ingredients.length, false);

  final String name;
  final int calories;
  final int protein;
  final int portions;
  final List<Ingredient> ingredients;
  final String description;
  final String? photoPath;
  final List<bool> checkedIngredients;
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
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (index) => setState(() => _tabIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.restaurant_menu), label: 'Recipes'),
          NavigationDestination(icon: Icon(Icons.shopping_cart), label: 'Groceries'),
          NavigationDestination(icon: Icon(Icons.local_dining), label: 'Diary'),
        ],
      ),
    );
  }
}

class RecipesTab extends StatefulWidget {
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
  State<RecipesTab> createState() => _RecipesTabState();
}

class _RecipesTabState extends State<RecipesTab> {
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Generate groceries?'),
        content: const Text(
          'This will replace the current grocery list with a fresh one built only from the selected meals.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.auto_awesome),
            label: const Text('Generate'),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete recipe?'),
        content: Text('This will remove "${widget.recipes[index].name}" permanently.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete'),
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
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined, color: AppPalette.tealDark),
              title: const Text('Choose from library'),
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
    final existing = editIndex != null ? widget.recipes[editIndex] : null;
    final nameController = TextEditingController(text: existing?.name ?? '');
    final caloriesController =
        TextEditingController(text: existing != null ? existing.calories.toString() : '');
    final proteinController =
        TextEditingController(text: existing != null ? existing.protein.toString() : '');
    final portionsController =
        TextEditingController(text: existing != null ? existing.portions.toString() : '');
    final descriptionController = TextEditingController(text: existing?.description ?? '');
    String? photoPath = existing?.photoPath;
    final ingredientNameControllers = existing != null && existing.ingredients.isNotEmpty
        ? existing.ingredients.map((i) => TextEditingController(text: i.name)).toList()
        : <TextEditingController>[TextEditingController()];
    final ingredientQuantityControllers = existing != null && existing.ingredients.isNotEmpty
        ? existing.ingredients.map((i) => TextEditingController(text: i.quantity)).toList()
        : <TextEditingController>[TextEditingController()];

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            return AlertDialog(
              title: Text(existing != null ? 'Edit Recipe' : 'Add Recipe'),
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
                        decoration: const InputDecoration(labelText: 'Meal name'),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: caloriesController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(labelText: 'Calories (kcal)'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextField(
                              controller: proteinController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                              decoration: const InputDecoration(labelText: 'Protein (g)'),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: portionsController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        decoration: const InputDecoration(labelText: 'Portions'),
                      ),
                      const SizedBox(height: 16),
                      const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold)),
                      ...ingredientNameControllers.asMap().entries.map((entry) {
                        final index = entry.key;
                        final nameController = entry.value;
                        final quantityController = ingredientQuantityControllers[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Expanded(
                                flex: 2,
                                child: IngredientFoodField(
                                  controller: nameController,
                                  label: 'Ingredient ${index + 1}',
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextField(
                                  controller: quantityController,
                                  decoration: const InputDecoration(labelText: 'Quantity'),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                onPressed: ingredientNameControllers.length > 1
                                    ? () {
                                        setDialogState(() {
                                          ingredientNameControllers.removeAt(index);
                                          ingredientQuantityControllers.removeAt(index);
                                        });
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
                              ingredientQuantityControllers.add(TextEditingController());
                            });
                          },
                          icon: const Icon(Icons.add),
                          label: const Text('Add ingredient'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: descriptionController,
                        maxLines: 4,
                        decoration: const InputDecoration(
                          labelText: 'Preparation description',
                          alignLabelWithHint: true,
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(dialogContext).pop(),
                  child: const Text('Cancel'),
                ),
                FilledButton.icon(
                  onPressed: () {
                    final name = nameController.text.trim();
                    if (name.isEmpty) return;

                    final ingredients = <Ingredient>[];
                    for (var i = 0; i < ingredientNameControllers.length; i++) {
                      final ingredientName = ingredientNameControllers[i].text.trim();
                      if (ingredientName.isEmpty) continue;
                      ingredients.add(
                        Ingredient(
                          name: ingredientName,
                          quantity: ingredientQuantityControllers[i].text.trim(),
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
                  label: Text(editIndex != null ? 'Save' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _openRecipeDetailsDialog(Recipe recipe, int index) {
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
                    tooltip: 'Edit recipe',
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _openAddRecipeDialog(editIndex: index);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: AppPalette.orangeDeep,
                    tooltip: 'Delete recipe',
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
                      Text(
                        '${recipe.calories} kcal • ${recipe.protein} g protein • ${recipe.portions} portion(s)',
                      ),
                      const SizedBox(height: 16),
                      if (recipe.ingredients.isNotEmpty) ...[
                        const Text('Ingredients', style: TextStyle(fontWeight: FontWeight.bold)),
                        ...recipe.ingredients.asMap().entries.map((entry) {
                          final i = entry.key;
                          final ingredient = entry.value;
                          return CheckboxListTile(
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
                          );
                        }),
                        const SizedBox(height: 16),
                      ],
                      if (recipe.description.isNotEmpty) ...[
                        const Text('Preparation', style: TextStyle(fontWeight: FontWeight.bold)),
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
                  child: const Text('Close'),
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
    final recipes = widget.recipes;
    return Scaffold(
      appBar: AppBar(title: const Text('🍽️  My Recipes')),
      body: recipes.isEmpty
          ? const _EmptyState(
              icon: Icons.restaurant_menu,
              message: 'No recipes yet.\nTap + to add one.',
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
                                icon: Icons.local_fire_department,
                                label: '${recipe.calories} kcal',
                                color: AppPalette.orangeDeep,
                              ),
                              _StatChip(
                                icon: Icons.fitness_center,
                                label: '${recipe.protein} g protein',
                                color: AppPalette.tealDark,
                              ),
                              _StatChip(
                                icon: Icons.people_outline,
                                label: '${recipe.portions} portion(s)',
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
                              tooltip: 'Edit recipe',
                              onPressed: () => _openAddRecipeDialog(editIndex: index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: AppPalette.orangeDeep,
                              tooltip: 'Delete recipe',
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
                        label: Text('Add to groceries (${_selectedIndexes.length})'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: _generateGroceries,
                        icon: const Icon(Icons.auto_awesome),
                        label: const Text('Generate groceries'),
                      ),
                    ),
                  ],
                ),
              ),
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
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reset groceries?'),
        content: const Text(
          'This clears the grocery list and unselects all meals in Recipes.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.restart_alt),
            label: const Text('Reset'),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('🛒  Groceries'),
        actions: items.isEmpty
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.restart_alt),
                  tooltip: 'Reset groceries',
                  onPressed: () => _confirmReset(context),
                ),
              ],
      ),
      body: items.isEmpty
          ? const _EmptyState(
              icon: Icons.shopping_basket_outlined,
              message: 'No groceries yet.\nSelect meals in Recipes and generate a list.',
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
