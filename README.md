# appaux
English Learning App (Flutter)
ARCHITECTURE: Clean Architecture | 4 layers | Presentation/Domain/Data/Core
LAYERS:
- Presentation: BLoC (word_list, flashcard,sentence, practice, word_learning) | Pages | Widgets
- Domain: Entities | Repository Interfaces | Usecases
- Data: Datasources (local (Database_helper, Daos)/remote) | Models | Mappers | Repository Implementations
- Core: Services (dictionary, image) | Utils (text_validator) | Constants
DATABASE SCHEMA (SQLite):
1. **words** | id:INTEGER PRIMARY KEY AUTOINCREMENT | word:TEXT NOT NULL | definition:TEXT NOT NULL | sentence:TEXT NOT NULL | learn:INTEGER DEFAULT 0 | created_at:TEXT DEFAULT CURRENT_TIMESTAMP | updated_at:TEXT DEFAULT CURRENT_TIMESTAMP
2. **images** | id:INTEGER PRIMARY KEY AUTOINCREMENT | wordId:INTEGER | name:TEXT | url:TEXT | tinyurl:TEXT | author:TEXT | source:TEXT | FOREIGN KEY (wordId) REFERENCES words(id) ON DELETE CASCADE
3. **translations** | id:INTEGER PRIMARY KEY AUTOINCREMENT | wordTranslate:TEXT | wordId:INTEGER | alternatives:TEXT | FOREIGN KEY (wordId) REFERENCES words(id) ON DELETE CASCADE
DOMAIN ENTITIES:
1. WordMeaning | partOfSpeech:String | definitions:List<WordDefinition> 
2. WordSummary | id:int? | word:String | sentence:String
3. WordImage | id:int? | url:String | tinyUrl:String | author:String | source:String | name:String
4. WordWithImage | id:int| word:String | tinyUrl:String | definition:String | learn:int
5. FlashcardWord
6. FlashcardImage
7. PaginatedResult<T> | items:List<T> | total:int | page:int | pageSize:int | hasNextPage:bool
ENTITY RELATIONSHIPS:
- WordWithImage | Used in lists for performance
- FlashcardWord/FlashcardImage | Specialized for exercise display
- PaginatedResult | Used in word_list_page for infinite scroll
EXTERNAL APIS:
1. Dictionary API | Returns WordMeaning data
2. Image API 
APP PAGES (7 total):
1. main_navigation_page | Root navigation (tab/bottom nav)
2. word_list_page | Uses PaginatedResult<WordWithImage> for list
3. word_learning_page | Use inputText and Widget( WordListSeccion)
4. practice_selection_page | Choose exercise type
5. practice_config_page | Configure ExerciseConfig
6. flashcard_practice_page | Uses FlashcardWord/FlashcardImage entities
7. sentence_practice_page
NAVIGATION FLOW:
main_navigation_page → Word List → word_list_page
main_navigation_page → Learn New → word_learning_page  
main_navigation_page → Practice → practice_selection_page → practice_config_page → [flashcard_practice_page OR sentence_practice_page]
EXERCISE TYPES:
1. Flashcard Practice
2. Sentence Practice
CURRENT FOCUS:
- 
KEY FILES:
- lib/domain/entities/ | All entity files
- lib/data/datasources/local/database_helper.dart | Database setup
- lib/data/models/word_model.dart, image_model.dart | Data model
- lib/domain/usecases/word  | Business logic
- lib/domain/usecases/image | Business logic
- lib/presentation/bloc/word_list_bloc/ | Uses PaginatedResult
- lib/presentation/bloc/flashcard_bloc/ | Uses FlashcardWord/FlashcardImage
- lib/presentation/bloc/practice_bloc/
DEPENDENCIES:
- flutter_bloc: ^8.0.0
- sqflite: ^2.0.0
- dio: ^5.0.0
DATA FLOWS:
Exercise: practice_selection_page → Choose type → practice_config_page → Configure → Generate entities → [flashcard_practice_page OR sentence_practice_page]

