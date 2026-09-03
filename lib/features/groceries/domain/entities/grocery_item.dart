import '../usecases/combine_quantities.dart';

class GroceryItem {
  GroceryItem({required this.name, required this.rawQuantities, this.checked = false});

  final String name;
  final List<String> rawQuantities;
  bool checked;

  String get displayQuantity => combineQuantities(rawQuantities);

  Map<String, dynamic> toJson() => {
        'name': name,
        'rawQuantities': rawQuantities,
        'checked': checked,
      };

  factory GroceryItem.fromJson(Map<String, dynamic> json) => GroceryItem(
        name: json['name'] as String,
        rawQuantities: (json['rawQuantities'] as List).cast<String>(),
        checked: json['checked'] as bool? ?? false,
      );
}
