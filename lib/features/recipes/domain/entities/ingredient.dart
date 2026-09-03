class Ingredient {
  Ingredient({
    required this.name,
    required this.quantity,
  });

  final String name;
  final String quantity;

  Map<String, dynamic> toJson() => {
        'name': name,
        'quantity': quantity,
      };

  factory Ingredient.fromJson(Map<String, dynamic> json) => Ingredient(
        name: json['name'] as String,
        quantity: json['quantity'] as String,
      );
}
