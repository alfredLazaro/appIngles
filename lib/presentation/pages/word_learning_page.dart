import 'package:first_app/domain/entities/word_sumary.dart';
import 'package:first_app/presentation/widgets/combine_word_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:first_app/core/services/speech_to_text_service.dart';
import 'package:first_app/core/utils/clipboard_helper.dart';
import 'package:first_app/presentation/bloc/word_learning/word_learning_bloc.dart';
import 'package:first_app/presentation/bloc/word_learning/word_learning_event.dart';
import 'package:first_app/presentation/bloc/word_learning/word_learning_state.dart';
import 'package:first_app/presentation/widgets/word_input_section.dart';
import 'package:first_app/presentation/widgets/listshort/word_list_section.dart';
import 'package:first_app/presentation/widgets/Dialog_inform.dart';
import 'package:first_app/presentation/widgets/Dialog_Image.dart';
import 'package:first_app/presentation/widgets/listshort/EditDialog.dart';

/// Página principal refactorizada (antes Pagina1)
class WordLearningPage extends StatefulWidget {
  const WordLearningPage({super.key});
  @override
  State<WordLearningPage> createState() => _WordLearningPageState();
}

class _WordLearningPageState extends State<WordLearningPage> {
  final TextEditingController _wordController = TextEditingController();
  final PageController _pageController = PageController();
  final SpeechToTextService _speechService = SpeechToTextService();
  List<Map<String, dynamic>>? _tempDefinitions;
  List<Map<String, dynamic>>? _tempImages;
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
// 1. Buscar definiciones
    context.read<WordLearningBloc>().add(SearchWordDefinitionEvent(word));
    context.read<WordLearningBloc>().add(SearchWordImagesEvent(word));
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Aprendiendo'),
      ),
      body: BlocListener<WordLearningBloc, WordLearningState>(
        listener: (context, state) {
          if (state is WordLearningError) {
            _showError(state.message);
          } else if (state is DefinitionsLoaded) {
            _tempDefinitions = state.meanings;
            _checkAndShowCombinedDialog();
          } else if (state is ImagesLoaded) {
            _tempImages = state.images;
            _checkAndShowCombinedDialog();
          } else if (state is WordSaved) {
            _showSuccess(
              'Palabra guardada con ${state.imagesCount} imagen(es)',
            );
            _wordController.clear();
          }
        },
        child: BlocBuilder<WordLearningBloc, WordLearningState>(
          builder: (context, state) {
            if (state is WordLearningLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final List<WordSummary> words =
                state is WordsLoaded ? state.words : [];
            final currentPage = state is WordsLoaded ? state.currentPage : 0;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                WordInputSection(
                  controller: _wordController,
                  isListening: _speechService.isListening,
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

  Map<String, dynamic>? _tempSelectedDefinition;
// Manejo de imágenes cargadas
  Future<void> _handleImagesLoaded(
    List<Map<String, dynamic>> images,
  ) async {
    if (_tempSelectedDefinition == null) return;

    // Si hay imágenes, mostrar selector normal
    final selectedImages = await showDialog<List<Map<String, dynamic>>>(
      context: context,
      builder: (_) => ImageSelectorDialog(
        imageUrls: images,
        allowMultipleSelection: false,
      ),
    );

    if (selectedImages == null) return;

    context.read<WordLearningBloc>().add(
          SaveNewWordEvent(
            wordData: _tempSelectedDefinition!,
            selectedImages: selectedImages,
          ),
        );

    _tempSelectedDefinition = null;
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

  void _deleteWord(int id) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirmar eliminación'),
        content: const Text('¿Estás seguro de eliminar esta palabra?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () {
              context.read<WordLearningBloc>().add(DeleteWordEvent(id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDefinitionsLoaded(
    List<Map<String, dynamic>> meanings,
  ) async {
    final selectedDefinition = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => DefinitionSelector(meanings: meanings),
    );

    if (selectedDefinition == null) return;

    selectedDefinition['word'] = _wordController.text;
    if (!mounted) return;
    context.read<WordLearningBloc>().add(
          SearchWordImagesEvent(_wordController.text),
        );

    _tempSelectedDefinition = selectedDefinition;
  }

  void _checkAndShowCombinedDialog() {
    // Solo mostrar cuando AMBOS resultados estén listos
    if (_tempDefinitions != null && _tempImages != null) {
      _showCombinedDialog();
    }
  }

  Future<void> _showCombinedDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (_) => CombinedWordDialog(
        word: _wordController.text,
        meanings: _tempDefinitions!,
        images: _tempImages!,
      ),
    );

    if (result != null && mounted) {
      // Preparar las imágenes en el formato esperado
      final selectedImages = result['imageUrl'] != null
          ? [
              {'url': result['imageUrl']}
            ]
          : <Map<String, dynamic>>[];

      context.read<WordLearningBloc>().add(
            SaveNewWordEvent(
              wordData: result,
              selectedImages: selectedImages,
            ),
          );
    }

    _resetTempData();
  }

  void _resetTempData() {
    _tempDefinitions = null;
    _tempImages = null;
  }
}
