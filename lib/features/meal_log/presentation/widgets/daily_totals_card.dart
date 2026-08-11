import 'package:flutter/material.dart';

import '../../domain/entities/daily_totals.dart';

class DailyTotalsCard extends StatelessWidget {
  const DailyTotalsCard({super.key, required this.totals});

  final DailyTotals totals;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: _Stat(label: 'Calories', value: totals.calories.round().toString()),
            ),
            Expanded(
              child: _Stat(label: 'Protein', value: '${totals.protein.toStringAsFixed(1)}g'),
            ),
            Expanded(
              child: _Stat(label: 'Carbs', value: '${totals.carbs.toStringAsFixed(1)}g'),
            ),
            Expanded(
              child: _Stat(label: 'Fat', value: '${totals.fat.toStringAsFixed(1)}g'),
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
