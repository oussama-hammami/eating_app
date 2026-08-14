import 'package:flutter/material.dart';

import '../../../../core/units/unit.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../nutrition/domain/entities/quantity.dart';

/// Weight units are always usable (universal conversion), so they're always
/// offered. Volume/count units only make sense when the ingredient has a
/// specific conversion for them (see [availableUnits]).
const _alwaysAvailable = [Unit.g, Unit.kg, Unit.oz, Unit.lb];

/// Preferred default order when picking the initial unit for a food: an
/// ingredient-specific unit (piece, tbsp, ...) reads more naturally than a
/// weight fallback, so it's tried first.
const _defaultPriority = [
  Unit.piece,
  Unit.tbsp,
  Unit.tsp,
  Unit.cup,
  Unit.ml,
  Unit.l,
  Unit.flOz,
  Unit.g,
];

Unit defaultUnitFor(Set<Unit> availableUnits) {
  for (final unit in _defaultPriority) {
    if (availableUnits.contains(unit)) return unit;
  }
  return Unit.g;
}

/// Prompts for an amount + unit. Returns null if cancelled.
Future<Quantity?> showQuantityDialog(
  BuildContext context, {
  required String foodName,
  required Set<Unit> ingredientUnits,
  Quantity? initialQuantity,
}) {
  final availableUnits = {..._alwaysAvailable, ...ingredientUnits};
  var selectedUnit = initialQuantity?.unit ?? defaultUnitFor(availableUnits);
  final controller = TextEditingController(
    text: initialQuantity == null ? '' : _formatAmount(initialQuantity.amount),
  );
  final formKey = GlobalKey<FormState>();

  return showDialog<Quantity>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context)!;
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text(foodName),
            content: Form(
              key: formKey,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: controller,
                      autofocus: true,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: InputDecoration(labelText: l10n.quantity),
                      validator: (value) {
                        final parsed = double.tryParse((value ?? '').trim());
                        if (parsed == null || parsed <= 0) {
                          return l10n.quantityValidatorMessage;
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  DropdownButton<Unit>(
                    value: selectedUnit,
                    items: [
                      for (final unit in availableUnits)
                        DropdownMenuItem(value: unit, child: Text(unitLabel(l10n, unit))),
                    ],
                    onChanged: (unit) => setState(() => selectedUnit = unit!),
                  ),
                ],
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
                    Navigator.of(context).pop(
                      Quantity(amount: double.parse(controller.text.trim()), unit: selectedUnit),
                    );
                  }
                },
                child: Text(l10n.save),
              ),
            ],
          );
        },
      );
    },
  );
}

String unitLabel(AppLocalizations l10n, Unit unit) {
  switch (unit) {
    case Unit.g:
      return l10n.unitG;
    case Unit.kg:
      return l10n.unitKg;
    case Unit.oz:
      return l10n.unitOz;
    case Unit.lb:
      return l10n.unitLb;
    case Unit.ml:
      return l10n.unitMl;
    case Unit.l:
      return l10n.unitL;
    case Unit.tsp:
      return l10n.unitTsp;
    case Unit.tbsp:
      return l10n.unitTbsp;
    case Unit.cup:
      return l10n.unitCup;
    case Unit.flOz:
      return l10n.unitFlOz;
    case Unit.piece:
      return l10n.unitPiece;
  }
}

String _formatAmount(double amount) {
  return amount == amount.roundToDouble()
      ? amount.toStringAsFixed(0)
      : amount.toString();
}
