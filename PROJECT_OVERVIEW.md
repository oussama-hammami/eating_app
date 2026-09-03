# My Food This Week — Project Overview (Condensed)

_Short-form summary. Full detail: `PROJECT_DOCUMENTATION.md`._

## What it is
Flutter app (`eating_app`, title "My Food This Week"), Android/iOS. **Fully offline** — no backend, no accounts, no network calls except opening a static privacy-policy webpage. No Dolby references anywhere in the repo.

## Core capabilities
- **Recipes**: create/edit/browse/delete, with name, meal type, portions, and **manually-entered** calories/protein/carbs/fat totals (`lib/features/recipes/`). Ingredients are simple free-text name + quantity pairs — no automatic nutrition lookup.
- **Groceries**: generates a deduplicated shopping list from selected recipes' ingredients (`lib/features/groceries/`).
- **Community recipes**: ~50 hardcoded curated recipes with fixed nutrition values, browsable/addable to personal list.
- **Filtering**: recipes (personal or community) filterable by meal type and by calories/protein/carbs/fat ranges, read directly off each recipe's totals.
- **Sharing**: recipes encoded (JSON → gzip → base64) into a QR code; receiver scans via camera and imports (`lib/features/sharing/`).
- **Localization**: English (canonical) + French; French has fewer ARB keys, likely incomplete.

## Architecture
- **No local database.** The CIQUAL nutrition database, the food-matching/unit-conversion engine, and sqflite were **fully removed** (see Recent Change below). All recipe/ingredient data lives only in in-memory widget state.
- **State management**: plain `StatefulWidget`/`setState` throughout (`RootShell`, `RecipesTab`, `CommunityTab`, etc.). Riverpod was removed along with the nutrition feature — no longer a dependency.
- **No auth/accounts/roles** anywhere.

## Recent change: nutrition/CIQUAL feature removed
The app previously matched free-text ingredients against a bundled CIQUAL SQLite database to auto-compute nutrition. This entire capability has been **deleted**:
- Removed: `lib/features/nutrition/`, `lib/core/database/`, `lib/core/units/`, `lib/core/text/`, `assets/db/nutrition.db`, `food_bd/` (raw CIQUAL source), `tool/community_dev/` (dev tool that only existed to drive the matcher), and all nutrition-engine tests.
- Removed dependencies: `sqflite`, `sqflite_common_ffi`, `path_provider`, `path`, `flutter_riverpod`, `file_picker`.
- Adapted: `Ingredient` simplified to `{name, quantity}`; recipe ingredient entry is now plain text fields instead of live food-search; `RecipeFilter` now reads nutrient ranges off `Recipe`-level totals instead of summing per-ingredient values (fiber filtering was dropped, no field left to filter on); `main.dart` no longer bootstraps a database or `ProviderScope`.
- Verified clean: `flutter analyze` (no issues) and `flutter test` (passing) after the change.

## Biggest gap
**Recipes and the grocery list are still NOT persisted anywhere** — they live only in `RootShell`'s in-memory state and are lost on app restart. This was true before the nutrition removal and remains the single most consequential limitation.

## Other known issues
- `recipes_tab.dart` is a large file mixing UI/state/business logic.
- No tests for sharing or groceries features; test suite is now just the widget smoke test (`test/widget_test.dart`) since all nutrition-engine tests were removed with the feature.
- Grocery quantity merging is naive regex/string matching, not unit-aware.
- Open TODO: privacy-policy URL points to a GitHub Pages repo not yet created (`recipes_tab.dart`).
- No CI config found.

## Where things live
| Feature | Code |
|---|---|
| Recipes | `lib/features/recipes/` |
| Groceries | `lib/features/groceries/` |
| Sharing (QR) | `lib/features/sharing/` |
| Top-level state/nav | `lib/app/root_shell.dart` |
| Theme/shared widgets | `lib/core/theme/`, `lib/core/widgets/` |
| Tests | `test/widget_test.dart` (only remaining test) |

## Dev commands
```
flutter pub get
flutter gen-l10n
flutter run
flutter test
```
