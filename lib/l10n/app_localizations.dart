import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('fr'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'My Food This Week'**
  String get appTitle;

  /// No description provided for @navRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get navRecipes;

  /// No description provided for @navGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get navGroceries;

  /// No description provided for @navCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

  /// No description provided for @navPlanner.
  ///
  /// In en, this message translates to:
  /// **'Planner'**
  String get navPlanner;

  /// No description provided for @menuTooltip.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menuTooltip;

  /// No description provided for @privacyLocalStorageBadge.
  ///
  /// In en, this message translates to:
  /// **'100% Local Storage'**
  String get privacyLocalStorageBadge;

  /// No description provided for @plannerTitle.
  ///
  /// In en, this message translates to:
  /// **'🗓️  Weekly Planner'**
  String get plannerTitle;

  /// No description provided for @plannerPreviousWeek.
  ///
  /// In en, this message translates to:
  /// **'Previous week'**
  String get plannerPreviousWeek;

  /// No description provided for @plannerNextWeek.
  ///
  /// In en, this message translates to:
  /// **'Next week'**
  String get plannerNextWeek;

  /// No description provided for @plannerAddMeal.
  ///
  /// In en, this message translates to:
  /// **'Add meal'**
  String get plannerAddMeal;

  /// No description provided for @plannerEmptySlot.
  ///
  /// In en, this message translates to:
  /// **'No meal planned.'**
  String get plannerEmptySlot;

  /// No description provided for @plannerEmptyDay.
  ///
  /// In en, this message translates to:
  /// **'No meals planned for this day yet.'**
  String get plannerEmptyDay;

  /// No description provided for @plannerDailyTotals.
  ///
  /// In en, this message translates to:
  /// **'Daily totals'**
  String get plannerDailyTotals;

  /// No description provided for @plannerServings.
  ///
  /// In en, this message translates to:
  /// **'Servings'**
  String get plannerServings;

  /// No description provided for @plannerGenerateGroceries.
  ///
  /// In en, this message translates to:
  /// **'Generate groceries'**
  String get plannerGenerateGroceries;

  /// No description provided for @plannerGenerateGroceriesConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Add week to groceries?'**
  String get plannerGenerateGroceriesConfirmTitle;

  /// No description provided for @plannerGenerateGroceriesConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This adds every ingredient from this week\'s planned meals — scaled to servings — to your grocery list.'**
  String get plannerGenerateGroceriesConfirmMessage;

  /// No description provided for @plannerShareWeek.
  ///
  /// In en, this message translates to:
  /// **'Share week'**
  String get plannerShareWeek;

  /// No description provided for @plannerExportPdf.
  ///
  /// In en, this message translates to:
  /// **'Export PDF'**
  String get plannerExportPdf;

  /// No description provided for @plannerExportPdfTitle.
  ///
  /// In en, this message translates to:
  /// **'Weekly meal plan — {start} – {end}'**
  String plannerExportPdfTitle(String start, String end);

  /// No description provided for @plannerExportPdfNoMeals.
  ///
  /// In en, this message translates to:
  /// **'No meals planned'**
  String get plannerExportPdfNoMeals;

  /// No description provided for @plannerShareWeekTitle.
  ///
  /// In en, this message translates to:
  /// **'Share this week'**
  String get plannerShareWeekTitle;

  /// No description provided for @plannerShareWeekInstructions.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code with another device\'s app to import {count, plural, one {this meal} other {these {count} meals}}.'**
  String plannerShareWeekInstructions(int count);

  /// No description provided for @plannerScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan to import'**
  String get plannerScanTitle;

  /// No description provided for @plannerImportTitle.
  ///
  /// In en, this message translates to:
  /// **'Import meal plan'**
  String get plannerImportTitle;

  /// No description provided for @plannerImportConfirmButton.
  ///
  /// In en, this message translates to:
  /// **'Add to my planner ({count})'**
  String plannerImportConfirmButton(int count);

  /// No description provided for @plannerImportSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {1 meal} other {{count} meals}} added to your planner.'**
  String plannerImportSuccess(int count);

  /// No description provided for @plannerPickRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose a recipe'**
  String get plannerPickRecipeTitle;

  /// No description provided for @plannerMyRecipesSection.
  ///
  /// In en, this message translates to:
  /// **'My recipes'**
  String get plannerMyRecipesSection;

  /// No description provided for @plannerCommunitySection.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get plannerCommunitySection;

  /// No description provided for @plannerCommunityUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Community recipes unavailable right now.'**
  String get plannerCommunityUnavailable;

  /// No description provided for @plannerServingsDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'How many servings?'**
  String get plannerServingsDialogTitle;

  /// No description provided for @plannerReplaceMeal.
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get plannerReplaceMeal;

  /// No description provided for @plannerRemoveMeal.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get plannerRemoveMeal;

  /// No description provided for @plannerWeekRange.
  ///
  /// In en, this message translates to:
  /// **'{start} – {end}'**
  String plannerWeekRange(String start, String end);

  /// No description provided for @recipesTitle.
  ///
  /// In en, this message translates to:
  /// **'🍽️  My Recipes'**
  String get recipesTitle;

  /// No description provided for @recipesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recipes yet.\nTap + to add one.'**
  String get recipesEmpty;

  /// No description provided for @searchRecipesHint.
  ///
  /// In en, this message translates to:
  /// **'Search recipes…'**
  String get searchRecipesHint;

  /// No description provided for @recipesSearchEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recipes match your search.'**
  String get recipesSearchEmpty;

  /// No description provided for @filtersButton.
  ///
  /// In en, this message translates to:
  /// **'Filters'**
  String get filtersButton;

  /// No description provided for @filtersActiveButton.
  ///
  /// In en, this message translates to:
  /// **'Filters ({count})'**
  String filtersActiveButton(int count);

  /// No description provided for @filterResetButton.
  ///
  /// In en, this message translates to:
  /// **'Reset filters'**
  String get filterResetButton;

  /// No description provided for @filterApplyButton.
  ///
  /// In en, this message translates to:
  /// **'Apply filter'**
  String get filterApplyButton;

  /// No description provided for @filterMinLabel.
  ///
  /// In en, this message translates to:
  /// **'Min'**
  String get filterMinLabel;

  /// No description provided for @filterMaxLabel.
  ///
  /// In en, this message translates to:
  /// **'Max'**
  String get filterMaxLabel;

  /// No description provided for @filterCarbsLabel.
  ///
  /// In en, this message translates to:
  /// **'Carbs (g)'**
  String get filterCarbsLabel;

  /// No description provided for @filterFatLabel.
  ///
  /// In en, this message translates to:
  /// **'Fat (g)'**
  String get filterFatLabel;

  /// No description provided for @filterFiberLabel.
  ///
  /// In en, this message translates to:
  /// **'Fiber (g)'**
  String get filterFiberLabel;

  /// No description provided for @filterMealTypesLabel.
  ///
  /// In en, this message translates to:
  /// **'Meal types'**
  String get filterMealTypesLabel;

  /// No description provided for @filterIncludeIngredientsLabel.
  ///
  /// In en, this message translates to:
  /// **'Include ingredients'**
  String get filterIncludeIngredientsLabel;

  /// No description provided for @filterExcludeIngredientsLabel.
  ///
  /// In en, this message translates to:
  /// **'Exclude ingredients'**
  String get filterExcludeIngredientsLabel;

  /// No description provided for @filterIngredientInputHint.
  ///
  /// In en, this message translates to:
  /// **'Type an ingredient and press enter…'**
  String get filterIngredientInputHint;

  /// No description provided for @privacyPolicyTitle.
  ///
  /// In en, this message translates to:
  /// **'Privacy Policy'**
  String get privacyPolicyTitle;

  /// No description provided for @privacyPolicyBody.
  ///
  /// In en, this message translates to:
  /// **'My Food This Week does not collect or share any personal data. Recipes, ingredients, and photos are stored only on your device.'**
  String get privacyPolicyBody;

  /// No description provided for @privacyPolicyViewFull.
  ///
  /// In en, this message translates to:
  /// **'View full policy'**
  String get privacyPolicyViewFull;

  /// No description provided for @privacyPolicyClose.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get privacyPolicyClose;

  /// No description provided for @communityTitle.
  ///
  /// In en, this message translates to:
  /// **'🌍  Community Recipes'**
  String get communityTitle;

  /// No description provided for @communityEmpty.
  ///
  /// In en, this message translates to:
  /// **'No community recipes yet.'**
  String get communityEmpty;

  /// No description provided for @communityLoadError.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t load community recipes. Check your connection and try again.'**
  String get communityLoadError;

  /// No description provided for @communityOfflineCached.
  ///
  /// In en, this message translates to:
  /// **'You\'re offline — showing recipes from the last sync.'**
  String get communityOfflineCached;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @addToRecipes.
  ///
  /// In en, this message translates to:
  /// **'Add to my recipes'**
  String get addToRecipes;

  /// No description provided for @addedToRecipes.
  ///
  /// In en, this message translates to:
  /// **'Added \"{name}\" to your recipes'**
  String addedToRecipes(String name);

  /// No description provided for @editRecipe.
  ///
  /// In en, this message translates to:
  /// **'Edit recipe'**
  String get editRecipe;

  /// No description provided for @deleteRecipe.
  ///
  /// In en, this message translates to:
  /// **'Delete recipe'**
  String get deleteRecipe;

  /// No description provided for @deleteRecipeConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete recipe?'**
  String get deleteRecipeConfirmTitle;

  /// No description provided for @deleteRecipeConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will remove \"{name}\" permanently.'**
  String deleteRecipeConfirmMessage(String name);

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @editRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit Recipe'**
  String get editRecipeTitle;

  /// No description provided for @addRecipeTitle.
  ///
  /// In en, this message translates to:
  /// **'Add Recipe'**
  String get addRecipeTitle;

  /// No description provided for @takeAPhoto.
  ///
  /// In en, this message translates to:
  /// **'Take a photo'**
  String get takeAPhoto;

  /// No description provided for @chooseFromLibrary.
  ///
  /// In en, this message translates to:
  /// **'Choose from library'**
  String get chooseFromLibrary;

  /// No description provided for @mealName.
  ///
  /// In en, this message translates to:
  /// **'Meal name'**
  String get mealName;

  /// No description provided for @caloriesKcal.
  ///
  /// In en, this message translates to:
  /// **'Calories (kcal)'**
  String get caloriesKcal;

  /// No description provided for @proteinG.
  ///
  /// In en, this message translates to:
  /// **'Protein (g)'**
  String get proteinG;

  /// No description provided for @portions.
  ///
  /// In en, this message translates to:
  /// **'Portions'**
  String get portions;

  /// No description provided for @ingredients.
  ///
  /// In en, this message translates to:
  /// **'Ingredients'**
  String get ingredients;

  /// No description provided for @ingredientN.
  ///
  /// In en, this message translates to:
  /// **'Ingredient {number}'**
  String ingredientN(int number);

  /// No description provided for @mealType.
  ///
  /// In en, this message translates to:
  /// **'Meal type'**
  String get mealType;

  /// No description provided for @mealTypeBreakfast.
  ///
  /// In en, this message translates to:
  /// **'Breakfast'**
  String get mealTypeBreakfast;

  /// No description provided for @mealTypeLunch.
  ///
  /// In en, this message translates to:
  /// **'Lunch'**
  String get mealTypeLunch;

  /// No description provided for @mealTypeDinner.
  ///
  /// In en, this message translates to:
  /// **'Dinner'**
  String get mealTypeDinner;

  /// No description provided for @mealTypeSnack.
  ///
  /// In en, this message translates to:
  /// **'Snack'**
  String get mealTypeSnack;

  /// No description provided for @mealTypeDrink.
  ///
  /// In en, this message translates to:
  /// **'Drink'**
  String get mealTypeDrink;

  /// No description provided for @addIngredient.
  ///
  /// In en, this message translates to:
  /// **'Add ingredient'**
  String get addIngredient;

  /// No description provided for @preparationDescription.
  ///
  /// In en, this message translates to:
  /// **'Preparation description'**
  String get preparationDescription;

  /// No description provided for @preparation.
  ///
  /// In en, this message translates to:
  /// **'Preparation'**
  String get preparation;

  /// No description provided for @recipeStatsLine.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal • {protein} g protein • {portions} portion(s)'**
  String recipeStatsLine(int calories, int protein, int portions);

  /// No description provided for @caloriesKcalChip.
  ///
  /// In en, this message translates to:
  /// **'{calories} kcal'**
  String caloriesKcalChip(int calories);

  /// No description provided for @proteinGChip.
  ///
  /// In en, this message translates to:
  /// **'{protein} g protein'**
  String proteinGChip(int protein);

  /// No description provided for @portionsChip.
  ///
  /// In en, this message translates to:
  /// **'{portions} portion(s)'**
  String portionsChip(int portions);

  /// No description provided for @ingredientNutritionUnknown.
  ///
  /// In en, this message translates to:
  /// **'Nutrition values unavailable for this ingredient'**
  String get ingredientNutritionUnknown;

  /// No description provided for @ingredientNeedsConfirmation.
  ///
  /// In en, this message translates to:
  /// **'No confident food match — please confirm which food this is'**
  String get ingredientNeedsConfirmation;

  /// No description provided for @carbsGChip.
  ///
  /// In en, this message translates to:
  /// **'{carbs} g carbs'**
  String carbsGChip(int carbs);

  /// No description provided for @fatGChip.
  ///
  /// In en, this message translates to:
  /// **'{fat} g fat'**
  String fatGChip(int fat);

  /// No description provided for @fiberGChip.
  ///
  /// In en, this message translates to:
  /// **'{fiber} g fiber'**
  String fiberGChip(int fiber);

  /// No description provided for @addToGroceriesCount.
  ///
  /// In en, this message translates to:
  /// **'Add to groceries ({count})'**
  String addToGroceriesCount(int count);

  /// No description provided for @generateGroceries.
  ///
  /// In en, this message translates to:
  /// **'Generate groceries'**
  String get generateGroceries;

  /// No description provided for @generateGroceriesConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Generate groceries?'**
  String get generateGroceriesConfirmTitle;

  /// No description provided for @generateGroceriesConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This will replace the current grocery list with a fresh one built only from the selected meals.'**
  String get generateGroceriesConfirmMessage;

  /// No description provided for @generate.
  ///
  /// In en, this message translates to:
  /// **'Generate'**
  String get generate;

  /// No description provided for @shareRecipesCount.
  ///
  /// In en, this message translates to:
  /// **'Share ({count})'**
  String shareRecipesCount(int count);

  /// No description provided for @shareRecipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Share recipes'**
  String get shareRecipesTitle;

  /// No description provided for @shareRecipesInstructions.
  ///
  /// In en, this message translates to:
  /// **'Scan this QR code with another device\'s app to share {count, plural, one {this recipe} other {these recipes}}.'**
  String shareRecipesInstructions(int count);

  /// No description provided for @shareRecipesLinkButton.
  ///
  /// In en, this message translates to:
  /// **'Share as link instead'**
  String get shareRecipesLinkButton;

  /// No description provided for @scanRecipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Scan to import'**
  String get scanRecipesTitle;

  /// No description provided for @scanDecodeError.
  ///
  /// In en, this message translates to:
  /// **'That QR code couldn\'t be read. Make sure it was generated by this app\'s recipe sharing screen.'**
  String get scanDecodeError;

  /// No description provided for @qrPayloadTooLargeError.
  ///
  /// In en, this message translates to:
  /// **'Too much content to fit in a QR code. Try sharing fewer items, or use \"Share as link instead\".'**
  String get qrPayloadTooLargeError;

  /// No description provided for @importRecipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Choose recipes to add'**
  String get importRecipesTitle;

  /// No description provided for @importRecipesAddButton.
  ///
  /// In en, this message translates to:
  /// **'Add to my recipes ({count})'**
  String importRecipesAddButton(int count);

  /// No description provided for @importRecipesSuccess.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, one {1 recipe} other {{count} recipes}} added to your list.'**
  String importRecipesSuccess(int count);

  /// No description provided for @groceriesTitle.
  ///
  /// In en, this message translates to:
  /// **'🛒  Groceries'**
  String get groceriesTitle;

  /// No description provided for @groceriesEmpty.
  ///
  /// In en, this message translates to:
  /// **'No groceries yet.\nSelect meals in Recipes and generate a list.'**
  String get groceriesEmpty;

  /// No description provided for @resetGroceries.
  ///
  /// In en, this message translates to:
  /// **'Reset groceries'**
  String get resetGroceries;

  /// No description provided for @resetGroceriesConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Reset groceries?'**
  String get resetGroceriesConfirmTitle;

  /// No description provided for @resetGroceriesConfirmMessage.
  ///
  /// In en, this message translates to:
  /// **'This clears the grocery list and unselects all meals in Recipes.'**
  String get resetGroceriesConfirmMessage;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @addArticle.
  ///
  /// In en, this message translates to:
  /// **'Add article'**
  String get addArticle;

  /// No description provided for @addArticleTitle.
  ///
  /// In en, this message translates to:
  /// **'Add article'**
  String get addArticleTitle;

  /// No description provided for @articleNameLabel.
  ///
  /// In en, this message translates to:
  /// **'Item name'**
  String get articleNameLabel;

  /// No description provided for @articleQuantityLabel.
  ///
  /// In en, this message translates to:
  /// **'Quantity (optional)'**
  String get articleQuantityLabel;

  /// No description provided for @shareGroceries.
  ///
  /// In en, this message translates to:
  /// **'Share list'**
  String get shareGroceries;

  /// No description provided for @shareGroceriesTitle.
  ///
  /// In en, this message translates to:
  /// **'Grocery list'**
  String get shareGroceriesTitle;

  /// No description provided for @groceriesRecipes.
  ///
  /// In en, this message translates to:
  /// **'Recipes'**
  String get groceriesRecipes;

  /// No description provided for @groceriesRecipesTitle.
  ///
  /// In en, this message translates to:
  /// **'Recipes in this list'**
  String get groceriesRecipesTitle;

  /// No description provided for @searchFoodsHint.
  ///
  /// In en, this message translates to:
  /// **'Search foods…'**
  String get searchFoodsHint;

  /// No description provided for @perHundredGrams.
  ///
  /// In en, this message translates to:
  /// **'per 100g'**
  String get perHundredGrams;

  /// No description provided for @kcalPer100g.
  ///
  /// In en, this message translates to:
  /// **'{kcal} kcal / 100g'**
  String kcalPer100g(int kcal);

  /// No description provided for @unitG.
  ///
  /// In en, this message translates to:
  /// **'g'**
  String get unitG;

  /// No description provided for @unitKg.
  ///
  /// In en, this message translates to:
  /// **'kg'**
  String get unitKg;

  /// No description provided for @unitOz.
  ///
  /// In en, this message translates to:
  /// **'oz'**
  String get unitOz;

  /// No description provided for @unitLb.
  ///
  /// In en, this message translates to:
  /// **'lb'**
  String get unitLb;

  /// No description provided for @unitMl.
  ///
  /// In en, this message translates to:
  /// **'ml'**
  String get unitMl;

  /// No description provided for @unitL.
  ///
  /// In en, this message translates to:
  /// **'l'**
  String get unitL;

  /// No description provided for @unitTsp.
  ///
  /// In en, this message translates to:
  /// **'tsp'**
  String get unitTsp;

  /// No description provided for @unitTbsp.
  ///
  /// In en, this message translates to:
  /// **'tbsp'**
  String get unitTbsp;

  /// No description provided for @unitCup.
  ///
  /// In en, this message translates to:
  /// **'cup'**
  String get unitCup;

  /// No description provided for @unitFlOz.
  ///
  /// In en, this message translates to:
  /// **'fl oz'**
  String get unitFlOz;

  /// No description provided for @unitPiece.
  ///
  /// In en, this message translates to:
  /// **'piece'**
  String get unitPiece;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
