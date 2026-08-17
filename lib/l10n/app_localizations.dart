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
  /// **'Eating App'**
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

  /// No description provided for @navDiary.
  ///
  /// In en, this message translates to:
  /// **'Diary'**
  String get navDiary;

  /// No description provided for @navCommunity.
  ///
  /// In en, this message translates to:
  /// **'Community'**
  String get navCommunity;

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

  /// No description provided for @communityLoadingNutrition.
  ///
  /// In en, this message translates to:
  /// **'Calculating nutrition from ingredients…'**
  String get communityLoadingNutrition;

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

  /// No description provided for @quantity.
  ///
  /// In en, this message translates to:
  /// **'Quantity'**
  String get quantity;

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

  /// No description provided for @foodDiaryTitle.
  ///
  /// In en, this message translates to:
  /// **'Food Diary'**
  String get foodDiaryTitle;

  /// No description provided for @searchFoodsHint.
  ///
  /// In en, this message translates to:
  /// **'Search foods…'**
  String get searchFoodsHint;

  /// No description provided for @searchErrorLabel.
  ///
  /// In en, this message translates to:
  /// **'Search error: {error}'**
  String searchErrorLabel(String error);

  /// No description provided for @noFoodsLoggedToday.
  ///
  /// In en, this message translates to:
  /// **'No foods logged yet today.'**
  String get noFoodsLoggedToday;

  /// No description provided for @errorLabel.
  ///
  /// In en, this message translates to:
  /// **'Error: {error}'**
  String errorLabel(String error);

  /// No description provided for @quantityGrams.
  ///
  /// In en, this message translates to:
  /// **'Quantity (grams)'**
  String get quantityGrams;

  /// No description provided for @quantityValidatorMessage.
  ///
  /// In en, this message translates to:
  /// **'Enter a quantity greater than 0'**
  String get quantityValidatorMessage;

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

  /// No description provided for @mealEntrySubtitle.
  ///
  /// In en, this message translates to:
  /// **'{amount} · {calories} kcal · P {protein}g · C {carbs}g · F {fat}g'**
  String mealEntrySubtitle(
    String amount,
    int calories,
    String protein,
    String carbs,
    String fat,
  );

  /// No description provided for @statCalories.
  ///
  /// In en, this message translates to:
  /// **'Calories'**
  String get statCalories;

  /// No description provided for @statProtein.
  ///
  /// In en, this message translates to:
  /// **'Protein'**
  String get statProtein;

  /// No description provided for @statCarbs.
  ///
  /// In en, this message translates to:
  /// **'Carbs'**
  String get statCarbs;

  /// No description provided for @statFat.
  ///
  /// In en, this message translates to:
  /// **'Fat'**
  String get statFat;

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
