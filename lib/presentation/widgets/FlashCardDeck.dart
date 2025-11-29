import 'dart:math';

import 'package:first_app/data/models/pf_ing_model.dart';
import 'package:flutter/material.dart';
import 'package:first_app/presentation/widgets/EnglishFlashCard.dart';
import 'package:first_app/data/models/image_model.dart';
import 'package:first_app/data/datasources/local/ImageDao.dart';

class FlashCardDeck extends StatefulWidget {
  final List<PfIng> flashCards;
  final Color cardColor;
  final void Function(PfIng word) onLearnedTap;
  final void Function(PfIng word) resetLearn;
  final void Function(PfIng word, String tesWord) isLearned;
  const FlashCardDeck({
    super.key,
    required this.flashCards,
    required this.onLearnedTap,
    required this.resetLearn,
    required this.isLearned,
    this.cardColor = Colors.white,
  });
  @override
  State<FlashCardDeck> createState() => _FlashCardDeckState();
}

class _FlashCardDeckState extends State<FlashCardDeck> {
  final Map<int, List<Image_Model>> _imageCache = {}; // Cache para las imágenes
  ImageDao imageDao = ImageDao();
  @override
  void initState() {
    super.initState();
    _loadImagesForCards();
  }

  Future<void> _loadImagesForCards() async {
    for (final card in widget.flashCards) {
      if (card.id != null) {
        final images = await imageDao.getByWordId(card.id!);
        if (images.isNotEmpty) {
          _imageCache[card.id!] = images;
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isPortrait =
        MediaQuery.of(context).orientation == Orientation.portrait;
    return Center(
      child: SizedBox(
        width: min(400.0,
            screenSize.width * 0.95), //ancho maximo de 400 0 de 95% de pantalla
        height: isPortrait ? screenSize.height * 0.65 : screenSize.height * 0.8,
        child: isPortrait ? _buildPortraitLayout() : _buildLandscapeLayout(),
      ),
    );
  }

  Widget _buildPortraitLayout() {
    return Stack(
      alignment: Alignment.center,
      children: [
        for (int i = 0; i < widget.flashCards.length; i++) // Mostrar máximo 5
          Positioned(
            top: i + 0.0,
            left: i + 0.0,
            child: SizedBox(
              width: 300,
              height: 400,
              child: EnglishFlashCard(
                key: ValueKey(widget.flashCards[i].id),
                wordData: widget.flashCards[i],
                learn: widget.flashCards[i].learn,
                word: widget.flashCards[i].word,
                onLearned: () => widget.onLearnedTap(widget.flashCards[i]),
                resetLearn: () => widget.resetLearn(widget.flashCards[i]),
                testingWord: (cad) => widget.isLearned(widget.flashCards[i],
                    cad), //se supone que le envia la palabra desde el card
                cardColor: widget.cardColor,
                imgsData: _imageCache[widget.flashCards[i].id] ??
                    [], // Pasamos las imágenes del cache
              ),
            ),
          ),
      ],
    );
  }

  _buildLandscapeLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = min(350.0, constraints.maxWidth * 0.8);
        final cardHeight = cardWidth * 1.25; // relación 4:5
        final totalCards = widget.flashCards.length;
        final totalWidth = cardWidth +
            ((totalCards - 1) * (cardWidth * 0.3)); // Ancho total calculado

        //Calculamos el desplazamiento inicial para centrar parcialmente
        final initialOffset =
            constraints.maxWidth * 0.3; // 20% del ancho disponibel

        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          reverse: true, // Esto hace que el scroll comience desde el final
          child: Container(
            width: totalWidth + initialOffset + 50, // Ancho total + margen
            padding: EdgeInsets.only(left: initialOffset, right: 20),
            child: Stack(
              alignment: Alignment.centerRight, // Alineamos a la derecha
              children: [
                for (int i = 0; i < totalCards; i++)
                  Positioned(
                    right: i *
                        (cardWidth * 0.02), // Desplazamiento desde la derecha
                    child: Transform.scale(
                      scale: 1 - (i * 0.015), // efecto de reducción
                      child: SizedBox(
                        width: cardWidth,
                        height: cardHeight,
                        child: EnglishFlashCard(
                          key: ValueKey(widget.flashCards[i].id),
                          wordData: widget.flashCards[i],
                          learn: widget.flashCards[i].learn,
                          word: widget.flashCards[i].word,
                          onLearned: () =>
                              widget.onLearnedTap(widget.flashCards[i]),
                          resetLearn: () =>
                              widget.resetLearn(widget.flashCards[i]),
                          testingWord: (cad) =>
                              widget.isLearned(widget.flashCards[i], cad),
                          cardColor: widget.cardColor,
                          imgsData: _imageCache[widget.flashCards[i].id] ??
                              [], // Pasamos las imágenes del cache
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
