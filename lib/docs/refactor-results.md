# Análisis de `/presentation`

## `/pages` — 10 pantallas

| Archivo (líneas) | Responsabilidad |
|---|---|
| `main_navigation_page.dart` (53L) | **Contenedor raíz** con `BottomNavigationBar` de 3 tabs: Aprender, Practica, Mis Palabras. Estado local con `_currentIndex`. |
| `word_learning_page.dart` (350L) | **Tab "Aprender"** — entrada de palabra (texto/STT), búsqueda de definiciones+imágenes, diálogo combinado para guardar. También lista palabras recientes con edición/copia/eliminación. Maneja `_cachedWords`, `_selecteWords`, `_tempDefinitions`, `_tempImages`. |
| `practice_selection_page.dart` (120L) | **Menú de tipos de práctica** — 6 opciones (Flashcards, Emparejar, Emparejar-Definición, Listening, Ordenar Oraciones, Spelling). Enumeración `PracticeType`. |
| `practice_config_page.dart` (152L) | **Puente de configuración** — carga datos vía `PracticeBloc`, muestra modal de selección de cantidad, redirige a la página de práctica correspondiente. |
| `word_list_page.dart` (89L) | **Tab "Mis Palabras"** — lista paginada de palabras vía `ListaCards`, acceso a prácticas y estadísticas (`WordStatsWidget`). |
| `word_detail_screen.dart` (516L) | **Detalle/edición de palabra** — imágenes (PageView con autor), campos editables, sección de traducciones, progreso, TTS. Estado local: `_isEditing`, `_localTranslations`, `_translationsToDelete`. |
| `flashcard_practice_page.dart` (221L) | **Práctica de flashcards** — modos learn/practice, navegación entre sesiones, progreso, diálogo completado. Crea su propio `FlashcardBloc`. |
| `sentence_practice_page.dart` (147L) | **Práctica de ordenar oraciones** — `PageView` con `SentenceBuilderWidget`, navegación, diálogo completado. Estado local: `_currentIndex`. |
| `listening_practice_page.dart` (418L) | **Práctica de listening** — definición, botón de audio con límite, input, feedback correcto/incorrecto. Crea su propio `ListeningBloc`. |
| `matching_practice_page.dart` (226L) | **Práctica de emparejar** — rondas de matching (palabra↔traducción o palabra↔definición), animaciones, progreso, resultados. Crea su propio `MatchingBloc`. |

---

## `/widgets` — 21 widgets + 7 subdirectorios

### `flashcard/` (7 widgets)

| Widget | Rol |
|---|---|
| `english_flashcard.dart` | Flashcard en modo "practicar" (anverso + reverso con info) |
| `flashcard_back.dart` | Reverso: definición, oración, traducciones |
| `flashcard_front.dart` | Anverso: palabra, fonética, imagen |
| `flashcard_controls.dart` | Controles de navegación + acciones (sí/no sé, voltear) |
| `flashcard_image.dart` | Imagen dentro del flashcard |
| `flashcard_word.dart` | `WordFlashcard` — modo "aprender" (solo palabra + imagen) |
| `word_test_input.dart` | Input para respuesta escrita en modo test |

### `listshort/` (4 widgets)

| Widget | Rol |
|---|---|
| `word_list_item.dart` | Item individual en lista de palabras |
| `word_list_section.dart` | Sección de lista paginada |
| `pagination_controls.dart` | Controles anterior/siguiente |
| `EditDialog.dart` | Diálogo para editar oración |

### `sentence/` (2 widgets)

| Widget | Rol |
|---|---|
| `sentence_builder.dart` | Juego de ordenar palabras para formar una oración |
| `word_stats_widget.dart` | Estadísticas aprendidas/totales |

### `dialogs/` (4 widgets)

| Widget | Rol |
|---|---|
| `completion_dialog.dart` | Diálogo genérico de completado |
| `delete_confirmation_dialog.dart` | Confirmación de eliminación |
| `Dialog_Image.dart` | Visor de imagen en diálogo |
| `Dialog_inform.dart` | Diálogo informativo genérico |

