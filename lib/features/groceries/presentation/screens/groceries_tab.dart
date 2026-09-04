import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../domain/entities/grocery_item.dart';
import 'groceries_source_recipes_screen.dart';

class GroceriesTab extends StatelessWidget {
  const GroceriesTab({
    super.key,
    required this.items,
    required this.onChanged,
    required this.onReset,
    required this.onAddItem,
    required this.sourceRecipes,
  });

  final List<GroceryItem> items;
  final VoidCallback onChanged;
  final VoidCallback onReset;
  final void Function(String name, String quantity) onAddItem;

  /// Recipes whose ingredients contributed to [items] — shown via the
  /// "Recipes" app bar button.
  final List<Recipe> sourceRecipes;

  Future<void> _confirmReset(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.resetGroceriesConfirmTitle),
        content: Text(l10n.resetGroceriesConfirmMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: Text(l10n.cancel),
          ),
          FilledButton.icon(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            icon: const Icon(Icons.restart_alt),
            label: Text(l10n.reset),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      onReset();
    }
  }

  Future<void> _openAddArticleDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();
    final quantityController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(l10n.addArticleTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: l10n.articleNameLabel),
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: quantityController,
              decoration: InputDecoration(labelText: l10n.articleQuantityLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              onAddItem(name, quantityController.text.trim());
              Navigator.of(dialogContext).pop();
            },
            child: Text(l10n.add),
          ),
        ],
      ),
    );
  }

  void _openSourceRecipes(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GroceriesSourceRecipesScreen(recipes: sourceRecipes),
      ),
    );
  }

  void _shareList(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final text = items.map((item) {
      final prefix = item.checked ? '[x] ' : '[ ] ';
      final quantity = item.displayQuantity;
      return quantity.isEmpty ? '$prefix${item.name}' : '$prefix${item.name} — $quantity';
    }).join('\n');
    Share.share(text, subject: l10n.shareGroceriesTitle);
  }

  Widget _actionButton(
    BuildContext context, {
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        border: Border.all(color: colorScheme.outlineVariant, width: 1.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: IconButton(
        icon: Icon(icon),
        tooltip: tooltip,
        onPressed: onPressed,
        visualDensity: VisualDensity.compact,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.groceriesTitle),
        actions: items.isEmpty
            ? null
            : [
                if (sourceRecipes.isNotEmpty)
                  _actionButton(
                    context,
                    icon: Icons.restaurant_menu,
                    tooltip: l10n.groceriesRecipes,
                    onPressed: () => _openSourceRecipes(context),
                  ),
                _actionButton(
                  context,
                  icon: Icons.ios_share,
                  tooltip: l10n.shareGroceries,
                  onPressed: () => _shareList(context),
                ),
                _actionButton(
                  context,
                  icon: Icons.restart_alt,
                  tooltip: l10n.resetGroceries,
                  onPressed: () => _confirmReset(context),
                ),
                const SizedBox(width: 8),
              ],
      ),
      body: items.isEmpty
          ? EmptyState(
              icon: Icons.shopping_basket_outlined,
              message: l10n.groceriesEmpty,
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
                            ? colorScheme.onSurfaceVariant
                            : colorScheme.onSurface,
                      ),
                    ),
                    subtitle: item.displayQuantity.isEmpty
                        ? null
                        : Text(
                            item.displayQuantity,
                            style: TextStyle(color: colorScheme.primary),
                          ),
                    value: item.checked,
                    activeColor: colorScheme.primary,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (checked) {
                      item.checked = checked ?? false;
                      onChanged();
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openAddArticleDialog(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.addArticle),
      ),
    );
  }
}
