# My Food This Week — Project Overview (Condensed)

_Short-form summary. Full detail, including a complete file-and-line-grounded optimization playbook: `PROJECT_DOCUMENTATION.md`. Updated 2026-09-06 after a 7-area code review (each area independently re-verified) that corrected several stale claims in this document and added the Weekly Planner feature, which was missing entirely._

## What it is
Flutter app (`eating_app`, title "My Food This Week"), Android/iOS. **Local-first**: recipes, groceries, the weekly meal plan, and sharing are all on-device; the one exception is that **community recipes are fetched from a hosted Supabase table** at runtime. No accounts, no login. No Dolby references anywhere in the repo (re-confirmed).

## Correction from prior documentation
Earlier versions of this document said recipes/groceries are **not persisted** and that the Community tab has **no offline fallback**. **Both claims are wrong.** `lib/app/local_storage.dart` is a full `shared_preferences`-backed persistence layer (recipes, groceries, weekly meal plan, grocery-source-recipe tracking, and a community-recipe offline cache), and `CommunityTab` already falls back to that cache with a retry banner when the Supabase fetch fails. The real remaining gaps are different ones — see below.

## Core capabilities
- **Recipes**: create/edit/browse/delete, manually-entered calories/protein/carbs/fat (`lib/features/recipes/`).
- **Groceries**: deduplicated shopping list from selected recipes or a planned week (`lib/features/groceries/`) — has three verified quantity-combination bugs, see below.
- **Weekly Planner** (new in this revision of the doc, not new in the code): assign recipes to day/meal-slot across a week, see daily macro totals, generate groceries from the week, share/scan a whole week via QR (`lib/features/planner/`).
- **Community recipes**: ~50 curated recipes served live from Supabase (`comminutyDishPropositions`), fetched independently (and redundantly) by both the Community tab and the planner's recipe picker.
- **Filtering**: by meal type and calorie/protein/carb/fat ranges — implemented three separate times (Recipes tab, Community tab, planner's recipe picker) instead of shared.
- **Sharing**: recipes and whole weekly plans encoded (JSON → gzip → base64) into a QR code, scanned via camera and imported.
- **Theming**: Material 3, light + dark mode following system setting.
- **Localization**: English (canonical) + French; French likely has fewer keys, especially for newer planner strings.

## Architecture
- **State management**: one top-level `StatefulWidget` (`RootShell`) owns all state (`_recipes`, `_groceries`, `_mealPlan`, plus grocery-source-recipe tracking) via plain `setState`. No Riverpod/Provider/Bloc.
- **Persistence**: `shared_preferences` via `LocalStorage` (`lib/app/local_storage.dart`) — five keys, all fire-and-forget writes with no error handling and no schema versioning.
- **Backend**: Supabase, used only for anonymous, read-only community-recipe fetches. No auth, no writes from the app.
- **Navigation**: a 4-tab `IndexedStack` (Recipes / Groceries / Planner / Community) that builds all four tabs eagerly — a single grocery-checkbox toggle rebuilds all four.

## Top verified issues to fix (full detail and file:line in `PROJECT_DOCUMENTATION.md` §25)

**Correctness bugs (real, reproduced by hand):**
1. Grocery-quantity combination only ever merges one unit; a third distinct unit never combines with earlier ones of the same unit (`combine_quantities.dart:17`).
2. Fractional quantities like `"1/2 cup"` are silently corrupted into a nonsensical unit (`combine_quantities.dart:5`, same bug in `scale_quantity.dart:9`).
3. Both QR-scan screens (recipes and weekly plans) silently swallow invalid codes with zero user feedback — the app looks frozen (`scan_recipes_screen.dart:36`, `scan_meal_plan_screen.dart:35`).
4. Both QR-share screens can silently render a blank box for an oversized payload with no error message (`share_recipes_screen.dart:39`, `share_meal_plan_screen.dart:43`).
5. `LocalStorage` has no error handling on any load path — one corrupted stored value can block all persisted state from loading at startup (`local_storage.dart:22,40,60,78,99`).
6. Every persistence write across `RootShell` is unawaited and uncaught — a failed disk write is silently indistinguishable from success.

**Performance:**
- `IndexedStack` rebuilds all 4 tabs on any single `setState`, including a single grocery-checkbox toggle (`root_shell.dart:257-289`).
- Every search keystroke rebuilds the whole tab and re-filters from scratch, in all three places search is implemented, with no debounce.
- `CommunityTab`'s Supabase fetch fires on every cold start regardless of which tab is opened, because `IndexedStack` builds all children up front.

**Architecture:**
- Recipe search/filter/browse UI and community-recipe fetching are each independently implemented **three times** (Recipes tab, Community tab, planner's recipe picker) and have already visibly drifted — the picker's tile is missing the photo and protein chip the other two show.
- `recipes_tab.dart` is 868 lines mixing UI, state, and two full inline dialogs.
- Grocery merge/generate business logic lives directly in `RootShell` rather than as a testable domain usecase.

**Testing:**
- The app's only widget test currently **fails** (`flutter test`: 9 pass, 1 fails) — `CommunityTab` fetches from an uninitialized Supabase client in the test environment and the test times out on `pumpAndSettle`.
- The entire Weekly Planner feature, including `MealPlanShareCodec` (which explicitly mirrors the already-tested `RecipeShareCodec`), has zero tests.
- The existing grocery-combination test only covers 2-element cases — it misses every case that would reveal the bugs above.

**Security/maintenance:**
- The previously-flagged committed Supabase key in `.vscode/launch.json` **is fixed** — it now reads from the environment.
- `share_plus` is 3 majors behind, `mobile_scanner` is 1 major behind; `SupabaseConfig` uses a deprecated `anonKey` parameter (`flutter analyze`'s one reported issue).

## Where things live
| Feature | Code |
|---|---|
| Recipes | `lib/features/recipes/` |
| Groceries | `lib/features/groceries/` |
| Weekly Planner | `lib/features/planner/` |
| Sharing (recipes + weekly plans, QR) | `lib/features/sharing/`, `lib/features/planner/domain/meal_plan_share_codec.dart` |
| Supabase client/config | `lib/core/supabase/` |
| Supabase schema/seed data | `supabase/` |
| Top-level state/nav | `lib/app/root_shell.dart` |
| Local persistence | `lib/app/local_storage.dart` |
| Theme/shared widgets | `lib/core/theme/`, `lib/core/widgets/` |
| Tests | `test/widget_test.dart` (currently failing), `test/features/groceries/`, `test/features/sharing/` |

## Dev commands
```
flutter pub get
flutter gen-l10n
flutter run --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
flutter test
flutter analyze
```
