import 'package:flutter/material.dart';

/// High-impact call to action: terracotta pill, bold white label, generous
/// padding. Use for the one primary action on a screen (e.g. "Ajouter au
/// planning", "Générer la liste de courses", "Enregistrer la recette").
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final child = icon == null
        ? Text(label)
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Text(label),
            ],
          );

    final button = FilledButton(onPressed: onPressed, child: child);
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}
