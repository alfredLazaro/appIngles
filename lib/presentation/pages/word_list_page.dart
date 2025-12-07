import 'package:first_app/data/mappers/word_with_image.dart';
import 'package:first_app/data/models/pf_ing_model.dart';
import 'package:first_app/domain/entities/flashcard_image.dart';
import 'package:first_app/domain/entities/word_with_image.dart';
import 'package:first_app/presentation/pages/sentence_practice_page.dart';
import 'package:flutter/material.dart';
import 'package:first_app/data/datasources/local/WordDao.dart';
import 'package:first_app/presentation/widgets/ListaCards.dart';
import 'package:first_app/data/datasources/local/ImageDao.dart';
import 'package:first_app/data/mappers/flashcard_mapper.dart';
import 'package:first_app/presentation/pages/flashcard_practice_page.dart';
// Al inicio de word_list_page.dart
import 'package:first_app/presentation/widgets/modals/practice_selection_modal.dart';
import 'package:logger/logger.dart';

class WordListPage extends StatefulWidget {
  const WordListPage({super.key});

  @override
  State<WordListPage> createState() => _WordListPageState();
}

class _WordListPageState extends State<WordListPage> {
  final WordDao wordDao = WordDao();
  final ImageDao imageDao = ImageDao(); // ✅ AGREGAR ESTO
  late Future<List<WordWithImage>> _futureWords;
  Logger log = Logger();
  @override
  void initState() {
    super.initState();
    _futureWords = _loadWords();
  }

  Future<List<WordWithImage>> _loadWords() async {
    final maps = await wordDao.getAllWordsWithImages();
    return WordWithImageMapper.fromMapList(maps);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Words"),
        actions: [
          // ✅ AGREGAR ESTE BOTÓN
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: _showPracticeModal,
            tooltip: 'Modo práctica',
          ),
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: _showSentenceModal,
            tooltip: 'Ordenar oraciones',
          ),
        ],
      ),
      body: FutureBuilder<List<WordWithImage>>(
        future: _futureWords,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No words found."));
          } else {
            return ListaCards(lswords: snapshot.data!);
          }
        },
      ),
    );
  }

  // Método 1: Mostrar modal
  void _showPracticeModal() async {
    // Contar total de palabras
    final allWords = await wordDao.countWords();

    if (!mounted) return;

    if (allWords == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay palabras para practicar')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => PracticeSelectionModal(
        totalWords: allWords,
        onStartPractice: (selectedCount) => _startPractice(selectedCount),
      ),
    );
  }

  // Método 2: Iniciar práctica
  Future<void> _startPractice(int count) async {
    try {
      // 1. Cargar palabras limitadas
      final allWordsMaps = await wordDao.getWordsForPractice(count);
      final selectedMaps = allWordsMaps.take(count).toList();

      // 2. Extraer IDs
      final wordIds = selectedMaps.map((m) => m['id'] as int).toList();

      // 3. Cargar imágenes para esas palabras
      final allImages = await imageDao.getImagesByWordIds(wordIds);

      // 5. Convertir a entidades FlashcardWord
      final flashcardWords = selectedMaps.map((map) {
        final pfIng = PfIng(
          id: map['id'],
          word: map['word'] ?? '',
          definition: map['definition'] ?? '',
          sentence: map['sentence'] ?? '',
          learn: map['learn'] ?? 0,
          createdAt: map['createdAt'] ?? DateTime.now().toIso8601String(),
          updatedAt: map['updatedAt'] ?? DateTime.now().toIso8601String(),
        );
        return FlashcardMapper.toEntity(pfIng); //recibe PfIng model
      }).toList();

      // 6. Convertir imágenes a entidades
      final flashcardImagesMap = <int, List<FlashcardImage>>{};
      for (var entry in allImages.entries) {
        flashcardImagesMap[entry.key] =
            FlashcardMapper.imagesToEntities(entry.value);
      }

      // 7. Navegar a práctica
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => FlashcardPracticePage(
            words: flashcardWords,
            imagesMap: flashcardImagesMap,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _showSentenceModal() async {
    final totalSentences =
        await wordDao.countWords(); // O crear countSentences()

    if (!mounted) return;

    if (totalSentences == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay oraciones para practicar')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => PracticeSelectionModal(
        totalWords: totalSentences,
        title: 'Ordenar Oraciones', // ✅ Título personalizado
        description:
            '¿Cuántas oraciones quieres ordenar?', // ✅ Descripción personalizada
        onStartPractice: (count) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SentencePracticePage(sentenceCount: count),
            ),
          );
        },
      ),
    );
  }
}
