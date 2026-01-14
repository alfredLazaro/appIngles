// sentence_builder_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/services/tts_service.dart';
import 'package:first_app/presentation/bloc/sentence_practice/sentence_practice_bloc.dart';

class SentenceBuilderWidget extends StatelessWidget {
  final int sentenceId;
  final String originalSentence;
  final TtsService ttsService;

  const SentenceBuilderWidget({
    super.key,
    required this.sentenceId,
    required this.originalSentence,
    required this.ttsService,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SentencePracticeBloc()
        ..add(InitializeSentenceEvent(
          sentenceId: sentenceId,
          originalSentence: originalSentence,
        )),
      child: BlocConsumer<SentencePracticeBloc, SentencePracticeState>(
        listener: (context, state) {
          if (state is SentencePracticeLoaded && state.showResult) {
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
        builder: (context, state) {
          if (state is! SentencePracticeLoaded) {
            return const Center(child: CircularProgressIndicator());
          }

          return _buildContent(context, state);
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, SentencePracticeLoaded state) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Stack(
        children: [
          Column(
            children: [
              // Audio hint card
              _buildAudioHint(context),
              const SizedBox(height: 12),

              // User sentence area
              _buildUserSentenceArea(context, state),
              const SizedBox(height: 24),

              // Available words
              _buildAvailableWords(context, state),
              const Spacer(),

              // Action buttons
              _buildActionButtons(context, state),
            ],
          ),

          // Show correct answer if wrong
          if (state.showResult && !state.isCorrect)
            _buildCorrectAnswer(state),
        ],
      ),
    );
  }

  Widget _buildAudioHint(BuildContext context) {
    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(2.0),
        child: Row(
          children: [
            const Icon(Icons.tips_and_updates, color: Colors.blue),
            const SizedBox(width: 5),
            const Expanded(
              child: Text(
                'Escucha y ordena las palabras:',
                style: TextStyle(fontSize: 16),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.volume_up, size: 28),
              color: Colors.blue,
              onPressed: () => ttsService.speak(originalSentence),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserSentenceArea(
    BuildContext context,
    SentencePracticeLoaded state,
  ) {
    return Container(
      width: double.infinity,
      height: 190,
      constraints: const BoxConstraints(minHeight: 120),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
        color: state.showResult
            ? (state.isCorrect ? Colors.green.shade50 : Colors.red.shade50)
            : Colors.white,
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Wrap(
            spacing: 8,
            runSpacing: -6,
            children: state.userSentence.isEmpty
                ? [
                    const Center(
                      child: Text(
                        'Toca las palabras para formar la oración',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  ]
                : state.userSentence
                    .asMap()
                    .entries
                    .map((entry) => _WordChip(
                          word: entry.value,
                          color: Colors.blue,
                          onTap: () {
                            context.read<SentencePracticeBloc>().add(
                                  RemoveWordFromSentenceEvent(entry.key),
                                );
                          },
                        ))
                    .toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableWords(
    BuildContext context,
    SentencePracticeLoaded state,
  ) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(1.0),
          child: Wrap(
            spacing: 5,
            runSpacing: -3,
            children: state.shuffledWords.asMap().entries.map((entry) {
              final index = entry.key;
              final word = entry.value;

              return Visibility(
                visible: state.wordVisibility[index],
                maintainSize: true,
                maintainAnimation: true,
                maintainState: true,
                child: _WordChip(
                  word: word,
                  color: const Color.fromARGB(255, 40, 37, 204),
                  onTap: () {
                    context.read<SentencePracticeBloc>().add(
                          AddWordToSentenceEvent(
                            word: word,
                            wordIndex: index,
                          ),
                        );
                  },
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    SentencePracticeLoaded state,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              context.read<SentencePracticeBloc>().add(
                    const ResetSentenceEvent(),
                  );
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Reiniciar'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: state.userSentence.isEmpty
                ? null
                : () {
                    context.read<SentencePracticeBloc>().add(
                          const CheckAnswerEvent(),
                        );
                  },
            icon: const Icon(Icons.check),
            label: const Text('Verificar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCorrectAnswer(SentencePracticeLoaded state) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.all(7),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green),
        ),
        child: Text(
          state.originalSentence,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 16.0,
          ),
          textScaler: const TextScaler.linear(0.9),
        ),
      ),
    );
  }
}

class _WordChip extends StatelessWidget {
  final String word;
  final Color color;
  final VoidCallback onTap;

  const _WordChip({
    required this.word,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Chip(
        label: Text(
          word,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 0),
      ),
    );
  }
}