import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/grocery_item.dart';

class GroceriesTab extends StatelessWidget {
  const GroceriesTab({
    super.key,
    required this.items,
    required this.onChanged,
    required this.onReset,
  });

  final List<GroceryItem> items;
  final VoidCallback onChanged;
  final VoidCallback onReset;

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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.groceriesTitle),
        actions: items.isEmpty
            ? null
            : [
                IconButton(
                  icon: const Icon(Icons.restart_alt),
                  tooltip: l10n.resetGroceries,
                  onPressed: () => _confirmReset(context),
                ),
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
                            ? AppPalette.ink.withValues(alpha: 0.4)
                            : AppPalette.ink,
                      ),
                    ),
                    subtitle: item.displayQuantity.isEmpty
                        ? null
                        : Text(
                            item.displayQuantity,
                            style: const TextStyle(color: AppPalette.tealDark),
                          ),
                    value: item.checked,
                    activeColor: AppPalette.tealDark,
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (checked) {
                      item.checked = checked ?? false;
                      onChanged();
                    },
                  ),
                );
              },
            ),
    );
  }
}
