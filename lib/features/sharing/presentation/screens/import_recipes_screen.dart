import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/stat_chip.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../recipes/domain/entities/recipe.dart';

/// Lets the user pick which of the decoded [recipes] to add to their own
/// list. Pops with the selected recipes, or null if cancelled.
class ImportRecipesScreen extends StatefulWidget {
  const ImportRecipesScreen({super.key, required this.recipes});

  final List<Recipe> recipes;

  @override
  State<ImportRecipesScreen> createState() => _ImportRecipesScreenState();
}

class _ImportRecipesScreenState extends State<ImportRecipesScreen> {
  late final Set<int> _selected = {for (var i = 0; i < widget.recipes.length; i++) i};

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.importRecipesTitle)),
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: widget.recipes.length,
          itemBuilder: (context, index) {
            final recipe = widget.recipes[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 6),
              child: CheckboxListTile(
                value: _selected.contains(index),
                onChanged: (checked) {
                  setState(() {
                    if (checked ?? false) {
                      _selected.add(index);
                    } else {
                      _selected.remove(index);
                    }
                  });
                },
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
                        label: '${recipe.calories}',
                        color: AppPalette.calories,
                      ),
                      StatChip(
                        icon: Icons.people_outline,
                        label: '${recipe.portions}',
                        color: const Color(0xFF92003A),
                      ),
                    ],
                  ),
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
            onPressed: _selected.isEmpty
                ? null
                : () => Navigator.of(context)
                    .pop(_selected.map((i) => widget.recipes[i]).toList()),
            icon: const Icon(Icons.playlist_add),
            label: Text(l10n.importRecipesAddButton(_selected.length)),
          ),
        ),
      ),
    );
  }
}
