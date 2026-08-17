// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'My Food This Week';

  @override
  String get navRecipes => 'Recipes';

  @override
  String get navGroceries => 'Groceries';

  @override
  String get navDiary => 'Diary';

  @override
  String get navCommunity => 'Community';

  @override
  String get recipesTitle => '🍽️  My Recipes';

  @override
  String get recipesEmpty => 'No recipes yet.\nTap + to add one.';

  @override
  String get privacyPolicyTitle => 'Privacy Policy';

  @override
  String get privacyPolicyBody =>
      'My Food This Week does not collect or share any personal data. Recipes, ingredients, and photos are stored only on your device.';

  @override
  String get privacyPolicyViewFull => 'View full policy';

  @override
  String get privacyPolicyClose => 'Close';

  @override
  String get communityTitle => '🌍  Community Recipes';

  @override
  String get communityEmpty => 'No community recipes yet.';

  @override
  String get communityLoadingNutrition =>
      'Calculating nutrition from ingredients…';

  @override
  String get editRecipe => 'Edit recipe';

  @override
  String get deleteRecipe => 'Delete recipe';

  @override
  String get deleteRecipeConfirmTitle => 'Delete recipe?';

  @override
  String deleteRecipeConfirmMessage(String name) {
    return 'This will remove \"$name\" permanently.';
  }

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get close => 'Close';

  @override
  String get save => 'Save';

  @override
  String get add => 'Add';

  @override
  String get editRecipeTitle => 'Edit Recipe';

  @override
  String get addRecipeTitle => 'Add Recipe';

  @override
  String get takeAPhoto => 'Take a photo';

  @override
  String get chooseFromLibrary => 'Choose from library';

  @override
  String get mealName => 'Meal name';

  @override
  String get caloriesKcal => 'Calories (kcal)';

  @override
  String get proteinG => 'Protein (g)';

  @override
  String get portions => 'Portions';

  @override
  String get ingredients => 'Ingredients';

  @override
  String ingredientN(int number) {
    return 'Ingredient $number';
  }

  @override
  String get quantity => 'Quantity';

  @override
  String get mealType => 'Meal type';

  @override
  String get mealTypeBreakfast => 'Breakfast';

  @override
  String get mealTypeLunch => 'Lunch';

  @override
  String get mealTypeDinner => 'Dinner';

  @override
  String get mealTypeSnack => 'Snack';

  @override
  String get mealTypeDrink => 'Drink';

  @override
  String get addIngredient => 'Add ingredient';

  @override
  String get preparationDescription => 'Preparation description';

  @override
  String get preparation => 'Preparation';

  @override
  String recipeStatsLine(int calories, int protein, int portions) {
    return '$calories kcal • $protein g protein • $portions portion(s)';
  }

  @override
  String caloriesKcalChip(int calories) {
    return '$calories kcal';
  }

  @override
  String proteinGChip(int protein) {
    return '$protein g protein';
  }

  @override
  String portionsChip(int portions) {
    return '$portions portion(s)';
  }

  @override
  String get ingredientNutritionUnknown =>
      'Nutrition values unavailable for this ingredient';

  @override
  String get ingredientNeedsConfirmation =>
      'No confident food match — please confirm which food this is';

  @override
  String carbsGChip(int carbs) {
    return '$carbs g carbs';
  }

  @override
  String fatGChip(int fat) {
    return '$fat g fat';
  }

  @override
  String fiberGChip(int fiber) {
    return '$fiber g fiber';
  }

  @override
  String addToGroceriesCount(int count) {
    return 'Add to groceries ($count)';
  }

  @override
  String get generateGroceries => 'Generate groceries';

  @override
  String get generateGroceriesConfirmTitle => 'Generate groceries?';

  @override
  String get generateGroceriesConfirmMessage =>
      'This will replace the current grocery list with a fresh one built only from the selected meals.';

  @override
  String get generate => 'Generate';

  @override
  String get groceriesTitle => '🛒  Groceries';

  @override
  String get groceriesEmpty =>
      'No groceries yet.\nSelect meals in Recipes and generate a list.';

  @override
  String get resetGroceries => 'Reset groceries';

  @override
  String get resetGroceriesConfirmTitle => 'Reset groceries?';

  @override
  String get resetGroceriesConfirmMessage =>
      'This clears the grocery list and unselects all meals in Recipes.';

  @override
  String get reset => 'Reset';

  @override
  String get foodDiaryTitle => 'Food Diary';

  @override
  String get searchFoodsHint => 'Search foods…';

  @override
  String searchErrorLabel(String error) {
    return 'Search error: $error';
  }

  @override
  String get noFoodsLoggedToday => 'No foods logged yet today.';

  @override
  String errorLabel(String error) {
    return 'Error: $error';
  }

  @override
  String get quantityGrams => 'Quantity (grams)';

  @override
  String get quantityValidatorMessage => 'Enter a quantity greater than 0';

  @override
  String get perHundredGrams => 'per 100g';

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
    return '$amount · $calories kcal · P ${protein}g · C ${carbs}g · F ${fat}g';
  }

  @override
  String get statCalories => 'Calories';

  @override
  String get statProtein => 'Protein';

  @override
  String get statCarbs => 'Carbs';

  @override
  String get statFat => 'Fat';

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
  String get unitTsp => 'tsp';

  @override
  String get unitTbsp => 'tbsp';

  @override
  String get unitCup => 'cup';

  @override
  String get unitFlOz => 'fl oz';

  @override
  String get unitPiece => 'piece';
}
