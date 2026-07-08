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
        return Column(
          children: [
            if (widget.images.isNotEmpty)
              SizedBox(
                height: (constraints.maxHeight * 0.5).clamp(120.0, 300.0),
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: FlashcardImageWidget(
                    images: widget.images,
                    height: (constraints.maxHeight * 0.5).clamp(120.0, 300.0),
                  ),
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(
                    (constraints.maxHeight * 0.02).clamp(6.0, 14.0)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          widget.word.word.isNotEmpty
                              ? widget.word.word
                              : 'Word not found',
                          style: TextStyle(
                            fontSize:
                                (constraints.maxHeight * 0.1).clamp(26.0, 48.0),
                            fontWeight: FontWeight.bold,
                            color: widget.textColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      FlashcardConstants.tapToSeeDefinition,
                      style: TextStyle(
                        fontSize:
                            (constraints.maxHeight * 0.02).clamp(10.0, 14.0),
                        fontStyle: FontStyle.italic,
                        color: widget.textColor.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTestFront(BuildContext context, FlashcardLoaded state) {
    final hasSubmitted = state.isAnswerCorrect != null;
    final isRevealed = state.isAnswerRevealed;
    final isCorrect = state.isAnswerCorrect ?? false;

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHintImage(context),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildDefinition(),
                    const SizedBox(height: 24),
                    if (!hasSubmitted && !isRevealed) ...[
                      _buildInputSection(context, state),
                    ],
                    if (hasSubmitted) ...[
                      _buildResultFeedback(state),
                      const SizedBox(height: 16),
                      if (!isCorrect)
                        _buildInputSection(context, state),
                    ],
                    if (isRevealed && !hasSubmitted) ...[
                      _buildRevealedAnswer(state),
                    ],
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHintImage(BuildContext context) {
    final hasImage = widget.images.isNotEmpty;
    return SizedBox(
      height: 192,
      child: Stack(
        children: [
          if (hasImage)
            Positioned.fill(
              child: ColorFiltered(
                colorFilter: const ColorFilter.matrix(<double>[
                  0.33,
                  0.33,
                  0.33,
                  0,
                  0,
                  0.33,
                  0.33,
                  0.33,
                  0,
                  0,
                  0.33,
                  0.33,
                  0.33,
                  0,
                  0,
                  0,
                  0,
                  0,
                  1,
                  0,
                ]),
                child: Image.network(
                  widget.images.first.url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    color: const Color(0xFFE0E3E6),
                  ),
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: const Color(0xFFE0E3E6),
                      child: const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    );
                  },
                ),
              ),
            )
          else
            Container(color: const Color(0xFFE0E3E6)),
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.white,
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefinition() {
    return Text(
      widget.word.definition.isNotEmpty
          ? widget.word.definition
          : 'No definition available',
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w400,
        height: 1.6,
        fontStyle: FontStyle.italic,
        color: Color(0xFF191C1E),
      ),
    );
  }

  Widget _buildInputSection(BuildContext context, FlashcardLoaded state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'ESCRIBE LA PALABRA',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.05,
            color: Color(0xFF454651),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.none,
          decoration: InputDecoration(
            hintText: '...',
            hintStyle: const TextStyle(color: Colors.black26),
            filled: true,
            fillColor: const Color(0xFFF2F4F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFC6C5D3)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFC6C5D3)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF4352A5), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
            color: Color(0xFF191C1E),
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              context.read<FlashcardBloc>().add(ValidateAnswer(value.trim()));
            }
          },
        ),
        const SizedBox(height: 16),
        _buildFeedbackArea(context, state),
        const SizedBox(height: 16),
        SizedBox(
          height: 56,
          child: ElevatedButton.icon(
            onPressed: () {
              final text = _controller.text.trim();
              if (text.isNotEmpty) {
                context.read<FlashcardBloc>().add(ValidateAnswer(text.trim()));
              }
            },
            icon: const Icon(Icons.check_circle, size: 20),
            label: const Text(
              'Comprobar',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4352A5),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: const Color(0xFF4352A5).withOpacity(0.3),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: TextButton(
            onPressed: () =>
                context.read<FlashcardBloc>().add(const RevealAnswer()),
            child: const Text(
              'Mostrar respuesta',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF454651),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFeedbackArea(BuildContext context, FlashcardLoaded state) {
    final hasSubmitted = state.isAnswerCorrect != null;
    final isCorrect = state.isAnswerCorrect ?? false;

    if (hasSubmitted) {
      if (isCorrect) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFD1FAE5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.check_circle,
                size: 20,
                color: Color(0xFF059669),
              ),
              const SizedBox(width: 8),
              const Text(
                '¡Correcto! Excelente memoria.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF065F46),
                ),
              ),
            ],
          ),
        );
      }
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFDAD6),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.error,
              size: 20,
              color: Color(0xFF93000A),
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'Casi... Inténtalo de nuevo.',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF93000A),
                ),
              ),
            ),
            Text(
              state.word.word,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Color(0xFF93000A),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFECEFF1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.info_outline,
            size: 20,
            color: Color(0xFF454651),
          ),
          const SizedBox(width: 8),
          const Text(
            'Toca comprobar para validar',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF454651),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultFeedback(FlashcardLoaded state) {
    final isCorrect = state.isAnswerCorrect!;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isCorrect ? const Color(0xFFD1FAE5) : const Color(0xFFFFDAD6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCorrect ? const Color(0xFF059669) : const Color(0xFFBA1A1A),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCorrect ? Icons.check_circle : Icons.cancel,
            color:
                isCorrect ? const Color(0xFF059669) : const Color(0xFFBA1A1A),
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
                    color: isCorrect
                        ? const Color(0xFF065F46)
                        : const Color(0xFF93000A),
                  ),
                ),
                if (!isCorrect)
                  Text(
                    'Correcto: ${state.word.word}',
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color(0xFF93000A),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevealedAnswer(FlashcardLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFDEE0FF).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4352A5).withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: const Color(0xFF2F3F92),
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Respuesta:',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2F3F92),
                      ),
                    ),
                    Text(
                      state.word.word,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F3F92),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Toca la tarjeta para ver la respuesta completa',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: const Color(0xFF454651).withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
