import 'package:cached_network_image/cached_network_image.dart';
import 'package:first_app/core/di/dependency_injection.dart';
import 'package:first_app/core/services/tts_service.dart';
import 'package:first_app/domain/entities/translation_entity.dart';
import 'package:first_app/domain/entities/word_with_image.dart';
import 'package:first_app/presentation/bloc/word_detail/word_detail_bloc.dart';
import 'package:first_app/presentation/bloc/word_detail/word_detail_event.dart';
import 'package:first_app/presentation/bloc/word_detail/word_detail_state.dart';
import 'package:first_app/presentation/widgets/dialogs/delete_confirmation_dialog.dart';
import 'package:first_app/presentation/widgets/learn_progress_indicator.dart';
import 'package:first_app/presentation/widgets/translation_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WordDetailScreen extends StatefulWidget {
  final WordWithImage wordWithImage;
  final VoidCallback onWordUpdated;

  const WordDetailScreen({
    super.key,
    required this.wordWithImage,
    required this.onWordUpdated,
  });

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  final TtsService _ttsService = sl<TtsService>();

  bool _isEditing = false;
  bool _wasSaving = false;
  bool _controllersInitialized = false;

  final Set<int> _translationsToDelete = {};
  List<TranslationEntity> _localTranslations = [];

  late TextEditingController _wordController;
  late TextEditingController _definitionController;
  late TextEditingController _sentenceController;
  late TextEditingController _phoneticController;

  @override
  void initState() {
    super.initState();
    _wordController = TextEditingController();
    _definitionController = TextEditingController();
    _sentenceController = TextEditingController();
    _phoneticController = TextEditingController();
    context
        .read<WordDetailBloc>()
        .add(LoadWordDetailEvent(widget.wordWithImage.id));
  }

  @override
  void dispose() {
    _wordController.dispose();
    _definitionController.dispose();
    _sentenceController.dispose();
    _phoneticController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WordDetailBloc, WordDetailState>(
      listener: _onStateChanged,
      child: BlocBuilder<WordDetailBloc, WordDetailState>(
        builder: (context, state) {
          if (state is WordDetailLoading) {
            return _buildLoadingScaffold();
          }
          if (state is WordDetailError && !_controllersInitialized) {
            return _buildErrorScaffold();
          }
          if (state is WordDetailLoaded) {
            return _buildContentScaffold(state);
          }
          return _buildLoadingScaffold();
        },
      ),
    );
  }

  void _onStateChanged(BuildContext context, WordDetailState state) {
    if (state is WordDetailLoaded) {
      if (!_controllersInitialized) {
        _wordController.text = state.word.word;
        _definitionController.text = state.word.definition;
        _sentenceController.text = state.word.sentence;
        _phoneticController.text = state.word.phonetic;
        _localTranslations = List.from(state.translations);
        _controllersInitialized = true;
      }
      if (state.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.errorMessage!)),
        );
      }
      if (_wasSaving && !state.isSaving && state.errorMessage == null) {
        _handleSaveSuccess();
      }
      _wasSaving = state.isSaving;
    } else if (state is WordDetailError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    } else if (state is WordDetailDeleted) {
      widget.onWordUpdated();
      Navigator.pop(context);
    }
  }

  void _handleSaveSuccess() {
    _wasSaving = false;
    _translationsToDelete.clear();
    final blocState = context.read<WordDetailBloc>().state;
    if (blocState is WordDetailLoaded) {
      _localTranslations = List.from(blocState.translations);
    }
    setState(() => _isEditing = false);
    widget.onWordUpdated();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Palabra actualizada')),
    );
  }

  Scaffold _buildLoadingScaffold() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.wordWithImage.word)),
      body: const Center(child: CircularProgressIndicator()),
    );
  }

  Scaffold _buildErrorScaffold() {
    return Scaffold(
      appBar: AppBar(title: Text(widget.wordWithImage.word)),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('No se pudo cargar la palabra'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context
                    .read<WordDetailBloc>()
                    .add(LoadWordDetailEvent(widget.wordWithImage.id));
              },
              child: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }

  Scaffold _buildContentScaffold(WordDetailLoaded state) {
    return Scaffold(
      appBar: AppBar(
        title: Text(state.word.word),
        centerTitle: true,
        actions: [
          if (_isEditing)
            IconButton(
              icon: state.isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.check),
              onPressed: state.isSaving ? null : () => _save(state),
            )
          else
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: _toggleEditing,
            ),
        ],
      ),
      body: _buildContent(state),
    );
  }

  Widget _buildContent(WordDetailLoaded state) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildImageSection(state),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLearnProgress(),
                const SizedBox(height: 16),
                if (_isEditing) ...[
                  _buildEditableField('Palabra', _wordController,
                      onTapSpeak: () => _speak(_wordController.text)),
                  const SizedBox(height: 12),
                  _buildEditableField('Fonética', _phoneticController),
                  const SizedBox(height: 12),
                  _buildEditableField('Definición', _definitionController,
                      maxLines: 3),
                  const SizedBox(height: 12),
                  _buildEditableField('Oración', _sentenceController,
                      maxLines: 3),
                ] else ...[
                  _buildInfoRow(Icons.text_fields, 'Palabra', state.word.word,
                      onTap: () => _speak(state.word.word)),
                  if (state.word.phonetic.isNotEmpty)
                    _buildInfoRow(
                        Icons.phonelink, 'Fonética', state.word.phonetic),
                  _buildInfoRow(
                      Icons.description, 'Definición', state.word.definition),
                  if (state.word.sentence.isNotEmpty)
                    _buildInfoRow(
                        Icons.format_quote, 'Oración', state.word.sentence),
                ],
                const SizedBox(height: 20),
                TranslationSection(
                  translations:
                      _isEditing ? _localTranslations : state.translations,
                  isEditing: _isEditing,
                  onAdd: _addTranslation,
                  onRemove: _markTranslationToDelete,
                ),
                const SizedBox(height: 24),
                if (!_isEditing) _buildDeleteButton(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection(WordDetailLoaded state) {
    final imageUrl = state.images.isNotEmpty ? state.images[0].url : '';
    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.grey[200],
      child: imageUrl.isNotEmpty
          ? CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              errorWidget: (context, url, error) => const Center(
                child: Icon(Icons.image_not_supported,
                    size: 64, color: Colors.grey),
              ),
            )
          : const Center(
              child:
                  Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
            ),
    );
  }

  Widget _buildLearnProgress() {
    return Row(
      children: [
        LearnProgressIndicator(learnValue: widget.wordWithImage.learn),
        const SizedBox(width: 8),
        Text('${widget.wordWithImage.learn} % aprendido'),
      ],
    );
  }

  void _toggleEditing() {
    if (_isEditing) {
      _cancelEditing();
    } else {
      setState(() {
        _isEditing = true;
        _translationsToDelete.clear();
      });
    }
  }

  void _cancelEditing() {
    final blocState = context.read<WordDetailBloc>().state;
    if (blocState is! WordDetailLoaded) return;
    _wordController.text = blocState.word.word;
    _definitionController.text = blocState.word.definition;
    _sentenceController.text = blocState.word.sentence;
    _phoneticController.text = blocState.word.phonetic;
    _localTranslations = List.from(blocState.translations);
    setState(() {
      _isEditing = false;
      _translationsToDelete.clear();
    });
  }

  void _addTranslation(String text) {
    if (text.isEmpty) return;
    setState(() {
      _localTranslations.add(TranslationEntity(
        wordId: widget.wordWithImage.id,
        wordTranslate: text,
      ));
    });
  }

  void _markTranslationToDelete(int index) {
    final translation = _localTranslations[index];
    if (translation.id != null) {
      _translationsToDelete.add(translation.id!);
    }
    setState(() => _localTranslations.removeAt(index));
  }

  void _save(WordDetailLoaded state) {
    final updatedWord = state.word.copyWith(
      word: _wordController.text.trim(),
      definition: _definitionController.text.trim(),
      sentence: _sentenceController.text.trim(),
      phonetic: _phoneticController.text.trim(),
    );

    context.read<WordDetailBloc>().add(SaveWordDetailEvent(
          updatedWord: updatedWord,
          translationIdsToDelete: _translationsToDelete.toList(),
          newTranslations:
              _localTranslations.where((t) => t.id == null).toList(),
        ));
  }

  Future<void> _delete() async {
    final confirm = await showDeleteConfirmationDialog(context);
    if (confirm != true) return;
    if (!mounted) return;

    context
        .read<WordDetailBloc>()
        .add(DeleteWordDetailEvent(widget.wordWithImage.id));
  }

  Future<void> _speak(String text) async {
    try {
      await _ttsService.speak(text);
    } catch (e) {
      // ignore
    }
  }

  Widget _buildInfoRow(IconData icon, String label, String value,
      {VoidCallback? onTap}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 2),
                GestureDetector(
                  onTap: onTap,
                  child: Text(value,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        decoration:
                            onTap != null ? TextDecoration.underline : null,
                      )),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEditableField(String label, TextEditingController controller,
      {int maxLines = 1, VoidCallback? onTapSpeak}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
            if (onTapSpeak != null) ...[
              const Spacer(),
              GestureDetector(
                onTap: onTapSpeak,
                child:
                    const Icon(Icons.volume_up, size: 18, color: Colors.blue),
              ),
            ],
          ],
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            border: const OutlineInputBorder(),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _delete,
        icon: const Icon(Icons.delete, color: Colors.red),
        label:
            const Text('Eliminar palabra', style: TextStyle(color: Colors.red)),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }
}
