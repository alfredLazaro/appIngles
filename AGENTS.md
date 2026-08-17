# appaux — English Learning App (Flutter)

## Quick start commands

```bash
flutter pub get          # install dependencies
flutter run              # run on connected device/emulator
flutter analyze          # lint (uses package:flutter_lints/flutter.yaml, no custom rules)
flutter test             # run tests
flutter pub run flutter_launcher_icons:main  # regenerate app icon
```

## Architecture

**Clean Architecture, 4 layers:**

| Layer | Contents |
|---|---|
| `lib/presentation/` | BLoCs (10 total), Pages (13), Widgets |
| `lib/domain/` | Entities (23), Repository interfaces, Use cases, Service interfaces |
| `lib/data/` | DAOs, Remote services, Model/DTOs, Mappers, Repository implementations |
| `lib/core/` | DI (`get_it`), Constants, Services (TTS, STT, sync, connectivity), Utils |

Extra: `lib/docs/` holds markdown notes (`app-constants.md`, `refactor-results.md`).

**State management:** `flutter_bloc` — each feature has a `bloc/` dir with event + state + bloc files.

**DI:** `GetIt` singleton (`sl()`) wired in `lib/core/di/dependency_injection.dart`.

## Entrypoint

`lib/main.dart` — loads `assets/.env` via `flutter_dotenv` → calls `setupDependencies()` → runs `MyApp`.

**Package name:** `first_app` — all imports use `package:first_app/...`

## Database

- SQLite via `sqflite`, file: `database.db`, version 3
- 8 tables: `Word`, `Image`, `Translation`, `progress`, `outbox`, `users`, `app_preferences`, `daily_activity` with foreign keys (CASCADE deletes)
- Singleton `DatabaseService` in `lib/data/datasources/local/DataBaseHelper.dart`; constants (name/version/columns) in `lib/data/datasources/local/db_constants.dart`
- Streak/practice days come from `daily_activity` (user_id + date), written when a practice finishes; `progress.updated_at` is NOT used for streaks.

## External APIs

| Service | Env key | URL key |
|---|---|---|
| Dictionary | — | `BASE_URL_DICTIONARY` → dictionaryapi.dev |
| Unsplash | `KEY_UNS` | `URL_UNS` |
| Pexels | `KEY_PEX` | `URL_PEX` |
| Datamuse | — | `DATAMUSE_API` → api.datamuse.com |
| Translation (on-device) | — | ML Kit Translate (EN→ES, offline) |
| AssemblyAI | hardcoded in `assembly_ai_service.dart` | api.assemblyai.com (speech-to-text) |
| Sync server | — | `BASE_URL_SYNC` |

Note: `ASSEMPLYAI_API_KEY`, `API_KEY`, `API_DEE`/`URL_D` (DeepSeek) and `TRANS_URL2` (Apertium) are declared in `.env` but not referenced in code.

## Critical quirks

- **`.env` is committed** (`assets/.env`) with real-looking API keys — do not rotate or expose them.
- **`test/widget_test.dart` is fully commented out** (it's a template, not a real test). The only active test is `test/translation_mapper_test.dart`.
- **No CI workflows** exist (no `.github/workflows/`).
- **`assets/.env`** and **`assets/img_defecto.jpg`** are required at runtime and declared in `pubspec.yaml` assets.
- App icon configured inline in `pubspec.yaml` under `flutter_launcher_icons:` (image: `assets/iconos/icono_app.png`).

## Navigation

Root is `MainNavigationPage` (tab/bottom nav) with 3 tabs:
- **Aprender** → `word_learning_page.dart`
- **Practica** → `practice_selection_page.dart` → `practice_config_page.dart` → `flashcard_practice_page.dart`, `matching_practice_page.dart`, `listening_practice_page.dart` or `sentence_practice_page.dart`
- **Mis Palabras** → `word_list_page.dart`
