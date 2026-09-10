import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../recipes/domain/entities/meal_type.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../../domain/entities/meal_plan_entry.dart';
import 'assigned_meal_card.dart';

/// One meal slot (Breakfast/Lunch/Dinner/Snack) for the selected day —
/// shrink-wraps to its content instead of stretching to fill space: a
/// single dashed "+ Add {meal}" button when empty, or a compact header plus
/// one [AssignedMealCard] per assigned recipe.
class MealSlotSection extends StatelessWidget {
  const MealSlotSection({
    super.key,
    required this.mealType,
    required this.entries,
    required this.recipeById,
    required this.onAdd,
    required this.onRemove,
    required this.onReplace,
    required this.onAdjustServings,
  });

  final MealType mealType;
  final List<MealPlanEntry> entries;
  final Recipe? Function(String recipeId) recipeById;
  final VoidCallback onAdd;
  final void Function(MealPlanEntry entry) onRemove;
  final void Function(MealPlanEntry entry) onReplace;
  final void Function(MealPlanEntry entry, int delta) onAdjustServings;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (entries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: _DashedAddButton(
          label: '+ ${l10n.add} ${mealType.label(l10n)}',
          onTap: onAdd,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 2),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppPalette.mealType,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(mealType.icon, size: 14, color: AppPalette.onMealType),
                      const SizedBox(width: 6),
                      Text(
                        mealType.label(l10n),
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: AppPalette.onMealType,
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline, size: 18),
                  tooltip: l10n.plannerAddMeal,
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 28, minHeight: 28),
                  onPressed: onAdd,
                ),
              ],
            ),
          ),
          ...entries.map((entry) {
            return AssignedMealCard(
              entry: entry,
              recipe: recipeById(entry.recipeId),
              onRemove: () => onRemove(entry),
              onReplace: () => onReplace(entry),
              onAdjustServings: (delta) => onAdjustServings(entry, delta),
            );
          }),
        ],
      ),
    );
  }
}

class _DashedAddButton extends StatelessWidget {
  const _DashedAddButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: CustomPaint(
          painter: _DashedRRectPainter(color: colorScheme.outline),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
            alignment: Alignment.center,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: colorScheme.primary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DashedRRectPainter extends CustomPainter {
  const _DashedRRectPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    final path = Path()
      ..addRRect(RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(12)));

    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final dashedPath = Path();
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        dashedPath.addPath(metric.extractPath(distance, next.clamp(0, metric.length)), Offset.zero);
        distance = next + dashSpace;
      }
    }
    canvas.drawPath(dashedPath, paint);
  }

  @override
  bool shouldRepaint(covariant _DashedRRectPainter oldDelegate) => oldDelegate.color != color;
}
