import 'package:flutter/material.dart';

import '../../../../core/theme/app_palette.dart';
import '../../../../l10n/app_localizations.dart';
import '../../domain/entities/meal_type.dart';
import '../../domain/entities/recipe_filter.dart';

/// Expandable panel with nutrient range fields, include/exclude ingredient
/// chip inputs, and a meal-type multi-select. Edits are held as a local
/// draft — [filter] only seeds that draft when the panel first opens — and
/// are only pushed out via [onApply] when the user taps "Apply filter"
/// (Reset applies immediately, since "clear everything" has no ambiguity
/// worth a confirmation step).
class RecipeFilterPanel extends StatefulWidget {
  const RecipeFilterPanel({super.key, required this.filter, required this.onApply});

  final RecipeFilter filter;
  final ValueChanged<RecipeFilter> onApply;

  @override
  State<RecipeFilterPanel> createState() => _RecipeFilterPanelState();
}

class _RecipeFilterPanelState extends State<RecipeFilterPanel> {
  late RecipeFilter _draft = widget.filter;

  /// Bumped on Reset to force every [_NutrientRangeRow] (keyed on this) to
  /// recreate with fresh state instead of keeping its dragged-to values.
  int _resetSignal = 0;

  final _includeController = TextEditingController();
  final _excludeController = TextEditingController();

  @override
  void dispose() {
    _includeController.dispose();
    _excludeController.dispose();
    super.dispose();
  }

  void _update(RecipeFilter Function(RecipeFilter current) transform) {
    setState(() => _draft = transform(_draft));
  }

  void _reset() {
    setState(() {
      _draft = const RecipeFilter();
      _resetSignal++;
    });
    widget.onApply(_draft);
  }

