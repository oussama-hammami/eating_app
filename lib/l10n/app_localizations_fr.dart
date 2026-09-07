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
  String get navCommunity => 'Communauté';

  @override
  String get navPlanner => 'Planning';

  @override
  String get plannerTitle => '🗓️  Planning hebdomadaire';

  @override
  String get plannerPreviousWeek => 'Semaine précédente';

  @override
  String get plannerNextWeek => 'Semaine suivante';

  @override
  String get plannerAddMeal => 'Ajouter un repas';

  @override
  String get plannerEmptySlot => 'Aucun repas prévu.';

  @override
  String get plannerEmptyDay =>
      'Aucun repas prévu pour ce jour pour le moment.';

  @override
  String get plannerDailyTotals => 'Totaux du jour';

  @override
  String get plannerServings => 'Portions';

  @override
  String get plannerGenerateGroceries => 'Générer les courses';

  @override
  String get plannerGenerateGroceriesConfirmTitle =>
      'Ajouter la semaine aux courses ?';

  @override
  String get plannerGenerateGroceriesConfirmMessage =>
      'Cela ajoute chaque ingrédient des repas planifiés cette semaine — proportionné aux portions — à votre liste de courses.';

  @override
  String get plannerShareWeek => 'Partager la semaine';

  @override
  String get plannerShareWeekTitle => 'Partager cette semaine';

  @override
  String plannerShareWeekInstructions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ces $count repas',
      one: 'ce repas',
    );
    return 'Scannez ce QR code avec l\'application d\'un autre appareil pour importer $_temp0.';
  }

  @override
  String get plannerScanTitle => 'Scanner pour importer';

  @override
  String get plannerImportTitle => 'Importer le planning';

  @override
  String plannerImportConfirmButton(int count) {
    return 'Ajouter à mon planning ($count)';
  }

  @override
  String plannerImportSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count repas ajoutés',
      one: '1 repas ajouté',
    );
    return '$_temp0 à votre planning.';
  }

  @override
  String get plannerPickRecipeTitle => 'Choisir une recette';

  @override
  String get plannerMyRecipesSection => 'Mes recettes';

  @override
  String get plannerCommunitySection => 'Communauté';

  @override
  String get plannerCommunityUnavailable =>
      'Recettes de la communauté indisponibles pour le moment.';

  @override
  String get plannerServingsDialogTitle => 'Combien de portions ?';

  @override
  String get plannerReplaceMeal => 'Remplacer';

  @override
  String get plannerRemoveMeal => 'Retirer';

  @override
  String plannerWeekRange(String start, String end) {
    return '$start – $end';
  }

  @override
  String get recipesTitle => '🍽️  Mes recettes';

  @override
  String get recipesEmpty =>
      'Aucune recette pour le moment.\nAppuyez sur + pour en ajouter une.';

  @override
  String get searchRecipesHint => 'Rechercher des recettes…';

  @override
  String get recipesSearchEmpty =>
      'Aucune recette ne correspond à votre recherche.';

  @override
  String get filtersButton => 'Filtres';

  @override
  String filtersActiveButton(int count) {
    return 'Filtres ($count)';
  }

  @override
  String get filterResetButton => 'Réinitialiser les filtres';

  @override
  String get filterApplyButton => 'Appliquer le filtre';

  @override
  String get filterMinLabel => 'Min';

  @override
  String get filterMaxLabel => 'Max';

  @override
  String get filterCarbsLabel => 'Glucides (g)';

  @override
  String get filterFatLabel => 'Lipides (g)';

  @override
  String get filterFiberLabel => 'Fibres (g)';

  @override
  String get filterMealTypesLabel => 'Types de repas';

  @override
  String get filterIncludeIngredientsLabel => 'Inclure des ingrédients';

  @override
  String get filterExcludeIngredientsLabel => 'Exclure des ingrédients';

  @override
  String get filterIngredientInputHint =>
      'Tapez un ingrédient et appuyez sur entrée…';

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
  String get communityLoadError =>
      'Impossible de charger les recettes de la communauté. Vérifiez votre connexion et réessayez.';

  @override
  String get communityOfflineCached =>
      'Vous êtes hors ligne — affichage des recettes de la dernière synchronisation.';

  @override
  String get retry => 'Réessayer';

  @override
  String get addToRecipes => 'Ajouter à mes recettes';

  @override
  String addedToRecipes(String name) {
    return '« $name » a été ajoutée à vos recettes';
  }

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
  String shareRecipesCount(int count) {
    return 'Partager ($count)';
  }

  @override
  String get shareRecipesTitle => 'Partager les recettes';

  @override
  String shareRecipesInstructions(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ces recettes',
      one: 'cette recette',
    );
    return 'Scannez ce code QR avec l\'application sur un autre appareil pour partager $_temp0.';
  }

  @override
  String get shareRecipesLinkButton => 'Partager sous forme de lien';

  @override
  String get scanRecipesTitle => 'Scanner pour importer';

  @override
  String get scanDecodeError =>
      'Ce code QR n\'a pas pu être lu. Assurez-vous qu\'il a été généré par l\'écran de partage de recettes de cette application.';

  @override
  String get qrPayloadTooLargeError =>
      'Trop de contenu pour tenir dans un code QR. Essayez de partager moins d\'éléments, ou utilisez « Partager sous forme de lien ».';

  @override
  String get importRecipesTitle => 'Choisir les recettes à ajouter';

  @override
  String importRecipesAddButton(int count) {
    return 'Ajouter à mes recettes ($count)';
  }

  @override
  String importRecipesSuccess(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count recettes ajoutées',
      one: '1 recette ajoutée',
    );
    return '$_temp0 à votre liste.';
  }

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
  String get addArticle => 'Ajouter un article';

  @override
  String get addArticleTitle => 'Ajouter un article';

  @override
  String get articleNameLabel => 'Nom de l\'article';

  @override
  String get articleQuantityLabel => 'Quantité (optionnel)';

  @override
  String get shareGroceries => 'Partager la liste';

  @override
  String get shareGroceriesTitle => 'Liste de courses';

  @override
  String get groceriesRecipes => 'Recettes';

  @override
  String get groceriesRecipesTitle => 'Recettes de cette liste';

  @override
  String get searchFoodsHint => 'Rechercher des aliments…';

  @override
  String get perHundredGrams => 'pour 100g';

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
