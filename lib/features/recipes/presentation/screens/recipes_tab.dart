import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/stat_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/ingredient.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_filter.dart';
import '../widgets/recipe_list_tile.dart';
import '../widgets/recipe_photo.dart';
import '../widgets/recipe_search_and_filter_bar.dart';
import '../../../sharing/presentation/screens/scan_recipes_screen.dart';
import '../../../sharing/presentation/screens/share_recipes_screen.dart';

// TODO: Update once the GitHub Pages repo is created and published.
const String privacyPolicyUrl =
    'https://ohammami.github.io/my-food-this-week/privacy-policy.html';

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

  void _shareRecipes() {
    final selectedRecipes = _selectedIndexes.map((i) => widget.recipes[i]).toList();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => ShareRecipesScreen(recipes: selectedRecipes)),
    );
    setState(() {
      _selectedIndexes.clear();
    });
  }

  Future<void> _scanToImport() async {
    final selected = await Navigator.of(context).push<List<Recipe>>(
      MaterialPageRoute(builder: (_) => const ScanRecipesScreen()),
    );
    if (selected == null) return;
    for (final recipe in selected) {
      widget.onAddRecipe(recipe);
    }
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.importRecipesSuccess(selected.length))),
    );
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
    final colorScheme = Theme.of(context).colorScheme;
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
              leading: Icon(Icons.photo_camera_outlined, color: colorScheme.primary),
              title: Text(l10n.takeAPhoto),
              onTap: () => Navigator.of(sheetContext).pop(ImageSource.camera),
            ),
            ListTile(
              leading: Icon(Icons.photo_library_outlined, color: colorScheme.primary),
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
    final colorScheme = Theme.of(context).colorScheme;
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
    // Each ingredient row is a plain name + quantity pair of text fields —
    // there is no more food-database matching or nutrition calculation.
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
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
                              image: photoPath != null
                                  ? DecorationImage(
                                      image: FileImage(File(photoPath!)),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                            child: photoPath == null
                                ? Icon(
                                    Icons.add_a_photo_outlined,
                                    size: 32,
                                    color: colorScheme.primary,
                                  )
                                : Align(
                                    alignment: Alignment.topRight,
                                    child: Padding(
                                      padding: const EdgeInsets.all(4),
                                      child: GestureDetector(
                                        onTap: () => setDialogState(() => photoPath = null),
                                        child: CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.white,
                                          child: Icon(
                                            Icons.close,
                                            size: 16,
                                            color: colorScheme.onSurface,
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
                                Icon(type.icon, size: 18, color: colorScheme.primary),
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
                        final nameFieldController = entry.value;
                        final quantityFieldController = ingredientQuantityControllers[index];
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 3,
                                child: TextField(
                                  controller: nameFieldController,
                                  decoration: InputDecoration(labelText: l10n.ingredientN(index + 1)),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 2,
                                child: TextField(
                                  controller: quantityFieldController,
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
                      final ingredientName = ingredientNameControllers[i].text.trim();
                      if (ingredientName.isEmpty) continue;
                      final quantity = ingredientQuantityControllers[i].text.trim();
                      ingredients.add(Ingredient(name: ingredientName, quantity: quantity));
                    }

                    final recipe = Recipe(
                      id: existing?.id,
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

  void _openRecipeDetailsDialog(Recipe recipe, int index) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
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
                    color: colorScheme.primary,
                    tooltip: l10n.editRecipe,
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                      _openAddRecipeDialog(editIndex: index);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    color: colorScheme.secondary,
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
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: RecipePhoto(
                          path: recipe.photoPath,
                          width: double.infinity,
                          height: 180,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(height: 16),
                      StatChip(
                        icon: recipe.mealType.icon,
                        label: recipe.mealType.label(l10n),
                        color: colorScheme.primary,
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
    final colorScheme = Theme.of(context).colorScheme;
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
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: l10n.scanRecipesTitle,
            onPressed: _scanToImport,
          ),
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
            RecipeSearchAndFilterBar(
              searchController: _searchController,
              searchQuery: _searchQuery,
              onSearchChanged: (value) => setState(() => _searchQuery = value),
              onSearchCleared: () => setState(() {
                _searchController.clear();
                _searchQuery = '';
              }),
              filter: _filter,
              filtersExpanded: _filtersExpanded,
              onFiltersExpandedChanged: (value) => setState(() => _filtersExpanded = value),
              onFilterApply: (updated) => setState(() => _filter = updated),
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
                      RecipeListTile(
                        recipe: recipe,
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
                        onTap: () => _openRecipeDetailsDialog(recipe, index),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit_outlined),
                              color: colorScheme.primary,
                              tooltip: l10n.editRecipe,
                              onPressed: () => _openAddRecipeDialog(editIndex: index),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              color: colorScheme.secondary,
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
        heroTag: 'recipesTabFab',
        onPressed: _openAddRecipeDialog,
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: _selectedIndexes.isEmpty
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
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
                    const SizedBox(height: 8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: _shareRecipes,
                        icon: const Icon(Icons.ios_share),
                        label: Text(l10n.shareRecipesCount(_selectedIndexes.length)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