### `modals/` (5 widgets)

| Widget | Rol |
|---|---|
| `combine_word_dialog.dart` | Diálogo combinado nueva palabra (definición, imagen, traducción) |
| `image_search_dialog.dart` | Búsqueda de imágenes (Unsplash) |
| `practice_card.dart` | Tarjeta de tipo de práctica |
| `practice_selection_modal.dart` | Modal para elegir cantidad de palabras |
| `translation_bulk_insert_dialog.dart` | Inserción masiva de traducciones |

### `translation/` (1 widget)

| Widget | Rol |
|---|---|
| `translation_text_input_widget.dart` | Input para agregar traducción |

### `controlers/` (1 widget)

| Widget | Rol |
|---|---|
| `page_navegation_controls.dart` | Barra de navegación inferior genérica |

### Raíz de `widgets/` (14 widgets)

| Widget | Rol |
|---|---|
| `author_info_button.dart` | Botón con info del autor de imagen |
| `bulk_insert_dialog.dart` | Diálogo de inserción masiva de palabras |
| `image_selection_grid.dart` | Grid de selección de imágenes |
| `learn_progress_indicator.dart` | Indicador circular de progreso |
| `ListaCards.dart` | Lista principal de palabras (usada en `word_list_page`) |
| `matching_animation_controller.dart` | Controlador de animaciones para matching |
| `matching_definition_layout.dart` | Layout matching palabra↔definición |
| `matching_progress_bar.dart` | Barra de progreso de matching |
| `matching_results_widget.dart` | Resultados finales de matching |
| `matching_tile.dart` | Tile individual de matching |
| `matching_translation_layout.dart` | Layout matching palabra↔traducción |
| `translation_section.dart` | Sección de traducciones editable |
| `word_input_section.dart` | Input de palabra con STT y guardar |
| `WordCard.dart` | Card de palabra (posiblemente obsoleto) |

---

## `/bloc` — 9 BLoCs

| BLoC | Eventos clave |
|---|---|
| `word_list/` | `LoadWordsEvent`, `RefreshWordsEvent` |
| `word_learning/` | `SearchWordEvent`, `SaveNewWordEvent`, `LoadRecentWordsEvent`, `DeleteWordEvent`, `UpdateWordSentenceEvent`, `FetchWordsEvent` |
| `word_detail/` | `LoadWordDetailEvent`, `SaveWordDetailEvent`, `DeleteWordDetailEvent`, `AddImagesToWordEvent` |
| `practice/` | `LoadPracticeDataEvent`, `StartPracticeEvent`, `FinishPracticeEvent` |
| `flashcard/` | `InitializeSession`, `NextFlashcard`, `PreviousFlashcard`, `SubmitAnswer` |
| `sentence_practice/` | (por leer) |
| `listening/` | `InitializeListening`, `SubmitListeningAnswer`, `NextListeningWord`, `PlayCurrentWordAudioListening` |
| `matching/` | `InitializeMatching`, `SelectLeftTile`, `SelectRightTile`, `NextMatchingRound` |
| `translation/` | (por leer) |

---

## Observaciones

1. **`word_learning_page.dart` (350L) y `word_detail_screen.dart` (516L)** son los más grandes, mezclando UI + estado local + diálogos + clipboard + STT.

2. **Duplicación de patrón**: `flashcard_practice_page`, `listening_practice_page`, `sentence_practice_page` comparten AppBar con %, `LinearProgressIndicator`, `PageNavigationControls`, `CompletionDialog`. Abstraíble en layout base.

3. **Pages gordas vs delgadas**: `word_list_page.dart` (89L) delega casi todo a `ListaCards`, mientras `listening_practice_page.dart` (418L) tiene mucho inline (`_buildDefinitionCard`, `_buildAudioButton`, etc.).

4. **Nombres inconsistentes**: `ListaCards.dart` (español), `Dialog_Image.dart` (PascalCase con guion bajo), `controlers` (typo → "controllers").

5. **Posibles widgets huérfanos**: `WordCard.dart`, `Dialog_Image.dart`, `Dialog_inform.dart`.
