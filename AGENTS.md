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
| `lib/presentation/` | BLoCs (9 total), Pages (10), Widgets |
| `lib/domain/` | Entities (18), Repository interfaces, Use cases, Service interfaces |
| `lib/data/` | DAOs, Remote services, Model/DTOs, Mappers, Repository implementations |
| `lib/core/` | DI (`get_it`), Constants, Services (TTS, STT), Utils |

**State management:** `flutter_bloc` — each feature has a `bloc/` dir with event + state + bloc files.

**DI:** `GetIt` singleton (`sl()`) wired in `lib/core/di/dependency_injection.dart`.

## Entrypoint

`lib/main.dart` — loads `assets/.env` via `flutter_dotenv` → calls `setupDependencies()` → runs `MyApp`.

**Package name:** `first_app` — all imports use `package:first_app/...`

## Database

- SQLite via `sqflite`, file: `database.db`, version 1
- 3 tables: `Word`, `Image`, `Translation` with foreign keys (CASCADE deletes)
- Singleton `DatabaseService` in `lib/data/datasources/local/DataBaseHelper.dart`

## External APIs

| Service | Env key | URL key |
|---|---|---|
| Dictionary | `ASSEMPLYAI_API_KEY`? | `BASE_URL_DICTIONARY` → dictionaryapi.dev |
| Unsplash | `KEY_UNS` | `URL_UNS` |
| Translation | — | `TRANSL_URL` → libretranslate.com |
| AssemblyAI | `ASSEMPLYAI_API_KEY` | (speech-to-text) |
| DeepSeek | `API_DEE` | `URL_D` |

## Critical quirks

- **`.env` is committed** (`assets/.env`) with real-looking API keys — do not rotate or expose them.
- **The only test file** (`test/widget_test.dart`) is **fully commented out** — any new test must be written from scratch.
- **No CI workflows** exist (no `.github/workflows/`).
- **`assets/.env`** and **`assets/img_defecto.jpg`** are required at runtime and declared in `pubspec.yaml` assets.
- App icon configured inline in `pubspec.yaml` under `flutter_launcher_icons:` (image: `assets/iconos/icono_app.png`).

## Navigation

Root is `MainNavigationPage` (tab/bottom nav) with 3 tabs:
- **Word List** → `word_list_page.dart`
- **Learn New** → `word_learning_page.dart`
- **Practice** → `practice_selection_page.dart` → `practice_config_page.dart` → `flashcard_practice_page.dart` or `sentence_practice_page.dart`
