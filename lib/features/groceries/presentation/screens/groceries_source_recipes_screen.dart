import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../../recipes/presentation/widgets/recipe_photo.dart';

/// Read-only list of the recipes whose ingredients contributed to the
/// current grocery list — name, photo, and portions only.
class GroceriesSourceRecipesScreen extends StatelessWidget {
  const GroceriesSourceRecipesScreen({super.key, required this.recipes});

  final List<Recipe> recipes;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.groceriesRecipesTitle)),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipes[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: RecipePhoto(
                    path: recipe.photoPath,
                    width: 48,
                    height: 48,
                    fit: BoxFit.cover,
                  ),
                ),
                title: Text(recipe.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                subtitle: Text(l10n.portionsChip(recipe.portions)),
              ),
            );
          },
        ),
      ),
    );
  }
}
