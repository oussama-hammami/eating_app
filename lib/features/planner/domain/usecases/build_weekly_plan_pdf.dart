import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../recipes/domain/entities/meal_type.dart';
import '../../../recipes/domain/entities/recipe.dart';
import '../entities/meal_plan_entry.dart';

const _mealTypeOrder = [
  MealType.breakfast,
  MealType.lunch,
  MealType.dinner,
  MealType.snack,
  MealType.drink,
];

String _dateKey(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

/// Renders a printable weekly meal plan: one row per day, its planned meals
/// grouped by [MealType] with the recipe name and servings. [mealTypeLabel]
/// supplies each type's localized display name (PDF text needs a plain
/// string, not a `BuildContext`-bound [AppLocalizations] call).
Future<Uint8List> buildWeeklyPlanPdf({
  required List<DateTime> weekDays,
  required List<MealPlanEntry> weekEntries,
  required List<Recipe> recipes,
  required String title,
  required String Function(MealType mealType) mealTypeLabel,
  required String noMealsLabel,
}) async {
  final doc = pw.Document();
  final recipeById = {for (final recipe in recipes) recipe.id: recipe};
  final dateFormat = DateFormat.yMMMMd();

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      build: (context) => [
        pw.Header(level: 0, text: title),
        pw.SizedBox(height: 12),
        for (final day in weekDays) ...[
          pw.Text(
            dateFormat.format(day),
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          _dayMealsBlock(
            entries: weekEntries.where((e) => e.date == _dateKey(day)).toList(),
            recipeById: recipeById,
            mealTypeLabel: mealTypeLabel,
            noMealsLabel: noMealsLabel,
          ),
          pw.SizedBox(height: 16),
        ],
      ],
    ),
  );

  return doc.save();
}

/// Builds the per-day block of meal-type rows — kept as a small helper
/// (rather than inlined in the page's `build`) since it needs to bail out
/// to a single "no meals" line when the day is empty.
pw.Widget _dayMealsBlock({
  required List<MealPlanEntry> entries,
  required Map<String, Recipe> recipeById,
  required String Function(MealType mealType) mealTypeLabel,
  required String noMealsLabel,
}) {
  if (entries.isEmpty) {
    return pw.Text(noMealsLabel, style: const pw.TextStyle(color: PdfColors.grey700));
  }
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.start,
    children: [
      for (final mealType in _mealTypeOrder)
        for (final entry in entries.where((e) => e.mealType == mealType))
          _mealLine(entry, mealType, recipeById, mealTypeLabel),
    ],
  );
}

pw.Widget _mealLine(
  MealPlanEntry entry,
  MealType mealType,
  Map<String, Recipe> recipeById,
  String Function(MealType mealType) mealTypeLabel,
) {
  final recipe = recipeById[entry.recipeId];
  final name = recipe?.name ?? entry.recipeId;
  return pw.Padding(
    padding: const pw.EdgeInsets.only(left: 8, bottom: 2),
    child: pw.Text('${mealTypeLabel(mealType)}: $name (${entry.servings})'),
  );
}
