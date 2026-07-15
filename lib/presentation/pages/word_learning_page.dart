import 'package:first_app/domain/entities/word.dart';
import 'package:first_app/domain/entities/word_sumary.dart';
import 'package:first_app/presentation/widgets/bulk_insert_dialog.dart';
import 'package:first_app/presentation/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:first_app/presentation/widgets/modals/combine_word_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/constants/app_constants.dart';
import 'package:first_app/domain/entities/image_search_result.dart';
import 'package:first_app/domain/services/speech_to_text_interface.dart';
import 'package:first_app/core/utils/clipboard_helper.dart';
import 'package:first_app/core/di/dependency_injection.dart';
import 'package:first_app/presentation/bloc/word_learning/word_learning_bloc.dart';
import 'package:first_app/presentation/bloc/word_learning/word_learning_event.dart';
import 'package:first_app/presentation/bloc/word_learning/word_learning_state.dart';
import 'package:first_app/presentation/widgets/word_input_section.dart';
import 'package:first_app/presentation/widgets/listshort/word_list_section.dart';
import 'package:first_app/presentation/widgets/listshort/EditDialog.dart';

class WordLearningPage extends StatefulWidget {
  const WordLearningPage({super.key});
  @override
  State<WordLearningPage> createState() => _WordLearningPageState();
}

class _WordLearningPageState extends State<WordLearningPage> {
  final TextEditingController _wordController = TextEditingController();
  final PageController _pageController = PageController();
  final ISpeechToTextService _speechService = sl<ISpeechToTextService>();
  List<Map<String, dynamic>>? _tempDefinitions;
  List<ImageSearchResult>? _tempImages;
  Map<String, dynamic>? _tempTranslation;
  // Cache to keep the last loaded list so it doesn't disappear while searching
  List<WordSummary> _cachedWords = [];
  List<Word> _selecteWords = [];
  int _cachedPage = 0;
  @override
  void initState() {
    super.initState();
// Cargar palabras al iniciar
    context.read<WordLearningBloc>().add(LoadRecentWordsEvent());
  }

  @override
  void dispose() {
    _wordController.dispose();
    _pageController.dispose();
    _speechService.dispose();
    super.dispose();
  }

  void _toggleListening() async {
    if (_speechService.isListening) {
      await _speechService.stopListening();
    } else {
      await _speechService.startListening(
        onResult: (text) {
          setState(() {
            _wordController.text = text;
          });
        },
      );
    }
    setState(() {});
  }

