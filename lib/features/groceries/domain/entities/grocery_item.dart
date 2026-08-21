import '../usecases/combine_quantities.dart';

class GroceryItem {
  GroceryItem({required this.name, required this.rawQuantities, this.checked = false});

  final String name;
  final List<String> rawQuantities;
  bool checked;

  String get displayQuantity => combineQuantities(rawQuantities);
}
