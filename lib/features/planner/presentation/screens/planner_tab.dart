import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/stat_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../widgets/common/primary_button.dart';
import '../../../recipes/domain/entities/meal_type.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../domain/entities/meal_plan_entry.dart';
import '../../domain/usecases/build_weekly_plan_pdf.dart';
import '../widgets/meal_slot_section.dart';
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
      MaterialPageRoute(
        builder: (_) => RecipePickerSheet(myRecipes: widget.recipes, mealType: mealType),
      ),
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

  /// Nudges an entry's servings by [delta], keeping its id (and slot) so the
  /// change is an in-place update rather than a brand new entry.
  void _adjustServings(MealPlanEntry entry, int delta) {
    final newServings = entry.servings + delta;
    if (newServings <= 0) return;
    widget.onRemoveEntry(entry.id);
    widget.onAddEntry(MealPlanEntry(
      id: entry.id,
      date: entry.date,
      mealType: entry.mealType,
      recipeId: entry.recipeId,
      servings: newServings,
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

  Future<void> _exportWeekPdf() async {
    final l10n = AppLocalizations.of(context)!;
    final weekDays = _weekDays;
    final bytes = await buildWeeklyPlanPdf(
      weekDays: weekDays,
      weekEntries: _weekEntries,
      recipes: widget.recipes,
      title: l10n.plannerExportPdfTitle(
        DateFormat.MMMd().format(weekDays.first),
        DateFormat.MMMd().format(weekDays.last),
      ),
      mealTypeLabel: (mealType) => mealType.label(l10n),
      noMealsLabel: l10n.plannerExportPdfNoMeals,
    );
    await Printing.layoutPdf(onLayout: (_) async => bytes);
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
    final weekIsEmpty = _weekEntries.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.plannerTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            tooltip: l10n.plannerShareWeek,
            onPressed: weekIsEmpty ? null : _openShareWeek,
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            tooltip: l10n.plannerExportPdf,
            onPressed: weekIsEmpty ? null : _exportWeekPdf,
          ),
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
                    padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.chevron_left),
                          tooltip: l10n.plannerPreviousWeek,
                          visualDensity: VisualDensity.compact,
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
                          visualDensity: VisualDensity.compact,
                          onPressed: () => _shiftWeek(1),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                    child: Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        StatChip(
                          icon: Icons.local_fire_department,
                          label: '${dayTotals.calories}',
                          color: AppPalette.calories,
                        ),
                        StatChip(
                          icon: Icons.bolt,
                          label: '${dayTotals.protein}',
                          color: const Color(0xFF2A835F),
                        ),
                        StatChip(
                          icon: Icons.grain,
                          label: '${dayTotals.carbs}',
                          color: colorScheme.onSurface,
                        ),
                        StatChip(
                          icon: Icons.opacity,
                          label: '${dayTotals.fat}',
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.all(12),
                      children: _plannerMealTypes.map((mealType) {
                        final slotEntries =
                            dayEntries.where((e) => e.mealType == mealType).toList();
                        return MealSlotSection(
                          mealType: mealType,
                          entries: slotEntries,
                          recipeById: _recipeById,
                          onAdd: () => _openRecipePickerFlow(mealType: mealType),
                          onRemove: (entry) => widget.onRemoveEntry(entry.id),
                          onReplace: (entry) =>
                              _openRecipePickerFlow(mealType: mealType, replacing: entry),
                          onAdjustServings: _adjustServings,
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: const [
            BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, -2)),
          ],
        ),
        child: SafeArea(
          minimum: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          top: false,
          child: PrimaryButton(
            label: l10n.plannerGenerateGroceries,
            icon: Icons.shopping_cart_outlined,
            onPressed: weekIsEmpty ? null : _confirmGenerateGroceries,
          ),
        ),
      ),
    );
  }
}
