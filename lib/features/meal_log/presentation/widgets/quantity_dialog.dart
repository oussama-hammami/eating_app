import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

/// Prompts for a quantity in grams. Returns null if cancelled.
Future<double?> showQuantityDialog(
  BuildContext context, {
  required String foodName,
  double? initialGrams,
}) {
  final controller = TextEditingController(
    text: initialGrams == null ? '' : _formatGrams(initialGrams),
  );
  final formKey = GlobalKey<FormState>();

  return showDialog<double>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return AlertDialog(
        title: Text(foodName),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: l10n.quantityGrams,
              suffixText: 'g',
            ),
            validator: (value) {
              final parsed = double.tryParse((value ?? '').trim());
              if (parsed == null || parsed <= 0) {
                return l10n.quantityValidatorMessage;
              }
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(double.parse(controller.text.trim()));
              }
            },
            child: Text(l10n.save),
          ),
        ],
      );
    },
  );
}

String _formatGrams(double grams) {
  return grams == grams.roundToDouble()
      ? grams.toStringAsFixed(0)
      : grams.toString();
}
