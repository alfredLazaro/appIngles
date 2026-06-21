import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/constants/app_constants.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_bloc.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_event.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_state.dart';
import 'flashcard_image.dart';

class FlashcardFront extends StatefulWidget {
  final FlashcardWord word;
  final List<FlashcardImage> images;
  final Color textColor;

  const FlashcardFront({
    super.key,
    required this.word,
    required this.images,
    required this.textColor,
  });

  @override
  State<FlashcardFront> createState() => _FlashcardFrontState();
}

class _FlashcardFrontState extends State<FlashcardFront> {
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blocState = context.watch<FlashcardBloc>().state;
    if (blocState is FlashcardLoaded && blocState.mode == FlashcardMode.test) {
      return _buildTestFront(context, blocState);
    }
    return _buildLearnFront(context);
  }

  Widget _buildLearnFront(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          constraints: BoxConstraints(
            minHeight: constraints.minHeight,
            maxWidth: constraints.maxWidth,
          ),
          padding: EdgeInsets.all((constraints.maxHeight * 0.02).clamp(6.0, 14.0)),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              FlashcardImageWidget(
                images: widget.images,
                height: (constraints.maxHeight * 0.5).clamp(120.0, 300.0),
              ),
              const SizedBox(height: 2),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.word.word.isNotEmpty ? widget.word.word : 'Word not found',
                    style: TextStyle(
                      fontSize: (constraints.maxHeight * 0.1).clamp(26.0, 48.0),
                      fontWeight: FontWeight.bold,
                      color: widget.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                FlashcardConstants.tapToSeeDefinition,
                style: TextStyle(
                  fontSize: (constraints.maxHeight * 0.02).clamp(10.0, 14.0),
                  fontStyle: FontStyle.italic,
                  color: widget.textColor.withOpacity(0.6),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTestFront(BuildContext context, FlashcardLoaded state) {
    final hasSubmitted = state.isAnswerCorrect != null;
    final isRevealed = state.isAnswerRevealed;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          padding: EdgeInsets.all((constraints.maxHeight * 0.02).clamp(12.0, 20.0)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Icon(
                Icons.menu_book,
                size: 28,
                color: Colors.grey[600],
              ),
              const SizedBox(height: 8),
              Text(
                'Escribe la palabra en inglés',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey[500],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Text(
                  widget.word.definition.isNotEmpty
                      ? widget.word.definition
                      : 'No definition available',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: IconButton.filled(
                  onPressed: () => context
                      .read<FlashcardBloc>()
                      .add(SpeakFlashcardText(widget.word.word)),
                  icon: const Icon(Icons.volume_up, size: 24),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.orange,
                    foregroundColor: Colors.white,
                  ),
                  tooltip: 'Escuchar palabra',
                ),
              ),
              const SizedBox(height: 12),
              if (!hasSubmitted && !isRevealed) ...[
                TextField(
                  controller: _controller,
                  textAlign: TextAlign.center,
                  textCapitalization: TextCapitalization.none,
                  decoration: InputDecoration(
                    hintText: 'Escribe la palabra aquí...',
                    filled: true,
                    fillColor: Colors.grey[50],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Colors.orange, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 14,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1.5,
                  ),
                  onSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      context.read<FlashcardBloc>().add(ValidateAnswer(value.trim()));
                    }
                  },
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.read<FlashcardBloc>().add(const RevealAnswer()),
                        icon: const Icon(Icons.visibility, size: 18),
                        label: const Text('Mostrar respuesta'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey[700],
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          final text = _controller.text.trim();
                          if (text.isNotEmpty) {
                            context.read<FlashcardBloc>().add(ValidateAnswer(text));
                          }
                        },
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Comprobar'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (hasSubmitted) _buildFeedback(state),
              if (isRevealed && !hasSubmitted)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Respuesta:',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.blue[800],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              widget.word.word,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[900],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 8),
              Text(
                'Toca la tarjeta para ver la respuesta completa',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFeedback(FlashcardLoaded state) {
    final isCorrect = state.isAnswerCorrect!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color: isCorrect ? Colors.green : Colors.red,
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isCorrect ? '¡Correcto! (+3)' : 'Incorrecto (-1)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isCorrect ? Colors.green[800] : Colors.red[800],
                  ),
                ),
                if (!isCorrect)
                  Text(
                    'Correcto: ${state.word.word}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.red[700],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
