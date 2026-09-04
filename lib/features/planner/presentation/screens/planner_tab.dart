import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/stat_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../recipes/domain/entities/meal_type.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../domain/entities/meal_plan_entry.dart';
import '../widgets/assigned_meal_card.dart';
import '../widgets/planner_day_sidebar.dart';
import '../widgets/recipe_picker_sheet.dart';
import 'scan_meal_plan_screen.dart';
import 'share_meal_plan_screen.dart';

const _plannerMealTypes = [
  MealType.breakfast,
  MealType.lunch,
  MealType.dinner,
  MealType.snack,
];

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

DateTime _mondayOf(DateTime date) {
  final d = DateTime(date.year, date.month, date.day);
  return d.subtract(Duration(days: d.weekday - 1));
}

class _Totals {
  const _Totals({this.calories = 0, this.protein = 0, this.carbs = 0, this.fat = 0});
  final int calories;
  final int protein;
  final int carbs;
  final int fat;
}

/// Weekly Planner: a vertical day sidebar (left) plus week nav, daily
/// macros, and a 2x2 meal-slot grid (right); "Generate groceries" (scaled
/// ingredients merged into the grocery list) and "Share week" / scan-to-
/// import via QR code.
class PlannerTab extends StatefulWidget {
  const PlannerTab({
    super.key,
    required this.recipes,
    required this.entries,
    required this.onAddEntry,
    required this.onRemoveEntry,
    required this.onAddRecipe,
    required this.onImportMealPlan,
    required this.onGenerateGroceries,
  });

  final List<Recipe> recipes;
  final List<MealPlanEntry> entries;
  final void Function(MealPlanEntry entry) onAddEntry;
  final void Function(String entryId) onRemoveEntry;
  final void Function(Recipe recipe) onAddRecipe;
  final void Function(List<MealPlanEntry> entries, List<Recipe> recipes) onImportMealPlan;
  final void Function(List<MealPlanEntry> weekEntries) onGenerateGroceries;

  @override
  State<PlannerTab> createState() => _PlannerTabState();
}

class _PlannerTabState extends State<PlannerTab> {
  late DateTime _weekStart = _mondayOf(DateTime.now());
  int _selectedDayIndex = DateTime.now().weekday - 1;

  List<DateTime> get _weekDays => List.generate(7, (i) => _weekStart.add(Duration(days: i)));

  List<MealPlanEntry> get _weekEntries {
    final keys = _weekDays.map(_dateKey).toSet();
    return widget.entries.where((e) => keys.contains(e.date)).toList();
  }

  Recipe? _recipeById(String id) {
    for (final recipe in widget.recipes) {
      if (recipe.id == id) return recipe;
    }
    return null;
  }

  _Totals _totalsForDate(String dateKey) {
    var calories = 0, protein = 0, carbs = 0, fat = 0;
    for (final entry in widget.entries.where((e) => e.date == dateKey)) {
      final recipe = _recipeById(entry.recipeId);
      if (recipe == null || recipe.portions <= 0) continue;
      final factor = entry.servings / recipe.portions;
      calories += (recipe.calories * factor).round();
      protein += (recipe.protein * factor).round();
      carbs += ((recipe.carbs ?? 0) * factor).round();
      fat += ((recipe.fat ?? 0) * factor).round();
    }
    return _Totals(calories: calories, protein: protein, carbs: carbs, fat: fat);
  }

  void _shiftWeek(int deltaWeeks) {
    setState(() {
      _weekStart = _weekStart.add(Duration(days: 7 * deltaWeeks));
    });
  }

