// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'My Food This Week';

  @override
  String get navRecipes => 'Recettes';

  @override
  String get navGroceries => 'Courses';

  @override
  String get navDiary => 'Journal';

  @override
  String get navCommunity => 'Communauté';

  @override
  String get recipesTitle => '🍽️  Mes recettes';

  @override
  String get recipesEmpty =>
      'Aucune recette pour le moment.\nAppuyez sur + pour en ajouter une.';

  @override
  String get privacyPolicyTitle => 'Politique de confidentialité';

  @override
  String get privacyPolicyBody =>
      'My Food This Week ne collecte ni ne partage aucune donnée personnelle. Les recettes, ingrédients et photos sont stockés uniquement sur votre appareil.';

  @override
  String get privacyPolicyViewFull => 'Voir la politique complète';

  @override
  String get privacyPolicyClose => 'Fermer';

  @override
  String get communityTitle => '🌍  Recettes de la communauté';

  @override
  String get communityEmpty =>
      'Aucune recette de la communauté pour le moment.';

  @override
  String get communityLoadingNutrition =>
      'Calcul des valeurs nutritionnelles à partir des ingrédients…';

  @override
  String get editRecipe => 'Modifier la recette';

  @override
  String get deleteRecipe => 'Supprimer la recette';

  @override
  String get deleteRecipeConfirmTitle => 'Supprimer la recette ?';

  @override
  String deleteRecipeConfirmMessage(String name) {
    return 'Cela supprimera définitivement « $name ».';
  }

  @override
  String get cancel => 'Annuler';

  @override
  String get delete => 'Supprimer';

  @override
  String get close => 'Fermer';

  @override
  String get save => 'Enregistrer';

  @override
  String get add => 'Ajouter';

  @override
  String get editRecipeTitle => 'Modifier la recette';

  @override
  String get addRecipeTitle => 'Ajouter une recette';

  @override
  String get takeAPhoto => 'Prendre une photo';

  @override
  String get chooseFromLibrary => 'Choisir depuis la galerie';

  @override
  String get mealName => 'Nom du plat';

  @override
  String get caloriesKcal => 'Calories (kcal)';

  @override
  String get proteinG => 'Protéines (g)';

  @override
  String get portions => 'Portions';

  @override
  String get ingredients => 'Ingrédients';

  @override
  String ingredientN(int number) {
    return 'Ingrédient $number';
  }

  @override
  String get quantity => 'Quantité';

  @override
  String get mealType => 'Type de repas';

  @override
  String get mealTypeBreakfast => 'Petit-déjeuner';

  @override
  String get mealTypeLunch => 'Déjeuner';

  @override
  String get mealTypeDinner => 'Dîner';

  @override
  String get mealTypeSnack => 'Snacks';

  @override
  String get mealTypeDrink => 'Boisson';

  @override
  String get addIngredient => 'Ajouter un ingrédient';

  @override
  String get preparationDescription => 'Description de la préparation';

  @override
  String get preparation => 'Préparation';

  @override
  String recipeStatsLine(int calories, int protein, int portions) {
    return '$calories kcal • $protein g de protéines • $portions portion(s)';
  }

  @override
  String caloriesKcalChip(int calories) {
    return '$calories kcal';
  }

  @override
  String proteinGChip(int protein) {
    return '$protein g de protéines';
  }

  @override
  String portionsChip(int portions) {
    return '$portions portion(s)';
  }

  @override
  String get ingredientNutritionUnknown =>
      'Valeurs nutritionnelles indisponibles pour cet ingrédient';

  @override
  String get ingredientNeedsConfirmation =>
      'Aucune correspondance fiable — veuillez confirmer l\'aliment';

  @override
  String carbsGChip(int carbs) {
    return '$carbs g de glucides';
  }

  @override
  String fatGChip(int fat) {
    return '$fat g de lipides';
  }

  @override
  String fiberGChip(int fiber) {
    return '$fiber g de fibres';
  }

  @override
  String addToGroceriesCount(int count) {
    return 'Ajouter aux courses ($count)';
  }

  @override
  String get generateGroceries => 'Générer les courses';

  @override
  String get generateGroceriesConfirmTitle => 'Générer la liste de courses ?';

  @override
  String get generateGroceriesConfirmMessage =>
      'Cela remplacera la liste de courses actuelle par une nouvelle liste basée uniquement sur les repas sélectionnés.';

  @override
  String get generate => 'Générer';

  @override
  String get groceriesTitle => '🛒  Courses';

  @override
  String get groceriesEmpty =>
      'Aucun article pour le moment.\nSélectionnez des repas dans Recettes et générez une liste.';

  @override
  String get resetGroceries => 'Réinitialiser les courses';

  @override
  String get resetGroceriesConfirmTitle => 'Réinitialiser les courses ?';

  @override
  String get resetGroceriesConfirmMessage =>
      'Cela efface la liste de courses et désélectionne tous les repas dans Recettes.';

  @override
  String get reset => 'Réinitialiser';

  @override
  String get foodDiaryTitle => 'Journal alimentaire';

  @override
  String get searchFoodsHint => 'Rechercher des aliments…';

  @override
  String searchErrorLabel(String error) {
    return 'Erreur de recherche : $error';
  }

  @override
  String get noFoodsLoggedToday => 'Aucun aliment enregistré aujourd\'hui.';

  @override
  String errorLabel(String error) {
    return 'Erreur : $error';
  }

  @override
  String get quantityGrams => 'Quantité (grammes)';

  @override
  String get quantityValidatorMessage =>
      'Saisissez une quantité supérieure à 0';

  @override
  String get perHundredGrams => 'pour 100g';

  @override
  String kcalPer100g(int kcal) {
    return '$kcal kcal / 100g';
  }

  @override
  String mealEntrySubtitle(
    String amount,
    int calories,
    String protein,
    String carbs,
    String fat,
  ) {
    return '$amount · $calories kcal · P ${protein}g · G ${carbs}g · L ${fat}g';
  }

  @override
  String get statCalories => 'Calories';

  @override
  String get statProtein => 'Protéines';

  @override
  String get statCarbs => 'Glucides';

  @override
  String get statFat => 'Lipides';

  @override
  String get unitG => 'g';

  @override
  String get unitKg => 'kg';

  @override
  String get unitOz => 'oz';

  @override
  String get unitLb => 'lb';

  @override
  String get unitMl => 'ml';

  @override
  String get unitL => 'l';

  @override
  String get unitTsp => 'c. à café';

  @override
  String get unitTbsp => 'c. à soupe';

  @override
  String get unitCup => 'tasse';

  @override
  String get unitFlOz => 'oz liq.';

  @override
  String get unitPiece => 'pièce';
}
