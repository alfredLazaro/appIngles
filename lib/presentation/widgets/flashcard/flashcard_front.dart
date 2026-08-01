import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/constants/app_constants.dart';
import 'package:first_app/domain/entities/flashcard_word.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_bloc.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_event.dart';
import 'package:first_app/presentation/bloc/flashcard/flashcard_state.dart';
import 'feedback_area.dart';

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
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blocState = context.watch<FlashcardBloc>().state;
    if (blocState is! FlashcardLoaded) {
      return const Center(child: CircularProgressIndicator());
    }
    return _buildTestFront(context, blocState);
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
                    _buildSentence(),
                    const SizedBox(height: 24),
                    if (!hasSubmitted && !isRevealed) ...[
                      _buildInputSection(context, state),
                    ],
                    if (hasSubmitted) ...[
                      if (!isCorrect) _buildInputSection(context, state),
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
      height: FlashcardConstants.hintImageHeight,
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
                child: CachedNetworkImage(
                  imageUrl: widget.images.first.url,
                  fit: BoxFit.cover,
                  errorWidget: (context, error, stackTrace) => Container(
                    color: FlashcardConstants.hintBg,
                  ),
                  placeholder: (context, url) => Container(
                    color: FlashcardConstants.hintBg,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
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

  Widget _buildSentence() {
    return Text(
      widget.word.sentence.isNotEmpty
          ? widget.word.sentence
          : FlashcardConstants.noSentenceAvailable,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontSize: FlashcardConstants.sentenceFontSize,
        fontWeight: FontWeight.w400,
        height: 1.6,
        fontStyle: FontStyle.italic,
        color: AppColors.textPrimary ,
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
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          textAlign: TextAlign.center,
          textCapitalization: TextCapitalization.none,
          decoration: InputDecoration(
            hintText: '...',
            hintStyle: const TextStyle(color: Colors.black26),
            filled: true,
            fillColor: const Color(0xFFF2F4F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppLayout.radiusMedium),
              borderSide: BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppLayout.radiusMedium),
              borderSide: BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppLayout.radiusMedium),
              borderSide: const BorderSide(color: Color(0xFF4352A5), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: const TextStyle(
            fontSize: FlashcardConstants.inputFontSize,
            fontWeight: FontWeight.w500,
            color: AppColors.textPrimary ,
          ),
          onSubmitted: (value) {
            if (value.trim().isNotEmpty) {
              context.read<FlashcardBloc>().add(ValidateAnswer(value.trim()));
            }
          },
        ),
        const SizedBox(height: 16),
        FeedbackArea(
                          isCorrect: state.isAnswerCorrect,
                          correctAnswer: widget.word.word,
                        ),
        const SizedBox(height: 16),
        SizedBox(
          height: FlashcardConstants.checkButtonHeight,
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
              backgroundColor:         AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppLayout.radiusLarge),
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
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ],
    );
  }


  Widget _buildRevealedAnswer(FlashcardLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlashcardConstants.infoContainer.withOpacity(0.3),
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
                color: FlashcardConstants.infoText,
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
                        color: FlashcardConstants.infoText,
                      ),
                    ),
                    Text(
                      state.word.word,
                      style: const TextStyle(
                        fontSize: FlashcardConstants.sentenceFontSize,
                        fontWeight: FontWeight.bold,
                        color: FlashcardConstants.infoText,
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
              color: AppColors.textSecondary.withOpacity(0.6),
            ),
          ),
        ],
      ),
    );
  }
}