  /// Shared flow for both "Add meal" and "Replace" — pick a recipe (adding
  /// it to the user's own list first if it came from Community), ask
  /// servings, then add the entry. When [replacing] is given, its slot
  /// (date + mealType) is reused and the old entry is removed on confirm.
  Future<void> _openRecipePickerFlow({required MealType mealType, MealPlanEntry? replacing}) async {
    final l10n = AppLocalizations.of(context)!;
    final recipe = await Navigator.of(context).push<Recipe>(
      MaterialPageRoute(builder: (_) => RecipePickerSheet(myRecipes: widget.recipes)),
    );
    if (recipe == null || !mounted) return;

    // A community recipe isn't in the user's own list yet — add it now so
    // there's a stable id for the plan entry to reference.
    final isOwnRecipe = widget.recipes.any((r) => r.id == recipe.id);
    if (!isOwnRecipe) {
      widget.onAddRecipe(recipe);
    }

    final servingsController = TextEditingController(
      text: (replacing?.servings ?? recipe.portions).toString(),
    );
    final servings = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.plannerServingsDialogTitle),
        content: TextField(
          controller: servingsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(labelText: l10n.plannerServings),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext)
                .pop(int.tryParse(servingsController.text.trim()) ?? recipe.portions),
            child: Text(l10n.add),
          ),
        ],
      ),
    );
    if (servings == null || servings <= 0) return;

    if (replacing != null) {
      widget.onRemoveEntry(replacing.id);
    }
    widget.onAddEntry(MealPlanEntry(
      date: replacing?.date ?? _dateKey(_weekDays[_selectedDayIndex]),
      mealType: mealType,
      recipeId: recipe.id,
      servings: servings,
    ));
  }

  Future<void> _confirmGenerateGroceries() async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.plannerGenerateGroceriesConfirmTitle),
        content: Text(l10n.plannerGenerateGroceriesConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: Text(l10n.generate),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      widget.onGenerateGroceries(_weekEntries);
    }
  }

  Future<void> _openShareWeek() async {
    final weekEntries = _weekEntries;
    final recipeIds = weekEntries.map((e) => e.recipeId).toSet();
    final recipes = widget.recipes.where((r) => recipeIds.contains(r.id)).toList();
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ShareMealPlanScreen(entries: weekEntries, recipes: recipes),
      ),
    );
  }

  Future<void> _openScanImport() async {
    final l10n = AppLocalizations.of(context)!;
    final imported = await Navigator.of(context).push<(List<MealPlanEntry>, List<Recipe>)>(
      MaterialPageRoute(builder: (_) => const ScanMealPlanScreen()),
    );
    if (imported == null || !mounted) return;
    final (entries, recipes) = imported;
    widget.onImportMealPlan(entries, recipes);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.plannerImportSuccess(entries.length))),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final weekDays = _weekDays;
    final today = DateTime.now();

    final caloriesByDay = weekDays.map((d) => _totalsForDate(_dateKey(d)).calories).toList();
    final selectedDateKey = _dateKey(weekDays[_selectedDayIndex]);
    final dayEntries = widget.entries.where((e) => e.date == selectedDateKey).toList();
    final dayTotals = _totalsForDate(selectedDateKey);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.plannerTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            tooltip: l10n.plannerScanTitle,
            onPressed: _openScanImport,
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlannerDaySidebar(
              days: weekDays,
              selectedIndex: _selectedDayIndex,
              caloriesByDay: caloriesByDay,
              today: today,
              onSelect: (index) => setState(() => _selectedDayIndex = index),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          tooltip: l10n.plannerPreviousWeek,
                          onPressed: () => _shiftWeek(-1),
                        ),
                        Expanded(
                          child: Text(
                            l10n.plannerWeekRange(
                              DateFormat.MMMd().format(weekDays.first),
                              DateFormat.MMMd().format(weekDays.last),
                            ),
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.chevron_right),
                          tooltip: l10n.plannerNextWeek,
                          onPressed: () => _shiftWeek(1),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        StatChip(
                          icon: Icons.local_fire_department,
                          label: l10n.caloriesKcalChip(dayTotals.calories),
                          color: colorScheme.secondary,
                        ),
                        StatChip(
                          icon: Icons.bolt,
                          label: l10n.proteinGChip(dayTotals.protein),
                          color: colorScheme.primary,
                        ),
                        StatChip(
                          icon: Icons.grain,
                          label: l10n.carbsGChip(dayTotals.carbs),
                          color: colorScheme.onSurface,
                        ),
                        StatChip(
                          icon: Icons.opacity,
                          label: l10n.fatGChip(dayTotals.fat),
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _weekEntries.isEmpty ? null : _confirmGenerateGroceries,
                            icon: const Icon(Icons.shopping_cart_outlined),
                            label: Text(l10n.plannerGenerateGroceries),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: _weekEntries.isEmpty ? null : _openShareWeek,
                            icon: const Icon(Icons.ios_share),
                            label: Text(l10n.plannerShareWeek),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: GridView.count(
                        crossAxisCount: 2,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 1.05,
                        children: _plannerMealTypes.map((mealType) {
                          final slotEntries =
                              dayEntries.where((e) => e.mealType == mealType).toList();
                          return Card(
                            margin: EdgeInsets.zero,
                            child: Padding(
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(mealType.icon, color: colorScheme.primary, size: 18),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          mealType.label(l10n),
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(fontWeight: FontWeight.w700),
                                        ),
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.add_circle_outline, size: 20),
                                        tooltip: l10n.plannerAddMeal,
                                        visualDensity: VisualDensity.compact,
                                        onPressed: () => _openRecipePickerFlow(mealType: mealType),
                                      ),
                                    ],
                                  ),
                                  Expanded(
                                    child: slotEntries.isEmpty
                                        ? Center(
                                            child: Text(
                                              l10n.plannerEmptySlot,
                                              textAlign: TextAlign.center,
                                              style:
                                                  TextStyle(color: colorScheme.onSurfaceVariant),
                                            ),
                                          )
                                        : ListView(
                                            padding: EdgeInsets.zero,
                                            children: slotEntries.map((entry) {
                                              return AssignedMealCard(
                                                entry: entry,
                                                recipe: _recipeById(entry.recipeId),
                                                onRemove: () => widget.onRemoveEntry(entry.id),
                                                onReplace: () => _openRecipePickerFlow(
                                                  mealType: mealType,
                                                  replacing: entry,
                                                ),
                                              );
                                            }).toList(),
                                          ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
