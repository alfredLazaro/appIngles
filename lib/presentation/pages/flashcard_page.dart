import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/services/tts_service.dart';
import 'package:first_app/domain/usecases/validate_word_answer.dart';
import 'package:first_app/domain/usecases/speak_text.dart';
import 'package:first_app/data/mappers/flashcard_mapper.dart';
import 'package:first_app/data/models/pf_ing_model.dart';
import 'package:first_app/data/models/image_model.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_bloc.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_state.dart';
import 'package:first_app/presentation/widgets/flashcard/english_flashcard.dart';

class FlashcardPage extends StatelessWidget {
  final PfIng wordData;
  final List<Image_Model> imgsData;

  const FlashcardPage({
    super.key,
    required this.wordData,
    required this.imgsData,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Flashcard')),
      body: BlocProvider(
        create: (context) {
          final ttsService = TtsService();
          final bloc = FlashcardBloc(
            validateWordAnswer: ValidateWordAnswer(),
            speakText: SpeakText(ttsService),
          );

          // Inicializar estado
          final word = FlashcardMapper.toEntity(wordData);
          final images = FlashcardMapper.imagesToEntities(imgsData);

          return bloc
            ..emit(FlashcardLoaded(
              word: word,
              images: images,
              showFront: true,
              learnCount: 0,
            ));
        },
        child: BlocListener<FlashcardBloc, FlashcardState>(
          listener: (context, state) {
            if (state is FlashcardAnswerValidated) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.isCorrect ? '¡Correcto! ✅' : 'Incorrecto ❌',
                  ),
                  backgroundColor: state.isCorrect ? Colors.green : Colors.red,
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
          child: const Center(
            child: EnglishFlashCard(),
          ),
        ),
      ),
    );
  }
}
