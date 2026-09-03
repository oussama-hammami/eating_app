# My Food This Week — Project Overview (Condensed)

_Short-form summary. Full detail: `PROJECT_DOCUMENTATION.md`._

## What it is
Flutter app (`eating_app`, title "My Food This Week"), Android/iOS. **Local-first, mostly offline**: user recipes/groceries/sharing are fully on-device; the one exception is that **community recipes are now fetched from a hosted Supabase table** at runtime instead of being hardcoded. No accounts, no login. No Dolby references anywhere in the repo.

## Core capabilities
- **Recipes**: create/edit/browse/delete, with name, meal type, portions, and **manually-entered** calories/protein/carbs/fat totals (`lib/features/recipes/`). Ingredients are simple free-text name + quantity pairs — no automatic nutrition lookup.
- **Groceries**: generates a deduplicated shopping list from selected recipes' ingredients (`lib/features/groceries/`).
- **Community recipes**: ~50 curated recipes, now served live from a Supabase table (`comminutyDishPropositions`) via a public read-only query, browsable/addable to the personal list.
- **Filtering**: recipes (personal or community) filterable by meal type and by calories/protein/carbs/fat ranges, read directly off each recipe's totals.
- **Sharing**: recipes encoded (JSON → gzip → base64) into a QR code; receiver scans via camera and imports (`lib/features/sharing/`).
- **Theming**: Material 3, light + dark mode following system setting, deep-plum/apricot/cream palette (`lib/core/theme/app_theme.dart`).
- **Localization**: English (canonical) + French; French has fewer ARB keys, likely incomplete.

## Architecture
- **No local database.** Recipes/groceries live only in in-memory widget state, same as before.
- **New: Supabase backend**, used *only* for community recipes (`lib/core/supabase/`, `lib/features/recipes/data/community_recipes_remote_data_source.dart`). Anonymous, public, read-only — no auth, no writes from the app.
- **State management**: plain `StatefulWidget`/`setState` throughout (`RootShell`, `RecipesTab`, `CommunityTab`, etc.). No Riverpod, no other state package.
- **No auth/accounts/roles** in the app. The Supabase schema has RLS policies anticipating per-user ownership (`auth.users`, `owner_id`) but nothing in the app uses them yet — forward-looking, unwired infrastructure.

## ⚠️ Security note
`.vscode/launch.json` has the Supabase anon/publishable key **hardcoded and committed to git**, even though `SupabaseConfig` itself is written to source the key from `--dart-define` specifically to keep it out of source control. This key is meant to be public-safe (protected by RLS), but committing it defeats the intended pattern and should be cleaned up (move to an untracked local launch config or a git-ignored `.env`).

## Biggest gap
**Recipes and the grocery list are still NOT persisted anywhere** — they live only in `RootShell`'s in-memory state and are lost on app restart. This predates the Supabase change and remains the single most consequential limitation.

## Other known issues
- `recipes_tab.dart` is a large file mixing UI/state/business logic.
- ~~`community_recipes.dart` dead code~~ — **fixed**: the old hardcoded recipe list was removed now that `CommunityTab` fetches from Supabase.
- Inconsistent table naming across the Supabase assets: the app and `schema.sql` use `comminutyDishPropositions`, but `supabase/seed/push_community_recipes.py` and a stray comment target `community_recipies` — needs reconciling.
- `supabase/seed/community_recipes.csv` has `photo_path` values pointing at Supabase Storage URLs, while the app's `Recipe.photoPath` still expects local asset paths — photo migration to remote storage looks intended but not yet wired into the UI.
- `test/widget_test.dart` boots `MyApp()` without calling `SupabaseConfig.initialize()` first; `CommunityTab` fetches from Supabase on `initState` — worth verifying this test still reliably passes rather than silently hitting the caught-error path.
- No tests for sharing or groceries features; test suite is still just the widget smoke test.
- Grocery quantity merging is naive regex/string matching, not unit-aware.
- Open TODO: privacy-policy URL points to a GitHub Pages repo not yet created (`recipes_tab.dart`).
- No CI config found.

## Where things live
| Feature | Code |
|---|---|
| Recipes | `lib/features/recipes/` |
| Groceries | `lib/features/groceries/` |
| Sharing (QR) | `lib/features/sharing/` |
| Supabase client/config | `lib/core/supabase/` |
| Supabase schema/seed data | `supabase/` |
| Top-level state/nav | `lib/app/root_shell.dart` |
| Theme/shared widgets | `lib/core/theme/`, `lib/core/widgets/` |
| Tests | `test/widget_test.dart` (only remaining test) |

## Dev commands
```
flutter pub get
flutter gen-l10n
flutter run --dart-define=SUPABASE_ANON_KEY=<your-anon-key>
flutter test
```