  Widget _ingredientChips(
    Set<String> values,
    void Function(Set<String>) onValuesChanged,
    TextEditingController controller,
    String hint,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          decoration: InputDecoration(hintText: hint, isDense: true),
          onSubmitted: (value) {
            final trimmed = value.trim().toLowerCase();
            if (trimmed.isEmpty) return;
            onValuesChanged({...values, trimmed});
            controller.clear();
          },
        ),
        if (values.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Wrap(
              spacing: 6,
              runSpacing: 6,
              children: values
                  .map(
                    (value) => Chip(
                      label: Text(value),
                      onDeleted: () => onValuesChanged({...values}..remove(value)),
                    ),
                  )
                  .toList(),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filter = _draft;

    return Card(
      margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _NutrientRangeRow(
              key: ValueKey('calories-$_resetSignal'),
              label: l10n.caloriesKcal,
              initial: filter.calories,
              lowerBound: 0,
              upperBound: 1000,
              step: 10,
              minLabel: l10n.filterMinLabel,
              maxLabel: l10n.filterMaxLabel,
              onCommitted: (r) => _update((f) => f.copyWith(calories: r)),
            ),
            _NutrientRangeRow(
              key: ValueKey('protein-$_resetSignal'),
              label: l10n.proteinG,
              initial: filter.protein,
              lowerBound: 0,
              upperBound: 100,
              step: 5,
              minLabel: l10n.filterMinLabel,
              maxLabel: l10n.filterMaxLabel,
              onCommitted: (r) => _update((f) => f.copyWith(protein: r)),
            ),
            _NutrientRangeRow(
              key: ValueKey('carbs-$_resetSignal'),
              label: l10n.filterCarbsLabel,
              initial: filter.carbs,
              lowerBound: 0,
              upperBound: 150,
              step: 5,
              minLabel: l10n.filterMinLabel,
              maxLabel: l10n.filterMaxLabel,
              onCommitted: (r) => _update((f) => f.copyWith(carbs: r)),
            ),
            _NutrientRangeRow(
              key: ValueKey('fat-$_resetSignal'),
              label: l10n.filterFatLabel,
              initial: filter.fat,
              lowerBound: 0,
              upperBound: 100,
              step: 5,
              minLabel: l10n.filterMinLabel,
              maxLabel: l10n.filterMaxLabel,
              onCommitted: (r) => _update((f) => f.copyWith(fat: r)),
            ),
            _NutrientRangeRow(
              key: ValueKey('fiber-$_resetSignal'),
              label: l10n.filterFiberLabel,
              initial: filter.fiber,
              lowerBound: 0,
              upperBound: 50,
              step: 5,
              minLabel: l10n.filterMinLabel,
              maxLabel: l10n.filterMaxLabel,
              onCommitted: (r) => _update((f) => f.copyWith(fiber: r)),
            ),
            const SizedBox(height: 12),
            Text(l10n.filterMealTypesLabel, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: MealType.values.map((type) {
                final selected = filter.mealTypes.contains(type);
                return FilterChip(
                  label: Text(type.label(l10n)),
                  avatar: Icon(type.icon, size: 16),
                  selected: selected,
                  selectedColor: AppPalette.tealDark.withValues(alpha: 0.2),
                  onSelected: (isSelected) => _update((f) {
                    final updated = {...f.mealTypes};
                    if (isSelected) {
                      updated.add(type);
                    } else {
                      updated.remove(type);
                    }
                    return f.copyWith(mealTypes: updated);
                  }),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text(
              l10n.filterIncludeIngredientsLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            _ingredientChips(
              filter.includeIngredients,
              (values) => _update((f) => f.copyWith(includeIngredients: values)),
              _includeController,
              l10n.filterIngredientInputHint,
            ),
            const SizedBox(height: 12),
            Text(
              l10n.filterExcludeIngredientsLabel,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 6),
            _ingredientChips(
              filter.excludeIngredients,
              (values) => _update((f) => f.copyWith(excludeIngredients: values)),
              _excludeController,
              l10n.filterIngredientInputHint,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: filter.isActive ? _reset : null,
                  icon: const Icon(Icons.filter_alt_off_outlined),
                  label: Text(l10n.filterResetButton),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  onPressed: () => widget.onApply(_draft),
                  icon: const Icon(Icons.check),
                  label: Text(l10n.filterApplyButton),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// One nutrient's label + min/max fields + [RangeSlider], entirely
/// self-contained. Dragging the slider only rebuilds this small widget —
/// not the whole filter panel (other rows, chips, buttons) — which is what
/// keeps the drag smooth; [onCommitted] only fires once the drag ends (or
/// a text field is edited), not on every intermediate frame.
class _NutrientRangeRow extends StatefulWidget {
  const _NutrientRangeRow({
    super.key,
    required this.label,
    required this.initial,
    required this.lowerBound,
    required this.upperBound,
    required this.step,
    required this.minLabel,
    required this.maxLabel,
    required this.onCommitted,
  });

  final String label;
  final NutrientRange initial;
  final double lowerBound;
  final double upperBound;
  final double step;
  final String minLabel;
  final String maxLabel;
  final ValueChanged<NutrientRange> onCommitted;

  @override
  State<_NutrientRangeRow> createState() => _NutrientRangeRowState();
}

class _NutrientRangeRowState extends State<_NutrientRangeRow> {
  late RangeValues _liveValues = RangeValues(
    (widget.initial.min ?? widget.lowerBound).clamp(widget.lowerBound, widget.upperBound),
    (widget.initial.max ?? widget.upperBound).clamp(widget.lowerBound, widget.upperBound),
  );
  late final _minController = TextEditingController(text: _formatNum(_liveValues.start));
  late final _maxController = TextEditingController(text: _formatNum(_liveValues.end));

  @override
  void dispose() {
    _minController.dispose();
    _maxController.dispose();
    super.dispose();
  }

  /// Snaps a slider-dragged thumb sitting at a bound back to "unconstrained"
  /// rather than leaving an explicit 0/max value.
  NutrientRange _commitRange(RangeValues values) {
    return NutrientRange(
      min: values.start <= widget.lowerBound ? null : values.start,
      max: values.end >= widget.upperBound ? null : values.end,
    );
  }

  void _commitText({String? minText, String? maxText}) {
    final parsedMin = minText == null ? _liveValues.start : double.tryParse(minText.trim());
    final parsedMax = maxText == null ? _liveValues.end : double.tryParse(maxText.trim());
    if (parsedMin == null || parsedMax == null) return;
    setState(() => _liveValues = RangeValues(parsedMin, parsedMax));
    widget.onCommitted(_commitRange(_liveValues));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(widget.label),
          Row(
            children: [
              SizedBox(
                width: 64,
                child: TextField(
                  controller: _minController,
                  decoration: InputDecoration(labelText: widget.minLabel, isDense: true),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => _commitText(minText: value),
                ),
              ),
              Expanded(
                child: RangeSlider(
                  values: _liveValues,
                  min: widget.lowerBound,
                  max: widget.upperBound,
                  divisions: ((widget.upperBound - widget.lowerBound) / widget.step).round(),
                  activeColor: AppPalette.tealDark,
                  labels: RangeLabels(
                    _formatNum(_liveValues.start),
                    _formatNum(_liveValues.end),
                  ),
                  // Live visual feedback only — cheap, local setState.
                  onChanged: (values) => setState(() {
                    _liveValues = values;
                    _minController.text = _formatNum(values.start);
                    _maxController.text = _formatNum(values.end);
                  }),
                  // The parent (and the rest of the panel) only hears about
                  // the change once the drag actually ends.
                  onChangeEnd: (values) => widget.onCommitted(_commitRange(values)),
                ),
              ),
              SizedBox(
                width: 64,
                child: TextField(
                  controller: _maxController,
                  decoration: InputDecoration(labelText: widget.maxLabel, isDense: true),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (value) => _commitText(maxText: value),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String _formatNum(double value) {
  return value == value.roundToDouble() ? value.toInt().toString() : value.toString();
}
