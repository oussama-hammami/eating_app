import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../domain/meal_plan_share_codec.dart';

/// Preview of a scanned week — one row per day/meal-slot/recipe — before the
/// user confirms merging it (and any recipes it references) into their own
/// local planner and recipe list. Pops with the decoded plan, or null if
/// cancelled.
class ImportMealPlanScreen extends StatelessWidget {
  const ImportMealPlanScreen({super.key, required this.plan});

  final DecodedMealPlan plan;

  Recipe? _recipeById(String id) {
    for (final recipe in plan.recipes) {
      if (recipe.id == id) return recipe;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sortedEntries = [...plan.entries]..sort((a, b) => a.date.compareTo(b.date));

    return Scaffold(
      appBar: AppBar(title: Text(l10n.plannerImportTitle)),
      body: SafeArea(
        child: sortedEntries.isEmpty
            ? const Center(child: Text('—'))
            : ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: sortedEntries.length,
                itemBuilder: (context, index) {
                  final entry = sortedEntries[index];
                  final recipe = _recipeById(entry.recipeId);
                  final date = DateTime.tryParse(entry.date);
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(entry.mealType.icon),
                      title: Text(recipe?.name ?? entry.recipeId),
                      subtitle: Text(
                        '${date == null ? entry.date : DateFormat.yMMMEd().format(date)} • '
                        '${entry.mealType.label(l10n)} • ${l10n.portionsChip(entry.servings)}',
                      ),
                    ),
                  );
                },
              ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: FilledButton.icon(
            onPressed: sortedEntries.isEmpty
                ? null
                : () => Navigator.of(context).pop(plan),
            icon: const Icon(Icons.playlist_add),
            label: Text(l10n.plannerImportConfirmButton(sortedEntries.length)),
          ),
        ),
      ),
    );
  }
}
