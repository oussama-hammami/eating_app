import 'package:flutter/material.dart';

import '../../../../core/widgets/stat_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/recipe.dart';

/// A recipe's row content — name plus its meal-type/calories/protein/portion
/// stat chips — shared by every screen that lists recipes (Recipes tab,
/// Community tab, the planner's recipe picker). Callers wrap it in a [Card]
/// themselves so screens that need extra per-tile content (e.g. an
/// expandable ingredients section) can share that Card with it.
class RecipeListTile extends StatelessWidget {
  const RecipeListTile({
    super.key,
    required this.recipe,
    this.leading,
    this.trailing,
    this.showProtein = true,
    this.onTap,
  });

  final Recipe recipe;
  final Widget? leading;
  final Widget? trailing;

  /// Whether to show the protein stat chip — omitted where space is tight
  /// (e.g. the planner's recipe picker).
  final bool showProtein;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: leading,
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
            if (showProtein)
              StatChip(
                icon: Icons.fitness_center,
                label: l10n.proteinGChip(recipe.protein),
                color: const Color(0xFF2A835F),
              ),
            StatChip(
              icon: Icons.people_outline,
              label: l10n.portionsChip(recipe.portions),
              color: const Color(0xFF92003A),
            ),
          ],
        ),
      ),
      onTap: onTap,
      trailing: trailing,
    );
  }
}