  Future<void> _handleSaveWord() async {
    final word = _wordController.text.trim();
    if (word.isEmpty) {
      _showError('Por favor escribe una palabra');
      return;
    }
    // 1. Buscar definiciones e imágenes
    context.read<WordLearningBloc>().add(SearchWordEvent(word));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> _copySearchResults() async {
    final wordsToCopy = _selecteWords;

    if (wordsToCopy.isEmpty) {
      _showError('No hay palabras para copiar');
      return;
    }

    // Format the words for copying
    String result = '';
    for (int i = 0; i < wordsToCopy.length; i++) {
      final word = wordsToCopy[i];
      result += 'id ${word.id}. ${word.word}\n';
      result += 'phonetic: ${word.phonetic}';
      result += '\n';
      result += 'definition: ${word.definition}';
      result += '\n';
      if (word.sentence.isNotEmpty) {
        result += ' sentence: ${word.sentence}\n';
      }
      result += '\n';
    }

    await ClipboardHelper.copyText(result);
    _showSuccess('${wordsToCopy.length} palabras copiadas al portapapeles');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprendiendo'),
        actions: [
          // Add copy button
          IconButton(
            icon: const Icon(Icons.content_copy),
            tooltip: 'Copiar resultados',
            onPressed: _copySearchResults,
          ),
          // Add this button to open bulk insert dialog
          IconButton(
              icon: const Icon(Icons.add_box),
              tooltip: 'Inserción masiva',
              onPressed: () => {
                    BulkInsertDialog.show(context),
                  }),
          IconButton(
              icon: const Icon(Icons.ac_unit),
              tooltip: 'last n words',
              onPressed: () => {
                    _showWordsLimitDialog(),
                  }),
        ],
      ),
      body: BlocListener<WordLearningBloc, WordLearningState>(
        listener: (context, state) {
          if (state is WordLearningError) {
            _showError(state.message);
          } else if (state is WordDataLoaded) {
            _tempDefinitions = state.meanings;
            _tempImages = state.images;
            _tempTranslation = state.translation;
            _showCombinedDialog();
          } else if (state is WordsLoaded) {
            // Update cache whenever words are (re)loaded
            _cachedWords = state.words;
            _cachedPage = state.currentPage;
          } else if (state is WordSaved) {
            _showSuccess(
              'Palabra guardada con ${state.imagesCount} imagen(es)',
            );
            _wordController.clear();
          } else if (state is WordsFetched) {
            // Handle the fetched words
            _selecteWords = state.words;
          }
        },
        child: BlocBuilder<WordLearningBloc, WordLearningState>(
          builder: (context, state) {
            final bool isLoading = state is WordLearningLoading;
            final List<WordSummary> words =
                state is WordsLoaded ? state.words : _cachedWords;
            final currentPage =
                state is WordsLoaded ? state.currentPage : _cachedPage;

            return Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                WordInputSection(
                  controller: _wordController,
                  isListening: _speechService.isListening,
                  isLoading: isLoading,
                  onListen: _toggleListening,
                  onSave: _handleSaveWord,
                ),
                const SizedBox(height: 10),
                if (words.isNotEmpty)
                  WordListSection(
                    words: words,
                    currentPage: currentPage,
                    pageController: _pageController,
                    onEdit: (word) => _showEditDialog(word),
                    onCopy: (sentence) => _copySentence(sentence),
                    onDelete: (id) => _deleteWord(id),
                    onPageChanged: (page) => context
                        .read<WordLearningBloc>()
                        .add(ChangePageEvent(page)),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _showCombinedDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => CombinedWordDialog(
        word: _wordController.text,
        meanings: _tempDefinitions!,
        images: _tempImages!,
        translation: _tempTranslation,
      ),
    );

    if (result != null && mounted) {
      final selectedImages =
          (result['images'] as List<ImageSearchResult>?) ?? [];
      final translation =
          result['translation'] as Map<String, dynamic>?;

      context.read<WordLearningBloc>().add(
            SaveNewWordEvent(
              wordData: result,
              selectedImages: selectedImages,
              translation: translation,
            ),
          );
    }

    _resetTempData();
  }

  void _showEditDialog(word) {
    showDialog(
      context: context,
      builder: (dialogContext) => EditSentenceDialog(
        initialSentence: word.sentence,
        onUpdate: (newSentence) {
          context.read<WordLearningBloc>().add(
                UpdateWordSentenceEvent(
                  wordId: word.id!,
                  newSentence: newSentence,
                ),
              );
        },
      ),
    );
  }

  Future<void> _copySentence(String sentence) async {
    await ClipboardHelper.copyText(sentence);
    _showSuccess('Texto copiado al portapapeles');
  }

  Future<void> _deleteWord(int id) async {
    final confirm = await showDeleteConfirmationDialog(context);
    if (confirm != true) return;
    if (!mounted) return;
    context.read<WordLearningBloc>().add(DeleteWordEvent(id));
  }

  void _resetTempData() {
    _tempDefinitions = null;
    _tempImages = null;
    _tempTranslation = null;
  }

  Future<void> _showWordsLimitDialog() async {
    // Create a TextEditingController for the input field
    final TextEditingController limitController = TextEditingController();

    await showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cargar palabras recientes'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Ingresa el número de palabras a cargar:'),
            const SizedBox(height: 16),
            TextField(
              controller: limitController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Límite',
                hintText: 'Ej: 9',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 8),
            const Text(
              'Dejar vacío para usar el valor por defecto (9)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              limitController.dispose();
              Navigator.pop(dialogContext);
            },
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final input = limitController.text.trim();

              int limit = AppLayout.defaultWordLoadLimit;
              if (input.isNotEmpty) {
                limit = int.tryParse(input) ?? AppLayout.defaultWordLoadLimit;

                if (limit <= 0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Por favor ingresa un número válido mayor a 0'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }
              }

              limitController.dispose();
              Navigator.pop(dialogContext);

              context.read<WordLearningBloc>().add(
                    FetchWordsEvent(limit),
                  );
              _showSuccessMessage(limit);
            },
            child: const Text('Cargar'),
          ),
        ],
      ),
    );
  }

  void _showSuccessMessage(int? limit) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          limit != null
              ? 'Cargando $limit palabras...'
              : 'Cargando palabras con límite por defecto...',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}
