import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../l10n/app_localizations.dart';

/// Vertical day-of-week selector for the planner's left sidebar — one tile
/// per day of the active week, each showing the day name, date number, and
/// a small badge with that day's total calories.
class PlannerDaySidebar extends StatelessWidget {
  const PlannerDaySidebar({
    super.key,
    required this.days,
    required this.selectedIndex,
    required this.caloriesByDay,
    required this.today,
    required this.onSelect,
  });

  final List<DateTime> days;
  final int selectedIndex;
  final List<int> caloriesByDay;
  final DateTime today;
  final ValueChanged<int> onSelect;

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    // Deep Plum — deliberately a literal brand color (not colorScheme.primary)
    // per the design spec, so the selected-day highlight stays this exact
    // hue regardless of theme.
    const selectedColor = Color(0xFF5C203A);

    return Container(
      width: 84,
      color: colorScheme.surface,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        itemCount: days.length,
        itemBuilder: (context, index) {
          final day = days[index];
          final isSelected = index == selectedIndex;
          final isToday = _isSameDay(day, today);
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Material(
              color: isSelected ? selectedColor : colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => onSelect(index),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border: isToday && !isSelected
                        ? Border.all(color: selectedColor, width: 1.5)
                        : null,
                  ),
                  child: Column(
                    children: [
                      Text(
                        DateFormat.E().format(day),
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isSelected ? Colors.white : colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${day.day}',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: isSelected ? Colors.white : colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.white.withValues(alpha: 0.18)
                              : colorScheme.secondaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          l10n.caloriesKcalChip(caloriesByDay[index]),
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? Colors.white : colorScheme.onSecondaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
