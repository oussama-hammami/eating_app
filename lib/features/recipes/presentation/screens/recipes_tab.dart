import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/units/ingredient_text_parser.dart';
import '../../../../core/units/legacy_quantity_parser.dart';
import '../../../../core/units/unit.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/stat_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../nutrition/presentation/widgets/unit_label.dart';
import '../../../nutrition/domain/entities/food.dart';
import '../../../nutrition/domain/usecases/nutrition_calculator.dart';
import '../../../nutrition/presentation/providers/food_search_provider.dart';
import '../../../nutrition/presentation/widgets/ingredient_food_field.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_filter.dart';
import '../widgets/recipe_filter_panel.dart';
import '../widgets/recipe_photo.dart';

// TODO: Update once the GitHub Pages repo is created and published.
const String privacyPolicyUrl =
    'https://ohammami.github.io/my-food-this-week/privacy-policy.html';

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
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  RecipeFilter _filter = const RecipeFilter();
  bool _filtersExpanded = false;

  @override
  void didUpdateWidget(covariant RecipesTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.groceryResetSignal != widget.groceryResetSignal) {
      setState(() {
        _selectedIndexes.clear();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int _activeFilterCount() {
    var count = 0;
    if (_filter.calories.isActive) count++;
    if (_filter.protein.isActive) count++;
    if (_filter.carbs.isActive) count++;
    if (_filter.fat.isActive) count++;
    if (_filter.fiber.isActive) count++;
    if (_filter.mealTypes.isNotEmpty) count++;
    if (_filter.includeIngredients.isNotEmpty) count++;
    if (_filter.excludeIngredients.isNotEmpty) count++;
    return count;
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
            final (amountText, unit) = parseLegacyQuantity(i.quantity);
            final prefix = amountText.isEmpty ? '' : '$amountText ${unitLabel(l10n, unit)} ';
            return TextEditingController(text: '$prefix${i.name}');
          }).toList()
        : <TextEditingController>[TextEditingController()];
    final ingredientAmounts = existing != null && existing.ingredients.isNotEmpty
        ? existing.ingredients
            .map((i) => double.tryParse(parseLegacyQuantity(i.quantity).$1))
            .toList()
        : <double?>[null];
    final ingredientUnits = existing != null && existing.ingredients.isNotEmpty
        ? existing.ingredients.map((i) => parseLegacyQuantity(i.quantity).$2).toList()
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
                          child: RecipePhoto(
                            path: recipe.photoPath!,
                            width: double.infinity,
                            height: 180,
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      StatChip(
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
    final query = _searchQuery.trim().toLowerCase();
    final filtered = [
      for (final entry in recipes.asMap().entries)
        if ((query.isEmpty || entry.value.name.toLowerCase().contains(query)) &&
            recipeMatchesFilter(entry.value, _filter))
          entry,
    ];
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
      body: Column(
        children: [
          if (recipes.isNotEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: InputDecoration(
                        hintText: l10n.searchRecipesHint,
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isEmpty
                            ? null
                            : IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () => setState(() {
                                  _searchController.clear();
                                  _searchQuery = '';
                                }),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(
                      _filter.isActive
                          ? l10n.filtersActiveButton(_activeFilterCount())
                          : l10n.filtersButton,
                    ),
                    avatar: const Icon(Icons.filter_alt_outlined, size: 18),
                    selected: _filtersExpanded,
                    onSelected: (value) => setState(() => _filtersExpanded = value),
                  ),
                ],
              ),
            ),
          if (_filtersExpanded)
            RecipeFilterPanel(
              filter: _filter,
              onApply: (updated) => setState(() => _filter = updated),
            ),
          Expanded(
            child: recipes.isEmpty
                ? EmptyState(
                    icon: Icons.restaurant_menu,
                    message: l10n.recipesEmpty,
                  )
                : filtered.isEmpty
                    ? EmptyState(
                        icon: Icons.search_off,
                        message: l10n.recipesSearchEmpty,
                      )
                    : ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: filtered.length,
              itemBuilder: (context, position) {
                final index = filtered[position].key;
                final recipe = filtered[position].value;
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
                                child: RecipePhoto(
                                  path: recipe.photoPath!,
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
                              StatChip(
                                icon: recipe.mealType.icon,
                                label: recipe.mealType.label(l10n),
                                color: AppPalette.tealDark,
                              ),
                              StatChip(
                                icon: Icons.local_fire_department,
                                label: l10n.caloriesKcalChip(recipe.calories),
                                color: AppPalette.orangeDeep,
                              ),
                              StatChip(
                                icon: Icons.fitness_center,
                                label: l10n.proteinGChip(recipe.protein),
                                color: AppPalette.tealDark,
                              ),
                              StatChip(
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
          ),
        ],
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
