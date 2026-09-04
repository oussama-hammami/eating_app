import 'package:flutter/material.dart';

import '../../../../core/widgets/stat_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../recipes/data/community_recipes_remote_data_source.dart';
import '../../../recipes/domain/entities/recipe.dart';

/// Full-screen recipe picker for the planner's "Add meal" flow — "My
/// recipes" plus a lazily-fetched "Community" section. Pops with the chosen
/// [Recipe], or null if cancelled.
class RecipePickerSheet extends StatefulWidget {
  const RecipePickerSheet({super.key, required this.myRecipes});

  final List<Recipe> myRecipes;

  @override
  State<RecipePickerSheet> createState() => _RecipePickerSheetState();
}

class _RecipePickerSheetState extends State<RecipePickerSheet> {
  late final Future<List<Recipe>> _communityFuture = fetchCommunityRecipes();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    Widget recipeTile(Recipe recipe) => Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 8,
                children: [
                  StatChip(
                    icon: recipe.mealType.icon,
                    label: recipe.mealType.label(l10n),
                    color: colorScheme.primary,
                  ),
                  StatChip(
                    icon: Icons.local_fire_department,
                    label: l10n.caloriesKcalChip(recipe.calories),
                    color: colorScheme.secondary,
                  ),
                  StatChip(
                    icon: Icons.people_outline,
                    label: l10n.portionsChip(recipe.portions),
                    color: const Color(0xFF92003A),
                  ),
                ],
              ),
            ),
            onTap: () => Navigator.of(context).pop(recipe),
          ),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.plannerPickRecipeTitle)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Text(
              l10n.plannerMyRecipesSection,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            if (widget.myRecipes.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(l10n.recipesEmpty, style: TextStyle(color: colorScheme.onSurfaceVariant)),
              )
            else
              ...widget.myRecipes.map(recipeTile),
            const SizedBox(height: 20),
            Text(
              l10n.plannerCommunitySection,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
            ),
            FutureBuilder<List<Recipe>>(
              future: _communityFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError || snapshot.data == null || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      l10n.plannerCommunityUnavailable,
                      style: TextStyle(color: colorScheme.onSurfaceVariant),
                    ),
                  );
                }
                return Column(children: snapshot.data!.map(recipeTile).toList());
              },
            ),
          ],
        ),
      ),
    );
  }
}
