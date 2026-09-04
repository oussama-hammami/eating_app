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
  String get navCommunity => 'Community';

  @override
  String get navPlanner => 'Planner';

  @override
  String get plannerTitle => '🗓️  Weekly Planner';

  @override
  String get plannerPreviousWeek => 'Previous week';

  @override
  String get plannerNextWeek => 'Next week';

  @override
  String get plannerAddMeal => 'Add meal';

  @override
  String get plannerEmptySlot => 'No meal planned.';

  @override
  String get plannerEmptyDay => 'No meals planned for this day yet.';

  @override
  String get plannerDailyTotals => 'Daily totals';

  @override
  String get plannerServings => 'Servings';

  @override
  String get plannerGenerateGroceries => 'Generate groceries';

  @override
  String get plannerGenerateGroceriesConfirmTitle => 'Add week to groceries?';

  @override
  String get plannerGenerateGroceriesConfirmMessage =>
      'This adds every ingredient from this week\'s planned meals — scaled to servings — to your grocery list.';

  @override
  String get plannerShareWeek => 'Share week';

  @override
  String get plannerShareWeekTitle => 'Share this week';

  @override
  String plannerShareWeekInstructions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'these $count meals',
      one: 'this meal',
    );
    return 'Scan this QR code with another device\'s app to import $_temp0.';
  }

  @override
  String get plannerScanTitle => 'Scan to import';

  @override
  String get plannerImportTitle => 'Import meal plan';

  @override
  String plannerImportConfirmButton(int count) {
    return 'Add to my planner ($count)';
  }

  @override
  String plannerImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count meals',
      one: '1 meal',
    );
    return '$_temp0 added to your planner.';
  }

  @override
  String get plannerPickRecipeTitle => 'Choose a recipe';

  @override
  String get plannerMyRecipesSection => 'My recipes';

  @override
  String get plannerCommunitySection => 'Community';

  @override
  String get plannerCommunityUnavailable =>
      'Community recipes unavailable right now.';

  @override
  String get plannerServingsDialogTitle => 'How many servings?';

  @override
  String get plannerReplaceMeal => 'Replace';

  @override
  String get plannerRemoveMeal => 'Remove';

  @override
  String plannerWeekRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get recipesTitle => '🍽️  My Recipes';

  @override
  String get recipesEmpty => 'No recipes yet.\nTap + to add one.';

  @override
  String get searchRecipesHint => 'Search recipes…';

  @override
  String get recipesSearchEmpty => 'No recipes match your search.';

  @override
  String get filtersButton => 'Filters';

  @override
  String filtersActiveButton(int count) {
    return 'Filters ($count)';
  }

  @override
  String get filterResetButton => 'Reset filters';

  @override
  String get filterApplyButton => 'Apply filter';

  @override
  String get filterMinLabel => 'Min';

  @override
  String get filterMaxLabel => 'Max';

  @override
  String get filterCarbsLabel => 'Carbs (g)';

  @override
  String get filterFatLabel => 'Fat (g)';

  @override
  String get filterFiberLabel => 'Fiber (g)';

  @override
  String get filterMealTypesLabel => 'Meal types';

  @override
  String get filterIncludeIngredientsLabel => 'Include ingredients';

  @override
  String get filterExcludeIngredientsLabel => 'Exclude ingredients';

  @override
  String get filterIngredientInputHint => 'Type an ingredient and press enter…';

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
  String get communityLoadError =>
      'Couldn\'t load community recipes. Check your connection and try again.';

  @override
  String get communityOfflineCached =>
      'You\'re offline — showing recipes from the last sync.';

  @override
  String get retry => 'Retry';

  @override
  String get addToRecipes => 'Add to my recipes';

  @override
  String addedToRecipes(String name) {
    return 'Added \"$name\" to your recipes';
  }

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
  String shareRecipesCount(int count) {
    return 'Share ($count)';
  }

  @override
  String get shareRecipesTitle => 'Share recipes';

  @override
  String shareRecipesInstructions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'these recipes',
      one: 'this recipe',
    );
    return 'Scan this QR code with another device\'s app to share $_temp0.';
  }

  @override
  String get shareRecipesLinkButton => 'Share as link instead';

  @override
  String get scanRecipesTitle => 'Scan to import';

  @override
  String get importRecipesTitle => 'Choose recipes to add';

  @override
  String importRecipesAddButton(int count) {
    return 'Add to my recipes ($count)';
  }

  @override
  String importRecipesSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recipes',
      one: '1 recipe',
    );
    return '$_temp0 added to your list.';
  }

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
  String get searchFoodsHint => 'Search foods…';

  @override
  String get perHundredGrams => 'per 100g';

  @override
  String kcalPer100g(int kcal) {
    return '$kcal kcal / 100g';
  }

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
