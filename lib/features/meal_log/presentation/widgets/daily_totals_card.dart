import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/daily_totals.dart';

class DailyTotalsCard extends StatelessWidget {
  const DailyTotalsCard({super.key, required this.totals});

  final DailyTotals totals;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _Stat(label: l10n.statCalories, value: totals.calories.round().toString()),
            ),
            Expanded(
              child: _Stat(label: l10n.statProtein, value: '${totals.protein.toStringAsFixed(1)}g'),
            ),
            Expanded(
              child: _Stat(label: l10n.statCarbs, value: '${totals.carbs.toStringAsFixed(1)}g'),
            ),
            Expanded(
              child: _Stat(label: l10n.statFat, value: '${totals.fat.toStringAsFixed(1)}g'),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium,
          overflow: TextOverflow.ellipsis,
        ),
        Text(label, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }
}
