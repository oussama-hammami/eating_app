import '../../../../core/units/unit.dart';
import '../../../../l10n/app_localizations.dart';

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
