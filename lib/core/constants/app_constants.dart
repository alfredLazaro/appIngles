import 'package:flutter/material.dart';

class FlashcardConstants {
  static const double defaultBorderRadius = 15.0;
  static const int flipAnimationDuration = 500;
  static const String tapToSeeWord = 'Tap to see word again';
  static const String learnedButtonLabel = 'Learned';
  static const String againButtonLabel = 'Again';
  static const String definitionLabel = 'Definition:';
  static const String exampleLabel = 'Example:';
  static const String testInputLabel = 'Aprendiste?';
  static const String noImageAvailable = 'assets/img_defecto.jpg';
  static const String wordNotFound = 'Word not found';
  static const String noSentenceAvailable = 'No sentence available';
  static const double wordFontSize = 48.0;
  static const double sentenceFontSize = 20.0;
  static const double hintImageHeight = 192.0;
  static const double inputFontSize = 24.0;
  static const double checkButtonHeight = 56.0;

  // Colors
  static const Color successContainer = Color(0xFFD1FAE5);
  static const Color successDark = Color(0xFF065F46);
  static const Color errorDark = Color(0xFF93000A);
  static const Color hintBg = Color(0xFFE0E3E6);
  static const Color inputBg = Color(0xFFF2F4F7);
  static const Color infoContainer = Color(0xFFDEE0FF);
  static const Color infoText = Color(0xFF2F3F92);
  static const Color controlBg = Color(0xFF5C6BC0);
  static const Color audioBtnBg = Color(0xFFC0C9FD);
}

class AppDurations {
  static const Duration pageTransition = Duration(milliseconds: 300);
  static const Duration snackbar = Duration(seconds: 2);
  static const Duration matchingTileAnimation = Duration(milliseconds: 200);
  static const Duration matchingFade = Duration(milliseconds: 500);
  static const Duration matchingFadeDelay = Duration(milliseconds: 800);
}

class AppLayout {
  // Border radii
  static const double radiusSmall = 4.0;
  static const double radiusMedium = 8.0;
  static const double radiusLarge = 12.0;
  static const double radiusXLarge = 16.0;
  static const double radiusXXLarge = 20.0;
  static const double radiusPill = 9999.0;

  // Page sizes
  static const int defaultPageSize = 3;
  static const int flashcardBatchSize = 3;
  static const int defaultWordLoadLimit = 9;
  static const int maxPracticeSelection = 30;
  static const int defaultPracticeCount = 10;
  static const List<int> practiceQuickSelect = [10, 15, 30, 50];
  static const List<int> audioPlayOptions = [0, 1, 3, -1];
  static const int defaultAudioPlays = 1;

  // Image grid
  static const int imageGridColumns = 3;

  // Dialog constraints
  static const double dialogInset = 20.0;
  static const double dialogMaxHeightRatio = 0.85;
  static const double dialogMinWidthRatio = 0.8;

  // Card
  static const double wordCardThumbSize = 75.0;

  // Text fields
  static const int bulkInsertMaxLines = 10;
  static const int bulkInsertMinLines = 6;
  static const int translationInputMaxLines = 6;
  static const int translationInputMinLines = 3;

  // Scroll
  static const double scrollLoadThreshold = 0.9;

  // Sentence builder
  static const double sentenceAreaHeight = 190.0;
  static const double availableWordsHeight = 260.0;
}

class AppColors {
  // Text
  static const Color textPrimary = Color(0xFF191C1E);
  static const Color textSecondary = Color(0xFF454651);
  static const Color textAccent = Color(0xFF535C89);

  // Primary
  static const Color primaryBlue = Color(0xFF4352A5);
  static const Color primaryDark = Color(0xFF2F3F92);

  // Status
  static const Color success = Color(0xFF006934);
  static const Color successLight = Color(0xFF6BFE9C);
  static const Color error = Color(0xFFBA1A1A);
  static const Color errorLight = Color(0xFFFFDAD6);

  // Matching
  static const Color surface = Color(0xFFFBF9F8);
  static const Color progressGreen = Color(0xFF22c55e);
  static const Color progressTrack = Color(0xFFE0E0FF);
  static const Color subtitleGrey = Color(0xFF767587);
  static const Color matchingTitle = Color(0xFF464556);
  static const Color matchingPrimary = Color.fromARGB(255, 39, 38, 63);

  // UI
  static const Color border = Color(0xFFC6C5D3);
  static const Color emptyImage = Color(0xFFE0E3E6);
  static const Color selectedBg = Color.fromARGB(255, 185, 213, 240);
  static const Color white = Colors.white;
}

class AppStrings {
  // Common
  static const String cancel = 'Cancelar';
  static const String save = 'Guardar';
  static const String delete = 'Eliminar';
  static const String update = 'Actualizar';
  static const String next = 'Siguiente';
  static const String previous = 'Anterior';
  static const String finish = 'Finalizar';
  static const String start = 'Comenzar';
  static const String retry = 'Reintentar';
  static const String back = 'Atrás';
  static const String add = 'Agregar';
  static const String search = 'Buscar';
  static const String close = 'Cerrar';
  static const String confirm = 'Agregar';

  // Feedback
  static const String correct = '¡Correcto!';
  static const String incorrect = 'Incorrecto';

  // Practice types
  static const String practiceFlashcards = 'Flashcards';
  static const String practiceMatching = 'Emparejar';
  static const String practiceMatchingDef = 'Emparejar-Definicion';
  static const String practiceListening = 'Listening';
  static const String practiceSentence = 'Ordenar Oraciones';
  static const String practiceSpelling = 'Spelling';
  static const String comingSoon = 'Próximamente';
  static const String selectPractice = 'Selecciona tu Práctica';

  // Practice prompts
  static const String promptFlashcards = '¿Cuántas palabras practicar?';
  static const String promptSentence = '¿Cuántas oraciones ordenar?';
  static const String promptListening = '¿Cuántas palabras escribir?';
  static const String promptMatching = '¿Cuántas palabras emparejar?';

  // Sections
  static const String words = 'Palabras';
  static const String translations = 'Traducciones';
  static const String definitions = 'Definiciones';
  static const String noTranslations = 'Sin traducciones';
}

class AppLimits {
  static const int learnMaxValue = 100;
  static const int learnLowMin = 1;
  static const int learnLowMax = 10;
  static const int learnMidMin = 11;
  static const int learnMidMax = 79;
  static const int learnHighMin = 80;
  static const int learnHighMax = 100;
}
